local rawget,rawset=rawget,rawset
local setmetatable=setmetatable
local getmetatable=getmetatable
local insert,remove=table.insert,table.remove
local gmatch=string.gmatch
local format=string.format
local newproxy=newproxy
local type=type

module("yu.runtime",package.seeall)

-------------------------@CLASS

local classMT={}

local function newClass( name, classDecl ,superClass, body) --needed by builtin class
	if superClass then setmetatable(body,superClass) end
	--todo: cache method for class?
	classDecl.__index=body
	classDecl.__name=name
	classDecl.__super=superClass or false
	classDecl.__type='class'
	
	if superClass then
		local subclass=superClass and superClass.__subclass
		if not subclass then subclass={} superClass.__subclass=subclass end
		subclass[classDecl]=true
	end

	local methodPointers=setmetatable({},{__mode='kv'})

	function body:__build_methodpointer(id)
		local pointers=rawget(self,'@methodpointers')
		if not poointers then
			pointers={}
			rawget(self,'@methodpointers',pointers)
		end
		local mp=pointers[id]
		if not mp then
			local f=self[id]
			mp=function(...) return f(self,...) end
			pointers[id]=mp
		end
		return mp
	end
	
	return classDecl
end

local proxygc=function(p)
	local t=getmetatable(p).__index
	local c=getmetatable(t)
	while c do
		local f=c.__finalize
		if f then f(t) end
		c=c.__super
	end
end

local function makefinalizer(t)
	local p=newproxy(true)
	local mt=getmetatable(p)
	mt.__index=t
	mt.__newindex=t
	mt.__gc=proxygc
	return p
end

local function callInit(clas,obj)
	local super=clas.__super
	if super then callInit(super,obj) end
	local init=clas.__index.__init
	if init then
		init(obj)
	end
end

function newObject(clas,obj, constructor, ...)
	setmetatable(obj,clas)
	callInit(clas,obj)

	if constructor then		
		constructor(obj,...)	
	else
		setmetatable(obj,clas)
	end

	return obj
	-- if finalizer then
	-- 	return makefinalizer(obj)
	-- else
	-- 	return obj
	-- end
end


------------@BultinType helpers
local builtinSymbols,runtimeIndex
builtinSymbols={}
--------------

function registerBuiltinClass(name,superclass, body )
	if superclass then
		local n={}
		for k,v in pairs(body) do
			n[k]=v
		end
		local s=superclass
		while s do
			for k,v in pairs(s.__index) do
				if not n[k] then n[k]=v end
			end
			s=s.__super
		end
		body=n
	end
	local clas=newClass(name, {}, superclass, body)
	builtinSymbols[name]=clas
	return clas
end

function registerBultinFunction(name, func)
	assert(not builtinSymbols[name])
	-- assert(type(func)=='function')
	builtinSymbols[name]=func
	return func
end

-----------@TYPE

function getType(v)
	local t= type(v)
	if t=="number" or t=="boolean" or t=="nil" or t=="string" then return t end
	--table/function
	
	if t=="table" then --table/ object
		local c=getmetatable(v)
		if c then return c end
	elseif t=="function" then --closure/function
		return t		
	elseif t=='userdata' then
		return t
	elseif t=='thread' then
		return t
	else
		error('unknown type:'..t)
	end

	--TODO:
end

local function __isSubclass(sub,super)

	repeat
		local s=sub.__super
		-- print(sub.__name, s)
		if s and s==super then return true end
		sub=s
	until not sub
	return false
end

function checkType(sub,super) --t == v or t is subclass of v
	if sub==super then return true end
	if super==nil then return false end
	if type(sub)=="table" then --class
		if super=='object' then return true end
		if __isSubclass(sub,super) then return true end
	end
	return false
end

function isType(data,t)

	return checkType(getType(data),t)
end

function objectNext( obj )
	return obj.__next,obj
end

function cast(obj,t)
	return isType(obj,t) and obj or nil
end

-----------@SIGNAL
local signalConnectionTable={}
local next=next

