local ipairs,pairs,format=ipairs,pairs,string.format
local stringrep=string.rep
local format=string.format

module("yu",package.seeall)


local function makeStringCheckTable( ... )
	local res={}
	for i=1,select('#',...) do
		res[select(i,...)]=true
	end
	return res
end

local function makeValueCheckerT(...)
	local checkTable=makeStringCheckTable(...)
	return function ( t )
		return checkTable[t]
	end
end

local function makeValueCheckerF(...)
	local h='return function(t)'
	local m=''
	for i=1,select('#',...) do
		if i>1 then m=m..' or ' end
		m=m..'t == "'..select(i,...)..'"'
	end
	local f=h..' '..m..' end'
	return loadstring(f)
end

local function makeTagCheckerT(...)
	local checkTable=makeStringCheckTable(...)
	return function ( t )
		return checkTable[t.tag]
	end
end

local function makeTagCheckerF(...)
	local h='return function(n) local t=n.tag'
	local m=''
	for i=1,select('#',...) do
		if i>1 then m=m..' or ' end
		m=m..'t == "'..select(i,...)..'"'
	end
	local f=h..' '..m..' end'
	return loadstring(f)
end

local gsub=string.gsub

function unescape(s)
	s=gsub(s,'\\(%d%d?%d?)',string.char)
	s=gsub(s,'\\.',{
		['\\n']='\n',
		['\\t']='\t',
		['\\r']='\r',
		['\\b']='\b',
		['\\a']='\a',
		['\\v']='\v',
		['\\\\']='\\',
		['\\\'']='\'',
		['\\\"']='\"',
		['\\0']='\0'
	})
	return s
 end
 
