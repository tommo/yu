require "yu.parser"
require "yu.visitor"
require "yu.decl"
require "yu.resolver"
require "yu.codegen"
require "yu.yigen"

module("yu")

totalDeclTime     = 0
totalResolveTime  = 0
totalGenerateTime = 0
local _fileBuildTime={}

local builder = {}
local allowDepBuild = true
local function getFileBuildTime(path)
	if not allowDepBuild then return 0 end
	if not rawget(_G,'lfs') then
		return 0
	end
	local t0 = _fileBuildTime[path] or 0
	local t1 = lfs.attributes(path,'modification') or 0
	if t1>t0 then
		_fileBuildTime[path] = t1 
		return t1
	else
		return t0
	end	
end

local function setFileBuildTime(path, t1)
	local t0=getFileBuildTime(path)
	if t0<t1 then
		_fileBuildTime[path]=t1
	end
end

local function inheritFileBuildTime(src, dep)
	setFileBuildTime(src,getFileBuildTime(dep))
end

local function isFileNewer(f1, f2)
	if rawget(_G,'lfs') then
		local m1=getFileBuildTime(f1)
		local m2=getFileBuildTime(f2)
		-- print('\t',f1,f2,m1-m2)
		return m1>m2
	else
		--TODO: some os-specific workaround?
		return true
	end	
end

local function fileExists(f)
	local h=io.open(f,'r')
	if h then h:close() return true end
	return false
end

local function fixPath(p)
	p = string.gsub(p,'\\','/')
	return p
end

local function stripExt(p)
	p = fixPath(p)
	p = string.gsub(p,'%..*$','')
	return p
end

local function extractDir(p)
	p = fixPath(p)
	return string.match(p, ".*/") or ''
end
 
local function extractFileName(p)
	p = fixPath(p)
	return string.match(p, "[%w_.%%]+$")
end
 
local function extractModName(p)
	p = extractFileName(p)
	p = string.gsub(p,'%..*$','')
	return string.gsub(p,'%.','_')
end

local function getYIPath(path)
	return stripExt(path)..'.yi'
end

local function getYOPath(path)
	return stripExt(path)..'.yo'
end


 
function newBuilder(option)
	return setmetatable({
		option=option,
		moduleTable={},
		buildingModules={}
	},{__index=builder})
end
 
function builder:setPreprocessorEnvironment(env)
	self.prepEnv=env or {}
end



function builder:build(src, traceBuild)

	if traceBuild then
		return self:startBuild(src)		
	else --hide compiler traceback
		local suc,m=pcall(function()		
				return self:startBuild(src)
			end
			)
		if suc then
			return m
		else
			return error(m)
		end
	end
	
end

function builder:startBuild(path, traceBuild)

	local function genYiFile(mm)
		--save generated interface info
		local interfaceCode=yu.generateInterface(mm)
		if traceBuild then --test generated code 
			local res, err=loadstring(interfaceCode)
			if not res then
				error(
					string.format("FATAL error in generated interface(%s):\n%s", mm.path, err)
						)
			end
		end

		local outfile=getYIPath(mm.path)
		local file=io.open(outfile,'w')
		file:write(interfaceCode)
		file:close() 

	end

	local function genYoFile(mm)
		--save generated code
		local code=yu.generateModule(mm)
		if traceBuild then --test generated code 
			local res, err=loadstring(code)
			if not res then
				error(
					string.format("FATAL error in generated code(%s):\n%s", mm.path, err)
						)
			end
		end

		local outfile=getYOPath(mm.path)
		local file=io.open(outfile,'w')
		file:write(code)
		file:close()
	end

 	-- local generatedModules={}
	self.baseDir=extractDir(path)
	local m=self:requireModule(path, false)
	for i,mm in ipairs(self.buildingModules) do
		local t1=os.clock()
			local res=yu.newResolver()
			res:visitNode(mm)
		totalResolveTime=totalResolveTime+os.clock()-t1
		local t0=os.clock()
			genYiFile(mm)
			genYoFile(mm)
		totalGenerateTime=totalGenerateTime+os.clock()-t0
	end

	return true
end
 
function builder:getAbsPath(path)

end

function builder:buildModule(path)
	-- print('>build',path)
	setFileBuildTime(path,os.time())
	local prepEnv=setmetatable({},{__index=self.prepEnv})

	local m, errors =parseFile(path,false,prepEnv)
	local errCount=#errors
	if errCount>0 then --error in parsing
		for i, e in pairs(errors) do
			print(tostring(e))
		end
	end
	m.externModules = {}
	m.path          = path
	m.modpath       = stripExt(path)
	m.name          = extractModName(path)

	self.moduleTable[path]=m
	
	local heads=m.heads
	local currentBase=extractDir(path)
	if heads then
		for i,node in ipairs(heads) do
			local tag=node.tag
			if tag=='import' then
				local modpath=currentBase..node.src
				local requiredModule=self:requireModule(modpath, path)
				if m==requiredModule then
					yu.compileErr('attempt to import self',node,m)
				end
				m.externModules[requiredModule.path]=requiredModule
				node.mod=requiredModule
			end
		end
	end

	local t1=os.clock()
	
	yu.newDeclCollector():visitNode(m)
	local dt=os.clock()-t1
	totalDeclTime=totalDeclTime+dt
	
	-- print(string.format('decl time += %d\t%d\t %s',dt*1000,totalDeclTime*1000,m.name))

	self:addBuildingModule(m)
	return m
end
 
function builder:addBuildingModule(m)
	local b = self.buildingModules
	for i,v in ipairs(b) do
		if v == m then return end
	end
	b[#b+1] = m
end

function builder:checkNeedBuild(path)
	local yi = getYIPath(path)
	local yo = getYOPath(path)

	local needBuild = 
						(not	fileExists(yo)) or
						(not	fileExists(yi)) or
						isFileNewer(path, yi) or
						isFileNewer(path, yo)

	return needBuild
end

function builder:requireModule(path, from)
	path = fixPath(path)
	local m = self.moduleTable[path]
	if m then return m end

	local needBuild=self:checkNeedBuild(path)

	if not needBuild then
		m=self:loadCompiledModule(path)
		if m then 
			self.moduleTable[path]=m
			return m
		end
	end
	m = self:buildModule(path)
	return m
end


function builder:loadCompiledModule(path)
	-- print('loadYi',path)
	local yi = getYIPath(path)
	inheritFileBuildTime(path, yi)

	local data      = dofile(yi)
	local needBuild = false
	local req       = {}
	local named     = {}

	for i, im in ipairs(data.import) do
		local r=self:requireModule(im.path, path)
		if isFileNewer(im.path, path) then 
			needBuild=true
		end
		if im.alias then named[r]=true end
		req[im]=r
	end


	if needBuild then return false end

	local m=loadInterface(data, req, named)

	-- print('>loaded',yi)

	return m
end


function build(...) --just a shortcut
	return newBuilder():build(...)
end
