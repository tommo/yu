require "yu.visitor"
require "yu.type"


local getTypeDecl,newTypeRef=yu.getTypeDecl,yu.newTypeRef

local ipairs,print=ipairs,print
local format = string.format
local makeDeclRefName=yu.makeDeclRefName
local setmetatable,getmetatable=setmetatable,getmetatable

module("yu",package.seeall)

local pre={}
local post={}

local isConst,isDecl,isGlobalDecl,isFuncDecl=isConst,isDecl,isGlobalDecl,isFuncDecl

local is,isBuiltinType=is,isBuiltinType
local function makeNamePrefix(stack,sep)
	local out=''
	for i,n in ipairs(stack) do
		out=out..n
		out=out..sep
	end
	return out
end


----------
local metamethodNames=makeStringCheckTable(
	'__new',
	'__init',
	'__gc',
	'__index',
	'__newindex',
	'__add',
	'__sub',
	'__div',
	'__mul',
	'__tostring',
	'__iter',
	'__next',
	'__gt',
	'__lt',
	'__eq'
	)


function newDeclCollector()
	
	return yu.newVisitor({
		pre=pre,
		post=post,
		
		nameStack=yu.newStack(),
		scopeStack=yu.newStack(),
		exNameStack=yu.newStack(),

		maxDeclId=0,
		maxClosureId=0,

		
		currentNamePrefix="",
		currentExNamePrefix="",

		currentScope=false,
		currentScopeLevel=0,

		-- currentN

		depth=0,
		
		pushName=function(self,name)
			local n
			if self.currentNamePrefix~='' then
				n=name..'_'..self.currentNamePrefix
			else
				n=name
			end
			self.currentNamePrefix=n
			return self.nameStack:push(n)
		end,
		
		popName=function(self)
			local n=self.nameStack:pop() or ''
			self.currentNamePrefix=n
			return n
		end,

		pushExternName=function(self,name)
			local n
			if self.currentExNamePrefix~='' then
				n=self.currentExNamePrefix..'.'..name
			else
				n=name
			end

			self.currentExNamePrefix=n
			return self.exNameStack:push(n)
		end,
		
		popExternName=function(self)
			local n=self.exNameStack:pop() or ''
			self.currentExNamePrefix=n
			return n
		end,

		genDeclId=function( self )
			local id=self.maxDeclId
			self.maxDeclId=id+1
			return id
		end,

		genClosureId=function( self )
			local id=self.maxClosureId
			self.maxClosureId=id+1
			return id
		end,

		pushScope=function(self)
			local mt={}
			local scope=setmetatable({},mt)
			self.scopeStack:push(scope)
			
			mt.parentScope=self.currentScope
			mt.node=self.currentNode

			self.currentScope=scope
			self.currentNode.scope=scope
			self.currentNode.scopeLevel=self.currentScopeLevel
			self.currentScopeLevel=self.currentScopeLevel+1
			return scope
		end,
		
		popScope=function(self)
			self.currentScope=self.scopeStack:pop()
			self.currentScopeLevel=self.currentScopeLevel-1
			return self.currentScope
		end,
		
		addEachDecl=function(self,list, parent)
			for i,n in ipairs(list) do
				local tag=n.tag
				if isDecl(n) then
					self:addDecl(n) 
				elseif tag=="public" or tag=="private" then 
					self:addDecl(n) 
				elseif tag=='import' then
					if not n.ishead then
						self:err('import must be in head of source', n)
					end
				 	if n.alias then
						n.type=moduleMetaType
						self:addDecl(n)
						parent.module.namedExternModule[n.mod]=true
					end
				end
			end
		end,
		
		addDecl=function(self,decl,inclass)
			local currentScope=self.currentScope
			-- 
			if isBuiltinType(decl.name) then
				self:err(decl.name..' is builtin type',decl,self.currentModule)
			end

			if inclass then
				if metamethodNames[decl.name] then
					if decl.tag~='methoddecl' then
						self:err(format('%q is reserved for metamethod',decl.name),decl)
					else
						decl.metamethod=true
					end
				end
			end

			
			local tag=decl.tag
			if tag=="vardecl" then
				local meta=decl.meta
				for i,var in ipairs(decl.vars) do
					var.vtype=decl.vtype
					var.extern=decl.extern
					if meta then var.meta=meta end
					self:addDecl(var,inclass)
				end
				return
			end
			
			if tag=="private" then
				getmetatable(currentScope).private=true
				return
			elseif tag=="public" then
				getmetatable(currentScope).private=false
				return
			end
	
			if tag=="import" then
				decl.name=decl.alias
			end
			--TODO:check for internal method name like '__new','__add','__next'
			
			local scope=currentScope
			decl.private=getmetatable(scope).private
			
			local name=decl.name
			local decl0=scope[name]
			
			if decl0 then  --duplicated?
				-- local tag0=decl0.tag
				-- if tag==tag0 then 
				-- 	if decl0.private ~= decl.private then
				-- 		self:err('function overload must be both private or public',decl)
				-- 	end
				-- 	--TODO:duplicated overloading
				-- 	local dd=decl0
				-- 	local n=1
				-- 	while true do
				-- 		local d1=dd.nextProto
				-- 		if not d1 then
				-- 			dd.nextProto=decl
				-- 			break
				-- 		end
				-- 		n=n+1
				-- 		dd=d1
				-- 	end
				-- 	decl.protoId=n
				-- else
					return self:err(
						"duplicated declaration:'"..decl.name
						.."',first defined:"
						..getTokenPosString(decl0,self.currentModule)
						,decl,self.currentModule)	
				-- end
				
			else
				scope[decl.name]=decl
			end
	
			decl.declId=self:genDeclId()
			decl.refname=makeDeclRefName(decl,decl.declId)

			if decl.alias then
				decl.fullname=decl.alias
			else			
				decl.fullname=name..'_'..self.currentNamePrefix
			end

			if decl.extern then
				local p=self.currentExNamePrefix
				if p~='' then p=p..'.' end
				decl.externname=p..name
			end

			if decl.protoId then
				decl.fullname=decl.fullname..'_p'..decl.protoId
			end

			decl.depth=self.depth
		end
		
		}
	)