----TOOL FUNCTIONS
	-- local stackmt={}
	-- function stackmt:push(d)
	-- 	local s=self.stack
	-- 	s[#s+1]=d
	-- 	return d
	-- end
	
	-- function stackmt:pop()
	-- 	local s=self.stack
	-- 	local l=#s
	-- 	local v=s[l]
	-- 	s[l]=nil
	-- 	return s[l-1]
	-- end
	
	-- function stackmt:peek(k)
	-- 	local s=self.stack
	-- 	return s[#s-(k or 0)]
	-- end
	local stackmt={}
	function stackmt:push(d)
		local count=self.count
		self[count+1]=d
		self.count=count+1
		return d
	end
	
	function stackmt:pop()
		local l=self.count
		-- local v=self[l]
		self[l]=nil
		self.count=l-1
		return self[l-1]
	end
	
	function stackmt:peek(k)
		return self[self.count-(k or 0)]
	end

	-- function stackmt:copy()
	-- 	local 
	-- end

	function newStack()
		local st={count=0}
		st.push=stackmt.push
		st.pop=stackmt.pop
		st.peek=stackmt.peek
		return st
		-- return setmetatable({
		-- 	stack={}
		-- },{__index=stackmt})
	end
	
	
	function findLine(lineInfo,pos)
		local off0=0
		local l0=0
		
		for l,off in ipairs(lineInfo) do
			if pos>=off0 and pos<off then 
				return l0,pos-off0
			end
			off0=off
			l0=l
		end
		return l0,pos-off0
	end
	
	function getTokenPosString(token,currentModule)
		local pos=token.p0 or 0
		local m=token.module or currentModule
		if not m then
			table.foreach(token,print)
			error('fatal')
		end
		local line,lpos=findLine(m.lineInfo,pos)
		local line2,lpos2=findLine(m.lineInfo,token.p1)
		return "@"..m.file.."<"..line..":"..lpos..">".."-<"..line2..":"..lpos2..">"
	end
	
	function compileErr(msg,token,currentModule)
		local errmsg=(token and getTokenPosString(token,currentModule) or "")..":"..msg
		print('[COMPILE ERROR]')
		print(errmsg)
		return error('compile error')
	end

	
	local select=select
	function is(i,a,b,...)
		-- for n=1, select('#',...) do
		-- 	if i==select(n,...) then return true end
		-- end
		if i==a then return true end
		if b then return is(i,b,...) end
		return false
	end

---------------------Token types		
	isFuncDecl = makeTagCheckerT('funcdecl','methoddecl','closure')

	function isConst(c)
		local tag=c.tag
		return tag=='number' or tag=='boolean' or tag=='string' or tag=='nil'
	end
	
	isDecl=makeTagCheckerT("vardecl" ,"classdecl" ,"funcdecl" ,"enumdecl" ,"methoddecl" 
		,"var","externfunc","externclass",'signaldecl')

	-- function isDecl(b)
	-- 	return declCheckTable[b.tag]
	-- end
	local globalDeclNames=makeStringCheckTable("classdecl" ,"funcdecl" ,"enumdecl" ,"methoddecl",'signaldecl')
	function isGlobalDecl(b)
		local tag=b.tag
		if tag=="vardecl" or tag=='var' then
			local vtype=b.vtype
			return vtype=="global" or vtype=="const"
		elseif tag=='funcdecl' then
			return not b.localfunc 
		else
			return globalDeclNames[tag]
		end
	end
	
	function isMemberDecl(d)
		local tag=d.tag
		return ((tag=='vardecl' or tag=='var') and d.vtype=='field') or tag=='methoddecl' or tag=='signaldecl'
	end

	isTypeDecl=makeTagCheckerT('classdecl','enumdecl','functype','tabletype','voidtype','mulrettype',
			'niltype','booleantype','numbertype','stringtype','externclass','anytype',
			'objecttype','classmeta','enummeta','funcmeta','tablemeta','modulemeta','tvar','vararg','typemeta',
			'signaldecl','corotype','signalmeta','threadtype')	

	builtinTypeTable=makeStringCheckTable('boolean','number','nil','string','object','any')
	function isBuiltinType(n)
		return builtinTypeTable[n]
	end


	local function findExternModule(src,dst,checked)
		if src==dst then return true end
		checked[src]=true
		for path,m in pairs(src.externModules) do
			if not checked[m] and findExternModule(m,dst,checked) then 
				return true
			end
		end
		return false
	end
	
	local _visibleCache={}
	function isModuleVisible(src,dst)
		local vis=src.visibleMods
		if not vis then vis={} src.visibleMods=vis end
		local v=vis[dst]
		if v~=nil then return v end
		v=findExternModule(src,dst,{})
		vis[dst]=v
		return v
	end
	
	local function getConstNode(n)
		local tag=n.tag
		if tag=='string' or tag=='nil' or tag=='number' then return n end
		if tag=='var' and n.vtype=='const' then return getConstNode(n.value) end
		if tag=='varacc' or tag=='member' then
			local decl=n.decl
			if decl then return getConstNode(decl) end
		end
		if tag=='enumitem' then
			return getConstNode(n.value)
		end
		
		return nil
	end
	
	local function getConst(n)
		local tag=n.tag
		if tag=='string' then return format('%q',yu.unescape(n.v)) end
		if tag=='nil' then return 'nil' end
		if tag=='number' or tag=='boolean' then return n.v end
		error('non const:'..tag)
	end

	
	
local opPrecedence={
	{'and','or'},
	{'>','<','>=','<=','==','~='},
	{'..'},
	{'+','-'},
	{'*','/','^','%'}
}

local opClass={
	['+']='arith',
	['-']='arith',
	['*']='arith',
	['/']='arith',
	['%']='arith',
	['^']='arith',
	
	['..']='concat',
	
	['>']='order',
	['<']='order',
	['>=']='order',
	['<=']='order',
	
	['==']='equal',
	['~=']='equal',
	
	['and']='logic',
	['or']='logic',
	['not']='logic',
}

function getOpPrecedence(op)
	for i,s in ipairs(opPrecedence) do
		for j,o in ipairs(s) do
			if op==o then return i end
		end
	end
	return error("unknown op:"..op)
end

function getOpClass(op)	
	return opClass[op]
end

local tempvarCount=0
	
function newTempVar(t,vtype)
	assert(t)
	local tempvar={tag='var',
			resolveState='done',
			type=t,
			vtype=vtype or 'local',
			name='_TMP_'..tempvarCount}
	tempvarCount=tempvarCount+1
	return tempvar
end

function makeMetaData(data)
	local m={}
	for i,n in ipairs(data) do
		local k,v=n.k,n.v
		if v==nil then 
			v=true
		else
			v=getConst(v)
		end
		m[k]=v
	end
	return m
end

local declPrefix={
	funcdecl='f',
	methoddecl='f',
	classdecl='c',
	module='m',
	signaldecl='s',
}

function makeDeclRefName(decl,id)
	local strip=false
	local dtag=(declPrefix[decl.tag] or 'v')
	if strip then
		return format('%s_%x',dtag,id)
	else
		return format('%s_%x',decl.name,id)
	end
end

_M.getConstNode=getConstNode
_M.getConst=getConst
_M.makeStringCheckTable=makeStringCheckTable

	