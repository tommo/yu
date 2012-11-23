require "lpeg"
require "yu.resolver"
module("yu",package.seeall)




--[[
	generated code layout:
		loader table for func/classdecl
		interface data, mainly for debug purpose
		reflection data

		each error-prone token occupies a single line-number, 
			so that we can convert Lua-line-number into Yu-token-pos easily
	]]


local generators={}

local getOpPrecedence=getOpPrecedence
local getConst=getConst

local format,gsub,unescape = string.format,string.gsub,unescape

local codegen,codegenList

local function isExposable(n)
	-- if n.extern then return false end
	local tag=n.tag
	if tag=='var' then
		local vtype=n.vtype
		return vtype=='global'
	else
		return 
			(tag=='funcdecl' and not n.localfunc)
			or (tag=='methoddecl' and not n.extern)
			or tag=='classdecl'
			or tag=='enumdecl'
			or tag=='signaldecl'
	end
end

local function printMetadata(m)
	local s=''
	for k,v in pairs(m) do
		local i=string.format('%s=%s,',k,v)
		s=s..i
	end
	return '{'..s..'}'
end

local function getDeclName(d)
	if d.name=='...' then return '...' end
	-- return d.refname
	local tag = d.tag
	if tag=='var' then
		local vtype=d.vtype
		if vtype=='local' then return d.name end
		if vtype=='global' then return d.refname end

		if vtype=='const' then return getConst(d.value) end
		-- if vtype=='field' then 
		-- 	--TODO: self?
		-- 	return d.name 
		-- end
	elseif tag=='funcdecl' then
		--TODO:....
	elseif tag=='arg' then
		return d.name
	end
	return d.refname
end

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
			
			__level=0,

			referedDecls={},		--context part
			exposeDecls={},
		},
		codeWriterMT)
 end
 
function codeWriter:append(str,s1,...)
	local l=self.__list
	local count=self.__count
	l[count+1]=str
	self.__count=count+1
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
 	self:append('\n'..stringrep('\t',self.__indent))
 	self.__line=self.__line+1
 end

 function codeWriter:ii()--increase indent
 	self.__indent=self.__indent+1
 end

 function codeWriter:di()--increase indent
 	self.__indent=self.__indent-1
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

local function doCodegen( node, parentGen )
	local gen=newCodeWriter()
	if parentGen then
		gen.parent=parentGen
		gen.__indent=parentGen.__indent
		gen.__level=parentGen.__level+1
	end
	codegen(gen,node)
	return gen
end

codegen= function(gen,m)
	-- print('generators...'..m.tag)
	assert(gen.__list) --NEED REMOVAL, at last
	local t=m.tag
	local g=generators[t]
	if g then
		return g(gen,m) 
	else
		error("generator not defined for:"..t)
	end
end

codegenList= function(gen,l,sep)
	assert(gen.__list) --NEED REMOVAL, at last
	if not l then return end

	sep=sep or ','
	for i,t in ipairs(l) do
		if t.tag=='mulval' then break end
		if i>1 then
			gen(sep)
		end
		codegen(gen,t)
	end

end

local function makeReferLink(gen,d,from)
	gen:cr()

	local name=getDeclName(d)
	local refname=d.refname
	if d.module~=from.module then
		gen:appendf('%s=__YU_MODULE_LOADED[%q].%s',name,d.module.name,refname)
	else
		gen:appendf('%s=__YU_LOADED.%s',name,refname)
	end
end



function generators.module(gen,m)
	-- gen.__indent=-1 --reset indent
	gen:appendf('__YU_MODULE_LOADER[%q]=function()',m.fullname)
	gen:ii()
	gen:cr()
		gen'local __YU_LOADED, __YU_LOADER=__YU_RUNTIME.makeSymbolTable()'
		gen:appendf('__YU_MODULE_LOADED[%q]=__YU_LOADED',m.fullname)
		gen:cr()
		codegen(gen,m.mainfunc)
		gen:cr()
		gen'return __YU_LOADED, __YU_LOADED.__main'
	gen:di()
	gen:cr()
	gen'end'
