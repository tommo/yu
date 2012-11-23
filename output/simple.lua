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
local type = type
	__YU_MODULE_LOADER["string"]=function()
	local __YU_LOADED, __YU_LOADER=__YU_RUNTIME.makeSymbolTable() __YU_MODULE_LOADED["string"]=__YU_LOADED
	
	function __YU_LOADER.__main()
	
	__YU_LOADED.format_F0 =__YU_EXTERN("string.format")
	local func=function ( ) 
		
	 end ; 
	__YU_LOADED.__main = func
	local _=__YU_LOADED.format_F0
	return func 
	end 
	return __YU_LOADED, __YU_LOADED.__main 
end 
__YU_MODULE_LOADER["io"]=function()
	local __YU_LOADED, __YU_LOADER=__YU_RUNTIME.makeSymbolTable() __YU_MODULE_LOADED["io"]=__YU_LOADED
	
	function __YU_LOADER.__main()
	
	__YU_LOADED.read_F1 =__YU_EXTERN("io.read")
	function __YU_LOADER.File_C4()
		local class= __YU_RUNTIME.newClass("File")
		__YU_LOADED.File_C4=class
		local classbody = class.__index 
		return class
	end 
	__YU_LOADED.write_F0 =__YU_EXTERN("io.write")
	__YU_LOADED.open_F2 =__YU_EXTERN("io.open")
	__YU_LOADED.type_F3 =__YU_EXTERN("io.type")
	local func=function ( ) 
		
	 end ; 
	__YU_LOADED.__main = func
	local _=__YU_LOADED.write_F0
	local _=__YU_LOADED.read_F1
	local _=__YU_LOADED.open_F2
	local _=__YU_LOADED.type_F3
	local _=__YU_LOADED.File_C4
	return func 
	end 
	return __YU_LOADED, __YU_LOADED.__main 
end 
__YU_MODULE_LOADER["math"]=function()
	local __YU_LOADED, __YU_LOADER=__YU_RUNTIME.makeSymbolTable() __YU_MODULE_LOADED["math"]=__YU_LOADED
	
	function __YU_LOADER.__main()
	
	__YU_LOADED.deg_F7 =__YU_EXTERN("math.deg")
	__YU_LOADED.asin_F8 =__YU_EXTERN("math.asin")
	__YU_LOADED.log10_F17 =__YU_EXTERN("math.log10")
	__YU_LOADED.random_F10 =__YU_EXTERN("math.random")
	__YU_LOADED.ceil_F13 =__YU_EXTERN("math.ceil")
	__YU_LOADED.cos_F4 =__YU_EXTERN("math.cos")
	__YU_LOADED.sin_F5 =__YU_EXTERN("math.sin")
	__YU_LOADED.log_F16 =__YU_EXTERN("math.log")
	__YU_LOADED.floor_F12 =__YU_EXTERN("math.floor")
	__YU_LOADED.atan2_F3 =__YU_EXTERN("math.atan2")
	__YU_LOADED.min_F1 =function ( a_v38 , b_v39 ) 
		return ( a_v38 < b_v39  and  a_v38  or  b_v39 ) 
	 end ; 
	__YU_LOADED.randomseed_F11 =__YU_EXTERN("math.randomseed")
	__YU_LOADED.tan_F6 =__YU_EXTERN("math.tan")
	__YU_LOADED.max_F0 =function ( a_v36 , b_v37 ) 
		return ( a_v36 > b_v37  and  a_v36  or  b_v37 ) 
	 end ; 
	__YU_LOADED.abs_F2 =__YU_EXTERN("math.abs")
	__YU_LOADED.modf_F15 =__YU_EXTERN("math.modf")
	__YU_LOADED.sqrt_F14 =__YU_EXTERN("math.sqrt")
	__YU_LOADED.acos_F9 =__YU_EXTERN("math.acos")
	local func=function ( ) 
		
	 end ; 
	__YU_LOADED.__main = func
	local _=__YU_LOADED.max_F0
	local _=__YU_LOADED.min_F1
	local _=__YU_LOADED.abs_F2
	local _=__YU_LOADED.atan2_F3
	local _=__YU_LOADED.cos_F4
	local _=__YU_LOADED.sin_F5
	local _=__YU_LOADED.tan_F6
	local _=__YU_LOADED.deg_F7
	local _=__YU_LOADED.asin_F8
	local _=__YU_LOADED.acos_F9
	local _=__YU_LOADED.random_F10
	local _=__YU_LOADED.randomseed_F11
	local _=__YU_LOADED.floor_F12
	local _=__YU_LOADED.ceil_F13
	local _=__YU_LOADED.sqrt_F14
	local _=__YU_LOADED.modf_F15
	local _=__YU_LOADED.log_F16
	local _=__YU_LOADED.log10_F17
	return func 
	end 
	return __YU_LOADED, __YU_LOADED.__main 
