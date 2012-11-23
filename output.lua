local __YU_RUNTIME=require'yu.runtime'
local __YU_CONNECT=__YU_RUNTIME.signalConnect
local __YU_SPAWN=__YU_RUNTIME.generatorSpawn
local __YU_RESUME=__YU_RUNTIME.generatorResume
local __YU_YIELD=__YU_RUNTIME.generatorYield
local __YU_WAIT=__YU_RUNTIME.signalWait
local __YU_ASSERT=__YU_RUNTIME.doAssert
local __YU_NEWOBJ=__YU_RUNTIME.newObject
local __YU_EXTERN=__YU_RUNTIME.loadExternSymbol
local __YU_OBJ_NEXT=__YU_RUNTIME.objectNext
local __YU_MODULE_LOADED, __YU_MODULE_LOADER=__YU_RUNTIME.makeSymbolTable()
local __YU_ISTYPE = __YU_RUNTIME.isType
	__YU_MODULE_LOADER["math"]=function()
	local __YU_LOADED, __YU_LOADER=__YU_RUNTIME.makeSymbolTable() __YU_MODULE_LOADED["math"]=__YU_LOADED
	
	function __YU_LOADER.__main()
	
	__YU_LOADED.acos_F9 =__YU_EXTERN("math.acos")
	__YU_LOADED.cos_F4 =__YU_EXTERN("math.cos")
	__YU_LOADED.randomseed_F11 =__YU_EXTERN("math.randomseed")
	__YU_LOADED.log10_F17 =__YU_EXTERN("math.log10")
	__YU_LOADED.floor_F12 =__YU_EXTERN("math.floor")
	__YU_LOADED.abs_F2 =__YU_EXTERN("math.abs")
	__YU_LOADED.tan_F6 =__YU_EXTERN("math.tan")
	__YU_LOADED.atan2_F3 =__YU_EXTERN("math.atan2")
	__YU_LOADED.modf_F15 =__YU_EXTERN("math.modf")
	__YU_LOADED.sin_F5 =__YU_EXTERN("math.sin")
	__YU_LOADED.asin_F8 =__YU_EXTERN("math.asin")
	__YU_LOADED.min_F1 =function ( a , b ) 
		return ( a < b  and  a  or  b ) 
	 end ; 
	__YU_LOADED.max_F0 =function ( a , b ) 
		return ( a > b  and  a  or  b ) 
	 end ; 
	__YU_LOADED.log_F16 =__YU_EXTERN("math.log")
	__YU_LOADED.deg_F7 =__YU_EXTERN("math.deg")
	__YU_LOADED.random_F10 =__YU_EXTERN("math.random")
	__YU_LOADED.ceil_F13 =__YU_EXTERN("math.ceil")
	__YU_LOADED.sqrt_F14 =__YU_EXTERN("math.sqrt")
	local func=function ( ) 
		
	 end ; 
	__YU_LOADED.__main = func
	return func 
	end 
	return __YU_LOADED, __YU_LOADED.__main 
end 
__YU_MODULE_LOADER["etc"]=function()
	local __YU_LOADED, __YU_LOADER=__YU_RUNTIME.makeSymbolTable() __YU_MODULE_LOADED["etc"]=__YU_LOADED
	
	function __YU_LOADER.__main()
	
	__YU_LOADED.collectgarbage_F1 =__YU_EXTERN(".collectgarbage")
	__YU_LOADED.print_F0 =__YU_EXTERN(".print")
	local func=function ( ) 
		
	 end ; 
	__YU_LOADED.__main = func
	return func 
	end 
	return __YU_LOADED, __YU_LOADED.__main 
end 
__YU_MODULE_LOADER["io"]=function()
	local __YU_LOADED, __YU_LOADER=__YU_RUNTIME.makeSymbolTable() __YU_MODULE_LOADED["io"]=__YU_LOADED
	
	function __YU_LOADER.__main()
	
	__YU_LOADED.open_F2 =__YU_EXTERN("io.open")
	__YU_LOADED.read_F1 =__YU_EXTERN("io.read")
	__YU_LOADED.type_F3 =__YU_EXTERN("io.type")
	function __YU_LOADER.File_C4()
		local class= __YU_RUNTIME.newClass("File")
		__YU_LOADED.File_C4=class
		local classbody = class.__index 
		return class
	end 
	__YU_LOADED.write_F0 =__YU_EXTERN("io.write")
	local func=function ( ) 
		
	 end ; 
	__YU_LOADED.__main = func
	return func 
	end 
	return __YU_LOADED, __YU_LOADED.__main 
end 
__YU_MODULE_LOADER["string"]=function()
	local __YU_LOADED, __YU_LOADER=__YU_RUNTIME.makeSymbolTable() __YU_MODULE_LOADED["string"]=__YU_LOADED
	
	function __YU_LOADER.__main()
	
	__YU_LOADED.format_F0 =__YU_EXTERN("string.format")
	local func=function ( ) 
		
	 end ; 
	__YU_LOADED.__main = func
	return func 
	end 
	return __YU_LOADED, __YU_LOADED.__main 