end

function generators.block(gen,b)
	gen:ii()
	local nonDecls={}
	for i,s in ipairs(b) do
		if isExposable(s) then
			gen:expose(s)
		else
			gen:cr()
			codegen(gen,s)
		end
	end
	gen:di()
	gen:cr()
end

-----------------------------CONTROL
function generators.import(gen,im)
	--currentModule.import
end

function generators.private(gen)
end

function generators.public(gen)
end

function generators.rawlua(gen,r)
	gen'--BEGIN of raw lua code'
	local i=gen.__indent
	gen.__indent=0
	gen:cr()
		gen(r.src)
	gen.__indent=i
	gen:cr()
	
	gen'--END of raw lua code'
	
end


--------------------TYPE
function generators.ttype(gen,t)
	--TODO:!!!!!!!!!!
end

function generators.type(gen,t)
	local decl=t.decl
	gen:refer(decl)
	local dt=decl.tag

	if dt=='classdecl' then
		return gen(getDeclName(decl))		
	else
		return gen:appendf('%q',t.name) 
	end
end

function generators.tabletype(gen,t)
	--TODO:!!!!
	gen:appendf('%q',t.name)
end

function generators.functype(gen,ft)
	-- if ft.args then resolveEach(ft.args) end
	-- if ft.rettype then resolveEach(ft.rettype) end
	-- return true
	gen:appendf('%q',ft.name)
end


--#STATEMENTS
--#FLOW
function generators.dostmt(gen,d)
	gen'do'
	codegen(gen,d.block)
	gen'end'
end

function generators.ifstmt(gen,s)
	gen'if'
	codegen(gen,s.cond)
	gen'then'
	
	codegen(gen,s.body.thenbody)
	if s.body.elsebody then
		gen'else'
		codegen(gen,s.body.elsebody)
	end
	gen'end'
end

function generators.switchstmt(gen,s)
	gen'do'
		gen:ii()
		gen:cr()
		gen'local __SWITCH ='
		codegen(gen,s.cond)
		gen:cr()
		for i, c in ipairs(s.cases) do
			gen(i>1 and 'elseif' or 'if')
			for j, cc in ipairs(c.conds) do
				if j>1 then gen'or' end
				gen'__SWITCH=='
				codegen(gen,cc)
			end
			gen'then'
			codegen(gen,c.block)
		end
		
		if s.default then
			if #s.cases>0 then gen'else' end
			codegen(gen,s.default)
		end
		gen'end'
	gen:di()
	gen:cr()
	gen'end'
end

function generators.case(gen,c) --done in select stmt
end

function generators.returnstmt(gen,r)
	gen 'return'
	codegenList(gen,r.values)
end

function generators.yieldstmt(gen,y)
	gen'__YU_YIELD('
	codegenList(gen, y.values)
	gen')'
end

function generators.connectstmt( gen,conn )
	local sig,slot,sender,receiver=conn.signal,conn.slot,conn.sender,conn.receiver

	gen '__YU_CONNECT('
	gen:refer(sig,slot)

	gen(getDeclName(sig))
	gen','
	if sender and sender~='all' then 
		gen:refer(sender)
		codegen(gen,sender)
	else
		gen'"all"'
	end
	gen','
	codegen(gen,slot)
	if receiver then 
		gen','
		codegen(gen,receiver)
		gen:refer(receiver)
	end
	gen ');'
	
end



local function genLoopBlock(gen,block, hasBreak, hasContinue)
	
	if hasContinue then
		gen'local __dobreak=true' 
		gen'repeat'
	end
	
	codegen(gen,block)
	
	if hasContinue then
		if hasBreak then 
			gen'__dobreak=false until true'
			gen'if __dobreak then break end'
		else
			gen'until true'
		end
	end