end 
__YU_MODULE_LOADER["os"]=function()
	local __YU_LOADED, __YU_LOADER=__YU_RUNTIME.makeSymbolTable() __YU_MODULE_LOADED["os"]=__YU_LOADED
	
	function __YU_LOADER.__main()
	
	__YU_LOADED.getenv_F2 =__YU_EXTERN("os.getenv")
	__YU_LOADED.time_F4 =__YU_EXTERN("os.time")
	__YU_LOADED.exit_F1 =__YU_EXTERN("os.exit")
	__YU_LOADED.clock_F0 =__YU_EXTERN("os.clock")
	__YU_LOADED.execute_F3 =__YU_EXTERN("os.execute")
	local func=function ( ) 
		
	 end ; 
	__YU_LOADED.__main = func
	local _=__YU_LOADED.clock_F0
	local _=__YU_LOADED.exit_F1
	local _=__YU_LOADED.getenv_F2
	local _=__YU_LOADED.execute_F3
	local _=__YU_LOADED.time_F4
	return func 
	end 
	return __YU_LOADED, __YU_LOADED.__main 
end 
__YU_MODULE_LOADER["etc"]=function()
	local __YU_LOADED, __YU_LOADER=__YU_RUNTIME.makeSymbolTable() __YU_MODULE_LOADED["etc"]=__YU_LOADED
	
	function __YU_LOADER.__main()
	
	__YU_LOADED.print_F0 =__YU_EXTERN("print")
	__YU_LOADED.collectgarbage_F1 =__YU_EXTERN("collectgarbage")
	local func=function ( ) 
		
	 end ; 
	__YU_LOADED.__main = func
	local _=__YU_LOADED.print_F0
	local _=__YU_LOADED.collectgarbage_F1
	return func 
	end 
	return __YU_LOADED, __YU_LOADED.__main 
end 
__YU_MODULE_LOADER["std"]=function()
	local __YU_LOADED, __YU_LOADER=__YU_RUNTIME.makeSymbolTable() __YU_MODULE_LOADED["std"]=__YU_LOADED
	
	__YU_LOADED.__main =function ( ) 
		local shit_v0 = 1 
	 end ; 
	return __YU_LOADED, __YU_LOADED.__main 
