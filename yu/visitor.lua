
require "yu.utils"

module("yu",package.seeall)

local visitor={}
local paths

local is,isConst=yu.is,yu.isConst
local ipairs,pairs,getmetatable=ipairs,pairs,getmetatable
local _doVisitCallback

local function pushStack(self,d)
		local count=self.count
		self[count+1]=d
		self.count=count+1
		return d
	end
	
local function popStack(self)
		local l=self.count
		self[l]=nil
		self.count=l-1
		return self[l-1]
	end

local function visitNode(vi,n,list)
	-- local vit=getmetatable(vi)
	-- if not vit or  vit.__index~=visitor then
	-- 	print(vi,vit)
	-- 	error("Internal error!")
	-- end
	local stack=vi.nodeStack
	
	local parentNode=vi.currentNode
	vi.currentNode=pushStack(stack,n)
	
	--spread token info
	if not n.p0 and parentNode then
		n.p0=parentNode.p0
		n.p1=parentNode.p1
		n.module=parentNode.module
	end

	local callback	
	local tag=n.tag
	local pre,post=vi.pre,vi.post

		callback=pre['any']
		if callback and _doVisitCallback(vi,n,list,parentNode,callback) then return true end	
		
		callback=pre[tag]
		if callback and _doVisitCallback(vi,n,list,parentNode,callback) then return true end	
	
	local p=paths[tag]		
	if p then 
		p(vi,n) 
	elseif p==nil then
		error("no visit path for "..tag) 
	end 
		
		local callback=post[tag]
		if callback and _doVisitCallback(vi,n,list,parentNode,callback) then return true end	
		
		callback=post['any']
		if callback and _doVisitCallback(vi,n,list,parentNode,callback) then return true end	
		
	
	vi.currentNode=popStack(stack)
	
	return true
end

local function visitEachNode(vi,l)
	-- local vit=getmetatable(vi)
	-- if not vit or  vit.__index~=visitor then
	-- 	print(vi,vit)
	-- 	error("Internal error!")
	-- end
	if not l then return end
	for i=1,#l do
		visitNode(vi,l[i],l)
	end
	-- for i,n in ipairs(l) do
	-- 	visitNode(vi,n,l)
	-- end
end

local function overwriteTable(t1,t2) --t2 -> t1
	for k in pairs(t1) do
		t1[k]=nil
	end
	for k,v in pairs(t2) do
		t1[k]=v
	end
end

_doVisitCallback= function (vi,n,list,parentNode,callback,callback2)
	local msg,data=callback(vi,n,parentNode)
	if msg=='replace' then

		data.p0=n.p0
		data.p1=n.p1
		data.module=n.module
		data.scope=n.scope
		overwriteTable(n,data)

		vi.currentNode=popStack(vi.nodeStack)
		visitNode(vi,n,list)
		return true 
		
	elseif msg=='skip' then
		vi.currentNode=popStack(vi.nodeStack)
		return true
	end
	return false
end


function newVisitor(data)
	data=data or {}
	data.nodeStack=yu.newStack()

	data.currentNode=false
	data.currentBlock=false
	data.currentFunc=false
	data.pre=data.pre or {}
	data.post=data.post or {}
	return setmetatable(data,{__index=visitor})
end

visitor.visitNode=visitNode
visitor.visitEachNode=visitEachNode



function visitor:err(msg,token,module)
	return yu.compileErr(msg,token,module or self.currentModule)
end

function visitor:getParentNode()
	return self.nodeStack:peek(1)
end

function visitor:findParentLoop()
	local s=self.nodeStack
	for i=s.count,1,-1 do
		local n=s[i]
		local t=n.tag
		if t=='whilestmt' or t=='repeatstmt' or t== 'forstmt' or t=='foreachstmt' or t=='cyclestmt'  then return n end
		if t=='funcdecl' or t=='methoddecl' then break end
	end
	return nil
end

function visitor:findParentClass()
	local s=self.nodeStack
	for i=s.count,1,-1 do
		local n=s[i]
		local t=n.tag
		if t=='classdecl' then return n end
		if t=='funcdecl' and not n.localfunc then break end
	end
	return nil
end


