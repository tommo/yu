require "yu.visitor"
require "yu.type"

local format=string.format

module("yu")

local is,isTypeDecl,isBuiltinType=is,isTypeDecl,isBuiltinType
local getType,getOneType,getTypeDecl,newTypeRef,checkType
	=getType,getOneType,getTypeDecl,newTypeRef,checkType
local getExprTypeList=getExprTypeList

local pre={}
local post={}

local __searchSeq=0 

local function _findExternSymbol(entryModule,name,found)
	found=found or {}
	local externModules=entryModule.externModules
	
	if externModules then
		for p,m in pairs(externModules) do
			if m.__seq~=__searchSeq then
				m.__seq=__searchSeq
				-- print(m.name,m.mainfunc.block.scope)
				local decl=m.scope[name]
				if decl and not decl.private then 
					found[#found+1]={module=m,decl=decl}
				end
				_findExternSymbol(m,name,found)
			end
		end
	end
	
	return found
end

local function _findSymbol(vi,name,token,limit)
	if isBuiltinType(name) then
		return getBuiltinType(name)
	end
	local t=vi.nodeStack
	local outClas,outFunc,outMethod=0,0,0

	for i=t.count,1,-1 do
		local node=t[i]
		local tag=node.tag
		local scope=node.scope
		if scope then
			local decl
			if tag=='classdecl' then
				local clas=node
				while clas do
					decl=clas.scope[name]
					if decl then break end
					clas=clas.superclass
				end
			else
				decl=scope[name]
			end
			
			local found=false
			if decl then 
				-- print('found:',scope,decl.name,decl.tag,node.name,decl.p0,token.p0,tag)
				if not (
						(limit=='global' and isMemberDecl(decl)) 
				) then
					local dtag=decl.tag
					if dtag=='var' then --variable?
						if decl.vtype=='local' then --local?
							if  decl.p0<token.p0 and decl.resolveState=='done' 
								and not (outFunc>0 and limit~='upvalue') then 
								found=true
							end
						elseif decl.vtype=='field' then
							if outMethod==1 then found=true end 
						else
							found=true
						end
					elseif dtag=='methoddecl' then
						if outMethod==1 then found=true end 
					elseif dtag=='funcdecl' and decl.localfunc then
						if  decl.p0<token.p0 and decl.resolveState=='done' 
							and not (outFunc>0 and limit~='upvalue') then 
							found=true
						end
					else
						found=true
					end
					
				end
			end
			if found then return decl end
		end

		if tag=='funcdecl' or tag=='closure' then outFunc =outFunc +1 end
		if tag=='classdecl' then outClas =outClas +1 end
		if tag=='methoddecl' then outMethod =outMethod +1 outFunc =outFunc +1 end
	end
	
	--search extern modules
	__searchSeq=__searchSeq+1
	
	if not token.module then
		-- print(token.tag)
	end
	
	local found=_findExternSymbol(token.module,name)
	
	local i=0
	local foundCount=#found
	if foundCount>1 then
		msg='multiple declaration found:'..name..'\n'
		for i,f in pairs(found) do
			msg=msg..getTokenPosString(f.decl)..'\n'
		end
		return vi:err(msg,token)
		
	elseif foundCount==1 then
		return found[1].decl
	end
	
	return nil
end

function newResolver()
	local r={	
				pre=pre,
				post=post,
				findSymbol=_findSymbol
			}
	return yu.newVisitor(r)
end

	local function makeFuncTypeName( ft )
		local rt=ft.rettype
		local argname=''
		for i,arg in ipairs(ft.args) do
			if i>1 then argname=argname..',' end
			argname=argname..getType(arg).name
		end
		local fname=ft.method and 'method' or 'func'
		local name=format('%s(%s)',fname,argname)
		if rt.name~='void' then
			name=name..'->'..rt.name
		end
		ft.name=name
	end

	local function makeMulRetTypeName( mt )
		local n=''
		for i,t in ipairs(mt.types) do			
			if i>1 then n=n..',' end
			n=n..t.name
		end
		mt.name='('..n..')'
	end

----------------TOPLEVEL
	function pre:any(n)
		-- print('resoving..',n.tag,n.name or n.id)
		local state=n.resolveState
		if state=='done' then 
			return 'skip'
		elseif state=='resolving' then
			self:err('cyclic declaration dependecy',n)
		end
		
		n.resolveState='resolving'
		
		local b=self.currentBlock
		if b and b.endState then
			self:err('unreachable statement',n)
		end
		
	end
	
	function post:any(n)
		n.resolveState='done'
	end
	
	function pre:module(m)
		m.resolving=true
	end
	
	function post:module(m)
	end
	
	-- function pre:block(b)
		
	-- end
	
	-- function post:block(b)
		
	-- end
	
---------------Directive
	-- function post:import(im)
		-- local m=im.mod
		-- --TODO!
	-- end
	
	-- function post:private()
		-- return true
	-- end
	
	-- function post:public()
		-- return true
	-- end
	
	function post:rawlua(r)
		local f,err=loadstring(r.src)
		if not f then
			self:err('error in Lua code:'..err,r)
		end
	end
	
	------------------------------CONTROL
	local stmtExprTable=makeStringCheckTable('new','call','wait','resume','emit')
	function post:exprstmt(e) 
		local expr=e.expr
		if not stmtExprTable[expr.tag] then
			self:err("only call/emit/wait/resume expression can be used as statement, given "..expr.tag,e)
		end
	end

	
	function post:continuestmt(c)
		local l=self:findParentLoop()
		if not l then
			self:err("'continue' must be inside loop block",c)
		end
		l.hasContinue=true
		self.currentBlock.endState=true
		return true
	end

	function post:breakstmt(b)
		local l=self:findParentLoop()
		if not l then
			self:err("'break' must be inside loop block",b)
		end
		l.hasBreak=true
		self.currentBlock.endState=true
		return true
	end
	
	function post:returnstmt(r)
		local f=self:findParentFunc()
		if not f then 
			self:err("'return'/'yield' should be inside function",r)
		end
		if r.tag~='yieldstmt' then
			self.currentBlock.endState=true
		end
		local rettype=getTypeDecl(f.type.rettype)
		
		if r.values then
			for i, v in ipairs(r.values) do
				if v.decl and v.decl.name=='...' then self:err('cannot return a vararg',v) end
			end

			if rettype==voidType then
				if not (#r.values==1 and getType(r.values[1])==voidType) then
					self:err('function should return no value',r)
				end
			elseif rettype.tag=='mulrettype' then
				f.hasReturn=true
				local etypes,mulret=getExprTypeList(r.values)
				local rtypes=rettype.types
				if #etypes~=#rtypes then
					self:err(format('expecting %d return values, given %d',#rtypes,#etypes),r)
				end
				for i, et in ipairs(etypes) do
					rt=rtypes[i]
					if not checkType(rt,'>=',et) then
						self:err(
							format('return type mismatch, expecting %s, given %s ',rt.name,et.name),
							r.values[i>#r.values and #r.values or i])
					end
				end
			else
				f.hasReturn=true
				if #r.values>1 then
					self:err('unexpected return value',r.values[2])
				end
				local rt=getType(r.values[1])
				if not checkType(rettype,'>=',rt) then
					self:err('return type mismatch:'..rettype.name..'<-'..rt.name,r.values[1])
				end
			end
		elseif rettype~=voidType then
			self:err('return value expected',r)
		end
		
		return true
	end
	
	function post:yieldstmt(y,p)
		return post.returnstmt(self,y,p)
	end
	
	-- function post:dostmt(d)
		-- return true
	-- end
	
	function post:ifstmt(s)
		s.cond=convertToBool(s.cond,self)
		self:visitNode(s.cond)
		return true
	end

	function post:switchstmt(s)
		local condtype=getType(s.cond)
		
		for i,c in ipairs(s.cases) do
			for i,v in ipairs(c.conds) do 
				if not checkType(condtype,'>=',getType(v)) then
					self:err('case expression type mismatch',v)
				end
			end
		end
		
		return true
	end
	
	-- function post:case(c)
		-- return true
	-- end
	
	
	function post:forstmt(f)
		local tt,mulret=getExprTypeList(f.range)
		for i,t in ipairs(tt) do
			if t~=numberType then 
				self:err('for-loop range must be number type, given:'..t.name,f)
			end
		end
	end


	function post:iterator( i )
		local itertype=getType(i.expr)

		local etypes=false
		local mode=false
		if itertype.tag=='tabletype' then
			etypes={itertype.ktype,itertype.etype}
			mode='table'
		elseif itertype.tag=='enumtype' then
			etypes={itertype}
			mode='enum'
		elseif itertype.tag=='threadtype' then
			local rettype=itertype.rettype
			if rettype.tag=='mulrettype' then etypes=rettype.types else etypes={rettype} end
			mode='thread'
		elseif itertype.tag=='classdecl' then
			local iterMethod=getClassMemberDecl(itertype,'__iter',true)
			if not iterMethod then
				self:err(format('"__iter" method not found in class "%s"',itertype.name),i)
			end

			local iterObjType=iterMethod.type.rettype
			if iterObjType.tag=='classdecl' then
				local nextMethod =getClassMemberDecl(iterObjType,'__next',true)
				if not nextMethod then
					self:err(format('"__next" method not found in iterator class "%s"',iterObjType.name),i)
				end
				local rettype=nextMethod.type.rettype
				if rettype.tag=='voidtype' then
					self:err(format('"__next" method in iterator class "%s" returns nothing',iterObjType.name),i)
				end	
				
				if rettype.tag=='mulrettype' then
					etypes=rettype.types
				else
					etypes={rettype}
				end
				mode='obj'

			-- elseif iterObjType.tag=='enumtype' then
			-- 	etypes={iterObjType}
			-- 	mode='obj-enum'
			elseif iterObjType.tag=='tabletype' then
				etypes={iterObjType.ktype,iterObjType.etype}
				mode='obj-table'
			elseif iterObjType.tag=='threadtype' then
				local rettype=iterObjType.rettype
				if rettype.tag=='mulrettype' then etypes=rettype.types else etypes={rettype} end
				mode='obj-thread'
			else
				self:err(format('"__iter" method not returns non-iteratable type "%s"',iterObjType.name),i)
			end

		else
			self:err('cannot iterate on type:'..itertype.name,i)
		end
		i.type={tag='mulrettype',types=etypes,resolveState=true}
		i.mode=mode
	end
	
	function post:foreachstmt(f)
		local etypes=f.iterator.type.types
		if #f.vars > #etypes then
			self:err(format('iterator is expected to return %d values, only given %d',#f.vars,#etypes),f.iterator)
		end
		-- local match=true
		-- local vartypename,valtypename="",""

		-- for i, var in ipairs(f.vars) do
		-- 	if i>1 then vartypename=vartypename..',' end
		-- 	if var.type.name ~= etypes[i].name then
		-- 		self:err(format('iteration variable/value type mismatch, expecting:"%s", given:"%s"',
		-- 					var.type.name,etypes[i].name), f.iterator) 
		-- 	end
		-- end

		--todo: subclass convertion ???
	end
		
	function post:whilestmt(s)
		s.cond=convertToBool(s.cond,self)
		self:visitNode(s.cond)
		return true
	end
	
	function post:repeatstmt(s)
		s.cond=convertToBool(s.cond,self)
		self:visitNode(s.cond)
		return true
	end
	
	-- function post:trystmt(t)
		-- return true
	-- end
	
	-- function post:throwstmt(t)
		-- return true
	-- end
	
	function post:catch(c)
		--todo:!!!!
		return true
	end

	function post:connectstmt( conn )
		--todo:
		
		local signal,slot = conn.signal.decl,conn.slot.decl
		local sender='all'

		if conn.signal.tag=='member' then
			sender=conn.signal.l
			local  sendertype = getType(sender)
			
			if sendertype.tag=='classmeta' then --static signal
				sender='all'
			end
		end	


		conn.sender=sender
		local sigarg,slotarg
		
		conn.signal=signal
		sigarg=signal.args

		local st=getType(signal)
		if st.tag~='signalmeta' then
			self:err('signal expected for connection, given:'..st.name, signal)
		end
	
		local slt=getType(slot)
		local tag=slt.tag
		if tag=='functype' then
			slotarg=slt.args
		elseif tag=='signalmeta' then 
			slotarg=slot.args
		else
			self:err('slot-function/signal expected for connection, given:'..slt.name,slot)
		end

		local r,msg=checkFuncArgs(slotarg,sigarg)
		
		if not r then
			self:err('Slot/Signal argument mismatch:'..msg,conn)
		end

		local receiver

		if conn.slot.tag=='member' and conn.slot.mtype~='static' then
			conn.receiver=conn.slot.l
		end

		--TODO: cyclic signal checking
	end
	
-----------------#ASSIGNSTMT
	local function isAssignable(var)
		local tag=var.tag
		
		if tag=='varacc' or tag=='member' then
			local decl=var.decl
			local dtag=decl.tag
			
			if dtag=='var' or dtag=='arg' then 
				return decl.vtype~='const' 
			end
			
		elseif tag=='index' then
			return true
		end

		return false
	end

	
	function post:assignstmt(a)
		
		local vars,values=a.vars,a.values
		
		for i,var in ipairs(vars) do
			if not isAssignable(var) then
				self:err('non-assignable symbol:'..(var.id or var.tag),var)
			end
		end
		
		--todo: different variable type(member/index/indexoverride)
		
		local valtypes,mulretcount=getExprTypeList(values)
		local valcount,varcount=#valtypes,#vars
		
		if valcount<varcount or (valcount-mulretcount+(mulretcount>0 and 1 or 0))>varcount then
			self:err(format('variable/value count mismatch, expecting:%d, given:%d',varcount,valcount),a)
		end
		
		for i,var in ipairs(vars) do
			local vt=valtypes[i]
			local vart=getType(var)
			
			if not checkType(vart,'>=',vt) then
				self:err(format('variable/value type mismatch,expecting: %s ,given: %s',
						vart.name,vt.name),
						values[i>#values and #values or i]
					)
			end
			-- var.initpos=a.p0
		end
		
		return true
	end
	
	
	local assop={
		['+=']='+',
		['-=']='-',
		['/=']='/',
		['*=']='*',
		['%=']='%',
		['^=']='^',
		['..=']='..',
		['and=']='and',
		['or=']='or'
	}
	
	function post:assopstmt(a)
		
		--todo: different variable type(member/index/indexoverride)
		local var=a.var
		if not isAssignable(var) then
			self:err('non-assignable symbol:'..var.id, var)
		end
			
		local vartag=var.tag
		local mode
		
		if vartag=='varacc' then
			mode='direct'
		elseif vartag=='member' or vartag=='index' then
			mode=is(var.l.tag,'varacc','self') and 'direct' or 'tempvar'
		else
			error("??")
		end
		
		if mode=='direct' then
			return 'replace',
					{tag='assignstmt',
					  vars={a.var},
					  values={{tag='binop',op=assop[a.op],l=a.var,r=a.value}}
					}
					
		elseif mode=='tempvar' then
			--need a tempvariable here
			local tempvar=newTempVar(getType(var.l))
			local oldl=var.l
			var.l=tempvar
			return 'replace',{
				tag='dostmt',
				block={tag='block',
					{tag='vardecl',vars={tempvar},vtype='local',resolveState='done'},
					{tag='assignstmt',vars={tempvar},values={oldl},resolveState='done'},
					{tag='assignstmt',
					  vars={a.var},
					  values={{tag='binop',op=assop[a.op],l=a.var,r=a.value}}
					}
				}
			}
		else
			--??
			error('??')
		end
		
	end 
	
	function post:batchassign(a)
		--todo: replace batch with assigns?
		--todo: check is isAssignable
		--todo: different variable type(member/index/indexoverride)
		--todo typecheck for value/var
		
		-- return 'replace',{
		-- 	tag='dostmt',
		-- 	block={tag='block',
		-- 		{tag='vardecl', vars={
		-- 			}
		-- 	}
		-- }
	end

	
-----------------#DECLARATION
	-- function pre:vardecl(vd)
		
	-- end
	
	
	function post:tvar(v)
		--todo:!!!!!!!!!!!!!!!!!!!
		return true
	end
	
	function post:var(v)
		if v.vtype=='const' and (not v.value or not getConstNode(v.value))then
			self:err('constant value expected for:'..v.name,v)
		end
		
		local td=getOneType(v)

		if not td then
			self:err('unresolved type',v)
		else
			v.type=td
		end
		if td.tag=='voidtype' then 
			return self:err('cannot declare a variable of void type',v)
		end
		if td.tag=='niltype' then 
			return self:err('cannot declare a variable of nil type',v)
		end
		if v.value then
			vartype=v.type
			valtype=getOneType(v.value)
			if valtype.metatype then
				self:err(format('cannot assign non-value type "%s" to variable',valtype.name),v.value)
			end
			if not checkType(vartype,'>=',valtype) then 
				self:err(format('type mismatch, "%s" expected, "%s" given.',vartype.name,valtype.name),v)
			end

		else
			v.value=td.defaultValue
		end

		return true
	end
	
	function post:arg(a)
		return true
	end
	
	function post:enumdecl(e)
		local ii={}
		for i,item in ipairs(e.items) do
			local iv=item.value
			if ii[iv] then self:err('duplicated enum item value',item) end
			ii[iv]=true
		end
		e.type=enumMetaType
	end
	
	function post:enumitem(i,e)
		
		if i.value then
			local v=getConstNode(i.value)
			i.value=v
			if not v or getType(v).tag~='numbertype' then 
				self:err('enum item must be numeric constant') 
			end
			e.currentValue=v
		else
			local cv=e.currentValue
			if not cv then
				cv=makeNumberConst(1)
			else
				cv=makeNumberConst(tonumber(cv.v)+1)
			end
			i.value=cv
			e.currentValue=cv
		end
		i.type=i.value.type
	end
	
	-- local function checkConst(n)
	-- 	local tag=n.tag
	-- 	if is(tag,'number','nil','boolean','string') then return true 
	-- 	elseif tag=='var' and n.vtype=='const' then return true 
	-- 	elseif tag=='varacc' or tag=='member' then
	-- 		if checkConst(n.decl) then return true end
	-- 	elseif tag=='binop' then
	-- 		if checkConst(n.l) and checkConst(n.r) then return true end
	-- 	elseif tag=='unop' then
	-- 		return checkConst(n.l)
	-- 	end
	-- 	return false
	-- end
	
	function pre:classdecl(c)
		local supername=c.supername
		if supername then
			local s=self:findSymbol(supername.id,c)
			--todo check template
			if not s then
				self:err('symbol not found:'..supername.id,c)
			end
			if s.tag~='classdecl' then self:err(supername.id..'is not a class',c) end
			if c.extern and not s.extern then self:err('normal class cannot extend extern class:'..supername.id,c) end
			if s.extern and not c.extern then self:err('extern class cannot extend normal class:'..supername.id,c) end
			c.superclass=s
		end
		c.resolveState='done'
	end

	function post:classdecl(c)
		local scope0=c.scope
		------------TODO:
		--todo:build default constructor
		local cons=scope0['__new']
		local defaultValues={}
		local defaultValuesCount=0
		
		for k,d0 in pairs(scope0) do
			if k~='private'	then
				if d0.tag=='var' and d0.vtype=='field' and d0.value then
					defaultValuesCount=defaultValuesCount+1
					defaultValues[defaultValuesCount]={
						tag='assignstmt',
						vars={{tag='member',
							mtype='member',decl=d0,id=d0.name,
							l={tag='self'}
							}},
						values={d0.value},
						resolveState='done',
					}
				end
			end
		end
		
		if defaultValuesCount>0 then
			if cons then
				local block=cons.block
				for i,a in ipairs(defaultValues) do
					table.insert(block,i,a)
				end
			else
				defaultValues.tag='block'
				defaultValues.resolveState='done'
				c.decls[#c.decls+1]={
					tag='methoddecl',
					type={tag='functype',args={},rettype=voidType,resolveState='done'},
					name='__new',
					refname=c.refname..'__new',
					resolveState='done',
					block=defaultValues
				}
			end
		end

		local sc=c.superclass

		-- while sc do
		-- 	local scope1=sc.scope

		-- 	for k,d0 in pairs(scope0) do
		-- 		local d1=scope1[k]				
		-- 		if d1 then 
		-- 			if d1.tag==d0.tag and d0.tag=='methoddecl' then
		-- 				 if not d0.override then
		-- 				 	self:err(format('method "%s" already defined in superclass "%s", use override keyword instead',d0.name,sc.name),d0)
		-- 				 end
		-- 			-- else
		-- 			-- 	self:err(format('member "%s" already defined in superclass "%s"',d0.name,sc.name),d0)
		-- 			end
		-- 		end
		-- 	end
		-- 	sc=sc.superclass
		-- end


	end
	
	function pre:methoddecl(m,parent)
		m.type.method=true
		return pre.funcdecl(self,m,parent)
	end

	function post:methoddecl(m,parent)
		if m.extern then return end
		post.funcdecl(self,m)

		local ftype=m.type
		-- assert(m.block or m.abstract,'abstract?'..m.name)
		local name=m.name
		if m.override then
			
			if name=='__new' or name=='__gc' then 
				self:err('constructor/finalizer is not overridable.',m)
			end

			local c=parent.superclass
			local superMethod
			while c do
				local m=c.scope[m.name]
				if m then
					if m.tag=='methoddecl' then superMethod=m end
					break
				end
				c=c.superclass
			end
			
			if not superMethod then
				self:err('cannot find method to override:'..m.name,m)
			end

			if superMethod.final then
				self:err('cannot override a final method:'..m.name,m)
			end
			
			local ftname0=getType(superMethod).name
			local ftname1=getType(m).name

			if ftname0~=ftname1 then
				self:err(format('override method type mismatch. expecting:%s, given:%s',ftname0,ftname1),m)
			end
			--todo: allow stricter override method type?

		end

		--some checking for internal method
		if name=='__new' or name=='__gc' then
			if m.type.rettype.tag~='voidtype' then
				self:err('constructor/finalizer should return no value',m)
			end
		elseif name=='__add' then
		end
		
	end
	
	function pre:funcdecl(f)
		if f.extern then return end
		
		if not f.abstract and f.block.tag=='exprbody' and f.type.rettype==voidType then
			local exprs=f.block.exprs
			if #exprs>1 then --multreturn
				local rt={}
				for i,expr in ipairs(exprs) do
					rt[i]=newTypeRef(expr)
				end
				local mulret={tag='mulrettype',types=rt}
				f.type.rettype=mulret
			else
				f.type.rettype=newTypeRef(exprs[1])
			end
		end
		f.resolveState='done'
	end
	
	function post:funcdecl(f)
		if f.extern then return end
		
		local rettype=f.type.rettype

		if rettype.tag=='typeref' then
			rettype=getTypeDecl(rettype)
			f.type.rettype=rettype
		elseif rettype.tag=='mulrettype' and not rettype.name then
			types=rettype.types
			for i,rt in ipairs(types) do
				if rt.tag=='typeref' then
					rt=getTypeDecl(rt)
					types[i]=rt
				end
			end
			makeMulRetTypeName(rettype)
		end

		if not f.hasReturn and rettype.tag~='voidtype' and not f.abstract then
			self:err('return value(s) expected',f)
		end

		if not f.type.name then --typeref
			makeFuncTypeName(f.type)
		end


		return true
	end
	

	function pre:exprbody(ex,parent)
		parent.exprbody=true
		return 'replace', {tag='block',
				{tag='returnstmt',
					module=ex.currentModule, p0=ex.p0,p1=ex.p1,
					values=ex.exprs
				}
			}
	end

	function post:signaldecl(sig)
		sig.type=signalMetaType
	end

----------------------EXPRESSION
	function post:varacc(v)
		if v.vartype=='upvalue' then
			local pf=self:findParentFunc()
			if not (pf and pf.tag=='closure' or (pf.tag=='funcdecl' and pf.localfunc)) then
				--todo:check all the outter functions until reach variable decl
				self:err('upvalue should be inside a closure',v)
			end
		end

		local d=self:findSymbol(v.id, v, v.vartype)
		if not d then self:err("symbol not found:'"..v.id.."'",v ) end
		
		if isMemberDecl(d) then 
			return 'replace', {tag='member',l={tag='self'},id=v.id, decl=d, type=getType(d)}
		end
		
		self:visitNode(d)
		
		v.decl=d
		local td=getType(d)
		if td then 
			v.type=td 
		else
			v.type=d.type
			assert(d.type)
		end
		
		return false
	end

	function post:emitter( e )
		local lt=getType(e.l)
		local rt=getType(e.signal)
		
		if not lt.valuetype and lt.tag~='classdecl' then
			self:err(format('"%s" can be used as signal sender',lt.name),e.l)
		end
		if rt.tag~='signalmeta' then
			self:err('signal expression expected, given:'..rt.name,e.signal)
		end
		e.type=rt
		return true
	end
	
	function post:tcall( c )
		local f=c.l
		local lt=getType(c.l)
		if lt.tag=='classmeta' then --raw new object
			if c.arg.tag=='seq' then 
				self:err('key-value-table is expected for object creation',c.arg)
			end
			
			if c.arg.type.ktype.tag~='stringtype' then
				self:err('string key expected,given:'..c.arg.ktype.name,c.arg)
			end
			local clas = c.l.decl
			for _,item in ipairs(c.arg.items) do
				local key=item.key.v
				-- table.foreach(item.key,print)
				local member=getClassMemberDecl(clas,key,true)
				if not member then
					self:err(format('field %q not found in class %q',key,clas.name),item)
				end
				if member.tag~='var' and member.vtype~='field' then
					self:err(format('"%s.%s" is not a field',clas.name,key),item)
				end
				local vtype=getType(item.value)
				if not checkType(member.type,'>=',vtype) then
					self:err(format('type mismatch, expecting %q, given %q',member.type.name,vtype.name),item)
				end
			end
		else
			self:err('table argument only valid for object creation',c.arg)
		end
		c.type=c.l.decl
	end

	function post:call(c)
		local f=c.l
		local lt=getType(c.l)
		
		resolveCall(lt,c,self)
		
		if lt.tag=='signalmeta' then
			local sender=nil
			local signal=f
			if f.tag=='member' then	sender=f.l end
			return 'replace',{tag='emit',sender=sender,signal=signal.decl,args=c.args}
		elseif lt.tag=='classmeta' then 
			return 'replace',{tag='new',class=c.l,args=c.args, constructor=c.constructor}
		elseif f.tag=='member' and f.mtype=='member' then
			f.mtype='methodcall'
		end
		
		return true
	end

	function post:new( n )
		n.type=n.class.decl
	end
	
	function pre:spawn(s)
		if s.call.tag~='call' then
			self:err('coroutine spawn syntax error',s.call)
		end
	end

	function post:spawn(s)
		local proto=s.call.l
		local ftype=getType(proto)
		s.type={tag='threadtype',
			name=format('thread<%s>',ftype.name),
			rettype=ftype.rettype,
			resolveState='done',
			type=threadMetaType
		}
		
		return true
	end

	function post:resume( r )
		local tt=getType(r.thread)
		if tt.tag~='threadtype' then
			self:err('thread expected for resume expression, given:'..tt.name,r.thread)
		end
		r.type=tt.rettype
	end

	function post:wait( w )
		
		local st=getType(w.signal)
		if st.tag~='signalmeta' then
			self:err('signal expected for wait expression,given:'..st.name,w.signal)
		end
		
		local signal=w.signal.decl

		--todo: wait type <- signal input type
		if #signal.args==0 then 
			w.type=voidType
		else
			local types={}
			for i, arg in ipairs(signal.args) do
				types[i]=arg.type
			end
			if #types==1 then
				w.type=types[1]
			else
				w.type={tag='mulrettype',types=types}
			end
		end
		return true
	end

	function post:emit( e )
		e.type=voidType
	end
	
	function post:binop(b)
		local tl=getType(b.l)
		local tr=getType(b.r)
		resolveOP(tl,b,self)
		return true
	end
	
	function post:unop(u)
		local tl=getType(u.l)
		resolveOP(tl,u,self)
		return true
	end
	
	function post:ternary(t)
		t.l=convertToBool(t.l,self)
		
		local tt,tf=getType(t.vtrue),getType(t.vfalse)
		local ts=getSharedSuperType(tt,tf)
		if not ts then
			self:err('ternary result values must be of same type',t)
		end
		t.type=ts
		return true
	end 

	function post:mulval(v)
		local srctype=getType(v.src)
		
		if srctype.tag~='mulrettype' then
			self:err('multiple return value expected, given:'..srctype.name,v)
		end
		local t=srctype.types[v.idx+1]
		if not t then return self:err('multiple value count mismatch',v.src) end
		v.type=t
		return true
	end
	
	function post:member(m)
		local td=getType(m.l)
		
		if not td then
			self:err('unresolved type<member>',m)
		end
		
		resolveMember(td,m,self)
		self:visitNode(m.decl)
		-- m.type=getType(m.decl)
	end
	
	function post:index(i)
		
		local td=getType(i.l)
		if not td then
			self:err('unresolved type<index>',i)
		end
		
		if getType(i.key).tag=='niltype' then 
			self:err('index key must not be nil',i.key)
		end

		if not yu.resolveIndex(td,i,self) then
			self:err('invalid index expression',i)
		end
	end
	
	function post:table(t)
		local kts={}
		for i,item in ipairs(t.items) do
			local tt=getType(item.key)
			if tt.tag=='niltype' then self:err('cannot use nil for table item key') end
			kts[#kts+1]=tt
		end
		
		local vts={}
		for i,item in ipairs(t.items) do
			local tt=getType(item.value)
			if tt.tag=='niltype' then self:err('table item value is nil') end
			vts[#vts+1]=tt
		end
		local kt=getSharedSuperType(unpack(kts))
		local vt=getSharedSuperType(unpack(vts))
		
		if not kt then 
			kt=anyType
			-- self:err('cannot determine table key type',t)
		end
		if not vt then 
			vt=anyType
			-- self:err('cannot determine table value type',t)
		end
		
		t.type={tag='tabletype',etype=vt,ktype=kt,name=vt.name..'['..kt.name..']'}
		return true
	end
	
	function post:item(i)
		return true
	end
	
	-- function pre:seq(t)
		
	-- end
	
	function post:seq(t)
		local vts={}
		if t.items then
			for i,item in ipairs(t.items) do
				local tt=getType(item)
				if tt.tag=='niltype' then self:err('table item value is nil') end
				vts[#vts+1]=tt
			end
			local vt=getSharedSuperType(unpack(vts))
			
			if not vt then 
				vt=anyType
				-- self:err('cannot determine table value type',t)
			end
			t.type={tag='tabletype',etype=vt,ktype=numberType,name=vt.name..'[number]'}
		else
			t.type=emptyTableType
		end
		
		return true
	end
	
	function post:cast(a)
		return resolveCast(getType(a.l),a,self)
	end
	
	function post:is(i)
		
		local lt=getType(i.l)
		if not checkType(lt,'><',i.dst) then
			self:err('unrelated type:'..lt.name..','..i.dst.name)
		end
		
		i.type=booleanType
		return true
	end
	
	function pre:closure(c)
		return pre.funcdecl(self,c)
	end
	
	function post:closure(c)
		return post.funcdecl(self,c)
	end
	
	function post:self(s)
		local c=self:findParentClass()
		local m=self:findParentMethod()
		local f=self:findParentFunc()
		-- print(c,m,f)
		if not (c and m) then
			self:err("'self' should be inside method",s)
		end

		if s.upvalue then
			if not (f.tag=='closure' or (f.tag=='funcdecl' and f.localfunc) ) then
				self:err("upvalue must be inside local function/closure",s)
			end
		end

		s.type=c
		return true
	end
	
	function post:super(s)
		local c=self:findParentClass()
		local f=self:findParentFunc()
		
		if not (c and f and f.tag=='methoddecl') then
			self:err("'super' should be inside method",s)
		end
		local sc=c.superclass
		if not sc then
			self:err("super type not defined",s)
		end
		s.type=sc
		return true
	end
	
---------------------EXTERN
	-- function post:extern(e)
		-- return true
	-- end
	
	-- function post:externfunc(f)
		-- return true
	-- end
	
	-- function post:externclass(c)
		-- return true
	-- end
	
	-- function post:externmethod(m)
		-- return true
	-- end
	
------------------TYPE
	function post:ttype(t) --template type
		local d=self:findSymbol(t.name,t)
		
		if not d or d.tag~='classdecl' then 
			self:err("generic class not found:'"..t.name.."'",t ) 
		end
		t.class=d
		
		
		local args=t.args
		local tvars=d.tvars
		
		local ac=#args
		local tc=#tvars
		
		if ac~=tc then
			self:err(format("expecting %d type variables ,given %d.",tc,ac),t ) 
		end
		for i,a in ipairs(args) do
			if getTypeDecl(a).tag=='nil' then
				self:err("invalid type for template variable:".."nil",t)
			end
		end

		--todo: get class instance?

	end
	
	function post:type(t,parent)  --symbol type
		if isBuiltinType(t.name) then 
			t.decl=getBuiltinType(t.name)
			return
		end
		
		local d=self:findSymbol(t.name,t)
		if not (d and isTypeDecl(d)) then 
			self:err(format("type symbol not found:'%s'",t.name),t )
		end
		t.decl=d	
		self:visitNode(d)
	end



	local function makeTableTypeName( ft )
		local rt=ft.rettype
		local argname=''
		for i,arg in ipairs(ft.args) do
			if i>1 then argname=argname..',' end
			argname=argname..getType(arg).name
		end
		local name=format('func(%s)',argname)
		if rt.name~='void' then
			name=name..'->'..rt.name
		end
		ft.name=name
	end

	
	function post:tabletype(t)
		t.etype=getTypeDecl(t.etype)
		t.ktype=getTypeDecl(t.ktype)
		t.name=format('%s[%s]',t.etype.name,t.ktype.name)

	end
	
	function post.mulrettype(vi,mt)
		-- for i,t in ipairs(mt.types) do
		-- end
		-- --let funcdecl handle this
		-- makeMulRetTypeName(mt)
	end
	
	function post:functype(ft)
		local rt=ft.rettype
		if rt.name then  --typeref will be handled by funcdecl
			makeFuncTypeName(ft)
		end
	end

	function post:vararg(va)
		va.name=format('vararg(%s)',va.type.name)
	end
	
