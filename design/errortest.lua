
local args={...}


-- setmetatable(_G,{__index=function(t,k) error("undefined symbol:"..k,2) end})
require "tools.printtable"
local t0=os.clock()
require "yu.yu"
local compilerloadtime=os.clock()-t0
t0=os.clock()
local file=args[1] or 'test/m1.yu'
local m=yu.parseFile(file,true)
print(table.show(m))