local weakmt = {__mode='kv'}
function signalCreate(name)
	--TODO
	local conn=setmetatable({},weakmt)
	local function signalEmit(sender,...)

		sender=sender or 'all'
		local l=conn[sender]
		if not l then return end

		local k,v
		while true do
			k,v =next(l,k) --k is func, v is receiver
			
			if not k then break end

			if v then --method/signal
				k(v,...)
			else
				k(...) 
			end
		end

		if sender~='all' then
			local l=conn['all']
			if not l then return end
			local k
			while true do
				k,v =next(l,k) --k is func, v is receiver
				if not k then break end
				if v then
					k(v,...)
				else
					k(...) 
				end
			end
		end
	end
	signalConnectionTable[signalEmit]=conn
	return signalEmit
end


function signalConnect(signal,sender,slot,receiver )
	local conn=signalConnectionTable[signal]
	local l=conn[sender]
	if not l then
		l=setmetatable({},weakmt)
		conn[sender]=l
	end
	
	l[slot]=receiver or false --random?
	return l --retur channel for fast remove
end


-------------------------@REFLECTION
--[[
	
]]

local reflectionRegistryN={} --todo: should we support multiple contexts?
local reflectionRegistryV={}
local TypeInfo={}

function TypeInfo:getName()
	return self.name
end

function TypeInfo:getTag()
	return 'type'
end


function TypeInfo:isExtern()
	return self.extern or false
end

function TypeInfo:isPrivate()
	return self.private or false
end

function TypeInfo:getAnnotationList()
	return self.annotaions or nil
end


local ClassInfo={}
function ClassInfo:getTag()
	return 'class'
end

function ClassInfo:getSuperClass()
	if not self.decl then return nil end
	local s=self.decl.__super
	if s then
		return reflectionRegistryV[s]
	else
		return nil
	end
end

function ClassInfo:getSubClassList()
	if not self.decl then return nil end
	local subclass=self.decl.__subclass
	if not subclass then return {} end
	local res={}
	local i=0
	for c in pairs(subclass) do
		i=i+1
		res[i]=reflectionRegistryV[c]
	end
end


function ClassInfo:getMemberList()
	return self.members
end

function ClassInfo:getMember(name)
	for i,v in ipairs(self.members) do
		if v.name==name then return v end
	end
	return nil
end

function ClassInfo:getField(name)	
	local m=self:getMember(name)
	if m.mtype=='field' then return m end
	return nil
end

function ClassInfo:getMethod(name)
	local m=self:getMember(name)
	if m.mtype=='method' then return m end
	return nil
end

----Enum
local EnumInfo={}
function EnumInfo:getTag()
	return 'enum'
end

function EnumInfo:getItem(name)
	for i, n in ipairs(self.items) do
		if n[1]==name then return n[2] end
	end
	return nil
end

function EnumInfo:getItemTable()
	local t={}
	for i, n in ipairs(self.items) do
		t[n[1]]=n[2]
	end
	return t
end

-----MemberInfo
local MemberInfo={}
function MemberInfo:getName()
	return self.name
end

function MemberInfo:isPrivate()
	return self.private or false
end

function MemberInfo:getMemberType()
	return self.mtype
end

function MemberInfo:getAnnotationList()
	return self.annotaions or nil
end

local FieldInfo={}
function FieldInfo:getType()
	local t=self.type
	local info=reflectionRegistryN[t]
	if info then
		return info
	elseif t:find('func(')==1 then
		--todo
		error('todo:func typeinfo')
	end
	error('todo:other typeinfo:'..t)
end

function FieldInfo:getValue(obj)
	--todo: typecheck?
	return obj[self.name]
end

function FieldInfo:setValue(obj,v)
	--todo: typecheck?
	obj[self.name]=v
end

local MethodInfo={}
function MethodInfo:invoke(obj, ...)
	local m=obj[self.name]
	if m then return m(obj, ...) end
end

function MethodInfo:getRetType()
end

function MethodInfo:getArguments()
end

local ArgInfo={}
function ArgInfo:getType()
end