end


function generators.forstmt(gen,f)
	gen'for'
		codegen(gen,f.var)
		gen'='
		codegenList(gen,f.range)
	gen'do'
	genLoopBlock(gen,f.block,f.hasBreak,f.hasContinue)
	gen'end'
end

function generators.foreachstmt(gen,f)
	--todo
	gen'for'
		codegenList(gen,f.vars)
	gen'in'
		codegen(gen,f.iterator)
	gen'do'
	genLoopBlock(gen,f.block,f.hasBreak,f.hasContinue)
	gen'end'
end

function generators.iterator( gen,i )
	local mode=i.mode
	if mode=='table' then
		gen'next ,' codegen(gen,i.expr) gen''
	elseif mode=='enum' then
		--todo
	elseif mode=='thread' then
		gen'__YU_RESUME ,' codegen(gen,i.expr)
	elseif mode=='obj' then
		gen'__YU_OBJ_NEXT (' codegen(gen,i.expr) gen':__iter() )'
	elseif mode=='obj-table' then
		gen'next ,' codegen(gen,i.expr) gen':__iter()'
	elseif mode=='obj-thread' then
		gen'__YU_RESUME ,' codegen(gen,i.expr) gen':__iter()'
	end
end
	
function generators.whilestmt(gen,s)
	gen'while'
		codegen(gen,s.cond)
	gen'do'
		genLoopBlock(gen,s.block,s.hasBreak,s.hasContinue)
	gen'end'
end

function generators.repeatstmt(gen,s)
	gen'repeat'
		genLoopBlock(gen,s.block,s.hasBreak,s.hasContinue)
	gen'until'
		codegen(gen,s.cond)
	
end

function generators.continuestmt(gen,c)
	gen'__dobreak=false break'
end

function generators.breakstmt(gen,b)
	gen'break'
end

function generators.trystmt(gen,t)
	--todo:!!!!!!!!!!!!
end

function generators.throwstmt(gen,t)
	--todo:!!!!!!!!!!!!!!
	gen'__YU_THROW('
	codegenList(gen,t.values)
	gen')'
end

function generators.catch(gen,c)
	--todo:..............
end

function generators.assertstmt( gen,t )
	gen'__YU_ASSERT('
	codegen(gen,t.expr)
	if t.exception then 
		gen','
		codegen(gen,t.exception)
	end
	gen');'
end

function generators.assignstmt(gen,a)
	codegenList(gen,a.vars)
	gen'='
	codegenList(gen,a.values)
end

function generators.assopstmt(gen,a)
	--todo:!!!!!!!!
end 

function generators.batchassign(gen,a)
	--todo:!!!!!!!
end


function generators.exprstmt(gen,e) 
	codegen(gen,e.expr)
	gen';'
end


--#VARIABLES

function generators.vardecl(gen,vd)
	local vtype=vd.vtype
	if vtype=='const' then 
		--no code generation for const
		return ''
	end
	
	local values={}
	for i,var in ipairs(vd.vars) do
		values[i]=var.value
	end
	
	local out=''
	if vtype=='local' then		
		gen'local'
		codegenList(gen,vd.vars)
		if next(values) then
			gen'='
			codegenList(gen,values)
		end
	elseif vtype=='global' then
		if next(values) then
			codegenList(gen,vd.vars)
			gen'='
			codegenList(gen,values)
		end
	elseif vtype=='field' then
		--
	end
	--TODO:global/fields
	return out
end

--#DECLARATION
function generators.tvar(gen,v)
	--todo:!!!!!!
	
end

function generators.var(gen,v)
	gen(getDeclName(v))
	-- gen(v.name)
	-- local vtype=v.vtype
	-- if vtype=='local' then
		-- return v.name
	-- elseif vtype=='global' then --TODO:get full spaced name
		-- return v.fullname
	-- elseif vtype=='field' then
		-- return v.name
	-- end
	
end

