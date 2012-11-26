
local args={...}
if MOAISim then
	os.clock=MOAISim.getDeviceTime
end

-- setmetatable(_G,{__index=function(t,k) error("undefined symbol:"..k,2) end})
require "tools.printtable"
local t0=os.clock()
require "yu.yu"
local compilerloadtime=os.clock()-t0
t0=os.clock()
local builder1=yu.newBuilder()
m=builder1:build((args[1] or 'test/moai.yu'))

local buildtime=os.clock()-t0
t0=os.clock()

local code=yu.codegen(m)

local codegentime=os.clock()-t0


print "---------------build time elapsed-----------"
print(string.format("\tloading:   \t%.2f",compilerloadtime*1000))
print(string.format("\tparse:     \t%.2f",yu.totalParseTime*1000))
print(string.format("\tdecl:      \t%.2f",yu.totalDeclTime*1000))
print(string.format("\tresolve:   \t%.2f",yu.totalResolveTime*1000))
print(string.format("\ttotalbuild:\t%.2f",buildtime*1000))
print(string.format("\tcodegen:   \t%.2f",codegentime*1000))
print "-------------------------------------------"

local file=io.open(args[2] or 'output.lua','w')
file:write(code)
file:close()
-- print('file written.')
-- print "---------------generated code-------------"
-- print(code)

-- print "---------------execution-------------"
-- local f,a,b,c=loadstring(code)
-- if type(f)~='function' then 
-- 	print(a) 
-- else
-- 	local a,b=pcall(f)
-- 	if not a then print(b) end
-- end

-- print "-------------------------------------------"

-- if not args[2] then dofile('output.lua') end
require 'yu.runtime'

local outFunc=loadfile('output.lua')
xpcall(outFunc,yu.runtime.errorHandler)