local TypeInfoClass = registerBuiltinClass("TypeInfo", nil, TypeInfo)
local ClassInfoClass = registerBuiltinClass("ClassType", TypeInfoClass, ClassInfo)
local EnumInfoClass = registerBuiltinClass("EnumType", TypeInfoClass, EnumInfo)

local MemberInfoClass =registerBuiltinClass("MemberInfo",nil,MemberInfo)
local FieldInfoClass =registerBuiltinClass("FieldInfo",MemberInfoClass,FieldInfo)
local MethodInfoClass =registerBuiltinClass("MethodInfo",MemberInfoClass,MethodInfo)
local ArgInfoClass =registerBuiltinClass("ArgInfo",nil,ArgInfo)

local function registerValueTypeInfo(name,clasname)
	local body={}
	function body:getTag()
		return name
	end
	local clas=registerBuiltinClass(clasname, TypeInfoClass, body)
	reflectionRegistryN[name]=setmetatable({},clas)
end

registerValueTypeInfo("number","NumberType")
registerValueTypeInfo("string","StringType")
registerValueTypeInfo("boolean","BooleanType")
registerValueTypeInfo("nil","NilType")

--basic types


-------static helpers

function getTypeInfoByName(name)
	if name then
		local t=reflectionRegistryN[name]
		return t
	else
		return nil
	end
end

function getTypeInfoByValue(v)
	local vt=getType(v)
	if vt then
		local t=reflectionRegistryV[vt]
		return t
	else
		return nil
	end
end


------------
function addReflection(rtype, decl, name, info, memberInfo)
	-- print('+', rtype, name, decl ,info , memberInfo)
	local r=info
	r.type=rtype
	r.name=name
	r.decl=decl or false
	-- r.extern=info.extern or false
	-- r.private=info.private
		
	if rtype=='class' then		
		r.superclass=info.superclass or false
		for i, m in ipairs(memberInfo) do
			local mtype=m.mtype
			if mtype=='field' then
				setmetatable(m, FieldInfoClass)
			elseif mtype=='method' then
				setmetatable(m,  MethodInfoClass)
			end
		end
		r.members=memberInfo
		setmetatable(r, ClassInfoClass)
	elseif rtype=='enum' then
		r.items=memberInfo
		setmetatable(r, EnumInfoClass)
	end
	if decl then
		reflectionRegistryV[decl]=r
	end
	reflectionRegistryN[name]=r
end

function addAnnotation(name, ann)
	local r=reflectionRegistryN[name]
	assert(r)
	
	--member
	if r:getTag()=='class' then
		local members=r.members
		for k,a in pairs(ann) do
			if k==1 then
				r.annotaions=a
			else
				local m=r:getMember(k)
				m.annotaions=a 
			end
		end
	end

end



-------------------@COROUTINE

local generatorPool={}
-- local generatorFuncs={}
local __THREAD_WAITING={}
local waitResumeKey={}
local yield=coroutine.yield
local corocreate=coroutine.create
local cororesume=coroutine.resume
local cororunning=coroutine.running

local function generatorInner(coro,func,...)
	generatorPool[coro]=nil --thread is out of pool
	yield() --wait for first resume
	return func(...)
end
	
local function generatorWrapper( coro, key, func, ... )
		if key~=__THREAD_WAITING then --the coro is used by a dead generator
			error("generator already dead")
		end
		return generatorWrapper(yield(__THREAD_WAITING, generatorInner(coro,func,...)))
		
end


local function generatorResumeInner(coro,flag,a,...)
	if flag then
		if a==__THREAD_WAITING then --the func returned
			generatorPool[coro]=true
			return ...
		else
			return a,...
		end
	else --error
		--TODO: handle error
		error(debug.traceback(coro))
	end
end

function generatorResume(coro)
	return generatorResumeInner(coro,cororesume(coro))
end

local function getGeneratorCoro()
	local coro,_=next(generatorPool)
	if not coro then
		coro=corocreate(generatorWrapper)
		generatorPool[coro]=true
	end
	return coro
end

