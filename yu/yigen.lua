--intermediate interface info generator
local format,gsub,unescape = string.format,string.gsub,unescape
local pairs,ipairs,next=pairs,ipairs,next

module('yu', package.seeall)

local getDeclName=getDeclName
local getType,getTypeDecl=getType,getTypeDecl
local yigenModule, yigenClass, yigenFunc,  yigenEnum, yigenNode, yigenVar
local isBuiltinType,getBuiltinType=isBuiltinType,getBuiltinType

local getConstNode,constToString =getConstNode, constToString


function yigenNode(gen, node)
	local tag=node.tag
	local name=node.name
	gen:cr()
	gen:appendf('%s = {', name)
	gen:ii()
		gen:cr()
		gen:appendf('tag = %q ; name = %q ; refname = %q ;', tag, name , node.refname)
		gen:cr()
		gen:appendf('p0 = %d; p1 = %d;', node.p0, node.p1)

		if tag=='funcdecl' or tag=='methoddecl' then
			if node.abstract then
				gen:cr()
				gen'abstract = true ;'
			end

			if node.final then
				gen:cr()
				gen'final = true ;'
			end

			yigenFunc(gen,node)
		elseif tag=='var' then
			yigenVar(gen,node)
		elseif tag=='classdecl' then
			yigenClass(gen,node)
		elseif tag=='enumdecl' then
			yigenEnum(gen,node)
		elseif tag=='import' then
			yigenImport(gen, node)
		else
			error('unsupported yi generation:'..tag)
		end

	gen:di()
	gen:cr()
	gen'};'
	gen:cr()

end

function yigenFunc(gen,f)
	yigenType(gen, f.type)
end

function yigenImport(gen, i)
	gen:cr()
	gen:appendf('path = %q;', i.mod.path)
end

function yigenClass(gen,c)
	if c.superclass then
		gen:cr()
		gen:appendf('superclass = %q ;', c.superclass.name)
	end
	if c.abstract then
		gen:cr()
		gen'abstract = true;'
	end

	gen:cr()
	gen'scope = {'
	gen:ii() 
	local scope=c.scope
	--member
	for k, v in pairs(scope) do
		if not v.private then
			yigenNode(gen, v)
		end
	end
	gen:di() gen:cr()
	gen'};'
end

function yigenVar(gen,v)
	gen:cr()
	gen:appendf('vtype = %q;',v.vtype)
	yigenType(gen , v.type)
end

function yigenEnum(gen,e)
	gen:cr()
	gen'scope={'
	for i,t in pairs(e.items) do
		gen:appendf(' %s = %d,', t.name, t.value.v)
	end
	gen'};'
end

function yigenModule(gen,m)
	--info
	gen'return {'
	gen:ii()
	gen:cr()

		gen:cr()
		gen'----module info--'
		gen:cr()
		gen:appendf('file=%q;', m.file)
		gen:cr()
		gen:appendf('name=%q;', m.name)
		gen:cr()
		gen'line_offset={'
		local off1=0
		for l,off in ipairs(m.lineOffset) do
			gen:append((off-off1)..',')
			off1=off
		end
		gen'};'

		gen:cr()
		gen'import={'
		gen:ii()
		for i,node in ipairs(m.heads) do
			if node.tag=='import' then
				ex=node.mod
				gen:cr()
				gen'{'
				gen:appendf("path = %q,",ex.path)
				if node.alias then
					gen:appendf("alias = %q,",node.alias)
				end
				gen'},'
			end
		end

		gen:di()
		gen:cr()
		gen'};'

		gen:cr()
		gen:cr()
		gen'----interface info--'
		gen:cr()

		--scope
		gen:cr()
		gen'scope={'
		gen:ii()

			local scope=m.scope
			for k, v in pairs(scope) do
				if not v.private then
					yigenNode(gen, v)
				end
			end

		gen:di()
		gen:cr()
		gen'}'
		gen:cr()
		
	gen:di()
	gen:cr()
	gen'}'
	gen:cr()
end

function yigenType(gen, t, typekey)
	local td=getTypeDecl(t)
	gen:cr()
	gen:appendf('%s = ', typekey or 'type')
	local tag=td.tag
	if tag=='functype' then --make signature
		gen'{'
		gen:ii()
			gen:cr()
			gen'tag = "functype";'
			gen:cr()
			gen:appendf('name = %q; ', td.name)
			--args
			gen:cr()
			if next(td.args) then
				gen'args = {' 
				gen:ii()
					for i,arg in ipairs(td.args) do
						gen:cr()
						gen'{'
						gen:ii()
							gen:cr()
							gen:appendf('name = %q;',arg.name)
							yigenType(gen, arg.type, 'type')
							if arg.value then
								gen:cr()
								local c=getConstNode(arg.value)
								gen:appendf('value = {%s};', constToString(c))
							end
						gen:di()
						gen:cr()
						gen'},'
					end
				gen:di()
				gen:cr()
				gen'};'
			else
				gen'args = {} ;'
			end
			gen:cr()
			local ret=td.rettype
			gen'rettype = {'
			gen:ii()
			if ret.tag=='mulrettype' then
				for i, rt in ipairs(ret.types) do
					gen:cr()
					gen'{'
					gen:ii()
					if rt.alias then
						gen:cr()
						gen:appendf('alias=%q;',rt.alias)
					end
					yigenType(gen, rt)
					gen:di()
					gen'},'
				end
			else
				gen:cr()
				gen'{'
					gen:ii()
					if ret.alias then
						gen:cr()
						gen:appendf('alias=%q;',ret.alias)
					end
					yigenType(gen, ret)
					gen:di()
					gen:cr()
				gen'}'
			end
			gen:di()
			gen:cr()
			gen'}' --end of ret
		
		gen:di()
		gen:cr()
		gen'};' --end of functype

	elseif tag=='tabletype' then
		gen'{'
		gen:ii()
			gen:cr()
			gen'tag = "tabletype";'
			gen:cr()
			gen:appendf('name = %q;', td.name or '??')
			yigenType(gen, td.ktype, 'ktype')
			yigenType(gen, td.etype, 'etype')
		gen:di()
		gen:cr()
		gen'};'
	elseif tag=='vararg' then
		gen'{'
		gen:ii()
			gen:cr()
			gen'tag = "vararg";'
			gen:cr()
			gen:appendf('name = %q;', td.name or '??')
			yigenType(gen, td.type, "type")
		gen:di()
		gen:cr()
		gen'};'	
	else
		if not td.name then table.foreach(td,print) end
		gen:appendf( '%q ;', td.name)
	end
