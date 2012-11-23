require "yu.visitor"
require "yu.type"


local getTypeDecl,newTypeRef=yu.getTypeDecl,yu.newTypeRef

local ipairs,print=ipairs,print
local format = string.format
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

local declPrefix={
	funcdecl='F',
	methoddecl='F',
	classdecl='C',
	module='M',
	signaldecl='S',
}
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

		-- currentN

		depth=0,
		
		pushName=function(self,name)
			local n=self.currentNamePrefix..name
			self.currentNamePrefix=n
			return self.nameStack:push(n)
		end,
		
		popName=function(self)
			local n=self.nameStack:pop() or ''
			self.currentNamePrefix=n
			return n
		end,

		pushExternName=function(self,name)
			local n=self.currentExNamePrefix..name
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
			local scope={}
			self.scopeStack:push(scope)
			self.currentScope=scope
			self.currentNode.scope=scope
			return scope
		end,
		
		popScope=function(self)
			self.currentScope=self.scopeStack:pop()
			return self.currentScope
		end,
		
		addEachDecl=function(self,list)
			for i,n in ipairs(list) do
				local tag=n.tag
				if isDecl(n) or (tag=="public" or tag=="private") then 
					self:addDecl(n) 
				end
			end
		end,
		
		addDecl=function(self,decl,inclass)
			local currentScope=self.currentScope
			
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
					if meta then var.meta=meta end
					self:addDecl(var,inclass)
				end
				return
			end
			
			if tag=="private" then
				currentScope.private=true
				return
			elseif tag=="public" then
				currentScope.private=false
				return
			end
	
			if tag=="import" then
				decl.name=decl.alias
			end
			--TODO:check for internal method name like '__new','__add','__next'
			
			local scope=currentScope
			decl.private=scope.private
			
			local name=decl.name
			local decl0=scope[name]
			
			if decl0 then  --duplicated?
				local tag0=decl0.tag
				if tag==tag0 then 
					if decl0.private ~= decl.private then
						self:err('function overload must be both private or public',decl)
					end
					--TODO:duplicated overloading
					local dd=decl0
					local n=1
					while true do
						local d1=dd.nextProto
						if not d1 then
							dd.nextProto=decl
							break
						end
						n=n+1
						dd=d1
					end
					decl.protoId=n
				else
					return self:err(
						"duplicated declaration:'"..decl.name
						.."',first defined:"
						..getTokenPosString(decl0,self.currentModule)
						,decl,self.currentModule)	
				end
				
			else
				scope[decl.name]=decl
			end
			--
			--
			decl.declId=self:genDeclId()
			decl.refname=decl.name..'_'..(declPrefix[decl.tag] or 'v')..decl.declId
			-- decl.refname='_'..(declPrefix[decl.tag] or 'v')..decl.declId

			if decl.alias then
				decl.fullname=decl.alias
			elseif decl.extern then
				decl.fullname=self.currentExNamePrefix..'.'..name	
			else
				decl.fullname=self.currentNamePrefix..'.'..name
			end

			if decl.protoId then
				decl.fullname=decl.fullname..'_p'..decl.protoId
			end					

			decl.depth=self.depth
			-- print("..added decl:",decl.tag,decl.name,decl.fullname,decl.vtype)
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
	vi:pushName(m.name)
	vi.currentModule=m
	m.module=m
end

function post.module(vi,m)
	vi:popName()
	-- vi:popScope()
	--todo: extract decls from main block scope rather than refer to it directly
	m.fullname=m.name
	m.mainfunc.fullname='__main'
	m.mainfunc.refname='__main'
	local expose={}
	for k,decl in pairs(m.mainfunc.block.scope) do
		if isGlobalDecl(decl) then
			expose[k]=decl
		end
	end
	m.scope=expose
end

---------------

function pre.block(vi,b,parent)
	-- if not is(parent.tag,'funcdecl','methoddecl','forstmt','catch','foreachstmt')
		-- b.scope=vi:pushScope()
	-- end
	vi:addEachDecl(b)
	if parent.tag=='module' then -- top block? add named imported module into scope
		for i,h in ipairs(parent.heads) do
			if h.tag=='import' and h.alias then
				h.type=moduleMetaType
				vi:addDecl(h)
			end
		end
	end
	
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
	if f.name~='__main' then vi:pushName(f.name,true) end
	vi:pushScope()
	vi.depth=vi.depth+1
end

function post.funcdecl(vi,f)
	vi:popScope()
	if f.block then 
		f.block.scope=f.scope
		f.scope=nil
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
	if f.abstract then 
		parent.abstract=true
	end
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
		spreadVarTypes(args,true,vi)
		if not ft.typeonly then
			for i,arg in ipairs(args) do
				vi:addDecl(arg)
				if arg.name=='...' then
					if i<#args then	vi:err('vararg should only appear at the end',arg) end
					arg.type={tag='vararg',type=arg.type}
				end
			end
		end
	end
	
end

function post.functype(vi,ft)

end

function pre.tabletype( vi,tt )
	if tt.ktype=='empty' then tt.ktype=numberType end
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
	if c.extern then vi:pushExternName(c.alias or c.name) end
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