function generatorSpawn(f,a,...)
	local coro=getGeneratorCoro()
	if type(f)=="string" then --method lookup
		f=a[f]
	end
	cororesume(coro, coro, __THREAD_WAITING, f, a,...)
	return coro
end

generatorYield=yield

local function waitInner(key,...)
	if key~=waitResumeKey then
		error('thread is waiting a signal,can not resume')
	end
	return ...
end

function signalWait(sig,sender)
	--todo: use some lighter structure
	local signalChannel
	local slot
	local coro=cororunning()

	slot=function(...)
		signalChannel[slot]=nil
		cororesume(coro,waitResumeKey,...)
	end
	
	signalChannel=signalConnect(sig,sender,slot)
	return waitInner(yield())
end
	
--------------------@TRY-CATCH
local coroCreate=coroutine.create
local coroStatus=coroutine.status
local coroResume=coroutine.resume
-- local assert = assert
local yield=coroutine.yield
local next=next

local ex


function doThrow(e)
	ex=e
	return error(tostring(e))
end

function doAssert( cond, ex )
	-- return assert(cond,ex)
	if not cond then
		return doThrow(ex)
	end
end

local RETURNKEY={} 
local ENDKEY={} -- if try block return this, there's no user return
local BREAKKEY={}
local CONTINUEKEY={}

local function tryCore(func)
	while true do
		local a,b,c,d,e,f,g=func(ENDKEY,BREAKKEY,CONTINUEKEY)
		
		if a==ENDKEY or a==BREAKKEY or a==CONTINUEKEY then --no user return
			func=yield(a) --wait for next entry
		else
			func=yield(RETURNKEY,a,b,c,d,e,f,g)
		end
		
	end
end

local tryCoroPool={} --coroutine pool
local function getTryCoro()
	local coro,_ = next(tryCoroPool)
	
	if coro then
		tryCoroPool[coro]=nil
	else
		coro=coroCreate(tryCore)
	end
	
	return coro
end

local function __handleTry(succ,a,...)
	if succ then 
		if a==ENDKEY then 
			tryCoroPool[coro]=true -- push to pool
			return "end"
		elseif a==BREAKKEY then
			tryCoroPool[coro]=true -- push to pool
			return "break"
		elseif a==CONTINUEKEY then
			tryCoroPool[coro]=true -- push to pool
			return "continue"
		elseif a==RETURNKEY then --user return values
			tryCoroPool[coro]=true -- push to pool
			return "return",...
		else	--yield in try block 
			yield(a,...) --send yield out
		end 
		
	else	--exception
		return "error",__lxexception(a)
	end
end

function doTry(func)
	local coro=getTryCoro()
	return __handleTry(coroResume(coro,func))
end


-------------@MODULE
local moduleTable={}

function requireModule(path)
	--todo:load module if not loaded
	local m=moduleTable[path]

	if not m then	
		--load module
		-- print('loading module:',path)
		local f,err=loadfile(path..'.yo') --todo: basepath support
		if not f then
			print(err)
			return error('Module not load:'..path)
		end
		f()
		m=moduleTable[path]
		assert(m)
	end
	return m
end

function launchModule(path,...)
	local m=requireModule(path)
	m.__yu_module_init()  --setup local symbol loaders
	m.__yu_module_refer() --link extern symbols
	return m.__yu_module_entry(...) --actually init local symbols, run module.main()
end

local loadExternSymbol

function loadExternSymbol( name )
	local s= runtimeIndex[name]
	if s then return s end
	local s= builtinSymbols[name]
	-- print(s,name)
	if s then return s end
	local t=_G
	for w in gmatch(name, "(%w+)[.]?") do
       t=t[w]
       if not t then
       	-- print('warning:extern symbol not found :',name)
       	return nil
       end
    end
    return t
end