end

function generateInterface(m)
	local gen=newCodeWriter()
	yigenModule(gen, m)
	return gen:tostring()
end



------------YI Loader----
local yiloadNode, yiloadClass, yiloadVar, yiloadFunc, yiloadType


local function yifindExternSymbol(entryModule,name,searchSeq) --should be safe without check duplications
	local externModules=entryModule.externModules
	if externModules then
		entryModule._seq=searchSeq --a random table as sequence

		for p,m in pairs(externModules) do			
			if m.__seq~=searchSeq and not entryModule.namedExternModule[m] then
				m.__seq=searchSeq
				local decl=m.scope[name]
				if decl and not decl.private then 
					return decl
				end
				decl=yifindExternSymbol(m,name,searchSeq)
				if decl then return decl end
			end
		end
	end
	
	return nil
end

local function yifindSymbol(m, name)
	local s=getBuiltinType(name)
	if s then return s end
	s=m.scope[name]
	if s then return s end
	
	s = yifindExternSymbol(m, name, {})
	assert(s)
	return s
	-- error('todo extern symbol:'..name)
end

function yiloadNode(d)
	d.resolveState='done'

	local tag=d.tag
	if tag=='funcdecl' or tag=='methoddecl' then
		yiloadFunc(d)
	elseif tag=='var' then
		yiloadVar(d)
	elseif tag=='classdecl' then
		yiloadClass(d)
	elseif tag=='enumdecl' then
		yiloadEnum(d)
	end
end

function yiloadFunc(f)
	f.type=yiloadType(f.module, f.type)
end

function yiloadClass(c)

	for k, d in pairs(c.scope) do
		d.module=c.module
		yiloadNode(d)
	end 
	c.valuetype=true
	c.type=classMetaType
	if c.superclass then
		c.superclass=yifindSymbol(c.module, c.superclass)
	end
	c.resolveState='done'
end

function yiloadEnum(e)
	e.valuetype=true
	e.type=enumMetaType
	local scope=e.scope --convert to resolver acceptable format	
	for k,v in pairs(scope) do
		scope[k]={
			tag='enumitem',
			resolveState='done',
			name=k,
			value=makeNumberConst(v),
			type=e
		}
	end
	e.items=newitems
end

function yiloadVar(v)
	v.type=yiloadType(v.module, v.type)
end

function yiloadType(m, t)
	local tt=type(t)

	if tt=='string' then 
		return yifindSymbol(m, t)
	elseif tt=='table' then
		local tag=t.tag
		if tag=='functype' then
			t.resolveState='done'
			t.valuetype=true
			t.type=funcMetaType
			
			local args=t.args
			for i, arg in ipairs(args) do
				arg.tag='arg'
				arg.type=yiloadType(m, arg.type)
				if arg.value then
					local v=arg.value[1]
					local tt= type(v)
					if tt=='nil' then
						arg.value=nilConst
					elseif tt=='number' then
						arg.value=makeNumberConst(v)
					elseif tt=='string' then
						arg.value=makeStringConst(v)
					elseif tt=='boolean' then
						arg.value=v and trueConst or falseConst
					else
						error("FATAL:unsupported arg value type:"..tt)
					end
				end
			end

			local ret=t.rettype
			local converted={}
			for i, rt in ipairs(ret) do
				converted[i]=yiloadType(m,rt.type)
			end
			if #converted>1 then
				t.rettype={
					tag='mulrettype',
					types=converted
				}
			else
				t.rettype=converted[1]
			end

			return t
		elseif tag=='tabletype' then
			t.resolveState='done'
			t.valuetype=true
			t.type=tableMetaType
			t.ktype=yiloadType(m,t.ktype)
			t.etype=yiloadType(m,t.etype)
			return t
		elseif tag=='vararg' then
			t.resolveState='done'
			t.valuetype=false
			t.type=yiloadType(m, t.type)
			return t
		else

			error("???")
		end
	end

end


local function fixpath(p)
	p=string.gsub(p,'\\','/')
	return p
end

local function stripExt(p)
	p=fixpath(p)
	p=string.gsub(p,'%..*$','')
	return p
end

function loadInterface(data, imports, namedExternModule)
	local m={}
	m.file=data.file
	m.path=data.file
	m.name=data.name
	m.modpath=stripExt(m.path)
	
	local externModules={}
	for im, mod in pairs(imports) do
		externModules[mod.path]=mod
	end

	m.externModules=externModules
	m.namedExternModule=namedExternModule

	m.lineOffset=data.line_offset
	m.scope=data.scope
	m.module=m

	for k, d in pairs(m.scope) do
		d.module=m
		yiloadNode(d)
	end
	m.resolveState='done'
	return m
end
