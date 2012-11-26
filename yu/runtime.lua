local setmetatable=setmetatable
local getmetatable=getmetatable
local newproxy=newproxy
local type=type

module("yu.runtime",package.seeall)


-----------TYPE

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
		if s==super then return true end
		sub=s
	until not sub
	return false
end

function checkType(sub,super) --t == v or t is subclass of v
	if sub==super then return true end
	
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

-----------SIGNAL
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

-------------------------CLASS
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


function newObject(obj, clas, constructor,finalizer, ...)
	setmetatable(obj,clas)
	
	if constructor then
		constructor(obj,...)
	end
	
	if finalizer then
		return makefinalizer(obj)
	else
		return obj
	end
end
-------------------------REFLECTION
--[[
	
]]
-------------------------COROUTINE


------------------------CORO
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
	
-------------------------TRY-CATCH
local coroCreate=coroutine.create
local coroStatus=coroutine.status
local coroResume=coroutine.resume
-- local assert = assert
local yield=coroutine.yield
local next=next

local ex


function doThrow(e, savetrace)
	if savetrace then 
			--TODO:trace
	end
	ex=e
	error("luxex",2)
end

function doAssert( cond, ex )
	-- return assert(cond,ex)
	if not cond then
		doThrow(ex)
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


-------------MODULE



function newClass( name )
	local t={}
	return {__index=t,__name=name,__type='class'}
end

function newObject( data, clas,constructor,... )
	setmetatable(data,clas)
	if constructor then 
		constructor(data,...) 
	end
	return data
end

local loaded={}
local loader={}

function loadSymbol( name )
	local d=loaded[name]
	if not d then 
		d=loader[name]()
	end
	return d
end


function makeSymbolTable(loaders)
	loaders=loaders or {}
	local loaded=setmetatable({},{
		__index=function( t,k )
			local l=loaders[k]
			if not l then 
				error('Symbol not found:'..k) 
			end
			local s=l()
			t[k]=s
			return s
		end})
	return loaded, loaders
end

local gmatch=string.gmatch
function loadExternSymbol( name )
	local t=_G
	for w in gmatch(name, "(%w+)[.]?") do
       t=t[w]
       if not t then
       	print('warning:extern symbol not found '..name)
       	return false
       end
    end
    return t
end

function loadModule( f,... )
	local env=setmetatable({},{__index=_G})
	setfenv(f,env)
	f(...)
end


-- local runtimeModuleEnv={
	
-- }
local runtimeMT={}

function module(name)
	local moduleEnv=setmetatable(
		{},{
			__name=name,
			__is_yu_module=true
		}
	)
	return setfenv(1, moduleEnv)
end


local function findLine(lineInfo,pos)
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

local function makeYuTraceString(info,modEnv)
	local dinfo=modEnv.__yu__debuginfo
	if not dinfo then 
		return 'unkown track in YU:'..getmetatable(modEnv).__name
	end

	local lineTarget=dinfo.line_target
	local line=info.currentline - 1
	local lineOffset=dinfo.line_offset
	for i, data in ipairs(lineTarget) do
		local l=data[1]
		if line==l then
			
			local l1,off1=findLine(lineOffset,data[2])
			local l2,off2=findLine(lineOffset,data[3])
			return string.format('%s: %d <%d:%d-%d:%d>',dinfo.path,l1,
				l1,off1,l2,off2)		
		end
	end
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
		whatInfo=string.format('function \'%s\'',info.name)
	elseif what=='C' then
		whatInfo=nil
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

function getStackInfo(level)
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

end

function errorHandler(msg,b)
	local level=3
	print('Error:',msg)
	while true do
		local info=getStackInfo(level)
		if not info then break end
		print(info)
		level=level+1
	end
		
end
