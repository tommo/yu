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
local insert=table.insert

local function isExposable(n)
	local tag=n.tag
	return 
		(tag=='funcdecl' and not n.localfunc)
		or (tag=='methoddecl' and not n.extern and not n.abstract)
		or tag=='classdecl'
		or tag=='enumdecl'
		or tag=='signaldecl'
end

local function printMetadata(m)
	local s=''
	for k,v in pairs(m) do
		local i=string.format('%s=%s,',k,tostring(v))
		s=s..i
	end
	return '{'..s..'}'
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

local currentModule=false
local _getDeclName=getDeclName
local function getDeclName(d)
	return _getDeclName(d,currentModule)
end

local function getSuperClassDeclName(c,s)
	if c.module~=s.module then
		return format('__yu_require%q.%s',s.module.modpath,s.refname)
	else
		return getDeclName(s)
	end
end


local function doCodegen( node, parentGen )
	local gen=newCodeWriter()
	gen.__annotationNodes={}
	if parentGen then
		gen.parent=parentGen
		gen.__indent=parentGen.__indent
		gen.__level=parentGen.__level+1
	end

	codegen(gen,node)
	return gen
end

codegen= function(gen,m)
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

local function genDebugInfo(gen,m)
	gen'__yu__debuginfo={'
	gen:ii()
	gen:cr()
		gen:appendf('path=%q;',m.path)
		gen:cr()
		gen:appendf('name=%q;',m.name)		
		gen:cr()
		gen'line_target={'
		for i,data in pairs(gen.__marked_line) do
			local line=data[1]
			local node=data[2]
			local range=data[3]
			gen:appendf('{%d, %d, %d,%d, %q},',
				line,
				range,
				node.p0 or 0,node.p1 or 0,
				node.tag
				)
		end
		gen'};'
		gen:cr()
		gen'line_offset={'
		local off1=0
		for l,off in ipairs(m.lineOffset) do
			gen:append((off-off1)..',')
			off1=off
		end
		gen'};'

		gen:cr()


	gen:di()
	gen:cr()
	gen'}'
	gen:cr()
end

local genNodeReflection

local function genFuncReflection(gen,f)
end

