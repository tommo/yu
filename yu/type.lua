require 'yu.utils'

local is,type=yu.is,type
local format=string.format
module ("yu")

-----Builtin types


typeMetaType={tag='typemeta',name='type'}

local function makeValueType(tag,name)
	return {tag=tag,name=name,type=typeMetaType,valuetype=true}
end

local function makeMetaType(tag,name,valuetype)
	return {tag=tag,name=name,type=typeMetaType,metatype=true}
end


nilType=makeValueType('niltype','nil')
booleanType=makeValueType('booleantype','boolean')
numberType=makeValueType('numbertype','number')
stringType=makeValueType('stringtype','string')
objectType=makeValueType('objecttype','object')
userdataType=makeValueType('userdatatype','userdata')
voidType=makeValueType('voidtype','void')
anyType=makeValueType('anytype','any')

signalMetaType=makeMetaType('signalmeta','signal')
classMetaType=makeMetaType('classmeta','class')
moduleMetaType=makeMetaType('modulemeta','module')
enumMetaType=makeMetaType('enummeta','enum')

funcMetaType=makeMetaType('funcmeta','func')
tableMetaType=makeMetaType('tablemeta','table')
threadMetaType=makeMetaType('threadmeta','thread')

emptyTableType={tag='tabletype',name='[]'}

stringTable={}
numberTable={}

trueConst={tag='boolean', v='true', type=booleanType}
falseConst={tag='boolean', v='false',type=booleanType}
nilConst={tag='nil',type=nilType}


function makeNumberConst(v)
	n=tostring(v)
	local c=numberTable[n]
	if not c then
		c={tag='number', v=n, type=numberType ,resolveState='done'}
		numberTable[n]=c
	end
	return c
end
local unescape=unescape
function makeStringConst(s,longstring)
	if not longstring then s=unescape(s) end
	local c=stringTable[s]
	if not c then
		c={tag='string', v=s, type=stringType, resolveState='done'}
		stringTable[s]=c
	end
	return c
end



-----------Default initial value for each type
booleanType.defaultValue=nilConst
stringType.defaultValue=nilConst
objectType.defaultValue=nilConst
numberType.defaultValue=nilConst


-----------TYPE comparison

local function getSuperType(t)
	--TODO:
	local tag=t.tag
	if tag=='classdecl' then
		local super=t.superclass
		if super then return super end
		return objectType
	end
	return nil
end

local function getFirstSuperType(t)
	if t.tag=='classdecl' then return objectType end
	
	local s=t
	while true do
		local s1=getSuperType(s)
		if not s1 then break end
		s=s1
	end
	return s
end