function visitor:findParentFunc()
	local s=self.nodeStack
	for i=s.count,1,-1 do
		local n=s[i]
		local t=n.tag
		if t=='funcdecl' or t=='methoddecl' or t=='closure' then return n end
	end
	return nil
end

function visitor:findParentMethod()
	local s=self.nodeStack
	for i=s.count,1,-1 do
		local n=s[i]
		local t=n.tag
		if t=='methoddecl' then return n end
	end
	return nil
end

paths={
	module=function(vi,m)
		local lastModule=vi.currentModule
		vi.currentModule=m
		visitNode(vi,m.mainfunc)
		vi.currentModule=lastModule
	end,
	
	block=function(vi,b)
		local pb=vi.currentBlock
		vi.currentBlock=b
		visitEachNode(vi,b)
		vi.currentBlock=pb
	end,
	
	import=function(vi,im)
		--TODO:...
	end,
	
	private=false,
	public=false,
	rawlua=false,
	
	typeref=false,
	
	ttype=function(vi,tt)
		return visitEachNode(vi,tt.args)
	end,
	
	type=function(vi,t)
		--TODO:...
	end,
	
	tabletype=function(vi,t)
		if t.ktype then visitNode(vi,t.ktype) end
		return visitNode(vi,t.etype)
	end,
	
	functype=function(vi,ft)
		if ft.args then visitEachNode(vi,ft.args) end
		if ft.rettype then 
			return visitNode(vi,ft.rettype)
		end
	end,
	
	mulrettype=function(vi,mr)
		return visitEachNode(vi,mr.types)
	end,

	vararg=function( vi,va )
		return visitNode(vi,va.type)
	end,
	
	dostmt=function(vi,d)
		return visitNode(vi,d.block)
	end,
	
	ifstmt=function(vi,i)
		visitNode(vi,i.cond)
		visitNode(vi,i.body.thenbody)
		if i.body.elsebody then return visitNode(vi,i.body.elsebody) end
	end,
	
	switchstmt=function(vi,s)
		visitNode(vi,s.cond)
		if s.default then visitNode(vi,s.default) end
		return visitEachNode(vi,s.cases)
	end,
	
	case=function(vi,c)
		visitEachNode(vi,c.conds)
		return visitNode(vi,c.block)
	end,
	
	returnstmt=function(vi,r)
		if r.values then return visitEachNode(vi,r.values) end
	end,
	
	yieldstmt=function(vi,y)
		if y.values then return visitEachNode(vi,y.values) end
	end,
	
	forstmt=function(vi,f)
		visitEachNode(vi,f.range)
		visitNode(vi,f.var)
		return visitNode(vi,f.block)
	end,
	
	foreachstmt=function(vi,f)
		visitNode(vi,f.iterator)
		visitEachNode(vi,f.vars)
		return visitNode(vi,f.block)
	end,

	iterator =function( vi,i )
		return visitNode(vi,i.expr)
	end,
	
	whilestmt=function(vi,w)
		visitNode(vi,w.cond)
		return visitNode(vi,w.block)
	end,

	repeatstmt=function(vi,r)
		visitNode(vi,r.block)
		return visitNode(vi,r.cond)
	end,
	
	continuestmt=false,
	breakstmt=false,
	
	trystmt=function(vi,t)
		visitNode(vi,t.block)
		visitEachNode(vi,t.catches)
		if t.final then return visitNode(vi,t.final) end
	end,
	
	throwstmt=function(vi,t)
		return visitEachNode(vi,t.values)
	end,

	assertstmt=function(vi,t)
		visitNode(vi,t.expr)
		if t.exception then return visitNode(vi,t.exception) end
	end,
	
	catch=function(vi,c)
		visitEachNode(vi,c.vars)
		return visitNode(vi,c.block)
	end,
	
	assignstmt=function(vi,a)
		visitEachNode(vi,a.vars)
		return visitEachNode(vi,a.values)
	end,
	
	assopstmt=function(vi,a)
		visitNode(vi,a.var)
		return visitNode(vi,a.value)
	end,
	
	batchassign=function(vi,a)
		visitNode(vi,a.var)
		--TODO!!!
		return visitEachNode(vi,a.values)
	end,

	connectstmt=function(vi,c)
		visitNode(vi,c.signal)
		return visitNode(vi,c.slot)
	end,
	
	exprstmt=function(vi,e)
		return visitNode(vi,e.expr)
	end,
	
	vardecl=function(vi,vd)
		visitEachNode(vi,vd.vars)
		if vd.values then return visitEachNode(vi,vd.values) end
	end,

	-- upvalue=false,
	
	tvar=function(vi,v)
		---TODO
	end,
	
	var=function(vi,v)
		if v.type then visitNode(vi,v.type) end
		if v.value then return visitNode(vi,v.value) end
	end,
	
	arg=function(vi,v)
		if v.type then visitNode(vi,v.type) end
		if v.value then return visitNode(vi,v.value) end
	end,
	
	enumdecl=function(vi,e)
		return visitEachNode(vi,e.items)
	end,
	
	enumitem=function(vi,v)
		if v.value then return visitNode(vi,v.value) end
	end,
	
	classdecl=function(vi,c)
		if c.tvars then
			visitEachNode(vi,c.tvars)
		end
		if c.decls then
			return visitEachNode(vi,c.decls)
		end
	end,
	
	methoddecl=function(vi,m)
		local pf=vi.currentFunc
		vi.currentFunc=m
		
		visitNode(vi,m.type)
		if m.block then visitNode(vi,m.block) end
		
		vi.currentFunc=pf
	end,
	
	funcdecl =function(vi,f)
		local pf=vi.currentFunc
		vi.currentFunc=f
		
		visitNode(vi,f.type)
		if not f.extern then visitNode(vi,f.block) end
		
		vi.currentFunc=pf
	end,
	
	exprbody=function(vi,e)
		return visitEachNode(vi,e.exprs)
	end,

	signaldecl=function(vi,s)
		return visitEachNode(vi,s.args)
	end,
	
	varacc=false,
	
	call=function(vi,c)
		visitNode(vi,c.l)
		if c.args then return  visitEachNode(vi,c.args) end
	end,

	tcall=function(vi,c)
		visitNode(vi,c.l)
		visitNode(vi,c.arg)
	end,

	emit=false,

	spawn=function(vi,s)
		return visitNode(vi,s.call)
	end,

	resume=function ( vi,r )
		return visitNode(vi,r.thread)
	end,

	wait=function( vi,w )
		return visitNode(vi,w.signal)
	end,

	emitter=function( vi,e )
		visitNode(vi,e.l)
		return visitNode(vi,e.signal)
	end,
	
	binop=function(vi,b)
		visitNode(vi,b.l)
		return visitNode(vi,b.r)
	end,
	
	unop=function(vi,u)
		return visitNode(vi,u.l)
	end,
	
	ternary=function(vi,t)
		visitNode(vi,t.l)
		visitNode(vi,t.vtrue)
		return visitNode(vi,t.vfalse)
	end,
	
	mulval=false, --job are taken by first expression

	member=function(vi,m)
		return visitNode(vi,m.l)
	end,
	
	index=function(vi,i)
		visitNode(vi,i.l)
		if i.key then return visitNode(vi,i.key) end
	end,
	
	table=function(vi,t)
		if t.items then
			return visitEachNode(vi,t.items)
		end
	end,
	
	item=function(vi,i)
		visitNode(vi,i.key)
		return visitNode(vi,i.value)
	end,
	
	seq=function(vi,t)
		if t.items then
			return visitEachNode(vi,t.items)
		end
	end,
	
	cast=function(vi,a)
		visitNode(vi,a.l)
		return visitNode(vi,a.dst)
	end,
	
	is=function(vi,a)
		visitNode(vi,a.l)
		return visitNode(vi,a.dst)
	end,
	
	closure=function(vi,c)
		visitNode(vi,c.type)
		return visitNode(vi,c.block)
	end,
	
	self=false,
	super=false,
	
	extern=function(vi,ex)
		return visitEachNode(vi,ex.decls)
	end,
	
	-- externfunc=function(vi,f)
	-- 	return visitNode(vi,f.type)
	-- end,
	
	-- externclass=function(vi,c)
	-- 	if c.decls then
	-- 		return visitEachNode(vi,c.decls)
	-- 	end
	-- end,
	
	-----------TYPES
	voidtype=false,
	numbertype=false,
	stringtype=false,
	booleantype=false,
	new=false,

	-----constant
	number=false,
	boolean=false,
	string=false,
	['nil']=false
}

