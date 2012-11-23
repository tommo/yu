collectgarbage("setpause",4000)
collectgarbage("setstepmul",200)

local setmetatable=setmetatable
local getmetatable=getmetatable
local newproxy=newproxy
local type=type

local lxtypes={}

function __lxregister(name,t,kind)
	if kind=="class" then
		t.__index=t
		lxtypes[name]=t
	elseif kind=="table" then
	end
	return t
end


function __lxtype(v)
	local t= type(v)
	if t=="number" or t=="boolean" or t=="nil" or t=="string" then return t end
	--table/function
	
	if t=="table" then --table/ object
		local c=getmetatable(v)
		if c then return c end
		
	elseif t=="function" then --closure/function
		return t
		
	else
		return t
	end
end

local function __isSubclass(sub,super)
	repeat
		local s=sub.__super
		if s==super then return true end
		sub=s
	until not sub
	return false
end

function __lxchecktype(sub,super) --t == v or t is subclass of v
	if sub==super then return true end
	
	if type(sub)=="table" then --class
		if __isSubclass(sub,super) then return true end
	end
	return false
end

------------------------
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


function __newobject(obj, clas, finalizer,  constructor, ...)
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

local error=error

-----------Try

local coroCreate=coroutine.create
local coroStatus=coroutine.status
local coroResume=coroutine.resume
local yield=coroutine.yield
local next=next

local ex

local function __lxexception(luaex)
	local f=ex
	ex=nil
	return f
end

function __lxthrow(e, savetrace)
	if savetrace then 
	end
	ex=e
	error("luxex",2)
end

local returnkey={} 
local endkey={} -- if try block return this, there's no user return
local breakkey={}
local continuekey={}

local function tryCore(func)
	while true do
		local a,b,c,d,e,f,g=func(endkey,breakkey,continuekey)
		
		if a==endkey or a==breakkey or a==continuekey then --no user return
			func=yield(a) --wait for next entry
		else
			func=yield(returnkey,a,b,c,d,e,f,g)
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


function __lxtry(func)
	local coro=getTryCoro()
	
	while true do
		local succ,a,b,c,d,e,f,g = coroResume(coro,func)
		
		if succ then 
			
			if a==endkey then 
				tryCoroPool[coro]=true -- push to pool
				return "end"
			elseif a==breakkey then
				tryCoroPool[coro]=true -- push to pool
				return "break"
			elseif a==continuekey then
				tryCoroPool[coro]=true -- push to pool
				return "continue"
			elseif a==returnkey then --user return values
				tryCoroPool[coro]=true -- push to pool
				return "return",b,c,d,e,f,g
				
			else 
				yield(a,b,c,d,e,f,g) --send yield out
			end 
			
		else	--exception
			return "error",__lxexception(a)
		end
	end
	
end


------------------------CORO
__lxyield=coroutine.yield
local corocreate=coroutine.create
local cororesume=coroutine.resume
local generatorPool={}
local threadWaitingKey={}
local function generatorWrapper(this)
	local func, a,b,c,d,e,f,g
	while true do
		generatorPool[this]=true
		local key
		key,func, a,b,c,d,e,f,g=yield(threadWaitingKey, a,b,c,d,e,f,g)
		if key~=threadWaitingKey then --the coro is used by a dead generator
			error("generator already dead")
		end
		generatorPool[this]=nil
		yield()
		a,b,c,d,e,f,g=func(a,b,c,e,f,g)
	end
end

local function generatorResume(coro)
	local flag, a,b,c,d,e,f,g,h = cororesume(coro)
	if flag then
		if a==threadWaitingKey then --the func returned
			return b,c,d,e,f,g,h
		else
			return a,b,c,d,e,f,g,h
		end
	else --error
		--TODO: handle error
		error(a)
	end
end

local function getGeneratorCoro()
	local coro,_=next(generatorPool)
	if not coro then
		coro=corocreate(generatorWrapper)
		cororesume(coro, coro)
	end
	return coro
end

__lxspawn=function (f,a,...)
	local coro=getGeneratorCoro()
	if type(f)=="string" then --method lookup
		f=a[f]
	end
	cororesume(coro, threadWaitingKey, f, a,...)
	return coro
end
__lxresume=generatorResume
__lxgeneratoralive=function(k)
	return not generatorPool[k]
end
__lxpairs=pairs