end 
__YU_MODULE_LOADER["os"]=function()
	local __YU_LOADED, __YU_LOADER=__YU_RUNTIME.makeSymbolTable() __YU_MODULE_LOADED["os"]=__YU_LOADED
	
	function __YU_LOADER.__main()
	
	__YU_LOADED.getenv_F2 =__YU_EXTERN("os.getenv")
	__YU_LOADED.execute_F3 =__YU_EXTERN("os.execute")
	__YU_LOADED.exit_F1 =__YU_EXTERN("os.exit")
	__YU_LOADED.clock_F0 =__YU_EXTERN("os.clock")
	__YU_LOADED.time_F4 =__YU_EXTERN("os.time")
	local func=function ( ) 
		
	 end ; 
	__YU_LOADED.__main = func
	return func 
	end 
	return __YU_LOADED, __YU_LOADED.__main 
end 
__YU_MODULE_LOADER["std"]=function()
	local __YU_LOADED, __YU_LOADER=__YU_RUNTIME.makeSymbolTable() __YU_MODULE_LOADED["std"]=__YU_LOADED
	
	function __YU_LOADER.__main()
	
	local print_F0,sin_F5 
	local func=function ( ) 
		local shit = 1 
		print_F0 ( sin_F5 ) ; 
	 end ; 
	__YU_LOADED.__main = func
	print_F0=__YU_MODULE_LOADED["etc"].print_F0
	sin_F5=__YU_MODULE_LOADED["math"].sin_F5
	return func 
	end 
	return __YU_LOADED, __YU_LOADED.__main 
end 
__YU_MODULE_LOADER["vec"]=function()
	local __YU_LOADED, __YU_LOADER=__YU_RUNTIME.makeSymbolTable() __YU_MODULE_LOADED["vec"]=__YU_LOADED
	
	function __YU_LOADER.__main()
	
	function __YU_LOADER.Vec_C0()
		local class= __YU_RUNTIME.newClass("Vec")
		__YU_LOADED.Vec_C0=class
		local classbody = class.__index 
		function __YU_LOADER.add_F11()
		
		local Vec_C0 
		local func=function ( self , v1 ) 
			return __YU_NEWOBJ( { [ "x" ]= self .x + v1 .x , [ "y" ]= self .y + v1 .y } , Vec_C0 ) 
		 end ; 
		__YU_LOADED.add_F11 = func
		Vec_C0=__YU_LOADED.Vec_C0
		return func 
		end 
		function __YU_LOADER.sub_F12()
		
		local Vec_C0 
		local func=function ( self , v1 ) 
			return __YU_NEWOBJ( { [ "x" ]= self .x - v1 .x , [ "y" ]= self .y - v1 .y } , Vec_C0 ) 
		 end ; 
		__YU_LOADED.sub_F12 = func
		Vec_C0=__YU_LOADED.Vec_C0
		return func 
		end 
		function __YU_LOADER.mul_F13()
		
		local Vec_C0 
		local func=function ( self , s ) 
			return __YU_NEWOBJ( { [ "x" ]= self .x * s , [ "y" ]= self .y * s } , Vec_C0 ) 
		 end ; 
		__YU_LOADED.mul_F13 = func
		Vec_C0=__YU_LOADED.Vec_C0
		return func 
		end 
		function __YU_LOADER.div_F14()
		
		local Vec_C0 
		local func=function ( self , s ) 
			return __YU_NEWOBJ( { [ "x" ]= self .x / s , [ "y" ]= self .y / s } , Vec_C0 ) 
		 end ; 
		__YU_LOADED.div_F14 = func
		Vec_C0=__YU_LOADED.Vec_C0
		return func 
		end 
		__YU_LOADED.tostring_F15 =function ( self ) 
			return "(" .. self .x .. "," .. self .y .. ")" 
		 end ; 
		__YU_LOADED.__new_F16 =function ( self , x , y ) 
			self .x = nil 
			self .y = nil 
			self .x , self .y = x , y 
		 end ; 
		classbody.add=__YU_LOADED.add_F11;
		classbody.sub=__YU_LOADED.sub_F12;
		classbody.mul=__YU_LOADED.mul_F13;
		classbody.div=__YU_LOADED.div_F14;
		classbody.tostring=__YU_LOADED.tostring_F15;
		return class
	end 
	local Vec_C0,print_F0 
	local func=function ( ) 
		local v = __YU_NEWOBJ( { [ "x" ]= 1 , [ "y" ]= 20 } , Vec_C0 ) 
		local i = 1 
		while true do local __dobreak=true repeat 
			if v .x > 100 then 
				break 
			end 
			v = v :mul ( 2 ) 
			if v .x < 20 then 
				__dobreak=false break 
			end 
			print_F0 ( v :tostring ( ) ) ; 
		__dobreak=false until true if __dobreak then break end end 
	 end ; 
	__YU_LOADED.__main = func
	Vec_C0=__YU_LOADED.Vec_C0
	print_F0=__YU_MODULE_LOADED["etc"].print_F0
	return func 
	end 
	return __YU_LOADED, __YU_LOADED.__main 
end 
return __YU_MODULE_LOADED["vec"].__main()
	