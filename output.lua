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
	__YU_MODULE_LOADER["signal"]=function()
	local __YU_LOADED, __YU_LOADER=__YU_RUNTIME.makeSymbolTable() __YU_MODULE_LOADED["signal"]=__YU_LOADED
	
	function __YU_LOADER.__main()
	
	__YU_LOADED.test_S0 = __YU_RUNTIME.signalCreate("test");
	function __YU_LOADER.Light_C3()
		local class= __YU_RUNTIME.newClass("Light")
		__YU_LOADED.Light_C3=class
		local classbody = class.__index 
		__YU_LOADED.stateChanged_S16 = __YU_RUNTIME.signalCreate("stateChanged");
		function __YU_LOADER.switchState_F17()
		
		local print_F10,stateChanged_S16 
		local func=function ( self ) 
			do 
				local __SWITCH = self .state 
				if __SWITCH== "red" then 
					self .state = "yellow" 
				elseif __SWITCH== "yellow" then 
					self .state = "green" 
				elseif __SWITCH== "green" then 
					self .state = "red" 
				end 
			end 
			stateChanged_S16(self , self .state ) ; 
			print_F10 ( "light:" .. self .id .. " is " .. self .state ) ; 
		 end ; 
		__YU_LOADED.switchState_F17 = func
		print_F10=__YU_LOADED.print_F10
		stateChanged_S16=__YU_LOADED.stateChanged_S16
		return func 
		end 
		__YU_LOADED.Light_C3__new =function ( self ) 
			self .state = "off" 
			self .id = nil 
		 end ; 
		classbody.switchState=__YU_LOADED.switchState_F17;
		return class
	end 
	function __YU_LOADER.Driver_C4()
		local class= __YU_RUNTIME.newClass("Driver")
		__YU_LOADED.Driver_C4=class
		local classbody = class.__index 
		function __YU_LOADER.waitLight_F20()
		
		local onLightChanged_F21,stateChanged_S16 
		local func=function ( self , l_v18 ) 
			__YU_CONNECT( stateChanged_S16 , l_v18 , self .onLightChanged , self ); 
		 end ; 
		__YU_LOADED.waitLight_F20 = func
		stateChanged_S16=__YU_LOADED.stateChanged_S16
		onLightChanged_F21=__YU_LOADED.onLightChanged_F21
		return func 
		end 
		function __YU_LOADER.onLightChanged_F21()
		
		local print_F10 
		local func=function ( self , state_v19 ) 
			print_F10 ( "I saw the light changed" ) ; 
			do 
				local __SWITCH = state_v19 
				if __SWITCH== "red" then 
					print_F10 ( "Time to stop" ) ; 
				elseif __SWITCH== "yellow" then 
					print_F10 ( "Get ready to go" ) ; 
				elseif __SWITCH== "green" then 
					print_F10 ( "Bon voyage" ) ; 
				end 
			end 
		 end ; 
		__YU_LOADED.onLightChanged_F21 = func
		print_F10=__YU_LOADED.print_F10
		return func 
		end 
		classbody.waitLight=__YU_LOADED.waitLight_F20;
		classbody.onLightChanged=__YU_LOADED.onLightChanged_F21;
		return class
	end 
	function __YU_LOADER.Button_C2()
		local class= __YU_RUNTIME.newClass("Button")
		__YU_LOADED.Button_C2=class
		local classbody = class.__index 
		__YU_LOADED.pressed_S12 = __YU_RUNTIME.signalCreate("pressed");
		function __YU_LOADER.realTrigger_F13()
		
		local pressed_S12 
		local func=function ( self ) 
			pressed_S12(self ) ; 
		 end ; 
		__YU_LOADED.realTrigger_F13 = func
		pressed_S12=__YU_LOADED.pressed_S12
		return func 
		end 
		classbody.realTrigger=__YU_LOADED.realTrigger_F13;
		return class
	end 
	__YU_LOADED.buttonHub_S1 = __YU_RUNTIME.signalCreate("buttonHub");
	__YU_LOADED.print_F10 =__YU_EXTERN("print")
	local Light_C3,Button_C2,switchState_F17,Driver_C4,pressed_S12,print_F10 
	local func=function ( ) 
		
		local l1_v5 = __YU_NEWOBJ( { [ "id" ]= 1 , [ "state" ]= "red" } , Light_C3 ) 
		local l2_v6 = __YU_NEWOBJ( { [ "id" ]= 2 , [ "state" ]= "red" } , Light_C3 ) 
		local b1_v7 = __YU_NEWOBJ( {}, Button_C2 ) 
		local b2_v8 = __YU_NEWOBJ( {}, Button_C2 ) 
		local driver_v9 = __YU_NEWOBJ( {}, Driver_C4 ) 
		driver_v9 :waitLight ( l2_v6 ) ; 
		__YU_CONNECT( pressed_S12 , b1_v7 , l1_v5 .switchState , l1_v5 ); 
		__YU_CONNECT( pressed_S12 , b2_v8 , l2_v6 .switchState , l2_v6 ); 
		print_F10 ( "*button 1 press" ) ; 
		pressed_S12(b1_v7 ) ; 
		print_F10 ( "*button 2 press" ) ; 
		pressed_S12(b2_v8 ) ; 
		print_F10 ( "*button 1 press" ) ; 
		pressed_S12(b1_v7 ) ; 
	 end ; 
	__YU_LOADED.__main = func
	Button_C2=__YU_LOADED.Button_C2
	Light_C3=__YU_LOADED.Light_C3
	Driver_C4=__YU_LOADED.Driver_C4
	print_F10=__YU_LOADED.print_F10
	pressed_S12=__YU_LOADED.pressed_S12
	switchState_F17=__YU_LOADED.switchState_F17
	return func 
	end 
	return __YU_LOADED, __YU_LOADED.__main 
end 
return __YU_MODULE_LOADED["signal"].__main()
	