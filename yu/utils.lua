pcall(function()
	require'lfs'
end
)


local ipairs,pairs=ipairs,pairs
local next=next
local insert=table.insert
local stringrep,format,gsub = string.rep, string.format,string.gsub


local codegen,codegenList
local insert=table.insert

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
	
	
	function findLine(lineOffset,pos)
		local off0=0
		local l0=0
		
		for l,off in ipairs(lineOffset) do
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
		local line,lpos=findLine(m.lineOffset,pos)
		local line2,lpos2=findLine(m.lineOffset,token.p1)
		return "@"..m.file.."<"..line..":"..lpos..">".."-<"..line2..":"..lpos2..">"
	end
	local function printerr(msg)
		io.stderr:write(tostring(msg)..'\n')
	end

	function compileErr(msg,token,currentModule)
		local errmsg=(token and getTokenPosString(token,currentModule) or "")..":"..msg
		printerr('[COMPILE ERROR]')
		printerr(errmsg)
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

	function constToString(c)
		local tag=c.tag
		if tag=='string' then
			return string.format("%q",c.v):gsub('\\\n','\\n')
		elseif tag=='nil' then 
			return 'nil'
		else
			return tostring(c.v)
		end
	end

	function isCompoundExpr(c)
		local tag=c.tag
		if tag=='number' or tag=='boolean' or tag=='string' or tag=='nil'	then return false end
		if tag=='varacc' or tag=='self' then return false end
		return true
	end
	
	isDecl=makeTagCheckerT("vardecl" ,"classdecl" ,"funcdecl" ,"enumdecl" ,"methoddecl" 
		,"var","externfunc","externclass",'signaldecl')

	-- function isDecl(b)
	-- 	return declCheckTable[b.tag]
	-- end
	local globalDeclNames=makeStringCheckTable("classdecl" ,"funcdecl" ,"enumdecl" ,"methoddecl",'signaldecl','import')
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
			'niltype','booleantype','numbertype','stringtype','externclass','anytype','anyfunc',
			'objecttype','classmeta','enummeta','funcmeta','tablemeta','modulemeta','tvar','vararg','typemeta',
			'signaldecl','corotype','signalmeta','threadtype')	

	builtinTypeTable=makeStringCheckTable('boolean','number','nil','string','object','any','anyfunc')
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
		if not n then return nil end
		local tag=n.tag
		if tag=='string' or tag=='nil' or tag=='number' or tag=='boolean' then return n end
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
			name='_TMP_'..tempvarCount,
			refname='_TMP_'..tempvarCount
		}
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

local mangleChar='0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ'
local mangleSize=#mangleChar
local floor=math.floor
local function makeMangle(id)
	assert(id>=0)
	local output=''
	local i=id
	while true do
		local p=i % mangleSize+1
		i=floor(i/mangleSize)
		local w=mangleChar:sub(p,p)
		output=w..output
		if i==0 then return output end
	end	
end

function makeDeclRefName(decl,id)
	if decl.name=='...' then return '...' end
	local strip=true
	local dtag=(declPrefix[decl.tag] or 'v')
	local mangle=makeMangle(id)--format('%x',id)
	if strip then
		return format('%s_%s',dtag,mangle)
	else
		return format('%s_%s',decl.name,mangle)
	end
end

local function getDeclName(d, currentModule)
	if not currentModule then currentModule=d.module end	
	local tag = d.tag
	if tag=='var' then
		local vtype=d.vtype
		if vtype=='local' then return d.refname end

		if vtype=='global' then
			if d.extern then
				return '_G.'..d.externname
			end

			if d.module~=currentModule then
				return getDeclName(d.module, currentModule)..'.'..d.refname
			end
				
			return d.refname
		end

		if vtype=='const' then 
			if d.extern then 
				return '_G.'..d.externname
			end

			return getConst(d.value)
		end

		if vtype=='field' then return d.name end
	end
	if d.module~=currentModule then
		local n= currentModule.externalReferNames[d]
		if not n then
			print('getting ext ref name',d.name,currentModule.name)
			error('internal error,refername not defined:'..d.name)
		else
			return n
		end
	else
		local res=assert(d.refname)
		return res 
	end
end

function referExternModuleDecl(m,d)
	if not d.module then
		table.foreach(d,print)
		error()
	end
	if m==d.module then return end
	if m.externalReferNames[d] then return end
	local id=m.maxDeclId+1
	m.maxDeclId=id
	m.externalReferNames[d]=makeDeclRefName(d,id)
	referExternModuleDecl(m,d.module)
end

function printNodeInfo(n)
	print('---------------')
	print(getTokenPosString(n))
	table.foreach(n,print)
	print('---------------')
end

_M.getConstNode=getConstNode
_M.getConst=getConst
_M.makeStringCheckTable=makeStringCheckTable
_M.getDeclName=getDeclName

---------code writer

 local codeWriter={}
 local codeWriterMT={
	__index=codeWriter,
	__call=function(t,...)
		return t:appends(...)
	end
	}

 local function newCodeWriter(str)
	return setmetatable({
			__line=1,
			__count=0,
			__indent=0,
			__list={str and tostring(str) or ''}, --string buffer part
			__marked_line={},
			__level=0,

			referedDecls={},		--context part
			exposeDecls={},
			classGlobalVars={},
		},
		codeWriterMT)
 end
 
function codeWriter:append(str,s1,...)
	local l=self.__list
	local count=self.__count
	l[count+1]=str
	self.__count=count+1
	self.dirty=true
	if s1 then return self:append(s1,...) end
 end

 function codeWriter:appends(str,s1,...)
	local l=self.__list
	local count=self.__count
	l[count+1]=str..' '
	self.__count=count+1
	if s1 then return self:appends(s1,...) end
 end
 
 function codeWriter:appendf(pattern,...)
	return self:append(format(pattern,...))
 end
 
 local stringrep = string.rep
 function codeWriter:cr()
 	-- if not self.dirty then return end
 	self:append(
 		-- '--'..self.__line..
 		'\n'..stringrep('\t',self.__indent))
 	self.__line=self.__line+1
 	self.dirty=false
 end

 function codeWriter:mark(node,cr, range,msg) --mark the code where error might occur
 	local line=self.__line
 	insert(self.__marked_line,{ line,node, range or 0})
 	
 	-- self:appendf('--[[<%d>->:%d,%d:%s]]',line, node.p0,node.p1, node.tag)
 	-- if msg then self:append(msg) end

 	if cr~=false then
 		self.dirty=true
 		self:cr() 
 		self:append'\t'
 	end
 end

 function codeWriter:ii()--increase indent
 	self.__indent=self.__indent+1
 	self.dirty=true
 end

 function codeWriter:di()--increase indent
 	self.__indent=self.__indent-1
 	self.dirty=true
 end

 function codeWriter:tostring()
	return table.concat(self.__list)
 end

function codeWriter:writefile(file)
	for i,t in ipairs(self.__list) do
		file:write(t)
	end
end

function codeWriter:refer(d,a,...)
	local tag=d.tag
	if tag=='methoddecl' 
		or (tag=='funcdecl' and not d.localfunc)
		or tag=='classdecl' 
		or tag=='enumdecl' 
		or tag=='signaldecl' then
		self.referedDecls[d]=true
	elseif tag=='varacc' or tag=='member' or tag=='type' then
		return self:refer(d.decl,a,...)
	end

	if a then return self:refer(a,...) end
end

function codeWriter:expose(d,a,...)
	self.exposeDecls[d]=true
	if a then return self:expose(a,...) end
end

_M.newCodeWriter=newCodeWriter