end 
__YU_MODULE_LOADER["gfx"]=function()
	local __YU_LOADED, __YU_LOADER=__YU_RUNTIME.makeSymbolTable() __YU_MODULE_LOADED["gfx"]=__YU_LOADED
	
	function __YU_LOADER.__main()
	
	__YU_LOADED.drawOval_F6 =__YU_EXTERN("drawOval")
	__YU_LOADED.setAlpha_F19 =__YU_EXTERN("setAlpha")
	__YU_LOADED.setScale_F23 =__YU_EXTERN("setScale")
	__YU_LOADED.MouseX_F11 =__YU_EXTERN("MouseX")
	__YU_LOADED.MouseHit_F13 =__YU_EXTERN("MouseHit")
	__YU_LOADED.flip_F4 =__YU_EXTERN("flip")
	__YU_LOADED.MilliSecs_F8 =__YU_EXTERN("MilliSecs")
	__YU_LOADED.drawRect_F5 =__YU_EXTERN("drawRect")
	__YU_LOADED.setBlend_F18 =__YU_EXTERN("setBlend")
	function __YU_LOADER.getMousePos_F1()
	
	local MouseX_F11,MouseY_F12 
	local func=function ( ) 
		return MouseX_F11 ( ) , MouseY_F12 ( ) 
	 end ; 
	__YU_LOADED.getMousePos_F1 = func
	MouseX_F11=__YU_LOADED.MouseX_F11
	MouseY_F12=__YU_LOADED.MouseY_F12
	return func 
	end __YU_LOADED.Blend_v0={}
	function __YU_LOADER.BMXImage_C24()
		local class= __YU_RUNTIME.newClass("BMXImage")
		__YU_LOADED.BMXImage_C24=class
		local classbody = class.__index 
		__YU_LOADED.load_F71 =__YU_EXTERN("loadImage")
		return class
	end 
	__YU_LOADED.drawLine_F7 =__YU_EXTERN("drawLine")
	__YU_LOADED.setColor_F17 =__YU_EXTERN("setColor")
	__YU_LOADED.cls_F15 =__YU_EXTERN("cls")
	__YU_LOADED.drawText_F16 =__YU_EXTERN("drawText")
	__YU_LOADED.endGraphics_F3 =__YU_EXTERN("endGraphics")
	function __YU_LOADER.Image_C21()
		local class= __YU_RUNTIME.newClass("Image")
		__YU_LOADED.Image_C21=class
		local classbody = class.__index 
		__YU_LOADED.load_F61 =__YU_EXTERN("loadImage")
		return class
	end 
	__YU_LOADED.setClsColor_F20 =__YU_EXTERN("setClsColor")
	__YU_LOADED.MouseY_F12 =__YU_EXTERN("MouseY")
	__YU_LOADED.setRotation_F22 =__YU_EXTERN("setRotation")
	__YU_LOADED.KeyDown_F10 =__YU_EXTERN("KeyDown")
	__YU_LOADED.KeyHit_F9 =__YU_EXTERN("KeyHit")
	__YU_LOADED.MouseDown_F14 =__YU_EXTERN("MouseDown")
	__YU_LOADED.Graphics_F2 =__YU_EXTERN("Graphics")
	local func=function ( ) 
		
	 end ; 
	__YU_LOADED.__main = func
	local _=__YU_LOADED.Blend_v0
	local _=__YU_LOADED.getMousePos_F1
	local _=__YU_LOADED.Graphics_F2
	local _=__YU_LOADED.endGraphics_F3
	local _=__YU_LOADED.flip_F4
	local _=__YU_LOADED.drawRect_F5
	local _=__YU_LOADED.drawOval_F6
	local _=__YU_LOADED.drawLine_F7
	local _=__YU_LOADED.MilliSecs_F8
	local _=__YU_LOADED.KeyHit_F9
	local _=__YU_LOADED.KeyDown_F10
	local _=__YU_LOADED.MouseX_F11
	local _=__YU_LOADED.MouseY_F12
	local _=__YU_LOADED.MouseHit_F13
	local _=__YU_LOADED.MouseDown_F14
	local _=__YU_LOADED.cls_F15
	local _=__YU_LOADED.drawText_F16
	local _=__YU_LOADED.setColor_F17
	local _=__YU_LOADED.setBlend_F18
	local _=__YU_LOADED.setAlpha_F19
	local _=__YU_LOADED.setClsColor_F20
	local _=__YU_LOADED.Image_C21
	local _=__YU_LOADED.setRotation_F22
	local _=__YU_LOADED.setScale_F23
	local _=__YU_LOADED.BMXImage_C24
	return func 
	end 
	return __YU_LOADED, __YU_LOADED.__main 