function generators.arg(gen,a)
	if a.vararg then 
		gen'...' 
	else
		gen(getDeclName(a))
		-- gen(a.name)
	end
end

function generators.enumdecl(gen,e)
	-- --todo:assign default const value
	gen:appendf('__YU_LOADED.%s={}',getDeclName(e))
	--TODO:Meta info
end

function generators.enumitem(gen,e)
	-- if e.value then resolve(e.value) end
	-- --todo:typecheck
end



local function defaultFieldBody(gen,c)
	for i,s in ipairs(c.decls) do
		if s.tag=='vardecl' and s.vtype=='field' then
			for i,var in ipairs(s.vars) do
				if var.value then
					gen'self.' gen(var.name)
					gen'='
					codegen(gen,var.value)
				end
			end
		end
	end
end


function generators.classdecl(gen,c)
	--TODO:!!!!!!!!!!!!!!!!!
	-- gen:appendf('--CLASS:%s',c.name)
	gen:cr()
	gen:appendf('function __YU_LOADER.%s()',getDeclName(c))
	gen:ii()
	gen:cr()
		if c.meta then 
			gen:appendf('local meta=%s',printMetadata(c.meta))
			gen:cr()
		end
		gen:appendf('local class= __YU_RUNTIME.newClass(%q)',c.name)
		gen:cr()
		gen:appendf('__YU_LOADED.%s=class',getDeclName(c))
		-- gen:appendf('__YU_META.%s=',getDeclName)
		gen:cr()
		gen'local classbody = class.__index'
		local cons=false
		for i,s in ipairs(c.decls) do
			if isExposable(s) then
				if s.name=='__new' then 
					cons=s
				end
				codegen(gen,s)	
			end
		end
		-- if not defaultConstructor then --build one
		-- 	--todo:build constructor
		-- 	gen:cr()	
		-- 	gen'classbody.__new=function(self)'
		-- 	gen:ii() gen:cr()
		-- 		defaultFieldBody(gen,c)
		-- 	gen:di() gen:cr()
		-- 	gen'end'
		-- 	gen:cr()
		-- else
		-- 	gen:cr()
		-- 	gen:appendf('classbody.__new=__YU_LOADED.%s',getDeclName(defaultConstructor))
		-- 	gen:cr()
		-- end
		
		if c.superclass then
			gen:cr()
			gen:appendf('class.__super=__YU_LOADED.%s',getDeclName(c.superclass))
		end
		local cc=c
		local added={}
		while cc do 
			for i,s in ipairs(cc.decls) do
				if s.tag=='methoddecl' and s.name~='__new'  and not added[s.name] then
					if not s.extern and not s.abstract then
						gen:cr()
						gen:appendf('classbody.%s=__YU_LOADED.%s;',s.name,getDeclName(s))
						added[s.name]=true
					end
				end
			end
			cc=cc.superclass
		end
		gen:cr()
		gen:appendf('return class',getDeclName(c))
	gen:di()
	gen:cr()
	gen'end'
end

local function compareDecl(d1,d2)
	local a1=d1.depth-d2.depth
	if a1==0 then return d1.declId-d2.declId <0  end
	return a1<0
end

local function makeDeclList(t)
	local l={}
	local i=1
	for d in pairs(t) do
		l[i]=d
		i=i+1
	end
	table.sort(l,compareDecl)
	return l
end



