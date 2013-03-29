local args={...}
if MOAISim then
	os.clock=MOAISim.getDeviceTime
end
-- require 'tools.clidebugger'
require "tools.printtable"

-- setmetatable(_G,{__index=function(t,k) error("undefined symbol:"..k,2) end})

local t0=os.clock()
require "yu.yu"
local compilerloadtime=os.clock()-t0
t0=os.clock()
local builder=yu.newBuilder()
builder:setPreprocessorEnvironment{
	DEBUG=false
}
local targetFile=args[1]
builder:build((targetFile or 'test/moai.yu'))

local buildtime=os.clock()-t0
t0=os.clock()

local codegentime=os.clock()-t0


print "---------------build time elapsed-----------"
print(string.format("\tloading:   \t%.2f",compilerloadtime*1000))
print(string.format("\tparse:     \t%.2f",yu.totalParseTime*1000))
print(string.format("\tdecl:      \t%.2f",yu.totalDeclTime*1000))
print(string.format("\tresolve:   \t%.2f",yu.totalResolveTime*1000))
print(string.format("\ttotalbuild:\t%.2f",buildtime*1000))
print(string.format("\tcodegen:   \t%.2f",yu.totalGenerateTime*1000))
print "-------------------------------------------"


require 'yu.runtime'
local function stripExt(p)
	p=string.gsub(p,'%..*$','')
	return p
end

yu.runtime.run(stripExt(targetFile))