local function genClassReflection(gen, c)
	--TODO: generate reflection for static member
	local hasAnnotation=c.ann and #c.ann>0
	gen:appendf("__yu_addreflection('class', %s, %q, ", c.refname, c.name)
		gen:ii() gen:ii() gen:cr()
		--class typeinfo
		gen"{" gen:ii()
			if c.superclass then
				gen:cr()
				gen:appendf('superclass = %s,' , 
					getSuperClassDeclName(c,c.superclass))
			end
			if c.private then
				gen:cr()
				gen:appendf('private = true,')
			end
			if c.extern then
				gen:cr()
				gen:appendf('extern = true,')
			end
			--TODO:annotation goes here?
		gen:di() gen:cr()	gen"},"
		gen:cr()

		--member typeinfo
		gen"{" gen:ii()
			for k, d in pairs(c.scope) do
				if not d.private then
					hasAnnotation=hasAnnotation or (d.ann and #d.ann>0)
					local tag=d.tag
					if tag=='var' then
						if d.vtype=='field' then
						 	gen:cr()
							gen:appendf('{ mtype="field", name=%q, type=%q},' , k, d.type.name)
						end
					elseif tag=='methoddecl' then
						gen:cr()
						gen:appendf('{ mtype="method", name=%q, type=%q},' , k, d.type.name)
					end
				end
			end
		gen:di() gen:cr()	gen"}"
		gen:di()
		gen:cr()
		gen")"
	gen:di() 
	gen:cr()
	
	if hasAnnotation then
		gen.__annotationNodes[c]=true
	end
end

local function genEnumReflection(gen,e)

	gen:appendf("__yu_addreflection('enum', %s, %q, ", e.refname, e.name)
		gen:ii() gen:ii() gen:cr()
		--enum typeinfo
		gen"{" gen:ii()
			if e.private then
				gen:cr()
				gen:appendf('private = true,')
			end
			if e.extern then
				gen:cr()
				gen:appendf('extern = true,')
			end
			--TODO:annotation goes here?
		gen:di() gen:cr()	gen"},"
		gen:cr()

		--items typeinfo
		gen"{" gen:ii()
			for i, item in ipairs(e.items) do
				gen:cr()
				gen:appendf('{%q , %d},', item.name, item.value.v)				
			end
		gen:di() gen:cr()	gen"}"
		gen:di()
		gen:cr()
		gen")"
	gen:di() 
	gen:cr()

	if e.ann and #e.ann>0 then
		gen.__annotationNodes[e]=true
	end
end

local function genNodeReflection(gen, node)
	local tag=node.tag
	if tag=='classdecl'  then
		genClassReflection(gen, node)
	elseif tag=='enumdecl' then
		genEnumReflection(gen, node)
	end
end

local function genReflection(gen, m)
	-- reg: reflection registry
	for k, d in pairs(m.scope) do
		if not d.private then
			genNodeReflection(gen, d)
		end
	end
end

local function genAnnotation(gen, ann, key)
	if not ann or #ann==0 then return end
	if key then
		gen:appendf("%s =",key)
	end

	gen"{" gen:ii()
	for i,a in ipairs(ann) do
		gen:cr()
		codegen(gen, a.value)
		gen","
	end
	gen:di() gen:cr()
	gen"};"
	gen:cr()
end

local function genAnnotationLoader(gen,m)
	for d in pairs(gen.__annotationNodes) do
		local tag=d.tag
		gen:cr()
		gen:appendf('__yu_addannotation(%q, {', d.name)
		gen:ii() gen:cr()
			--self annotations
			genAnnotation(gen, d.ann)
			if tag=='classdecl' then
				for k, m in pairs(d.scope) do
					genAnnotation(gen, m.ann, k)
				end
			-- elseif tag=='enumdecl' then
			end
		gen:di() gen:cr()
		gen'})'
	end
end
----------------------------------

function generators.module(gen,m)
	currentModule=m
	-- gen.__indent=-1 --reset indent
	gen:appendf("yu.runtime.module(%q)",m.modpath)
	gen:cr()
	--load module
	
	gen"-------declaration pass------"
	gen:cr()

	gen('local __yu_module_inited=false')
	gen:cr()
	gen('function __yu_module_init()')
	gen:ii()			
		gen:cr()
		gen('if __yu_module_inited then return else __yu_module_inited=true end')
		gen:cr()
		for i, m in pairs(m.externModules) do
			gen:appendf('__yu_require%q.__yu_module_init()',m.modpath)
			gen:cr()
		end
		gen:expose(m.mainfunc)
		local classDecls={}
		while true do
			local exposed=makeDeclList(gen.exposeDecls)
			gen.exposeDecls={}
			for i,s in ipairs(exposed) do
				if s.tag=='classdecl' then insert(classDecls,s) end
			end

			for i,s in ipairs(exposed) do
				codegen(gen,s)
				gen:cr()
			end
			if not next(gen.exposeDecls) then break end
		end

	gen:di()
	gen:cr()
	gen'end'
	gen:cr()


	gen:cr()
	gen"-------reference pass------"
	gen:cr()
	gen('local __yu_module_refered=false')
	gen:cr()
	gen('function __yu_module_refer()')
	gen:ii()			
		gen:cr()
		gen('if __yu_module_refered then return else __yu_module_refered=true end')
		gen:cr()
		for i, m in pairs(m.externModules) do
			gen:appendf('__yu_require%q.__yu_module_refer()',m.modpath)
			gen:cr()
		end
		--load refered extern symbol
		local listByModule={}
		local referModules={}
		for r in pairs(m.externalReferNames) do
				local rm=r.module
				if r~=rm and not(
						r.vtype=='global' or
						r.vtype=='const'
					)
				then --module
					local list=listByModule[rm]
					if not list then list={} listByModule[rm]=list end
					list[r]=true
				elseif r==rm then
					referModules[r]=true
				end
			-- end
		end
		for m,list in pairs(listByModule) do
			gen:appendf('local _m=__yu_require%q',m.modpath)
			gen:cr()
			for r in pairs(list) do
				gen:appendf('%s=_m.%s',getDeclName(r),r.refname)
				gen:cr()
			end			
		end

		for m in pairs(referModules) do
			gen:appendf('%s=__yu_require%q',getDeclName(m),m.modpath)
			gen:cr()			
		end
	
	gen:di()
	gen:cr()
	gen'end'
	gen:cr()

	---------------reflection pass
	gen:cr()
	gen"-------reflection data------"
	gen:cr()
	gen('function __yu_module_reflection()')
		gen:ii()
		gen:cr()
			genReflection(gen,m)
		gen:di()
		gen:cr()
	gen'end'
	gen:cr()

	gen:cr()
	gen"-------module entry------"
	gen:cr()
	gen('local __yu_module_entered=false')
	gen:cr()
	gen('function __yu_module_entry(...)')
	gen:ii()
		gen:cr()
		gen('if __yu_module_entered then return else __yu_module_entered=true end')
		gen:cr()
		for i, m in pairs(m.externModules) do
			gen:appendf('__yu_require%q.__yu_module_entry()',m.modpath)
			gen:cr()
		end

		gen:cr()
		gen"----load reflection here----"
		gen:cr()
		gen('__yu_module_reflection()')
		gen:cr()

		gen:cr()
		gen"----init globals----"
		gen:cr()
		for i, g in ipairs(gen.classGlobalVars) do
			codegen(gen,g)
			gen:cr()
		end


		gen:cr()
		gen"----init annotations----"
		gen:cr()
		
		genAnnotationLoader(gen, m)

		gen:cr()
		gen'---start module---'
		gen:cr()
		gen'return __yu_main(...)'
		gen:di()
		gen:cr()
	gen'end'
	gen:cr() 
	--end of moudle_entry---

	gen:cr()
	gen:appendf("--------forward class creation------")
	gen:cr()
	for i,s in ipairs(classDecls) do
		if not s.extern then
			gen:appendf('%s = {}',getDeclName(s))
			gen:cr()
		end
	end
	gen:cr()

	gen:appendf("--------debug info------")
	gen:cr()	
	genDebugInfo(gen,m)		
	gen:cr()

	gen:appendf("--------require modules------")
		gen:cr()
		for path,m1 in pairs(m.externModules)  do
			gen:appendf('__yu_require%q',m1.modpath)
			gen:cr()				
		end
	gen:cr()

	currentModule=nil
end

function generators.block(gen,b)
	gen:ii()
	local nonDecls={}
	local blockEnd=false
	for i,s in ipairs(b) do
		local tag=s.tag
		if tag=='continuestmt' or tag=='returnstmt' or tag=='breakstmt' then
			blockEnd=true
		elseif blockEnd then
			compileErr('unreachable statement',s)
		end
		
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
	for l in string.gmatch(r.src,'(.-)\r?\n') do
		gen(l)
		gen:cr(true) --no indent
	end
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

	gen 'yu.runtime.signalConnect('
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
		gen'next ,' codegen(gen,i.expr) 
		gen''
	elseif mode=='enum' then
		--todo
	elseif mode=='thread' then
		gen'__yu_resume ,' codegen(gen,i.expr)
	elseif mode=='obj' then
		gen'__yu_obj_next (' codegen(gen,i.expr) gen':__iter() )'
	elseif mode=='obj-table' then
		gen'next ,' codegen(gen,i.expr) gen':__iter()'
	elseif mode=='obj-thread' then
		gen'__yu_resume ,' codegen(gen,i.expr) gen':__iter()'
	end
		gen:mark(i)

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
	gen'__yu_throw('
	codegenList(gen,t.values)
	gen')'
	gen:mark(t,false)
end

function generators.catch(gen,c)
	--todo:..............
end

function generators.assertstmt( gen,t )
	gen'__yu_assert('
	codegen(gen,t.expr)
	if t.exception then 
		gen','
		codegen(gen,t.exception)
	end
	gen');'
	gen:mark(t,false)
end

function generators.assignstmt(gen,a)
	if a.genHint=='defaultvalue' then
		local v=a.vars[1]
		gen'if '
		codegen(gen,v)
		gen'==nil then '
		codegen(gen,v)
		gen'='
		codegen(gen,a.values[1])
		gen' end'
		gen:mark(a,false)
	-- elseif a.tempvar or a.tempkey then --index/member assop
	-- 	local var,value=a.vars[1],a.values[1]
	-- 	gen'do' gen:ii() gen:cr()
	-- 	if var.tag=='member' then
	-- 		gen'local __tmp_assop_var = '
	-- 		codegen(gen, var.l)
	-- 		gen('__tmp_assop_var.'..var.id)
	-- 		gen'='

	-- 	codegen(gen, var)
	-- 	gen'='
	-- 	codegen(gen, value)
	-- 	gen:mark(a,false)
	-- 	gen:di() gen:cr() gen'end'
	else
		codegenList(gen,a.vars)
		gen'='
		codegenList(gen,a.values)
		gen:mark(a,false)
	end
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
	
	gen:mark(vd,false)
end

--#DECLARATION
function generators.tvar(gen,v)
	--todo:!!!!!!
	
end

function generators.var(gen,v)
	gen(getDeclName(v))
end

function generators.arg(gen,a)
	if a.vararg then 
		gen'...' 
	else
		gen(getDeclName(a))
	end
end

function generators.enumdecl(gen,e)
	-- --todo:assign default const value
	gen:appendf('%s={}',getDeclName(e))
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



local function genConstTable(gen,t)
	gen'{'
		for i,item in ipairs(t) do
			local k,v=item.k,item.v
			gen(k)
			if v==nil then 
				gen'=true'
			else
				local tag=v.tag
				if tag~='table' then
					gen'='
					codegen(gen,v)
					-- gen:appendf('=%q',v.tag)
				else
					error('not implement')
				end
			end
			-- local tt=type(v)
			-- if tt=='string' then
			-- 	gen:appendf('%s')
			-- else
			gen','
		end
	gen'}'
end



function generators.classdecl(gen,c)	
	if c.extern then
		gen:appendf('%s = __yu_extern%q',getDeclName(c),c.alias or c.externname)
		for i,s in ipairs(c.decls) do
			if isExposable(s) then
				gen:expose(s)			
			end
		end
		return
	end
	local cons=false
	
	
	for i,s in ipairs(c.decls) do
		if isExposable(s) then
			if s.name=='__new' then 
				cons=s
			end
			codegen(gen,s)
		elseif s.vtype=='global' then 
			insert(gen.classGlobalVars,s)
		end
		
	end

	gen:cr()

	gen:appendf('__yu_newclass(%q,%s,%s,',			
			c.name,
			getDeclName(c),
			c.superclass and getSuperClassDeclName(c,c.superclass) or 'nil'
		)
	if c.superclass then gen:refer(c.superclass) end
	gen:ii()
	gen:cr()
	gen'{'
	gen:cr()
	for i,d in ipairs(c.decls) do
		if d.tag=='methoddecl' and not d.abstract then
			gen:appendf('%s=%s;',d.name,getDeclName(d))
			gen:cr()
		end
	end
	gen:di()
	gen'}'
	
	gen')'
	gen:cr()	
end

function generators.funcdecl(gen,f)
	--TODO:!!!!!!!!!!!!!!!
	if f.abstract then 
		--todo:add a abstract place holder
		return
	end
	
	if f.extern then 		
		gen:appendf('%s = __yu_extern%q',getDeclName(f),f.alias or f.externname)
		return
	end
	--generate exposed decl
	for i,s in ipairs(f.block) do		
		if isExposable(s) then
			gen:expose(s)			
		end
	end
	
	gen:cr()

	local ismethod=f.tag=='methoddecl'
	if ismethod then
		gen:appendf('function %s',getDeclName(f))
	elseif f.name=='@main' then
		gen:append('function __yu_main')
	else
		if f.localfunc then gen'local ' end
		gen:appendf('function %s',getDeclName(f))
	end

	gen'('
	
	if ismethod then 
		gen'self' 
		if f.type.args[1] then gen',' end
	elseif f.name=='@main' then
		gen'...'
	end

	codegenList(gen,f.type.args)
	gen')'

	codegen(gen,f.block)
	gen'end'
	
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
	gen:appendf('%s = yu.runtime.signalCreate(%q);',sig.refname,sig.name)
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
	local c=getConstNode(v)
	if c then return codegen(gen,c) end

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
		gen'('
			gen:mark(c)
			codegenList(gen,c.args)
		gen')'
	elseif tag=='member' then
		local mtype=c.l.mtype

		if mtype=='methodcall' then
			codegen(gen,c.l)
			gen'(' 
				gen:mark(c)
				codegenList(gen,c.args)
			gen')'
		elseif mtype=='super' then --static call
			gen(getDeclName(c.l.decl))
			gen'( self' 
				gen:mark(c)
				if c.args then gen',' end
				codegenList(gen,c.args)
				gen')'
			gen:refer(c.l.decl)
		elseif mtype=='static' then
			--gen(getDeclName(c.l.decl))
			codegen(gen,c.l)
			gen'('
				gen:mark(c)
				codegenList(gen,c.args)
			gen')'
			gen:refer(c.l.decl)
		else
			table.foreach( c.l, print )
			error('wtf?'..tostring(mtype))
		end
	else
		gen(getDeclName(c.l.decl))
		gen'('
			gen:mark(c)
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
	gen:refer(n.class.decl)
	gen:appendf('__yu_newobject(%s,',getDeclName(n.class.decl))
		gen:mark(n)
		gen'{'
		gen:ii()
		gen:cr()


		gen:di()
		gen:cr()
		gen'}'
		if n.constructor then 
			gen','
			gen(getDeclName(n.constructor))
		end
		if n.args and #n.args>0 then 
			gen',' 
			codegenList(gen,n.args)
		end
	gen')'
end

function generators.tcall( gen,n )	
	gen:appendf('__yu_newobject(%s,',getDeclName(n.l.decl))
		codegen(gen,n.arg)		
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
	gen:mark(b)

	--TODO:operator override
end

function generators.unop(gen,u)
	gen(u.op)
	gen'('
		gen:mark(u)
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
	local c=getConstNode(m)
	if c then return codegen(gen,c) end
	
	local mtype=m.mtype
	if mtype=='methodcall' then
		codegen(gen,m.l)
		gen:mark(m)
		gen(':'..m.id)
	elseif mtype=='member' then
		decl=m.decl
		if decl.tag=='methoddecl' then --build a methodpointer
			codegen(gen,m.l)
			gen:mark(m,true,1) --error maybe in next line
			gen(':__build_methodpointer("'..m.id..'")')
		else
			codegen(gen,m.l)
			gen:mark(m,true,1) --error maybe in next line
			gen('.'..m.id)
		end
	elseif mtype=='static' then
		local ldecl=m.l.decl
		if ldecl and ldecl.extern and ldecl.tag=='var' then --extern class static member
			codegen(gen,m.l)
			gen:mark(m)
			gen('.'..m.id)
		else
			gen(getDeclName(m.decl))
			if ldecl then gen:refer(ldecl) end
			gen:refer(m.decl)
		end
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

	gen'[' 	
	codegen(gen,i.key)
	gen:mark(i)
	gen']'
end

function generators.table(gen,t)
	gen'{'
		codegenList(gen,t.items)
	gen'}'
end

function generators.item(gen,i)
	gen'['
	gen:mark(i)
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
	
	if a.nocast then
		return codegen(gen,a.l)
	end
	local dst=a.dst

	local t=dst.decl
	if t.tag=='stringtype' then
		gen'__yu_tostring(' codegen(gen,a.l) gen')'
	elseif t.tag=='numbertype' then
		gen'tonumber(' codegen(gen,a.l) gen')'
	else
		gen'__yu_cast('
			codegen(gen,a.l)
			gen','
			codegen(gen,a.dst)
		gen')'
	end
end

function generators.is(gen,i)
	gen'__yu_is('
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

local function generateModule(m)
	local gen=doCodegen(m)
	local output=gen:tostring()
	return output
end

local function generateAllModule(m ,generated)
	generated=generated or {}
	local output=generateModule(m)
	
	for k,mm in pairs(m.externModules) do
		if not generated[mm] then
			output=generateAllModule(mm,generated)..'\n'..output
		end
	end
	return output
end


local function generateFullCode(entry)
	local header='require"yu.runtime"\n'
	local code=generateAllModule(entry)
	code=header..code	
	return code
end


_M.generateFullCode=generateFullCode
_M.generateModule=generateModule