function generators.funcdecl(gen,f)
	--TODO:!!!!!!!!!!!!!!!
	if f.localfunc then
		gen:cr()
		gen:append('local function '..getDeclName(f))
		gen'('
		if f.type.args then codegenList(gen,f.type.args) end
		gen')'
		codegen(gen,f.block)
		gen'end'
		return
	end
	if f.abstract then return end
	if f.extern then 
		gen:cr()
		gen:appendf('__YU_LOADED.%s =',f.refname)
		gen:appendf('__YU_EXTERN(%q)',f.fullname)
	else
		
		local gen1 = doCodegen(f.block, gen)

		if next(gen1.exposeDecls) or next(gen1.referedDecls) then --need loader
			gen:cr()
			gen:appendf('function __YU_LOADER.%s()',f.refname)
			gen:cr()
			for d in pairs(gen1.exposeDecls) do
				codegen(gen,d)
			end
			local reflist
			for d in pairs(gen1.referedDecls) do
				
				local name=getDeclName(d)

				if reflist then
					reflist=reflist..','..name
				else
					reflist=name
				end
			end
			
			if reflist then 
				gen:cr()
				gen('local '..reflist) 
			end

			gen:cr()
			gen'local func=function'
			gen'('
				if f.tag=='methoddecl' then 
					gen 'self'
					if #f.type.args>0 then gen',' end
				end
				codegenList(gen,f.type.args)
			gen')'

			gen(gen1:tostring())

			gen'end ;'	
			gen:cr()
			gen:appendf('__YU_LOADED.%s = func',f.refname)
			--load refered symbol
			--todo: extern symbols

			local expose1=makeDeclList(gen1.exposeDecls)
			local refer=gen1.referedDecls
			-- for _,d in ipairs(expose1) do
			-- 	if not refer[d] then 
			-- 		local name=getDeclName(d)
			-- 		gen:cr()
			-- 		gen:appendf('local _=__YU_LOADED.%s',d.refname)
			-- 	end
			-- end

			local refer1=makeDeclList(gen1.referedDecls)
			for _,d in ipairs(refer1) do
				makeReferLink(gen,d,f)
			end

			gen:cr()
			gen'return func'
			gen:cr()
			gen'end'
		else --no loader needed
			gen:cr()
			gen:appendf('__YU_LOADED.%s =',f.refname)
			gen'function'
			gen'('
				if f.tag=='methoddecl' then 
					gen 'self'
					if #f.type.args>0 then gen',' end
				end
				codegenList(gen,f.type.args)
			gen')'

			gen(gen1:tostring())

			gen'end ;'	
		end
	end
end

function generators.methoddecl(gen,m)
	-- if m.extern then return nil end
	return generators.funcdecl(gen,m)
	--TODO:!!!!!!!!!!!!!!!1
end

function generators.exprbody(gen,e)
	gen'return'
	codegenList(gen,e.exprs)
end

function generators.signaldecl( gen,sig )
	gen:cr()
	gen:appendf('__YU_LOADED.%s = __YU_RUNTIME.signalCreate(%q);',sig.refname,sig.name)
end

--#EXPRESSION

-------CONST
generators["nil"]=function(gen,n)
	gen 'nil'
end

function generators.number(gen,n)
	gen( n.v )--raw
end

function generators.string(gen,n)

	local v=format('%q',n.v)
	-- v=unescape(n.v)
	v=gsub(v,'\\\n','\\n')
	gen(v)
end

function generators.boolean(gen,b)
	gen( b.v)
end



function generators.varacc(gen,v)
	local d=v.decl
	gen:refer(d)
	gen(getDeclName(d))
	-- if d.tag=='var' and d.vtype=='const' then
	-- 	gen(getConst(d.value))
	-- else
	-- 	gen(d.name)
	-- end
end

function generators.call(gen,c)
	-- local l=codegen(c.l)
	--todo:arguments
	local tag=c.l.tag

	if tag=='closure' then
		gen'(' codegen(gen,c.l) gen')'
		gen'(' codegenList(gen,c.args) gen')'
	elseif tag=='member' then
		local mtype=c.l.mtype

		if mtype=='methodcall' then
			codegen(gen,c.l)
			gen'(' codegenList(gen,c.args) gen')'
		elseif mtype=='super' then --static call
			gen(getDeclName(c.l.decl))
			gen'( self' 
				if c.args then gen',' end
				codegenList(gen,c.args)
				gen')'
			gen:refer(c.l.decl)
		elseif mtype=='static' then
			--gen(getDeclName(c.l.decl))
			codegen(gen,c.l)
			gen'('
				codegenList(gen,c.args)
			gen')'
			-- gen:refer(c.l.decl)
		else
			error('wtf?'..mtype)
		end
	else
		gen(getDeclName(c.l.decl))
		gen'('
			codegenList(gen,c.args)
		gen')'
		gen:refer(c.l.decl)
	end