end 
__YU_MODULE_LOADER["simple"]=function()
	local __YU_LOADED, __YU_LOADER=__YU_RUNTIME.makeSymbolTable() __YU_MODULE_LOADED["simple"]=__YU_LOADED
	
	function __YU_LOADER.__main()
	
	function __YU_LOADER.rand_F4()
	
	local random_F10 
	local func=function ( v_v14 ) 
		return random_F10 ( ) * v_v14 
	 end ; 
	__YU_LOADED.rand_F4 = func
	random_F10=__YU_MODULE_LOADED["math"].random_F10
	return func 
	end 
	function __YU_LOADER.RectEnt_C3()
		local class= __YU_RUNTIME.newClass("RectEnt")
		__YU_LOADED.RectEnt_C3=class
		local classbody = class.__index 
		__YU_LOADED.onUpdate_F12 =function ( self ) 
			self .x = self .x + self .dx 
			self .y = self .y + self .dy 
			if self .x < 0 then 
				self .x = 0 
				self .dx = - ( self .dx ) 
			end 
			if self .y < 0 then 
				self .y = 0 
				self .dy = - ( self .dy ) 
			end 
			if self .x > 500 then 
				self .x = 500 
				self .dx = - ( self .dx ) 
			end 
			if self .y > 500 then 
				self .y = 500 
				self .dy = - ( self .dy ) 
			end 
		 end ; 
		function __YU_LOADER.onDraw_F13()
		
		local drawOval_F6 
		local func=function ( self ) 
			drawOval_F6 ( self .x , self .y , 15 , 15 ) ; 
		 end ; 
		__YU_LOADED.onDraw_F13 = func
		drawOval_F6=__YU_MODULE_LOADED["gfx"].drawOval_F6
		return func 
		end 
		__YU_LOADED.RectEnt_C3__new =function ( self ) 
			self .dx = nil 
			self .dy = nil 
		 end ; class.__super=__YU_LOADED.Entity_C2
		classbody.onUpdate=__YU_LOADED.onUpdate_F12;
		classbody.onDraw=__YU_LOADED.onDraw_F13;
		return class
	end 
	function __YU_LOADER.Entity_C2()
		local class= __YU_RUNTIME.newClass("Entity")
		__YU_LOADED.Entity_C2=class
		local classbody = class.__index 
		__YU_LOADED.Entity_C2__new =function ( self ) 
			self .y = nil 
			self .x = nil 
		 end ; 
		return class
	end 
	local setBlend_F18,cls_F15,setAlpha_F19,KeyHit_F9,RectEnt_C3,Graphics_F2,flip_F4,setColor_F17,rand_F4 
	local func=function ( ) 
		
		
		Graphics_F2 ( 500 , 500 , 0 ) ; 
		local ents_v5 = { } 
		for i_v15 = 1 , 3000 do 
			local e1_v16 = __YU_NEWOBJ( { [ "x" ]= rand_F4 ( 500 ) , [ "y" ]= rand_F4 ( 500 ) , [ "dx" ]= rand_F4 ( 5 ) , [ "dy" ]= rand_F4 ( 5 ) } , RectEnt_C3 ) 
			ents_v5 [ i_v15 ] = e1_v16 
		end 
		setBlend_F18 ( 4 ) ; 
		setAlpha_F19 ( 0.3 ) ; 
		while not ( KeyHit_F9 ( 27 ) ) do 
			flip_F4 ( -1 ) ; 
			cls_F15 ( ) ; 
			for i_v17 , e_v18 in next , ents_v5  do 
				e_v18 :onUpdate ( ) ; 
				setColor_F17 ( rand_F4 ( 255 ) , rand_F4 ( 255 ) , rand_F4 ( 255 ) ) ; 
				e_v18 :onDraw ( ) ; 
			end 
		end 
	 end ; 
	__YU_LOADED.__main = func
	local _=__YU_LOADED.Entity_C2
	Graphics_F2=__YU_MODULE_LOADED["gfx"].Graphics_F2
	RectEnt_C3=__YU_LOADED.RectEnt_C3
	flip_F4=__YU_MODULE_LOADED["gfx"].flip_F4
	rand_F4=__YU_LOADED.rand_F4
	KeyHit_F9=__YU_MODULE_LOADED["gfx"].KeyHit_F9
	cls_F15=__YU_MODULE_LOADED["gfx"].cls_F15
	setColor_F17=__YU_MODULE_LOADED["gfx"].setColor_F17
	setBlend_F18=__YU_MODULE_LOADED["gfx"].setBlend_F18
	setAlpha_F19=__YU_MODULE_LOADED["gfx"].setAlpha_F19
	return func 
	end 
	return __YU_LOADED, __YU_LOADED.__main 
end 
return __YU_MODULE_LOADED["simple"].__main()
	