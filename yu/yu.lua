require "yu.parser"
require "yu.visitor"
require "yu.decl"
require "yu.resolver"
require "yu.codegen"
require "yu.yigen"
module("yu")

local builder={}
totalDeclTime=0
totalResolveTime=0
totalGenerateTime=0

local function compareFileTime(f1, f2)
	if rawget(_G,'lfs') then
		--TODO: use lfs
	end
	local r=os.execute(string.format)
end


local function fixpath(p)
	p=string.gsub(p,'\\','/')
	return p
end

local function stripExt(p)
	p=fixpath(p)
	p=string.gsub(p,'%..*$','')
	return p
end

local function extractDir(p)
	p=fixpath(p)
	return string.match(p, ".*/") or ''
end
 
local function extractFileName(p)
	p=fixpath(p)
	return string.match(p, "[%w_.%%]+$")
end
 
local function extractModName(p)
	p=extractFileName(p)
	p=string.gsub(p,'%..*$','')
	return string.gsub(p,'%.','_')
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
 	-- local generatedModules={}
	self.baseDir=extractDir(path)
	local m=self:requireModule(path)
	local t1=os.clock()
	for i,mm in ipairs(self.buildingModules) do
		local res=yu.newResolver()
		res:visitNode(mm)
	end
	totalResolveTime=totalResolveTime+os.clock()-t1
	--generatecode
	local t0=os.clock()
	
	for i,mm in ipairs(self.buildingModules) do
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
		local outfile=stripExt(mm.path)..'.yo'
		local file=io.open(outfile,'w')
		file:write(code)
		file:close()
		
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
		local outfile=stripExt(mm.path)..'.yi'
		local file=io.open(outfile,'w')
		file:write(interfaceCode)
		file:close() 
	end

	totalGenerateTime=os.clock()-t0
	return true
end
 
function builder:getAbsPath(path)

end

function builder:buildModule(path)
	local prepEnv=setmetatable({},{__index=self.prepEnv})

	local m=parseFile(path,false,prepEnv)
	m.externModules={}
	m.path=path
	m.modpath=stripExt(path)
	m.name=extractModName(path)
	self.moduleTable[path]=m
	
	local heads=m.heads
	local currentBase=extractDir(path)
	if heads then
		for i,node in ipairs(heads) do
			local tag=node.tag
			if tag=='import' then
				local modpath=currentBase..node.src
				local requiredModule=self:requireModule(modpath)
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
	local b=self.buildingModules
	for i,v in ipairs(b) do
		if v==m then return end
	end
	b[#b+1]=m
end

function builder:requireModule(path)
	path=fixpath(path)
	local m=self.moduleTable[path]
	if not m then
		--todo:search for precompiled module first		
		m=self:buildModule(path)
	end
	return m
end