end


-------------
function pre.any(vi,n)
	n.module=vi.currentModule 
end

function pre.module(vi,m)
	-- vi:pushScope()
	-- vi:pushName(m.name)

	vi.currentModule=m
	m.module=m
	m.namedExternModule={}

end

function post.module(vi,m)
	--todo: extract decls from main block scope rather than refer to it directly
	m.fullname=m.name
	m.mainfunc.fullname='@main'
	m.mainfunc.refname='@main'
	m.mainfunc.name='@main'	

	local expose={}
	for k,decl in pairs(m.mainfunc.block.scope) do
		if k~='private'	then
			if isGlobalDecl(decl) then
				expose[k]=decl
			end
		end
	end
	m.scope=expose
	m.maxDeclId=vi.maxDeclId
	m.externalRefers={}
	m.externalReferNames={}
	
end

---------------

function pre.block(vi,b,parent)
	-- if not is(parent.tag,'funcdecl','methoddecl','forstmt','catch','foreachstmt')
		-- b.scope=vi:pushScope()
	-- end
	vi:addEachDecl(b, parent)
end

function post.block(vi,b)
	-- vi:popScope()
end

function pre.dostmt(vi,d)
	vi:pushScope()
end

function post.dostmt(vi,d)
	vi:popScope()
end

-----------

function pre.extern(vi,e)
	for i,s in ipairs(e.decls) do
		if isDecl(s) or is(s.tag,"public","private") then 
			vi:addDecl(s)
		end
	end
end

-----------


local function spreadVarTypes(vars,forceType,visitor)
	local lasttype=nil
	for i=#vars,1,-1 do
		local var=vars[i]
		if var.type then
			lasttype=var.type
		elseif lasttype then
			var.type=lasttype
		elseif forceType then
			return visitor:err("type identifier expected",var)
		end
	end
end