end

function generators.emit( gen,e )
	--TODO:!!!!
	gen:refer(e.signal)
	gen:appendf('%s(',getDeclName(e.signal))
	if not e.sender then 
		gen'"all"' 
	else
		codegen(gen,e.sender)
		gen:refer(e.sender)
	end
	if e.args and #e.args>0 then gen(',') end
	codegenList(gen,e.args)
	gen')'
end

function generators.spawn(gen,s)
	--TODO:!!!!!!!
	gen'__YU_SPAWN('
	codegen(gen,s.call.l)
	if s.call.args then
		gen','
		codegenList(gen,s.call.args)
	end
	gen')'
end

function generators.wait( gen,w )
	--TODO:!!!!!!!
	gen'__YU_WAIT('
	local sig=w.signal
	local sender
	if sig.tag=='emitter' then
		sender=sig.sender
		sig=sig.signal
	end
	gen:appendf('%q ,',sig.decl.fullname)
	if sender then
		codegen(gen,sender)
	else
		gen'"all"'
	end
	gen')'
end

function generators.resume( gen,r )
	gen'__YU_RESUME('
	codegen(gen,r.thread)
	gen')'
end


function generators.new(gen,n)
	gen'__YU_NEWOBJ('
		gen'{},'
		codegen(gen,n.class)
		gen:refer(n.class.decl)
		if n.constructor then 
			gen:refer(n.constructor)
			gen','
			gen(getDeclName(n.constructor))
			if n.args then 
				gen',' 
				codegenList(gen,n.args)
			end
		end
	gen')'
end

function generators.tcall( gen,n )
	gen'__YU_NEWOBJ('
		codegen(gen,n.arg)
		gen','
		codegen(gen,n.l)
	gen')'

end

function generators.binop(gen,b)
	local p=getOpPrecedence(b.op)
	
	local wrapl= b.l.tag=='binop' and getOpPrecedence(b.l.op)<p 
	local wrapr= b.r.tag=='binop' and getOpPrecedence(b.r.op)<=p
	
	
	if wrapl then 
		gen'(' 
		codegen(gen,b.l)
		gen')'
	else
		codegen(gen,b.l)
	end
		
		gen(b.op)
		
	if wrapr then 
		gen'(' 
		codegen(gen,b.r)
		gen')'
	else
		codegen(gen,b.r)
	end
	
	--TODO:operator override
end

function generators.unop(gen,u)
	gen(u.op)
	gen'('
	codegen(gen,u.l)
	gen')'
	
	--TODO:operator override
end

function generators.ternary(gen,t)
	gen'('
	
	codegen(gen,t.l)
		gen' and '
	codegen(gen,t.vtrue)
		gen' or '
	codegen(gen,t.vfalse)
	
	gen')'
end 

function generators.mulval(gen, v )
		
end

function generators.member(gen,m)
	--TODO:!!!
	local c=getConstNode(m)
	if c then return codegen(gen,c) end
	
	local mtype=m.mtype
	if mtype=='methodcall' then
		codegen(gen,m.l)
		gen(':'..m.id)
	elseif mtype=='member' then
		codegen(gen,m.l)
		gen('.'..m.id)
	elseif mtype=='static' then
		gen(getDeclName(m.decl))
		if m.l.decl then gen:refer(m.l.decl) end
		gen:refer(m.decl)
	elseif mtype=='signal' then
		gen(getDeclName(m.decl))
		gen:refer(m.decl)
	else
		error('wtf?'..mtype)
	end