local tostring=tostring
runtimeIndex=setmetatable({
		__yu_newclass=newClass,
		__yu_newobject=newObject,

		__yu_addannotation=addAnnotation,
		__yu_addreflection=addReflection,

		__yu_try=doTry,
		__yu_throw=doThrow,
		__yu_assert=doAssert,
		__yu_cast=cast,
		__yu_is=isType,

		__yu_tostring=function(x)
			return x and tostring(x)
		end,
		
		__yu_obj_next=objectNext,

		__yu_wait=signalWait,
		__yu_connect=signalConnect,
		
		__yu_resume=generatorResume,
		__yu_spawn=generatorSpawn,
		__yu_yield=generatorYield,

		__yu_require=requireModule,
		__yu_extern=loadExternSymbol,

		__yu_gettypeinfoN=getTypeInfoByName,
		__yu_gettypeinfoV=getTypeInfoByValue

	},{__index=_G})

function module(path)
	local moduleEnv=setmetatable(
		{},{
			__path=path,
			__name=name,
			__is_yu_module=true,			
			__index=runtimeIndex,
		}
	)

	moduleTable[path]=moduleEnv
	setfenv(2, moduleEnv)
	return moduleEnv
end


---------------@Lua Debug Injections---
local function findLine(lineOffset,pos)
	local off0=0
	local l0=0
	local off=0
	for l,linesize in ipairs(lineOffset) do
		off=off+linesize
		if pos>=off0 and pos<off then 
			return l0,pos-off0
		end
		off0=off
		l0=l
	end
	return l0,pos-off0
end

local function makeYuTraceString(info,modEnv)
	local dinfo=modEnv.__yu__debuginfo
	if not dinfo then 
		return 'unkown track in YU:'..getmetatable(modEnv).__name
	end

	local lineTarget=dinfo.line_target
	local line=info.currentline 
	local lineOffset=dinfo.line_offset
	for i, data in ipairs(lineTarget) do
		local l=data[1]
		local range=data[2]
		if line>=l and line<=l+range then
			local l1,off1=findLine(lineOffset,data[3])
			local l2,off2=findLine(lineOffset,data[4])
			return format('%s: %d <%d:%d-%d:%d>',dinfo.path,l1,
				l1,off1,l2,off2)		
		end
	end
	-- table.foreach(getmetatable(modEnv),print)
	return 'unkown track in YU:'..(getmetatable(modEnv).__path or '?')
end

local function makeLuaTraceString(info)
	local what=info.what
	local whatInfo
	if what=='main' then
		if info.name then
			whatInfo=string.format('function \'%s\'',info.name)
		else
			whatInfo='main chunk'
		end
	elseif what=='Lua' then
		whatInfo=string.format('function \'%s\'',info.name or '?')
	elseif what=='C' then
		whatInfo=nil
		return '[C]: ?'
	end
	if whatInfo~=nil then
		whatInfo='in '..whatInfo
	else
		whatInfo='?'
	end

	return 
		string.format(
			'%s:%d: %s',info.short_src,info.currentline,whatInfo
		)
end

function getStackPos(level)
	local info=debug.getinfo(level)
	if not info then return false end
	local func=info.func	
	local env=getfenv(func)
	local mt=env and getmetatable(env)

	if mt and mt.__is_yu_module then
		return makeYuTraceString(info,env)
	else -- normal Lua stack
		return makeLuaTraceString(info)
	end
	return makeLuaTraceString(info)
end

function traceBack(level)
	level=level or 3
	local output='stack traceback:\n'
	while true do
		local info=getStackPos(level+1)
		if not info then break end
		output=output..'\t'..info..'\n'
		level=level+1
	end
	return output
end

function convertLuaErrorMsg(msg)
	return msg
end

function errorHandler(msg,b)
	local startLevel=2
	local info=debug.getinfo(startLevel)
	if info.func==error then startLevel=startLevel+1 end

	local traceInfo=traceBack(startLevel+1)
	if errorInYu then
		msg=convertLuaErrorMsg(msg)
	end
	if msg then
		io.stderr:write(msg,'\n')
	end
	io.stderr:write(traceInfo,'\n')
end


----------------------@Entry Interfaces
local _dofile=dofile
function run(file,...) --yu module launcher
	return xpcall(function(...)
			return launchModule(file,...)
		end
		,errorHandler
		,...)	
end