function pre:vardecl(vd)
	local vars,values=vd.vars,vd.values
	local varcount,valcount=#vars,values and #values or 0
	local mulval=false

	if values and vd.extern and vd.vtype~='const' then
		return self:err('cannot assign initial value for extern variable',vd)
	end

	if values and varcount>valcount then
		if is(values[#values].tag,'call','wait') then 
			mulval=true  --might be mul value
		else
			return self:err('too less values in variable declaration',vd)
		end
	elseif varcount<valcount then
		return self:err('too many values in variable declaration',vd)
	end

	if vd.def then --should no type id
		for i,var in ipairs(vars) do
			if var.type then return self:err("unnecessary type identifier",var.type) end
		end

		for i = 1, valcount do
			local var=vars[i]
			local v=values[i]
			var.value=v
			var.type=newTypeRef(v)
		end
		if varcount>valcount then
			local lastval=values[valcount]
			for i = valcount+1, varcount do
				local var=vars[i]
				local v={tag='mulval',src=lastval,idx=i-valcount}
				var.value=v
				var.type=newTypeRef(v)
			end
		end
		
	else
		spreadVarTypes(vars,not values,self)
		
		if values then
			for i = 1, valcount do
				local var=vars[i]
				local v=values[i]
				var.value=v
				if not var.type then var.type=newTypeRef(v) end
			end
			if varcount>valcount then
				local lastval=values[valcount]
				for i = valcount+1, varcount do
					local var=vars[i]
					local v={tag='mulval',src=lastval,idx=i-valcount}
					var.value=v
					if not var.type then var.type=newTypeRef(v) end
				end
			end
		end
		
	end
	return true
end



function pre.funcdecl(vi,f)
	if f.name~='@main' then vi:pushName(f.name,true) end
	vi:pushScope()
	vi.depth=vi.depth+1
end

function post.funcdecl(vi,f)
	vi:popScope()
	if f.block then 
		f.block.scope=f.scope
		f.block.scopeLevel=f.scopeLevel
		f.scope=nil
		f.scopeLevel=nil
	end
	vi:popName()
	vi.depth=vi.depth-1
end

function pre.closure(vi,f)
	f.name='C'
	vi:pushName(f.name,true)
	vi:pushScope()
end

function post.closure(vi,f)
	vi:popScope()
	vi:popName()
end


-----------
function pre.methoddecl(vi,f,parent)
	vi:pushName(f.name)
	vi:pushScope()
	vi.depth=vi.depth+1
end

function post.methoddecl(vi,f)
	vi:popScope()
	vi:popName()
	vi.depth=vi.depth-1
end

------------




function pre.functype(vi,ft)
	local args=ft.args
	if args then
		--spread arg types:
		local lastType=nil
		for i=#args,1,-1 do
			local arg=args[i]
			if not arg.type then --check default value firstt
				if arg.value then
					arg.type=newTypeRef(arg.value)
				elseif lastType then
					arg.type=lastType
				else
					vi:err('argument type expected '..i,arg)
				end
			end
			lastType=arg.type
		end

		local prevHasDefault=false
		for i,arg in ipairs(args) do			

			if arg.value then
				prevHasDefault=true
			elseif prevHasDefault and arg.name~='...' then
				vi:err('non-optional argument follows optional argument', arg)
			end


			if not ft.typeonly then
				vi:addDecl(arg)
			end
			arg.argId=i
			if arg.name=='...' then
				if i<#args then	vi:err('vararg should only appear at the end',arg) end
				arg.type={tag='vararg',type=arg.type}
			end
		end
	end
	
end

function post.functype(vi,ft)

end

function pre.tabletype( vi,tt )
	if tt.ktype=='empty' then tt.ktype=numberType end
	tt.valuetype=true
end

function pre.signaldecl( vi,sig )
	local args=sig.args
	if args then
		spreadVarTypes(args,true,vi)
		for i,arg in ipairs(args) do
			if arg.name=='...' then
				if i<#args then	vi:err('vararg should only appear at the end',arg) end
				arg.type={tag='vararg',type=arg.type}
			end
		end
	end
end



------------
function pre.catch(vi,c)
	vi:pushScope()
	for i,v in ipairs(c.vars) do
		vi:addDecl(v)
	end
end

function post.catch(vi,c)
	vi:popScope()
end

------------
function pre.foreachstmt(vi,f)
	vi:pushScope()
	
	for i,v in ipairs(f.vars) do
		v.vtype='local'
		vi:addDecl(v)
	end	
end

function post.foreachstmt(vi,f)
	spreadVarTypes(f.vars,false,vi)
	for i,v in ipairs(f.vars) do
		if not v.type then --make typeref
			local val={tag='mulval',src=f.iterator,idx=i-1}
			v.type=newTypeRef(val)
			v.value=val
		end
	end	
	vi:popScope()
end


function pre.forstmt(vi,f)
	vi:pushScope()
	f.var.type=numberType
	f.var.vtype='local'
	vi:addDecl(f.var)
end

function post.forstmt(vi,f)
	vi:popScope()
end

function pre.whilestmt( vi,f )
	vi:pushScope()
end
function post.whilestmt( vi,f )
	vi:popScope()
end

function pre.cyclestmt( vi,f )
	vi:pushScope()
end
function post.cyclestmt( vi,f )
	vi:popScope()
end

function pre.repeatstmt( vi,f )
	vi:pushScope()
end
function post.repeatstmt( vi,f )
	vi:popScope()
end



function pre.classdecl(vi,c)
	c.type=classMetaType
	c.valuetype=true
	vi:pushName(c.alias or c.name)
	if c.extern then 
		for i,d in ipairs(c.decls) do
			d.extern=true
		end
		vi:pushExternName(c.alias or c.name)
	end
	vi:pushScope()
	vi.depth=vi.depth+1
end

function post.classdecl(vi,c)
	if c.tvars then
		for i,v in ipairs(c.tvars) do
			vi:addDecl(v)
		end	
	end
	
	if c.decls then
		for i,d in ipairs(c.decls) do
			vi:addDecl(d,true)			
		end
		if not vi.currentScope['__init'] then
			for k,d in pairs(vi.currentScope) do
				if d.vtype=='field' and d.value then 
				--has default value, 
				--create a empty initializer container, fill it in resolver
					local loader={
						tag='methoddecl',
						type={tag='functype',args={},rettype=voidType},
						name='__init',
						block={tag='block'},
						module=vi.currentModule
					}
					table.insert(c.decls,loader)
					vi:addDecl(loader,true)

					break
				end
			end

		end
	end

	vi:popScope()
	vi:popName()
	if c.extern then vi:popExternName(c.name) end
	vi.depth=vi.depth-1
	

end


---
function pre.enumdecl(vi,e)
	vi:pushName(e.name)
	vi:pushScope()
	
	for i,ei in ipairs(e.items) do
		vi:addDecl(ei)
	end
	
end

function post.enumdecl(vi,c)
	vi:popScope()
	vi:popName()

end

-- function pre:signaldecl(s)
-- 	s.type=
-- end

function post.varacc(vi,a)
	a.scope=vi.currentScope
end