end

function generators.index(gen,i)
	--TODO:!!!!
	--Todo: operator overloading
	if is(i.l.tag,'table','seq') then
		gen'('
			codegen(gen,i.l)
		gen')'
	else
		codegen(gen,i.l)
	end

	gen'[' codegen(gen,i.key) gen']'
end

function generators.table(gen,t)
	gen'{'
		codegenList(gen,t.items)
	gen'}'
end

function generators.item(gen,i)
	gen'['
	codegen(gen,i.key)
	gen']='
	codegen(gen,i.value)

end

function generators.seq(gen,t)
	gen'{'
		codegenList(gen,t.items)
	gen'}'
end

function generators.cast(gen,a)
	--TODO:!!!! add runtime typecheck
	local t=a.dst.decl
	if t.tag=='stringtype' then
		gen'tostring(' codegen(gen,a.l) gen')'
	elseif t.tag=='numbertype' then
		gen'tonumber(' codegen(gen,a.l) gen')'
	else
		gen'__YU_CAST('
			codegen(gen,a.l)
			gen','
			codegen(gen,a.dst)
		gen')'
	end
end

function generators.is(gen,i)
	gen'__YU_ISTYPE('
		codegen(gen,i.l)
		gen','
		codegen(gen,i.dst)
	gen')'
	
	
end

function generators.closure(gen,c)
	gen'function'
	gen'('
	if c.type.args then codegenList(gen,c.type.args) end
	gen')'
	codegen(gen,c.block)
	gen'end'
end

function generators.self(gen,s)
	gen'self'
end

function generators.super(gen,s)
	gen'self'
end


--------------------EXTERN
function generators.extern(gen,e)
	--TODO:!!!!
	
	for i,s in ipairs(e.decls) do
		if isExposable(s) then 	gen:expose(s) end
	end
	
end

-- function generators.externfunc(gen,f)
-- 	--TODO:!!!!
-- 	gen:cr()
-- 	gen:appendf('__YU_LOADED.%s =',f.refname)
-- 	gen:appendf('__YU_EXTERN(%q)',f.fullname)
-- end

-- function generators.externclass(gen,c)
-- 	--TODO:!!!!
-- 	return generators.classdecl(gen,c)
-- end

-- function generators.externmethod(gen,m)
-- 	--TODO:!!!!
-- 	return generators.externfunc(gen,m)
-- end
	
local function generateAllModule(m ,generated)
	generated=generated or {}
	local gen=doCodegen(m)
	local output=gen:tostring()
	generated[m]=true

	for k,mm in pairs(m.externModules) do
		if not generated[mm] then
			output=generateAllModule(mm,generated)..'\n'..output
		end
	end
	return output
end

local function generateFullCode(entry)
	local code=generateAllModule(entry)
	local header=[[
local __YU_RUNTIME=require'yu.runtime'
local __YU_CONNECT=__YU_RUNTIME.signalConnect
local __YU_SPAWN=__YU_RUNTIME.generatorSpawn
local __YU_RESUME=__YU_RUNTIME.generatorResume
local __YU_YIELD=__YU_RUNTIME.generatorYield
local __YU_WAIT=__YU_RUNTIME.signalWait
local __YU_ASSERT=__YU_RUNTIME.doAssert
local __YU_NEWOBJ=__YU_RUNTIME.newObject
local __YU_EXTERN=__YU_RUNTIME.loadExternSymbol
local __YU_OBJ_NEXT=__YU_RUNTIME.objectNext
local __YU_MODULE_LOADED, __YU_MODULE_LOADER=__YU_RUNTIME.makeSymbolTable()
local __YU_ISTYPE = __YU_RUNTIME.isType
	]]

	code=header..code
	local entrycode=string.format([[

return __YU_MODULE_LOADED[%q].__main()
	]],m.fullname)

	code=code..entrycode
	return code
end
_M.codegen=generateFullCode