local function getSuperTypeList(t)
	local list={t}
	local s=t
	while true do
		local s1=getSuperType(s)
		if not s1 then break end
		list[#list+1]=s1
		s=s1
	end
	return list
end

local function getSharedSuperType(a,b,c,...)
	if not b then return a end
	local asl,bsl=getSuperTypeList(a),getSuperTypeList(b)
	for i,as in ipairs(asl) do
		for j,bs in ipairs(bsl) do
			if as==bs then
				if c then
					return getSharedSuperType(as,c,...)
				else
					return as
				end
			end
		end
	end
	return nil
end


local function isSameType(t1,t2)
	local d1,d2=getTypeDecl(t1),getTypeDecl(t2)
	if d1==d2 then return true end
	local tag1,tag2=d1.tag,d2.tag
	if tag1~=tag2 then return false end
	
	if tag1=='tabletype' then
		return isSameType(d1.ktype,d2.ktype) and 
				isSameType(d1.etype,d2.etype)
	end
	
	return d1.name==d2.name
end


local function isSuperType(t1,t2) --T1 is super type of T2?
	if t1==anyType then return true end
	if t2==nilType and t1.valuetype then return true end

	if t1.tag=='tabletype' then
		if t2==emptyTableType then return true end
		return (isSameType(t1.etype,t2.etype) or isSuperType(t1.etype,t2.etype))
			and  (isSameType(t1.ktype,t2.ktype) or isSuperType(t1.ktype,t2.ktype))
	end
	
	local s=t2
	while true do
		local s1=getSuperType(s)
		if not s1 then break end
		if s1==t1 then return true end
		s=s1
	end
	return false
end


-- '>' t1 is super of t2, vice vesa
-- '==' t1 is same as t2
-- '>=' t1 is super of t2 or t1 is same as t2, vicevesa
-- '~=' t1 is not the same as t2
-- '><' t1 and t2 has same origin(super)
-- 'ret' t1 is return type of t2(func)
-- '->' t1 can be converted into t2
function checkType(t1,m,t2)
	local result=false
	t1,t2=getTypeDecl(t1),getTypeDecl(t2)
	
	if m=='>' then
		result=isSuperType(t1,t2)
	elseif m=='>=' then
		result=isSuperType(t1,t2) or isSameType(t1,t2)
	elseif m=='==' then
		result=isSameType(t1,t2)
	elseif m=='~=' then
		result= not isSameType(t1,t2)
	elseif m=='<' then
		result=isSuperType(t2,t1)
	elseif m=='<=' then
		result=isSuperType(t2,t1) or isSameType(t1,t2)
	elseif m=='><' then
		if t1.valuetype and t2.valuetype and (t1==anyType or t2==anyType) then return true end
		local s1=getFirstSuperType(t1)
		local s2=getFirstSuperType(t2)
		result= isSameType(s1,s2)
	end
	return result
end

function castType(node,targetType)
	local td=getTypeDecl(node)
	if td==targetType then return node end
	--TODO:
	
end



local builtinTypeDecls={
	
	['nil']=nilType,
	['boolean']=booleanType,
	['number']=numberType,
	['string']=stringType,
	['object']=objectType,
	['@void']=voidType,
	['any']=anyType,
	
	['classdecl']=classMetaType,
	['import']=moduleMetaType,
	['enumdecl']=enumMetaType,
	['functype']=funcMetaType,
	['tabletype']=tableMetaType,
	['signaldecl']=signalMetaType,
	
}


function getBuiltinType(name)
	return builtinTypeDecls[name]
end


local function getGenericInstance(class,tvars)

end

local function getTypeDecl(d,noMulRet)
	-- print('getting type',d.tag)

	if d.tag=='mulrettype' and noMulRet then
		d=d.types[1]--return only the first type
		assert(d)
	end

	if isTypeDecl(d) then return d end

	local tag=d.tag
	if tag=='type' then
		if not d.decl then
			-- assert(d.resolveState)
			compileErr("FATAL:unresolved typenode:"..tag..","..d.name or "", d)
		end
		return d.decl
	elseif tag=='typeref' then
		return getType(d.ref, noMulRet)
	elseif tag=='ttype' then
		--TODO:
		error('todo')
	else		
		table.foreach(d,print)
		error('invalid type:'..tag)
	end
		
end

local function replaceTableContent(src,dst)
	--clear src
	for k,v in pairs(src) do
		rawset(src,k,nil)
	end

	for k,v in pairs(dst) do
		rawset(src,k,rawget(dst,k))
	end
end

local function getType(node,noMulRet)
	local t=node.type
	if not t then
		assert(node.resolveState=='done','no resolve:'..node.tag)
		table.foreach(node,print)
		error('fatal: type not resolved:'..node.tag)
	end
	return getTypeDecl(t, noMulRet)
end

local function getOneType( node )
	return getType(node, true)
end

 function getExprTypeList(values) --for expanding multiple return
	local types={}
	local c=#values
	local mulret=0
	
	for i=1,c do
		local v=values[i]
		local t=getType(v)
		if t.tag=='mulrettype' then
			if i==c then --lastone
				for j,rt in ipairs(t.types) do
					local td=getTypeDecl(rt)
					types[#types+1]=td
				end
				mulret=#t.types
			else
				types[#types+1]=t.types[1]
			end
		else
			types[#types+1]=t
		end
	end
	return types,mulret
end


function newTypeRef(n)
	assert(n)
	return {tag='typeref',ref=n}
end



------CLASS TEMPLATE
local tvarKeys={}
function getTVarKey(args)
	local t=tvarKeys
	local tt=nil
	for i,a in ipairs(args) do
		tt=t[a]
		if not tt then
			tt={}
			t[a]=tt
		end
	end
	return tt
end

local function getClassInstance(c,args)
	assert(c.tvars)
	local instances=c.instances
	if not instances then instances={} c.instances=instances end
	local key=getTVarKey(args)
	
	local i=instances[key]
	if not i then 
		--replace tvar with real type
		
	end
	
	return i
end

local typeres={
	op={},
	index={},
	member={},
	call={},
	cast={}
	
}


----------OP
function typeres.op.niltype(t,n)
	local op=n.op
	local cls=yu.getOpClass(op)
	
	if cls~='equal' and cls~='logic' then return false end
	
	n.type=booleanType
	return true 
end

function typeres.op.booleantype(t,n)
	local op=n.op
	local cls=yu.getOpClass(op)
	
	if cls~='equal' and cls~='logic' then return false end
	
	n.type=booleanType
	return true 
end


function typeres.op.numbertype(t,n)
	local op=n.op
	
	if n.tag=='binop' then
		local cls=yu.getOpClass(op)
		local tr=getType(n.r)
		if cls=='arith' then
			if tr.tag~='numbertype' then return false end
			n.type=numberType
		elseif cls=='order' then
			if tr.tag~='numbertype' then return false end
			n.type=booleanType
		elseif cls=='concat' then
			n.type=stringType
		elseif cls=='equal' then
			n.type=booleanType
		else
			return false
		end
	else
		if op=='-' then
			n.type=numberType
		elseif op=='not' then
			n.type=booleanType
		else
			return false
		end
	end
	return true
end

function typeres.op.stringtype(t,n)
	local op=n.op
	if n.tag=='binop' then
		local cls=yu.getOpClass(op)
		local tr=getType(n.r)
		if cls=='concat' then
			if not is(tr.tag,'numbertype','stringtype') then return false end
			n.type=stringType
		elseif cls=='order' then
			if tr.tag~='stringtype' then return false end
			n.type=booleanType
		elseif cls=='equal' then
			n.type=booleanType
		else
			return false
		end
	else
		if op=='not' then
			n.type=booleanType
		else
			return false
		end
	end
	return true
end

function typeres.op.classdecl(t,n,resolver)--object
	--TODO:check operator override first
end





----------MEMBER
local function getClassMemberDecl(c, id, getSuper, fromModule)
	local scope=c.scope
	local d=scope[id]
	
	if d and not (fromModule~=c.module and d.private) then
		local dtag=d.tag
		local mtype='static'
		
		if dtag=='methoddecl' then 
			mtype='member'
		elseif dtag=='var' then
			if d.vtype=='field' then mtype='member' end
		elseif dtag=='signaldecl' then
			mtype='signal'
		end
		
		return d,mtype
	end
	
	if getSuper and c.superclass then return getClassMemberDecl(c.superclass,id,getSuper,fromModule) end
	
	return nil,false
end


function typeres.member.enummeta(t,m)
	local e=m.l.decl
	local item=e.scope[m.id]
	
	if item then
		m.decl=item
		m.type=e
		return true
	end
	
	compileErr('enum item not found:'..m.id,m)
end

function typeres.member.modulemeta(t,m)
	local im=m.l.decl
	local mod=im.mod
	local item=mod.scope[m.id]
	
	if item and not item.private then
		m.decl=item
		m.type=getType(item)
		
		local module=m.module

		if not module.externalReferNames[item] then
			local id=module.maxDeclId+1
			module.maxDeclId=id
			module.externalReferNames[item]=makeDeclRefName(item,id)
		end

		return true
	end
	
	compileErr('symbol not found:'..m.id,m)
end

function typeres.member.classmeta(t,m)
	local c=m.l.decl
	local d,mtype=getClassMemberDecl(c,m.id,true,m.module)
	
	if d and (mtype=='static' or mtype=='signal') then
		m.decl=d
		m.type=getType(d)
		m.mtype=mtype
		return true
	end
	
	compileErr('static member not found:'..m.id,m)
end


function typeres.member.classdecl(t,m,resolver)
	local d,mtype=getClassMemberDecl(t,m.id,true,m.module)
	
	if (mtype=='member' or mtype=='signal') then
		m.decl=d
		m.type=getType(d)
		if m.l.tag=='super' then
			if mtype=='signal' then resolver:err('cannot emit signal by super',m) end
		 	mtype='super' 
		end
		m.mtype=mtype
		return true
	end
	
	resolver:err('member not found:'..m.id,m)
end

typeres.member.externclass=typeres.member.classdecl


function typeres.member.ttype(t,m)
	local c=t.class
	local d,ismember=getClassMemberDecl(c,m.id,true,m.module)
	
	if not ismember then return false end
end

-----------INDEX
function typeres.index.tabletype(t,idx,resolver)
	local kt=getType(idx.key)
	local akt=t.ktype
	
	if not checkType(akt,'>=',kt) then
		resolver:err(format('index key type mismatch,expecting: %s, given: %s',akt.name,kt.name),idx)
	end
	
	idx.type=t.etype
	return true
end

-------CALL



local function checkFuncArgs(targs,cargs)
	-- assert(t.tag=='functype',t.tag)
	cargs=cargs or {}
	targs=targs or {}
	
	local ctypes,mulret=getExprTypeList(cargs)
	
	local varargType
	local lastArg=targs[#targs] --last func decl arg
	if lastArg and lastArg.name=='...' then
		varargType=lastArg.type.type
	end

	if #ctypes<#targs-(varargType and 1 or 0) then
		return false, format('too less arguments, %d expected, given %d',#targs,#ctypes)
	end
	
	for i,cat in ipairs(ctypes) do
		local ta=targs[i]
		local tat
		
		if not ta then
			if varargType then
				tat=varargType
			elseif mulret>0 and #ctypes-mulret<#targs then
				break
			else
				return false,format('too many arguments, %d expected, given %d',#targs,#ctypes)
			end
		elseif ta.name=='...' then
			tat=varargType
		else
			tat=getType(ta)
		end
		
		if not checkType(tat,'>=',cat) then 
			return false, 
				format('argument type mismatch,expecting:%s ,given: %s',tat.name,cat.name), 
				cargs[i>#cargs and #cargs or i]
		end
	end
	--todo: rate by type matching
	return 1
end

function typeres.call.functype(t,c,resolver)
	local ok,err,errnode=checkFuncArgs(t.args,c.args)

	if not ok then 
		resolver:err(err,errnode or c) 
	end

	local rettype=t.rettype
	if not rettype then
		c.type=voidType
	else
		c.type=rettype
	end
	return true
end

local function findCallProto(f,c,resolver)
	-- local rates={}
	local topRate=0
	local topProto={}
	local noMatch={}
	
	while f do
		resolver:visitNode(f)
		local rate,err,errnode=checkFuncArgs(getType(f).args,c.args)
		
		if rate then
			if rate>topRate then
				topRate=rate
				topProto={f}
			elseif rate==topRate then
				topProto[#topProto+1]=f
			end
		else
			noMatch[#noMatch+1]=f
		end
		f=f.nextProto
	end
	
	--TODO:with same rate? order by argument type(the more specific, the better)
	--fixed arg > optional arg > vararg 
	return topProto[1],noMatch
end

function typeres.call.classmeta(t,n,resolver )
	local clas=n.l.decl
	
	if clas.abstract then
		local msg=''
		while clas do
			for i, m in ipairs(clas.decls) do
				if m.abstract then
					msg=msg..format('\n\t%s.%s:%s',clas.name,m.name,m.type.name)
				end
			end
			clas=clas.superclass
		end
		resolver:err('class has abstract method(s):'..msg,n.l)
	end
	local constructor=getClassMemberDecl(clas,'__new',false)
	if constructor then

		local proto,noMatch=findCallProto(constructor,n,resolver)		
		if not proto and n.args then
			local msg=''
			for i,p in ipairs(noMatch) do
				if i>1 then msg=msg..' , ' end
				msg=msg..getType(p).name
			end
			resolver:err(format('not found matching constructor for class "%s", valid constructors:%s',clas.name,msg),n)
		else
			n.constructor=proto
		end
	elseif n.args then
		resolver:err(format('class "%s" has no constructor',clas.name),n)
	end
	n.type=clas
	return true
end

function typeres.call.signalmeta(t,n,resolver )
	local sig
	if n.l.tag=='emitter' then 
		sig=n.l.signal.decl
	else
		sig=n.l.decl
	end

	local ok,err,errnode = checkFuncArgs(sig.args,n.args)
	if not ok then 
		resolver:err(err,errnode or n) 
	end
	n.type=voidType
	return true
end


-- function typeres.call.threadtype(t,n,resolver )
-- 	n.type=t.rettype
-- 	return true
-- end


-------CAST
function typeres.cast.numbertype(t,n,target)
	--TODO:...
	
	local td=getTypeDecl(target)
	if td==booleanType then
		return 'replace',convertToBool(n.l)
	elseif td==stringType then
		return n
	end
end

function typeres.cast.stringtype(t,n,target)
	--TODO:...
	local td=getTypeDecl(target)
	if target==numberType then
	elseif target==booleanType then
		
	end
end

function typeres.cast.niltype(t,n,target)
	local td=getTypeDecl(target)
	if td==booleanType then
		return falseConst
	end
	return false
end

function typeres.cast.classdecl( t,n,target )
	local td=getTypeDecl(target)

	if td==booleanType then
		return 'replace',convertToBool(n.l)
	elseif td.tag=='classdecl' then
		return checkType(t,'>',target) or checkType(t,'<=',target) 
	end
	return false
end
-------------

-------ENTRY
function resolveMember(t,node,resolver)
	local tag=t.tag
	local r=typeres.member[tag]
	--TODO: member for builtin types
	if r and r(t,node,resolver) then return true end
	resolver:err('no member for type:'..t.name,node)	
end

function resolveOP(t,node,resolver)
	local tag=t.tag
	local r=typeres.op[tag]
	local op=node.op
	local cls=yu.getOpClass(op)
	
	if cls=='equal' then 
		node.type=booleanType
		return true
	elseif cls=='logic' then
		if op=='not' then
			node.l=convertToBool(node.l)
			node.type=booleanType
			return true
		elseif op=='and' then
			-- local lt=getType(node.l)
			local rt=getType(node.r)
			-- node.notype=lt
			node.yestype=rt
			node.type=booleanType

			return true
		elseif op=='or' then
			-- local lnotype=node.l.notype

			local lt=getType(node.l)
			lt=node.l.yestype or lt

			local rt=getType(node.r)
			local shared=getSharedSuperType(lt,rt)

			if not shared then 
				node.type=anyType
			else
				node.type=shared
			end
			
			return true
		end

	elseif r and r(t,node,resolver) then 
		return true 
	end
	
	local tr=getType(node.r)
	local msg
	if node.tag=='binop' then
		msg=format('between types: %s , %s',t.name, tr.name)
	else
		msg=format('on type: %s',t.name) 
	end
	resolver:err(format('cannot perform %s op ',cls)..msg, node)
end

function resolveIndex(t,node,resolver)
	local tag=t.tag
	local r=typeres.index[tag]
	if r and r(t,node,resolver) then return true end
	resolver:err('cannot perform index on type:'..t.name,node)
end

function resolveCall(t,node,resolver)
	local tag=t.tag
	local r=typeres.call[tag]
	if r and r(t,node,resolver) then return true end
	resolver:err('cannot invoke type:'..t.name,node)
end

function resolveCast(t,node,resolver)
	local tag=t.tag
	local dst=node.dst
	
	if checkType(t,'=',dst) then

		return 'replace',node.l
	end
	
	if checkType(t,'<',dst) then
		node.type=dst
		return true
	end

	local r=typeres.cast[tag]
	if r then 
		local res,data= r(t,node,dst,resolver)
		if res then 
			node.type=dst
			return res,data
		end
	end
	resolver:err(format('cannot cast type "%s" into "%s".',t.name,dst.name),node)
end

function convertToBool(node,resolver)
	local t=getType(node)
	local tag=t.tag
	
	if t==nilType then
		return falseConst
	elseif t==booleanType then
		return node
	elseif t==numberType then
		return {tag='binop',op='~=',l=node,r=nilConst, type=booleanType, resolveState='done'}
	elseif t==stringType then
		return {tag='binop',op='~=',l=node,r=nilConst, type=booleanType, resolveState='done'}
	elseif tag=='classdecl' then
		return {tag='binop',op='~=',l=node,r=nilConst,type=booleanType, resolveState='done'}
	else
		resolver:err('cannot convert into boolean type:'..t.name,node)
	end
	
end

---------------------------


_M.getTypeDecl=getTypeDecl
_M.getType=getType
_M.getOneType=getOneType
_M.builtinTypeDecls=builtinTypeDecls
_M.getSharedSuperType=getSharedSuperType
_M.getClassMemberDecl=getClassMemberDecl
_M.checkFuncArgs=checkFuncArgs