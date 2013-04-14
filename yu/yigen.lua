--intermediate interface info generator
local format,gsub,unescape = string.format,string.gsub,unescape
local pairs,ipairs,next=pairs,ipairs,next

module('yu', package.seeall)

local getDeclName=getDeclName
local getType,getTypeDecl=getType,getTypeDecl
local yigenModule, yigenClass, yigenFunc,  yigenEnum, yigenNode, yigenVar

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
		gen'line_offset={'
		local off1=0
		for l,off in ipairs(m.lineInfo) do
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
			gen:appendf('name = %q; ', td.name or '??')
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
					if rt.alias then
						gen:cr()
						gen:appendf('alias=%q;',rt.alias)
					end
					yigenType(gen, rt)
					gen'},'
				end
			else
				gen:cr()
				gen'{'
				if ret.alias then
					gen:cr()
					gen:appendf('alias=%q;',ret.alias)
				end
					yigenType(gen, ret)
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
			yigenType(gen, td.ktype, 'etype')
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
-- function 

local currentModule
-- local 
local yiloadNode, yiloadClass, yiloadVar, yiloadFunc, yiloadType

function yiloadNode(d)
	d.module=currentModule
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
	f.type=yiloadType(f.type)
end

function yiloadClass(c)
	for k, d in pairs(c.scope) do
		yiloadNode(d)
	end 
	c.valuetype=true
	c.type=classMetaType
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
	v.type=yiloadType(v.type)
end

function yiloadType(t)
	local tt=type(t)
	if tt=='string' then --TODO: find symbol
		error('todo find type:'..t)

	elseif tt=='table' then
		local tag=t.tag
		if tag=='functype' then
			t.resolveState='done'
			t.valuetype=true
			t.type=funcMetaType
			return t
		elseif tag=='tabletype' then
			t.resolveState='done'
			t.valuetype=true
			t.type=tableMetaType
			return t
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

function loadInterface(data, externModules, namedExternModule)
	local m={}
	m.path=data.file
	m.modpath=stripExt(m.path)

	m.externModules=externModules
	m.namedExternModule=namedExternModule

	m.line_offset=data.line_offset
	m.scope=data.scope
	currentModule=m
	for k, d in pairs(m.scope) do
		yiloadNode(d)
	end
	m.module=m
	m.resolveState='done'
	currentModule=nil
	return m
end
