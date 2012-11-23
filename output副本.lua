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
	__YU_MODULE_LOADER["api"]=function()
	local __YU_LOADED, __YU_LOADER=__YU_RUNTIME.makeSymbolTable() __YU_MODULE_LOADED["api"]=__YU_LOADED
	
	function __YU_LOADER.__main()
	
	function __YU_LOADER.MOAIBox2DWheelJoint_C18()
		local class= __YU_RUNTIME.newClass("MOAIBox2DWheelJoint")
		__YU_LOADED.MOAIBox2DWheelJoint_C18=class
		local classbody = class.__index 
		__YU_LOADED.new_F381 =__YU_EXTERN("MOAIBox2DWheelJoint.new")class.__super=__YU_LOADED.MOAIBox2DJoint_C11
		return class
	end 
	function __YU_LOADER.MOAICpBody_C28()
		local class= __YU_RUNTIME.newClass("MOAICpBody")
		__YU_LOADED.MOAICpBody_C28=class
		local classbody = class.__index 
		__YU_LOADED.new_F648 =__YU_EXTERN("MOAICpBody.new")
		return class
	end 
	function __YU_LOADER.MOAITileFlags_C110()
		local class= __YU_RUNTIME.newClass("MOAITileFlags")
		__YU_LOADED.MOAITileFlags_C110=class
		local classbody = class.__index 
		__YU_LOADED.new_F1970 =__YU_EXTERN("MOAITileFlags.new")
		return class
	end 
	function __YU_LOADER.MOAIScriptNode_C95()
		local class= __YU_RUNTIME.newClass("MOAIScriptNode")
		__YU_LOADED.MOAIScriptNode_C95=class
		local classbody = class.__index 
		__YU_LOADED.new_F1771 =__YU_EXTERN("MOAIScriptNode.new")class.__super=__YU_LOADED.MOAINode_C72
		return class
	end 
	function __YU_LOADER.MOAIParticleForce_C76()
		local class= __YU_RUNTIME.newClass("MOAIParticleForce")
		__YU_LOADED.MOAIParticleForce_C76=class
		local classbody = class.__index 
		__YU_LOADED.new_F1519 =__YU_EXTERN("MOAIParticleForce.new")
		return class
	end 
	function __YU_LOADER.MOAIButtonSensor_C20()
		local class= __YU_RUNTIME.newClass("MOAIButtonSensor")
		__YU_LOADED.MOAIButtonSensor_C20=class
		local classbody = class.__index 
		__YU_LOADED.new_F477 =__YU_EXTERN("MOAIButtonSensor.new")class.__super=__YU_LOADED.MOAISensor_C96
		return class
	end 
	function __YU_LOADER.MOAIAnim_C2()
		local class= __YU_RUNTIME.newClass("MOAIAnim")
		__YU_LOADED.MOAIAnim_C2=class
		local classbody = class.__index 
		__YU_LOADED.new_F152 =__YU_EXTERN("MOAIAnim.new")
		return class
	end 
	function __YU_LOADER.MOAIEnvironment_C42()
		local class= __YU_RUNTIME.newClass("MOAIEnvironment")
		__YU_LOADED.MOAIEnvironment_C42=class
		local classbody = class.__index 
		__YU_LOADED.getScreenSize_F960 =__YU_EXTERN("MOAIEnvironment.getScreenSize")
		__YU_LOADED.isRetinaDisplay_F961 =__YU_EXTERN("MOAIEnvironment.isRetinaDisplay")
		__YU_LOADED.getLanguageCode_F962 =__YU_EXTERN("MOAIEnvironment.getLanguageCode")
		__YU_LOADED.generateGUID_F963 =__YU_EXTERN("MOAIEnvironment.generateGUID")
		__YU_LOADED.getCountryCode_F964 =__YU_EXTERN("MOAIEnvironment.getCountryCode")
		__YU_LOADED.getConnectionType_F965 =__YU_EXTERN("MOAIEnvironment.getConnectionType")
		__YU_LOADED.getCarrierMobileNetworkCode_F966 =__YU_EXTERN("MOAIEnvironment.getCarrierMobileNetworkCode")
		__YU_LOADED.getAppID_F967 =__YU_EXTERN("MOAIEnvironment.getAppID")
		__YU_LOADED.getOSVersion_F968 =__YU_EXTERN("MOAIEnvironment.getOSVersion")
		__YU_LOADED.getCPUABI_F969 =__YU_EXTERN("MOAIEnvironment.getCPUABI")
		__YU_LOADED.getResourceDirectory_F970 =__YU_EXTERN("MOAIEnvironment.getResourceDirectory")
		__YU_LOADED.getViewSize_F971 =__YU_EXTERN("MOAIEnvironment.getViewSize")
		__YU_LOADED.getDevProduct_F972 =__YU_EXTERN("MOAIEnvironment.getDevProduct")
		__YU_LOADED.getOSBrand_F973 =__YU_EXTERN("MOAIEnvironment.getOSBrand")
		__YU_LOADED.getDocumentDirectory_F974 =__YU_EXTERN("MOAIEnvironment.getDocumentDirectory")
		__YU_LOADED.getCarrierName_F975 =__YU_EXTERN("MOAIEnvironment.getCarrierName")
		__YU_LOADED.getAppDisplayName_F976 =__YU_EXTERN("MOAIEnvironment.getAppDisplayName")
		__YU_LOADED.getAppVersion_F977 =__YU_EXTERN("MOAIEnvironment.getAppVersion")
		__YU_LOADED.getDevManufacturer_F978 =__YU_EXTERN("MOAIEnvironment.getDevManufacturer")
		__YU_LOADED.getUDID_F979 =__YU_EXTERN("MOAIEnvironment.getUDID")
		__YU_LOADED.getDevModel_F980 =__YU_EXTERN("MOAIEnvironment.getDevModel")
		__YU_LOADED.getCarrierMobileCountryCode_F981 =__YU_EXTERN("MOAIEnvironment.getCarrierMobileCountryCode")
		__YU_LOADED.getDevBrand_F982 =__YU_EXTERN("MOAIEnvironment.getDevBrand")
		__YU_LOADED.getCacheDirectory_F983 =__YU_EXTERN("MOAIEnvironment.getCacheDirectory")
		__YU_LOADED.getCarrierISOCountryCode_F984 =__YU_EXTERN("MOAIEnvironment.getCarrierISOCountryCode")
		__YU_LOADED.getDevName_F985 =__YU_EXTERN("MOAIEnvironment.getDevName")
		__YU_LOADED.new_F986 =__YU_EXTERN("MOAIEnvironment.new")
		return class
	end 
	function __YU_LOADER.MOAILogMgr_C69()
		local class= __YU_RUNTIME.newClass("MOAILogMgr")
		__YU_LOADED.MOAILogMgr_C69=class
		local classbody = class.__index 
		__YU_LOADED.log_F1423 =__YU_EXTERN("MOAILogMgr.log")
		__YU_LOADED.setLogLevel_F1424 =__YU_EXTERN("MOAILogMgr.setLogLevel")
		__YU_LOADED.isDebugBuild_F1425 =__YU_EXTERN("MOAILogMgr.isDebugBuild")
		__YU_LOADED.registerLogMessage_F1426 =__YU_EXTERN("MOAILogMgr.registerLogMessage")
		__YU_LOADED.openFile_F1427 =__YU_EXTERN("MOAILogMgr.openFile")
		__YU_LOADED.closeFile_F1428 =__YU_EXTERN("MOAILogMgr.closeFile")
		return class
	end 
	function __YU_LOADER.MOAIBox2DFrictionJoint_C9()
		local class= __YU_RUNTIME.newClass("MOAIBox2DFrictionJoint")
		__YU_LOADED.MOAIBox2DFrictionJoint_C9=class
		local classbody = class.__index 
		__YU_LOADED.new_F273 =__YU_EXTERN("MOAIBox2DFrictionJoint.new")class.__super=__YU_LOADED.MOAIBox2DJoint_C11
		return class
	end 
	function __YU_LOADER.MOAICpShape_C30()
		local class= __YU_RUNTIME.newClass("MOAICpShape")
		__YU_LOADED.MOAICpShape_C30=class
		local classbody = class.__index 
		__YU_LOADED.momentForCircle_F764 =__YU_EXTERN("MOAICpShape.momentForCircle")
		__YU_LOADED.momentForRect_F765 =__YU_EXTERN("MOAICpShape.momentForRect")
		__YU_LOADED.momentForSegment_F766 =__YU_EXTERN("MOAICpShape.momentForSegment")
		__YU_LOADED.momentForPolygon_F778 =__YU_EXTERN("MOAICpShape.momentForPolygon")
		__YU_LOADED.areaForRect_F780 =__YU_EXTERN("MOAICpShape.areaForRect")
		__YU_LOADED.areaForCircle_F784 =__YU_EXTERN("MOAICpShape.areaForCircle")
		__YU_LOADED.areaForSegment_F785 =__YU_EXTERN("MOAICpShape.areaForSegment")
		__YU_LOADED.new_F786 =__YU_EXTERN("MOAICpShape.new")
		return class
	end 
	function __YU_LOADER.MOAITextLayout_C107()
		local class= __YU_RUNTIME.newClass("MOAITextLayout")
		__YU_LOADED.MOAITextLayout_C107=class
		local classbody = class.__index 
		return class
	end 
	function __YU_LOADER.MOAIDataBuffer_C32()
		local class= __YU_RUNTIME.newClass("MOAIDataBuffer")
		__YU_LOADED.MOAIDataBuffer_C32=class
		local classbody = class.__index 
		__YU_LOADED.inflate_F872 =__YU_EXTERN("MOAIDataBuffer.inflate")
		__YU_LOADED.toCppHeader_F876 =__YU_EXTERN("MOAIDataBuffer.toCppHeader")
		__YU_LOADED.deflate_F881 =__YU_EXTERN("MOAIDataBuffer.deflate")
		__YU_LOADED.new_F884 =__YU_EXTERN("MOAIDataBuffer.new")
		return class
	end 
	function __YU_LOADER.MOAIProp2D_C92()
		local class= __YU_RUNTIME.newClass("MOAIProp2D")
		__YU_LOADED.MOAIProp2D_C92=class
		local classbody = class.__index 
		__YU_LOADED.new_F1756 =__YU_EXTERN("MOAIProp2D.new")class.__super=__YU_LOADED.MOAITransform_C113
		return class
	end 
	function __YU_LOADER.MOAIGridSpace_C55()
		local class= __YU_RUNTIME.newClass("MOAIGridSpace")
		__YU_LOADED.MOAIGridSpace_C55=class
		local classbody = class.__index 
		return class
	end 
	function __YU_LOADER.MOAIGfxDevice_C47()
		local class= __YU_RUNTIME.newClass("MOAIGfxDevice")
		__YU_LOADED.MOAIGfxDevice_C47=class
		local classbody = class.__index 
		__YU_LOADED.setPenColor_F1049 =__YU_EXTERN("MOAIGfxDevice.setPenColor")
		__YU_LOADED.setClearDepth_F1050 =__YU_EXTERN("MOAIGfxDevice.setClearDepth")
		__YU_LOADED.setPointSize_F1052 =__YU_EXTERN("MOAIGfxDevice.setPointSize")
		__YU_LOADED.setPenWidth_F1053 =__YU_EXTERN("MOAIGfxDevice.setPenWidth")
		__YU_LOADED.setClearColor_F1054 =__YU_EXTERN("MOAIGfxDevice.setClearColor")
		return class
	end 
	function __YU_LOADER.MOAIMesh_C70()
		local class= __YU_RUNTIME.newClass("MOAIMesh")
		__YU_LOADED.MOAIMesh_C70=class
		local classbody = class.__index 
		__YU_LOADED.new_F1434 =__YU_EXTERN("MOAIMesh.new")
		return class
	end 
	function __YU_LOADER.MOAIViewport_C118()
		local class= __YU_RUNTIME.newClass("MOAIViewport")
		__YU_LOADED.MOAIViewport_C118=class
		local classbody = class.__index 
		__YU_LOADED.new_F2147 =__YU_EXTERN("MOAIViewport.new")
		return class
	end 
	function __YU_LOADER.MOAIDeck2D_C36()
		local class= __YU_RUNTIME.newClass("MOAIDeck2D")
		__YU_LOADED.MOAIDeck2D_C36=class
		local classbody = class.__index class.__super=__YU_LOADED.MOAIDeck_C35
		return class
	end 
	function __YU_LOADER.MOAIVertexFormatMgr_C117()
		local class= __YU_RUNTIME.newClass("MOAIVertexFormatMgr")
		__YU_LOADED.MOAIVertexFormatMgr_C117=class
		local classbody = class.__index 
		__YU_LOADED.new_F2135 =__YU_EXTERN("MOAIVertexFormatMgr.new")
		return class
	end 
	function __YU_LOADER.MOAIVertexFormat_C116()
		local class= __YU_RUNTIME.newClass("MOAIVertexFormat")
		__YU_LOADED.MOAIVertexFormat_C116=class
		local classbody = class.__index 
		__YU_LOADED.new_F2134 =__YU_EXTERN("MOAIVertexFormat.new")
		return class
	end 
	function __YU_LOADER.MOAIVertexBuffer_C115()
		local class= __YU_RUNTIME.newClass("MOAIVertexBuffer")
		__YU_LOADED.MOAIVertexBuffer_C115=class
		local classbody = class.__index 
		__YU_LOADED.new_F2118 =__YU_EXTERN("MOAIVertexBuffer.new")
		return class
	end 
	function __YU_LOADER.MOAIPathFinder_C87()
		local class= __YU_RUNTIME.newClass("MOAIPathFinder")
		__YU_LOADED.MOAIPathFinder_C87=class
		local classbody = class.__index 
		return class
	end 
	function __YU_LOADER.MOAIPointerSensor_C90()
		local class= __YU_RUNTIME.newClass("MOAIPointerSensor")
		__YU_LOADED.MOAIPointerSensor_C90=class
		local classbody = class.__index 
		__YU_LOADED.new_F1716 =__YU_EXTERN("MOAIPointerSensor.new")class.__super=__YU_LOADED.MOAISensor_C96
		return class
	end 
	function __YU_LOADER.MOAIBox2DWorld_C19()
		local class= __YU_RUNTIME.newClass("MOAIBox2DWorld")
		__YU_LOADED.MOAIBox2DWorld_C19=class
		local classbody = class.__index 
		__YU_LOADED.new_F470 =__YU_EXTERN("MOAIBox2DWorld.new")
		return class
	end 
	function __YU_LOADER.MOAIProp_C91()
		local class= __YU_RUNTIME.newClass("MOAIProp")
		__YU_LOADED.MOAIProp_C91=class
		local classbody = class.__index 
		__YU_LOADED.new_F1720 =__YU_EXTERN("MOAIProp.new")class.__super=__YU_LOADED.MOAINode_C72
		return class
	end 
	function __YU_LOADER.MOAITexture_C108()
		local class= __YU_RUNTIME.newClass("MOAITexture")
		__YU_LOADED.MOAITexture_C108=class
		local classbody = class.__index 
		__YU_LOADED.new_F1951 =__YU_EXTERN("MOAITexture.new")
		return class
	end 
	function __YU_LOADER.MOAICp_C26()
		local class= __YU_RUNTIME.newClass("MOAICp")
		__YU_LOADED.MOAICp_C26=class
		local classbody = class.__index 
		__YU_LOADED.getContactPersistence_F560 =__YU_EXTERN("MOAICp.getContactPersistence")
		__YU_LOADED.getCollisionSlop_F561 =__YU_EXTERN("MOAICp.getCollisionSlop")
		__YU_LOADED.getBiasCoefficient_F562 =__YU_EXTERN("MOAICp.getBiasCoefficient")
		__YU_LOADED.setContactPersistence_F563 =__YU_EXTERN("MOAICp.setContactPersistence")
		__YU_LOADED.setCollisionSlop_F564 =__YU_EXTERN("MOAICp.setCollisionSlop")
		__YU_LOADED.setBiasCoefficient_F565 =__YU_EXTERN("MOAICp.setBiasCoefficient")
		return class
	end 
	function __YU_LOADER.MOAITouchSensor_C112()
		local class= __YU_RUNTIME.newClass("MOAITouchSensor")
		__YU_LOADED.MOAITouchSensor_C112=class
		local classbody = class.__index 
		__YU_LOADED.new_F1995 =__YU_EXTERN("MOAITouchSensor.new")class.__super=__YU_LOADED.MOAISensor_C96
		return class
	end 
	function __YU_LOADER.MOAIParticleState_C79()
		local class= __YU_RUNTIME.newClass("MOAIParticleState")
		__YU_LOADED.MOAIParticleState_C79=class
		local classbody = class.__index 
		__YU_LOADED.new_F1599 =__YU_EXTERN("MOAIParticleState.new")
		return class
	end 
	function __YU_LOADER.MOAITileDeck2D_C109()
		local class= __YU_RUNTIME.newClass("MOAITileDeck2D")
		__YU_LOADED.MOAITileDeck2D_C109=class
		local classbody = class.__index 
		__YU_LOADED.new_F1969 =__YU_EXTERN("MOAITileDeck2D.new")class.__super=__YU_LOADED.MOAIDeck2D_C36
		return class
	end 
	function __YU_LOADER.MOAILayoutFrame_C65()
		local class= __YU_RUNTIME.newClass("MOAILayoutFrame")
		__YU_LOADED.MOAILayoutFrame_C65=class
		local classbody = class.__index 
		__YU_LOADED.new_F1412 =__YU_EXTERN("MOAILayoutFrame.new")
		return class
	end 
	function __YU_LOADER.MOAIPartitionResultMgr_C86()
		local class= __YU_RUNTIME.newClass("MOAIPartitionResultMgr")
		__YU_LOADED.MOAIPartitionResultMgr_C86=class
		local classbody = class.__index 
		return class
	end 
	function __YU_LOADER.MOAIParticleDistanceEmitter_C74()
		local class= __YU_RUNTIME.newClass("MOAIParticleDistanceEmitter")
		__YU_LOADED.MOAIParticleDistanceEmitter_C74=class
		local classbody = class.__index 
		__YU_LOADED.new_F1484 =__YU_EXTERN("MOAIParticleDistanceEmitter.new")
		return class
	end 
	function __YU_LOADER.MOAIParser_C73()
		local class= __YU_RUNTIME.newClass("MOAIParser")
		__YU_LOADED.MOAIParser_C73=class
		local classbody = class.__index 
		__YU_LOADED.new_F1479 =__YU_EXTERN("MOAIParser.new")
		return class
	end 
	function __YU_LOADER.MOAIColor_C23()
		local class= __YU_RUNTIME.newClass("MOAIColor")
		__YU_LOADED.MOAIColor_C23=class
		local classbody = class.__index 
		__YU_LOADED.new_F546 =__YU_EXTERN("MOAIColor.new")
		return class
	end 
	function __YU_LOADER.MOAITransform_C113()
		local class= __YU_RUNTIME.newClass("MOAITransform")
		__YU_LOADED.MOAITransform_C113=class
		local classbody = class.__index 
		__YU_LOADED.new_F2084 =__YU_EXTERN("MOAITransform.new")class.__super=__YU_LOADED.MOAITransformBase_C114
		return class
	end 
	function __YU_LOADER.MOAITextFrame_C106()
		local class= __YU_RUNTIME.newClass("MOAITextFrame")
		__YU_LOADED.MOAITextFrame_C106=class
		local classbody = class.__index 
		__YU_LOADED.new_F1936 =__YU_EXTERN("MOAITextFrame.new")
		return class
	end 
	function __YU_LOADER.MOAIWheelSensor_C119()
		local class= __YU_RUNTIME.newClass("MOAIWheelSensor")
		__YU_LOADED.MOAIWheelSensor_C119=class
		local classbody = class.__index class.__super=__YU_LOADED.MOAISensor_C96
		return class
	end 
	function __YU_LOADER.MOAISurfaceSampler2D_C104()
		local class= __YU_RUNTIME.newClass("MOAISurfaceSampler2D")
		__YU_LOADED.MOAISurfaceSampler2D_C104=class
		local classbody = class.__index 
		return class
	end 
	function __YU_LOADER.MOAIActionMgr_C1()
		local class= __YU_RUNTIME.newClass("MOAIActionMgr")
		__YU_LOADED.MOAIActionMgr_C1=class
		local classbody = class.__index 
		__YU_LOADED.getRoot_F136 =__YU_EXTERN("MOAIActionMgr.getRoot")
		__YU_LOADED.setProfilingEnabled_F137 =__YU_EXTERN("MOAIActionMgr.setProfilingEnabled")
		__YU_LOADED.setThreadInfoEnabled_F138 =__YU_EXTERN("MOAIActionMgr.setThreadInfoEnabled")
		__YU_LOADED.setRoot_F139 =__YU_EXTERN("MOAIActionMgr.setRoot")
		return class
	end 
	function __YU_LOADER.MOAISurfaceDeck2D_C103()
		local class= __YU_RUNTIME.newClass("MOAISurfaceDeck2D")
		__YU_LOADED.MOAISurfaceDeck2D_C103=class
		local classbody = class.__index 
		__YU_LOADED.new_F1891 =__YU_EXTERN("MOAISurfaceDeck2D.new")
		return class
	end 
	function __YU_LOADER.MOAISerializerBase_C98()
		local class= __YU_RUNTIME.newClass("MOAISerializerBase")
		__YU_LOADED.MOAISerializerBase_C98=class
		local classbody = class.__index 
		return class
	end 
	function __YU_LOADER.MOAIFrameBuffer_C46()
		local class= __YU_RUNTIME.newClass("MOAIFrameBuffer")
		__YU_LOADED.MOAIFrameBuffer_C46=class
		local classbody = class.__index 
		__YU_LOADED.new_F1036 =__YU_EXTERN("MOAIFrameBuffer.new")
		return class
	end 
	function __YU_LOADER.MOAIPartitionResultBuffer_C85()
		local class= __YU_RUNTIME.newClass("MOAIPartitionResultBuffer")
		__YU_LOADED.MOAIPartitionResultBuffer_C85=class
		local classbody = class.__index 
		return class
	end 
	function __YU_LOADER.MOAISim_C101()
		local class= __YU_RUNTIME.newClass("MOAISim")
		__YU_LOADED.MOAISim_C101=class
		local classbody = class.__index 
		__YU_LOADED.setLoopFlags_F1818 =__YU_EXTERN("MOAISim.setLoopFlags")
		__YU_LOADED.getMemoryUsage_F1819 =__YU_EXTERN("MOAISim.getMemoryUsage")
		__YU_LOADED.timeToFrames_F1820 =__YU_EXTERN("MOAISim.timeToFrames")
		__YU_LOADED.pushRenderPass_F1821 =__YU_EXTERN("MOAISim.pushRenderPass")
		__YU_LOADED.setStepMultiplier_F1822 =__YU_EXTERN("MOAISim.setStepMultiplier")
		__YU_LOADED.getDeviceTime_F1823 =__YU_EXTERN("MOAISim.getDeviceTime")
		__YU_LOADED.getElapsedFrames_F1824 =__YU_EXTERN("MOAISim.getElapsedFrames")
		__YU_LOADED.getElapsedTime_F1825 =__YU_EXTERN("MOAISim.getElapsedTime")
		__YU_LOADED.setLuaAllocLogEnabled_F1826 =__YU_EXTERN("MOAISim.setLuaAllocLogEnabled")
		__YU_LOADED.popRenderPass_F1827 =__YU_EXTERN("MOAISim.popRenderPass")
		__YU_LOADED.exitFullscreenMode_F1828 =__YU_EXTERN("MOAISim.exitFullscreenMode")
		__YU_LOADED.setStep_F1829 =__YU_EXTERN("MOAISim.setStep")
		__YU_LOADED.getLoopFlags_F1830 =__YU_EXTERN("MOAISim.getLoopFlags")
		__YU_LOADED.setTimerError_F1831 =__YU_EXTERN("MOAISim.setTimerError")
		__YU_LOADED.getDeviceSize_F1832 =__YU_EXTERN("MOAISim.getDeviceSize")
		__YU_LOADED.setCpuBudget_F1833 =__YU_EXTERN("MOAISim.setCpuBudget")
		__YU_LOADED.openWindow_F1834 =__YU_EXTERN("MOAISim.openWindow")
		__YU_LOADED.getPerformance_F1835 =__YU_EXTERN("MOAISim.getPerformance")
		__YU_LOADED.setLongDelayThreshold_F1836 =__YU_EXTERN("MOAISim.setLongDelayThreshold")
		__YU_LOADED.getStep_F1837 =__YU_EXTERN("MOAISim.getStep")
		__YU_LOADED.clearLoopFlags_F1838 =__YU_EXTERN("MOAISim.clearLoopFlags")
		__YU_LOADED.setLeakTrackingEnabled_F1839 =__YU_EXTERN("MOAISim.setLeakTrackingEnabled")
		__YU_LOADED.setHistogramEnabled_F1840 =__YU_EXTERN("MOAISim.setHistogramEnabled")
		__YU_LOADED.forceGarbageCollection_F1841 =__YU_EXTERN("MOAISim.forceGarbageCollection")
		__YU_LOADED.setBoostThreshold_F1842 =__YU_EXTERN("MOAISim.setBoostThreshold")
		__YU_LOADED.enterFullscreenMode_F1843 =__YU_EXTERN("MOAISim.enterFullscreenMode")
		__YU_LOADED.getLuaObjectCount_F1844 =__YU_EXTERN("MOAISim.getLuaObjectCount")
		__YU_LOADED.reportHistogram_F1845 =__YU_EXTERN("MOAISim.reportHistogram")
		__YU_LOADED.pauseTimer_F1846 =__YU_EXTERN("MOAISim.pauseTimer")
		__YU_LOADED.framesToTime_F1847 =__YU_EXTERN("MOAISim.framesToTime")
		__YU_LOADED.reportLeaks_F1848 =__YU_EXTERN("MOAISim.reportLeaks")
		__YU_LOADED.clearRenderStack_F1849 =__YU_EXTERN("MOAISim.clearRenderStack")
		return class
	end 
	function __YU_LOADER.MOAIDebugLines_C34()
		local class= __YU_RUNTIME.newClass("MOAIDebugLines")
		__YU_LOADED.MOAIDebugLines_C34=class
		local classbody = class.__index 
		__YU_LOADED.showStyle_F896 =__YU_EXTERN("MOAIDebugLines.showStyle")
		__YU_LOADED.setStyle_F897 =__YU_EXTERN("MOAIDebugLines.setStyle")
		return class
	end 
	function __YU_LOADER.MOAIBox2DPulleyJoint_C14()
		local class= __YU_RUNTIME.newClass("MOAIBox2DPulleyJoint")
		__YU_LOADED.MOAIBox2DPulleyJoint_C14=class
		local classbody = class.__index 
		__YU_LOADED.new_F330 =__YU_EXTERN("MOAIBox2DPulleyJoint.new")class.__super=__YU_LOADED.MOAIBox2DJoint_C11
		return class
	end 
	function __YU_LOADER.MOAIShaderMgr_C100()
		local class= __YU_RUNTIME.newClass("MOAIShaderMgr")
		__YU_LOADED.MOAIShaderMgr_C100=class
		local classbody = class.__index 
		return class
	end 
	function __YU_LOADER.MOAIStretchPatch2D_C102()
		local class= __YU_RUNTIME.newClass("MOAIStretchPatch2D")
		__YU_LOADED.MOAIStretchPatch2D_C102=class
		local classbody = class.__index 
		__YU_LOADED.new_F1878 =__YU_EXTERN("MOAIStretchPatch2D.new")
		return class
	end 
	function __YU_LOADER.MOAIImage_C57()
		local class= __YU_RUNTIME.newClass("MOAIImage")
		__YU_LOADED.MOAIImage_C57=class
		local classbody = class.__index 
		__YU_LOADED.new_F1331 =__YU_EXTERN("MOAIImage.new")
		return class
	end 
	function __YU_LOADER.MOAIGlyph_C52()
		local class= __YU_RUNTIME.newClass("MOAIGlyph")
		__YU_LOADED.MOAIGlyph_C52=class
		local classbody = class.__index 
		return class
	end 
	function __YU_LOADER.MOAIPartitionCell_C83()
		local class= __YU_RUNTIME.newClass("MOAIPartitionCell")
		__YU_LOADED.MOAIPartitionCell_C83=class
		local classbody = class.__index 
		return class
	end 
	function __YU_LOADER.MOAIMotionSensor_C71()
		local class= __YU_RUNTIME.newClass("MOAIMotionSensor")
		__YU_LOADED.MOAIMotionSensor_C71=class
		local classbody = class.__index 
		__YU_LOADED.new_F1438 =__YU_EXTERN("MOAIMotionSensor.new")class.__super=__YU_LOADED.MOAISensor_C96
		return class
	end 
	function __YU_LOADER.MOAIQuadBrush_C93()
		local class= __YU_RUNTIME.newClass("MOAIQuadBrush")
		__YU_LOADED.MOAIQuadBrush_C93=class
		local classbody = class.__index 
		return class
	end 
	function __YU_LOADER.MOAICpSpace_C31()
		local class= __YU_RUNTIME.newClass("MOAICpSpace")
		__YU_LOADED.MOAICpSpace_C31=class
		local classbody = class.__index 
		__YU_LOADED.new_F854 =__YU_EXTERN("MOAICpSpace.new")
		return class
	end 
	function __YU_LOADER.MOAISerializer_C97()
		local class= __YU_RUNTIME.newClass("MOAISerializer")
		__YU_LOADED.MOAISerializer_C97=class
		local classbody = class.__index 
		__YU_LOADED.serializeToFile_F1778 =__YU_EXTERN("MOAISerializer.serializeToFile")
		__YU_LOADED.serializeToString_F1781 =__YU_EXTERN("MOAISerializer.serializeToString")
		__YU_LOADED.new_F1783 =__YU_EXTERN("MOAISerializer.new")
		return class
	end 
	function __YU_LOADER.MOAIBox2DBody_C6()
		local class= __YU_RUNTIME.newClass("MOAIBox2DBody")
		__YU_LOADED.MOAIBox2DBody_C6=class
		local classbody = class.__index 
		__YU_LOADED.new_F237 =__YU_EXTERN("MOAIBox2DBody.new")
		return class
	end 
	function __YU_LOADER.MOAISensor_C96()
		local class= __YU_RUNTIME.newClass("MOAISensor")
		__YU_LOADED.MOAISensor_C96=class
		local classbody = class.__index 
		__YU_LOADED.new_F1772 =__YU_EXTERN("MOAISensor.new")
		return class
	end 
	function __YU_LOADER.MOAIGrid_C53()
		local class= __YU_RUNTIME.newClass("MOAIGrid")
		__YU_LOADED.MOAIGrid_C53=class
		local classbody = class.__index 
		__YU_LOADED.new_F1187 =__YU_EXTERN("MOAIGrid.new")
		return class
	end 
	function __YU_LOADER.MOAIDeserializer_C38()
		local class= __YU_RUNTIME.newClass("MOAIDeserializer")
		__YU_LOADED.MOAIDeserializer_C38=class
		local classbody = class.__index 
		__YU_LOADED.new_F908 =__YU_EXTERN("MOAIDeserializer.new")
		return class
	end 
	function __YU_LOADER.MOAIPathGraph_C88()
		local class= __YU_RUNTIME.newClass("MOAIPathGraph")
		__YU_LOADED.MOAIPathGraph_C88=class
		local classbody = class.__index 
		return class
	end 
	function __YU_LOADER.MOAIXmlParser_C120()
		local class= __YU_RUNTIME.newClass("MOAIXmlParser")
		__YU_LOADED.MOAIXmlParser_C120=class
		local classbody = class.__index 
		return class
	end 
	function __YU_LOADER.MOAILayer2D_C64()
		local class= __YU_RUNTIME.newClass("MOAILayer2D")
		__YU_LOADED.MOAILayer2D_C64=class
		local classbody = class.__index 
		__YU_LOADED.new_F1402 =__YU_EXTERN("MOAILayer2D.new")class.__super=__YU_LOADED.MOAIProp2D_C92
		return class
	end 
	function __YU_LOADER.MOAIDeckRemapper_C37()
		local class= __YU_RUNTIME.newClass("MOAIDeckRemapper")
		__YU_LOADED.MOAIDeckRemapper_C37=class
		local classbody = class.__index 
		__YU_LOADED.new_F907 =__YU_EXTERN("MOAIDeckRemapper.new")
		return class
	end 
	function __YU_LOADER.MOAIPathTerrainDeck_C89()
		local class= __YU_RUNTIME.newClass("MOAIPathTerrainDeck")
		__YU_LOADED.MOAIPathTerrainDeck_C89=class
		local classbody = class.__index 
		__YU_LOADED.reserve_F1711 =__YU_EXTERN("MOAIPathTerrainDeck.reserve")
		__YU_LOADED.new_F1712 =__YU_EXTERN("MOAIPathTerrainDeck.new")class.__super=__YU_LOADED.MOAIDeck2D_C36
		return class
	end 
	function __YU_LOADER.MOAICpConstraint_C29()
		local class= __YU_RUNTIME.newClass("MOAICpConstraint")
		__YU_LOADED.MOAICpConstraint_C29=class
		local classbody = class.__index 
		__YU_LOADED.newRotaryLimitJoint_F709 =__YU_EXTERN("MOAICpConstraint.newRotaryLimitJoint")
		__YU_LOADED.newDampedRotarySpring_F710 =__YU_EXTERN("MOAICpConstraint.newDampedRotarySpring")
		__YU_LOADED.newSimpleMotor_F711 =__YU_EXTERN("MOAICpConstraint.newSimpleMotor")
		__YU_LOADED.newSlideJoint_F715 =__YU_EXTERN("MOAICpConstraint.newSlideJoint")
		__YU_LOADED.newGearJoint_F716 =__YU_EXTERN("MOAICpConstraint.newGearJoint")
		__YU_LOADED.newGrooveJoint_F717 =__YU_EXTERN("MOAICpConstraint.newGrooveJoint")
		__YU_LOADED.newPinJoint_F719 =__YU_EXTERN("MOAICpConstraint.newPinJoint")
		__YU_LOADED.newPivotJoint_F720 =__YU_EXTERN("MOAICpConstraint.newPivotJoint")
		__YU_LOADED.newRatchetJoint_F721 =__YU_EXTERN("MOAICpConstraint.newRatchetJoint")
		__YU_LOADED.newDampedSpring_F722 =__YU_EXTERN("MOAICpConstraint.newDampedSpring")
		__YU_LOADED.new_F725 =__YU_EXTERN("MOAICpConstraint.new")
		return class
	end 
	function __YU_LOADER.MOAIParticleEmitter_C75()
		local class= __YU_RUNTIME.newClass("MOAIParticleEmitter")
		__YU_LOADED.MOAIParticleEmitter_C75=class
		local classbody = class.__index 
		return class
	end 
	function __YU_LOADER.MOAIDataIOAction_C33()
		local class= __YU_RUNTIME.newClass("MOAIDataIOAction")
		__YU_LOADED.MOAIDataIOAction_C33=class
		local classbody = class.__index 
		__YU_LOADED.new_F887 =__YU_EXTERN("MOAIDataIOAction.new")
		return class
	end 
	function __YU_LOADER.MOAIJoystickSensor_C61()
		local class= __YU_RUNTIME.newClass("MOAIJoystickSensor")
		__YU_LOADED.MOAIJoystickSensor_C61=class
		local classbody = class.__index 
		__YU_LOADED.new_F1342 =__YU_EXTERN("MOAIJoystickSensor.new")class.__super=__YU_LOADED.MOAISensor_C96
		return class
	end 
	function __YU_LOADER.MOAIScriptDeck_C94()
		local class= __YU_RUNTIME.newClass("MOAIScriptDeck")
		__YU_LOADED.MOAIScriptDeck_C94=class
		local classbody = class.__index 
		__YU_LOADED.new_F1766 =__YU_EXTERN("MOAIScriptDeck.new")class.__super=__YU_LOADED.MOAIDeck_C35
		return class
	end 
	function __YU_LOADER.MOAIJsonParser_C62()
		local class= __YU_RUNTIME.newClass("MOAIJsonParser")
		__YU_LOADED.MOAIJsonParser_C62=class
		local classbody = class.__index 
		__YU_LOADED.decode_F1345 =__YU_EXTERN("MOAIJsonParser.decode")
		__YU_LOADED.encode_F1346 =__YU_EXTERN("MOAIJsonParser.encode")
		__YU_LOADED.new_F1347 =__YU_EXTERN("MOAIJsonParser.new")
		return class
	end 
	function __YU_LOADER.MOAITransformBase_C114()
		local class= __YU_RUNTIME.newClass("MOAITransformBase")
		__YU_LOADED.MOAITransformBase_C114=class
		local classbody = class.__index 
		__YU_LOADED.new_F2089 =__YU_EXTERN("MOAITransformBase.new")class.__super=__YU_LOADED.MOAIProp_C91
		return class
	end 
	function __YU_LOADER.MOAICameraFitter2D_C22()
		local class= __YU_RUNTIME.newClass("MOAICameraFitter2D")
		__YU_LOADED.MOAICameraFitter2D_C22=class
		local classbody = class.__index 
		__YU_LOADED.new_F524 =__YU_EXTERN("MOAICameraFitter2D.new")class.__super=__YU_LOADED.MOAIProp2D_C92
		return class
	end 
	function __YU_LOADER.MOAIPartitionLayer_C84()
		local class= __YU_RUNTIME.newClass("MOAIPartitionLayer")
		__YU_LOADED.MOAIPartitionLayer_C84=class
		local classbody = class.__index 
		return class
	end 
	function __YU_LOADER.MOAITextBox_C105()
		local class= __YU_RUNTIME.newClass("MOAITextBox")
		__YU_LOADED.MOAITextBox_C105=class
		local classbody = class.__index 
		__YU_LOADED.new_F1935 =__YU_EXTERN("MOAITextBox.new")class.__super=__YU_LOADED.MOAIProp2D_C92
		return class
	end 
	function __YU_LOADER.MOAIParticleTimedEmitter_C81()
		local class= __YU_RUNTIME.newClass("MOAIParticleTimedEmitter")
		__YU_LOADED.MOAIParticleTimedEmitter_C81=class
		local classbody = class.__index 
		__YU_LOADED.new_F1644 =__YU_EXTERN("MOAIParticleTimedEmitter.new")
		return class
	end 
	function __YU_LOADER.MOAIParticleSystem_C80()
		local class= __YU_RUNTIME.newClass("MOAIParticleSystem")
		__YU_LOADED.MOAIParticleSystem_C80=class
		local classbody = class.__index 
		__YU_LOADED.new_F1640 =__YU_EXTERN("MOAIParticleSystem.new")
		return class
	end 
	function __YU_LOADER.MOAIDraw_C39()
		local class= __YU_RUNTIME.newClass("MOAIDraw")
		__YU_LOADED.MOAIDraw_C39=class
		local classbody = class.__index 
		__YU_LOADED.drawRay_F939 =__YU_EXTERN("MOAIDraw.drawRay")
		__YU_LOADED.drawLine_F940 =__YU_EXTERN("MOAIDraw.drawLine")
		__YU_LOADED.drawRect_F941 =__YU_EXTERN("MOAIDraw.drawRect")
		__YU_LOADED.drawCircle_F942 =__YU_EXTERN("MOAIDraw.drawCircle")
		__YU_LOADED.fillCircle_F943 =__YU_EXTERN("MOAIDraw.fillCircle")
		__YU_LOADED.fillEllipse_F944 =__YU_EXTERN("MOAIDraw.fillEllipse")
		__YU_LOADED.fillRect_F945 =__YU_EXTERN("MOAIDraw.fillRect")
		__YU_LOADED.drawEllipse_F946 =__YU_EXTERN("MOAIDraw.drawEllipse")
		__YU_LOADED.fillFan_F947 =__YU_EXTERN("MOAIDraw.fillFan")
		__YU_LOADED.drawPoints_F948 =__YU_EXTERN("MOAIDraw.drawPoints")
		return class
	end 
	function __YU_LOADER.MOAIHttpTask_C56()
		local class= __YU_RUNTIME.newClass("MOAIHttpTask")
		__YU_LOADED.MOAIHttpTask_C56=class
		local classbody = class.__index 
		__YU_LOADED.new_F1271 =__YU_EXTERN("MOAIHttpTask.new")
		return class
	end 
	function __YU_LOADER.MOAITimer_C111()
		local class= __YU_RUNTIME.newClass("MOAITimer")
		__YU_LOADED.MOAITimer_C111=class
		local classbody = class.__index 
		__YU_LOADED.new_F1984 =__YU_EXTERN("MOAITimer.new")
		return class
	end 
	function __YU_LOADER.MOAIGridPathGraph_C54()
		local class= __YU_RUNTIME.newClass("MOAIGridPathGraph")
		__YU_LOADED.MOAIGridPathGraph_C54=class
		local classbody = class.__index 
		__YU_LOADED.new_F1190 =__YU_EXTERN("MOAIGridPathGraph.new")
		return class
	end 
	function __YU_LOADER.MOAIBox2DDistanceJoint_C7()
		local class= __YU_RUNTIME.newClass("MOAIBox2DDistanceJoint")
		__YU_LOADED.MOAIBox2DDistanceJoint_C7=class
		local classbody = class.__index 
		__YU_LOADED.new_F247 =__YU_EXTERN("MOAIBox2DDistanceJoint.new")
		return class
	end 
	function __YU_LOADER.MOAIBox2DPrismaticJoint_C13()
		local class= __YU_RUNTIME.newClass("MOAIBox2DPrismaticJoint")
		__YU_LOADED.MOAIBox2DPrismaticJoint_C13=class
		local classbody = class.__index 
		__YU_LOADED.new_F324 =__YU_EXTERN("MOAIBox2DPrismaticJoint.new")class.__super=__YU_LOADED.MOAIBox2DJoint_C11
		return class
	end 
	function __YU_LOADER.MOAIParticleScript_C78()
		local class= __YU_RUNTIME.newClass("MOAIParticleScript")
		__YU_LOADED.MOAIParticleScript_C78=class
		local classbody = class.__index 
		__YU_LOADED.new_F1579 =__YU_EXTERN("MOAIParticleScript.new")
		return class
	end 
	function __YU_LOADER.MOAIParticlePlugin_C77()
		local class= __YU_RUNTIME.newClass("MOAIParticlePlugin")
		__YU_LOADED.MOAIParticlePlugin_C77=class
		local classbody = class.__index 
		return class
	end 
	function __YU_LOADER.MOAINode_C72()
		local class= __YU_RUNTIME.newClass("MOAINode")
		__YU_LOADED.MOAINode_C72=class
		local classbody = class.__index 
		return class
	end 
	function __YU_LOADER.MOAICameraAnchor2D_C21()
		local class= __YU_RUNTIME.newClass("MOAICameraAnchor2D")
		__YU_LOADED.MOAICameraAnchor2D_C21=class
		local classbody = class.__index 
		__YU_LOADED.new_F485 =__YU_EXTERN("MOAICameraAnchor2D.new")class.__super=__YU_LOADED.MOAIProp2D_C92
		return class
	end 
	function __YU_LOADER.MOAILogMessages_C68()
		local class= __YU_RUNTIME.newClass("MOAILogMessages")
		__YU_LOADED.MOAILogMessages_C68=class
		local classbody = class.__index 
		return class
	end 
	function __YU_LOADER.MOAIBox2DRopeJoint_C16()
		local class= __YU_RUNTIME.newClass("MOAIBox2DRopeJoint")
		__YU_LOADED.MOAIBox2DRopeJoint_C16=class
		local classbody = class.__index class.__super=__YU_LOADED.MOAIBox2DJoint_C11
		return class
	end 
	function __YU_LOADER.MOAIGfxQuad2D_C48()
		local class= __YU_RUNTIME.newClass("MOAIGfxQuad2D")
		__YU_LOADED.MOAIGfxQuad2D_C48=class
		local classbody = class.__index 
		__YU_LOADED.new_F1068 =__YU_EXTERN("MOAIGfxQuad2D.new")class.__super=__YU_LOADED.MOAIDeck2D_C36
		return class
	end 
	function __YU_LOADER.MOAIKeyboardSensor_C63()
		local class= __YU_RUNTIME.newClass("MOAIKeyboardSensor")
		__YU_LOADED.MOAIKeyboardSensor_C63=class
		local classbody = class.__index 
		__YU_LOADED.new_F1358 =__YU_EXTERN("MOAIKeyboardSensor.new")class.__super=__YU_LOADED.MOAISensor_C96
		return class
	end 
	function __YU_LOADER.MOAIFileSystem_C44()
		local class= __YU_RUNTIME.newClass("MOAIFileSystem")
		__YU_LOADED.MOAIFileSystem_C44=class
		local classbody = class.__index 
		__YU_LOADED.checkFileExists_F1004 =__YU_EXTERN("MOAIFileSystem.checkFileExists")
		__YU_LOADED.setWorkingDirectory_F1005 =__YU_EXTERN("MOAIFileSystem.setWorkingDirectory")
		__YU_LOADED.getAbsoluteFilePath_F1006 =__YU_EXTERN("MOAIFileSystem.getAbsoluteFilePath")
		__YU_LOADED.listDirectories_F1007 =__YU_EXTERN("MOAIFileSystem.listDirectories")
		__YU_LOADED.getAbsoluteDirectoryPath_F1008 =__YU_EXTERN("MOAIFileSystem.getAbsoluteDirectoryPath")
		__YU_LOADED.getWorkingDirectory_F1009 =__YU_EXTERN("MOAIFileSystem.getWorkingDirectory")
		__YU_LOADED.rename_F1010 =__YU_EXTERN("MOAIFileSystem.rename")
		__YU_LOADED.affirmPath_F1011 =__YU_EXTERN("MOAIFileSystem.affirmPath")
		__YU_LOADED.checkPathExists_F1012 =__YU_EXTERN("MOAIFileSystem.checkPathExists")
		__YU_LOADED.mountVirtualDirectory_F1013 =__YU_EXTERN("MOAIFileSystem.mountVirtualDirectory")
		__YU_LOADED.listFiles_F1014 =__YU_EXTERN("MOAIFileSystem.listFiles")
		__YU_LOADED.deleteFile_F1015 =__YU_EXTERN("MOAIFileSystem.deleteFile")
		__YU_LOADED.deleteDirectory_F1016 =__YU_EXTERN("MOAIFileSystem.deleteDirectory")
		__YU_LOADED.new_F1017 =__YU_EXTERN("MOAIFileSystem.new")
		return class
	end 
	function __YU_LOADER.MOAICompassSensor_C24()
		local class= __YU_RUNTIME.newClass("MOAICompassSensor")
		__YU_LOADED.MOAICompassSensor_C24=class
		local classbody = class.__index 
		__YU_LOADED.new_F550 =__YU_EXTERN("MOAICompassSensor.new")class.__super=__YU_LOADED.MOAISensor_C96
		return class
	end 
	function __YU_LOADER.MOAIAction_C0()
		local class= __YU_RUNTIME.newClass("MOAIAction")
		__YU_LOADED.MOAIAction_C0=class
		local classbody = class.__index 
		__YU_LOADED.new_F132 =__YU_EXTERN("MOAIAction.new")
		return class
	end 
	function __YU_LOADER.MOAICpArbiter_C27()
		local class= __YU_RUNTIME.newClass("MOAICpArbiter")
		__YU_LOADED.MOAICpArbiter_C27=class
		local classbody = class.__index 
		__YU_LOADED.new_F576 =__YU_EXTERN("MOAICpArbiter.new")
		return class
	end 
	function __YU_LOADER.MOAIEaseDriver_C40()
		local class= __YU_RUNTIME.newClass("MOAIEaseDriver")
		__YU_LOADED.MOAIEaseDriver_C40=class
		local classbody = class.__index 
		__YU_LOADED.new_F959 =__YU_EXTERN("MOAIEaseDriver.new")class.__super=__YU_LOADED.MOAIAction_C0
		return class
	end 
	function __YU_LOADER.MOAIBox2DMouseJoint_C12()
		local class= __YU_RUNTIME.newClass("MOAIBox2DMouseJoint")
		__YU_LOADED.MOAIBox2DMouseJoint_C12=class
		local classbody = class.__index 
		__YU_LOADED.new_F300 =__YU_EXTERN("MOAIBox2DMouseJoint.new")class.__super=__YU_LOADED.MOAIBox2DJoint_C11
		return class
	end 
	function __YU_LOADER.MOAILineBrush_C66()
		local class= __YU_RUNTIME.newClass("MOAILineBrush")
		__YU_LOADED.MOAILineBrush_C66=class
		local classbody = class.__index 
		return class
	end 
	function __YU_LOADER.MOAIAnimCurve_C3()
		local class= __YU_RUNTIME.newClass("MOAIAnimCurve")
		__YU_LOADED.MOAIAnimCurve_C3=class
		local classbody = class.__index 
		__YU_LOADED.new_F164 =__YU_EXTERN("MOAIAnimCurve.new")
		return class
	end 
	function __YU_LOADER.MOAIEaseType_C41()
		local class= __YU_RUNTIME.newClass("MOAIEaseType")
		__YU_LOADED.MOAIEaseType_C41=class
		local classbody = class.__index 
		return class
	end 
	function __YU_LOADER.MOAIBox2DGearJoint_C10()
		local class= __YU_RUNTIME.newClass("MOAIBox2DGearJoint")
		__YU_LOADED.MOAIBox2DGearJoint_C10=class
		local classbody = class.__index 
		__YU_LOADED.new_F279 =__YU_EXTERN("MOAIBox2DGearJoint.new")class.__super=__YU_LOADED.MOAIBox2DJoint_C11
		return class
	end 
	function __YU_LOADER.MOAIBox2DArbiter_C5()
		local class= __YU_RUNTIME.newClass("MOAIBox2DArbiter")
		__YU_LOADED.MOAIBox2DArbiter_C5=class
		local classbody = class.__index 
		__YU_LOADED.new_F169 =__YU_EXTERN("MOAIBox2DArbiter.new")
		return class
	end 
	function __YU_LOADER.MOAIBox2DJoint_C11()
		local class= __YU_RUNTIME.newClass("MOAIBox2DJoint")
		__YU_LOADED.MOAIBox2DJoint_C11=class
		local classbody = class.__index 
		return class
	end 
	function __YU_LOADER.MOAIInputMgr_C60()
		local class= __YU_RUNTIME.newClass("MOAIInputMgr")
		__YU_LOADED.MOAIInputMgr_C60=class
		local classbody = class.__index 
		return class
	end 
	function __YU_LOADER.MOAIThread_C25()
		local class= __YU_RUNTIME.newClass("MOAIThread")
		__YU_LOADED.MOAIThread_C25=class
		local classbody = class.__index 
		__YU_LOADED.currentThread_F553 =__YU_EXTERN("MOAIThread.currentThread")
		__YU_LOADED.blockOnAction_F554 =__YU_EXTERN("MOAIThread.blockOnAction")
		__YU_LOADED.new_F556 =__YU_EXTERN("MOAIThread.new")
		return class
	end 
	function __YU_LOADER.MOAIBox2DRevoluteJoint_C15()
		local class= __YU_RUNTIME.newClass("MOAIBox2DRevoluteJoint")
		__YU_LOADED.MOAIBox2DRevoluteJoint_C15=class
		local classbody = class.__index 
		__YU_LOADED.new_F354 =__YU_EXTERN("MOAIBox2DRevoluteJoint.new")class.__super=__YU_LOADED.MOAIBox2DJoint_C11
		return class
	end 
	function __YU_LOADER.MOAIGfxQuadDeck2D_C49()
		local class= __YU_RUNTIME.newClass("MOAIGfxQuadDeck2D")
		__YU_LOADED.MOAIGfxQuadDeck2D_C49=class
		local classbody = class.__index 
		__YU_LOADED.new_F1106 =__YU_EXTERN("MOAIGfxQuadDeck2D.new")class.__super=__YU_LOADED.MOAIDeck2D_C36
		return class
	end 
	function __YU_LOADER.MOAIShader_C99()
		local class= __YU_RUNTIME.newClass("MOAIShader")
		__YU_LOADED.MOAIShader_C99=class
		local classbody = class.__index 
		__YU_LOADED.new_F1798 =__YU_EXTERN("MOAIShader.new")
		return class
	end 
	function __YU_LOADER.MOAIEventSource_C43()
		local class= __YU_RUNTIME.newClass("MOAIEventSource")
		__YU_LOADED.MOAIEventSource_C43=class
		local classbody = class.__index 
		return class
	end 
	function __YU_LOADER.MOAIIndexBuffer_C58()
		local class= __YU_RUNTIME.newClass("MOAIIndexBuffer")
		__YU_LOADED.MOAIIndexBuffer_C58=class
		local classbody = class.__index 
		__YU_LOADED.new_F1338 =__YU_EXTERN("MOAIIndexBuffer.new")
		return class
	end 
	function __YU_LOADER.MOAIGfxResource_C51()
		local class= __YU_RUNTIME.newClass("MOAIGfxResource")
		__YU_LOADED.MOAIGfxResource_C51=class
		local classbody = class.__index 
		__YU_LOADED.new_F1161 =__YU_EXTERN("MOAIGfxResource.new")
		return class
	end 
	function __YU_LOADER.MOAIPartition_C82()
		local class= __YU_RUNTIME.newClass("MOAIPartition")
		__YU_LOADED.MOAIPartition_C82=class
		local classbody = class.__index 
		__YU_LOADED.new_F1673 =__YU_EXTERN("MOAIPartition.new")
		return class
	end 
	function __YU_LOADER.MOAIInputDevice_C59()
		local class= __YU_RUNTIME.newClass("MOAIInputDevice")
		__YU_LOADED.MOAIInputDevice_C59=class
		local classbody = class.__index 
		return class
	end 
	function __YU_LOADER.MOAIBlendMode_C4()
		local class= __YU_RUNTIME.newClass("MOAIBlendMode")
		__YU_LOADED.MOAIBlendMode_C4=class
		local classbody = class.__index 
		return class
	end 
	function __YU_LOADER.MOAIBox2DWeldJoint_C17()
		local class= __YU_RUNTIME.newClass("MOAIBox2DWeldJoint")
		__YU_LOADED.MOAIBox2DWeldJoint_C17=class
		local classbody = class.__index 
		__YU_LOADED.new_F358 =__YU_EXTERN("MOAIBox2DWeldJoint.new")class.__super=__YU_LOADED.MOAIBox2DJoint_C11
		return class
	end 
	function __YU_LOADER.MOAIGfxQuadListDeck2D_C50()
		local class= __YU_RUNTIME.newClass("MOAIGfxQuadListDeck2D")
		__YU_LOADED.MOAIGfxQuadListDeck2D_C50=class
		local classbody = class.__index 
		__YU_LOADED.new_F1158 =__YU_EXTERN("MOAIGfxQuadListDeck2D.new")class.__super=__YU_LOADED.MOAIDeck2D_C36
		return class
	end 
	function __YU_LOADER.MOAILocationSensor_C67()
		local class= __YU_RUNTIME.newClass("MOAILocationSensor")
		__YU_LOADED.MOAILocationSensor_C67=class
		local classbody = class.__index 
		__YU_LOADED.new_F1416 =__YU_EXTERN("MOAILocationSensor.new")class.__super=__YU_LOADED.MOAISensor_C96
		return class
	end 
	function __YU_LOADER.MOAIFont_C45()
		local class= __YU_RUNTIME.newClass("MOAIFont")
		__YU_LOADED.MOAIFont_C45=class
		local classbody = class.__index 
		__YU_LOADED.new_F1035 =__YU_EXTERN("MOAIFont.new")
		return class
	end 
	function __YU_LOADER.MOAIBox2DFixture_C8()
		local class= __YU_RUNTIME.newClass("MOAIBox2DFixture")
		__YU_LOADED.MOAIBox2DFixture_C8=class
		local classbody = class.__index 
		__YU_LOADED.new_F266 =__YU_EXTERN("MOAIBox2DFixture.new")
		return class
	end 
	function __YU_LOADER.MOAIDeck_C35()
		local class= __YU_RUNTIME.newClass("MOAIDeck")
		__YU_LOADED.MOAIDeck_C35=class
		local classbody = class.__index 
		return class
	end 
	local func=function ( ) 
		
	 end ; 
	__YU_LOADED.__main = func
	local _=__YU_LOADED.MOAIAction_C0
	local _=__YU_LOADED.MOAIActionMgr_C1
	local _=__YU_LOADED.MOAIAnim_C2
	local _=__YU_LOADED.MOAIAnimCurve_C3
	local _=__YU_LOADED.MOAIBlendMode_C4
	local _=__YU_LOADED.MOAIBox2DArbiter_C5
	local _=__YU_LOADED.MOAIBox2DBody_C6
	local _=__YU_LOADED.MOAIBox2DDistanceJoint_C7
	local _=__YU_LOADED.MOAIBox2DFixture_C8
	local _=__YU_LOADED.MOAIBox2DFrictionJoint_C9
	local _=__YU_LOADED.MOAIBox2DGearJoint_C10
	local _=__YU_LOADED.MOAIBox2DJoint_C11
	local _=__YU_LOADED.MOAIBox2DMouseJoint_C12
	local _=__YU_LOADED.MOAIBox2DPrismaticJoint_C13
	local _=__YU_LOADED.MOAIBox2DPulleyJoint_C14
	local _=__YU_LOADED.MOAIBox2DRevoluteJoint_C15
	local _=__YU_LOADED.MOAIBox2DRopeJoint_C16
	local _=__YU_LOADED.MOAIBox2DWeldJoint_C17
	local _=__YU_LOADED.MOAIBox2DWheelJoint_C18
	local _=__YU_LOADED.MOAIBox2DWorld_C19
	local _=__YU_LOADED.MOAIButtonSensor_C20
	local _=__YU_LOADED.MOAICameraAnchor2D_C21
	local _=__YU_LOADED.MOAICameraFitter2D_C22
	local _=__YU_LOADED.MOAIColor_C23
	local _=__YU_LOADED.MOAICompassSensor_C24
	local _=__YU_LOADED.MOAIThread_C25
	local _=__YU_LOADED.MOAICp_C26
	local _=__YU_LOADED.MOAICpArbiter_C27
	local _=__YU_LOADED.MOAICpBody_C28
	local _=__YU_LOADED.MOAICpConstraint_C29
	local _=__YU_LOADED.MOAICpShape_C30
	local _=__YU_LOADED.MOAICpSpace_C31
	local _=__YU_LOADED.MOAIDataBuffer_C32
	local _=__YU_LOADED.MOAIDataIOAction_C33
	local _=__YU_LOADED.MOAIDebugLines_C34
	local _=__YU_LOADED.MOAIDeck_C35
	local _=__YU_LOADED.MOAIDeck2D_C36
	local _=__YU_LOADED.MOAIDeckRemapper_C37
	local _=__YU_LOADED.MOAIDeserializer_C38
	local _=__YU_LOADED.MOAIDraw_C39
	local _=__YU_LOADED.MOAIEaseDriver_C40
	local _=__YU_LOADED.MOAIEaseType_C41
	local _=__YU_LOADED.MOAIEnvironment_C42
	local _=__YU_LOADED.MOAIEventSource_C43
	local _=__YU_LOADED.MOAIFileSystem_C44
	local _=__YU_LOADED.MOAIFont_C45
	local _=__YU_LOADED.MOAIFrameBuffer_C46
	local _=__YU_LOADED.MOAIGfxDevice_C47
	local _=__YU_LOADED.MOAIGfxQuad2D_C48
	local _=__YU_LOADED.MOAIGfxQuadDeck2D_C49
	local _=__YU_LOADED.MOAIGfxQuadListDeck2D_C50
	local _=__YU_LOADED.MOAIGfxResource_C51
	local _=__YU_LOADED.MOAIGlyph_C52
	local _=__YU_LOADED.MOAIGrid_C53
	local _=__YU_LOADED.MOAIGridPathGraph_C54
	local _=__YU_LOADED.MOAIGridSpace_C55
	local _=__YU_LOADED.MOAIHttpTask_C56
	local _=__YU_LOADED.MOAIImage_C57
	local _=__YU_LOADED.MOAIIndexBuffer_C58
	local _=__YU_LOADED.MOAIInputDevice_C59
	local _=__YU_LOADED.MOAIInputMgr_C60
	local _=__YU_LOADED.MOAIJoystickSensor_C61
	local _=__YU_LOADED.MOAIJsonParser_C62
	local _=__YU_LOADED.MOAIKeyboardSensor_C63
	local _=__YU_LOADED.MOAILayer2D_C64
	local _=__YU_LOADED.MOAILayoutFrame_C65
	local _=__YU_LOADED.MOAILineBrush_C66
	local _=__YU_LOADED.MOAILocationSensor_C67
	local _=__YU_LOADED.MOAILogMessages_C68
	local _=__YU_LOADED.MOAILogMgr_C69
	local _=__YU_LOADED.MOAIMesh_C70
	local _=__YU_LOADED.MOAIMotionSensor_C71
	local _=__YU_LOADED.MOAINode_C72
	local _=__YU_LOADED.MOAIParser_C73
	local _=__YU_LOADED.MOAIParticleDistanceEmitter_C74
	local _=__YU_LOADED.MOAIParticleEmitter_C75
	local _=__YU_LOADED.MOAIParticleForce_C76
	local _=__YU_LOADED.MOAIParticlePlugin_C77
	local _=__YU_LOADED.MOAIParticleScript_C78
	local _=__YU_LOADED.MOAIParticleState_C79
	local _=__YU_LOADED.MOAIParticleSystem_C80
	local _=__YU_LOADED.MOAIParticleTimedEmitter_C81
	local _=__YU_LOADED.MOAIPartition_C82
	local _=__YU_LOADED.MOAIPartitionCell_C83
	local _=__YU_LOADED.MOAIPartitionLayer_C84
	local _=__YU_LOADED.MOAIPartitionResultBuffer_C85
	local _=__YU_LOADED.MOAIPartitionResultMgr_C86
	local _=__YU_LOADED.MOAIPathFinder_C87
	local _=__YU_LOADED.MOAIPathGraph_C88
	local _=__YU_LOADED.MOAIPathTerrainDeck_C89
	local _=__YU_LOADED.MOAIPointerSensor_C90
	local _=__YU_LOADED.MOAIProp_C91
	local _=__YU_LOADED.MOAIProp2D_C92
	local _=__YU_LOADED.MOAIQuadBrush_C93
	local _=__YU_LOADED.MOAIScriptDeck_C94
	local _=__YU_LOADED.MOAIScriptNode_C95
	local _=__YU_LOADED.MOAISensor_C96
	local _=__YU_LOADED.MOAISerializer_C97
	local _=__YU_LOADED.MOAISerializerBase_C98
	local _=__YU_LOADED.MOAIShader_C99
	local _=__YU_LOADED.MOAIShaderMgr_C100
	local _=__YU_LOADED.MOAISim_C101
	local _=__YU_LOADED.MOAIStretchPatch2D_C102
	local _=__YU_LOADED.MOAISurfaceDeck2D_C103
	local _=__YU_LOADED.MOAISurfaceSampler2D_C104
	local _=__YU_LOADED.MOAITextBox_C105
	local _=__YU_LOADED.MOAITextFrame_C106
	local _=__YU_LOADED.MOAITextLayout_C107
	local _=__YU_LOADED.MOAITexture_C108
	local _=__YU_LOADED.MOAITileDeck2D_C109
	local _=__YU_LOADED.MOAITileFlags_C110
	local _=__YU_LOADED.MOAITimer_C111
	local _=__YU_LOADED.MOAITouchSensor_C112
	local _=__YU_LOADED.MOAITransform_C113
	local _=__YU_LOADED.MOAITransformBase_C114
	local _=__YU_LOADED.MOAIVertexBuffer_C115
	local _=__YU_LOADED.MOAIVertexFormat_C116
	local _=__YU_LOADED.MOAIVertexFormatMgr_C117
	local _=__YU_LOADED.MOAIViewport_C118
	local _=__YU_LOADED.MOAIWheelSensor_C119
	local _=__YU_LOADED.MOAIXmlParser_C120
	return func 
	end 
	return __YU_LOADED, __YU_LOADED.__main 
end 
__YU_MODULE_LOADER["moai"]=function()
	local __YU_LOADED, __YU_LOADER=__YU_RUNTIME.makeSymbolTable() __YU_MODULE_LOADED["moai"]=__YU_LOADED
	
	function __YU_LOADER.__main()
	
	local new_F2147,new_F1402,new_F1756,pushRenderPass_F1821,openWindow_F1834,new_F1035,blockOnAction_F554,new_F1068,new_F556,new_F1935 
	local func=function ( ) 
		openWindow_F1834 ( "test" , 320 , 480 ) ; 
		local viewport_v0 = new_F2147 ( ) 
		viewport_v0 :setSize ( 320 , 480 ) ; 
		viewport_v0 :setScale ( 320 , 480 ) ; 
		local layer_v1 = new_F1402 ( ) 
		layer_v1 :setViewport ( viewport_v0 ) ; 
		pushRenderPass_F1821 ( layer_v1 ) ; 
		local gfxQuad_v2 = new_F1068 ( ) 
		gfxQuad_v2 :setTexture ( "cathead.png" , 0 ) ; 
		gfxQuad_v2 :setRect ( -64 , -64 , 64 , 64 ) ; 
		local prop_v3 = new_F1756 ( ) 
		prop_v3 :setDeck ( gfxQuad_v2 ) ; 
		prop_v3 :setLoc ( 0 , 80 ) ; 
		layer_v1 :insertProp ( prop_v3 ) ; 
		local font_v4 = new_F1035 ( ) 
		font_v4 :loadFromTTF ( "arialbd.ttf" , " abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789,.?!" , 12 , 163 ) ; 
		local textbox_v5 = new_F1935 ( ) 
		textbox_v5 :setFont ( font_v4 ) ; 
		textbox_v5 :setTextSize ( font_v4 :getScale ( ) ) ; 
		textbox_v5 :setRect ( -160 , -80 , 160 , 80 ) ; 
		textbox_v5 :setLoc ( 0 , 100 ) ; 
		textbox_v5 :setYFlip ( true ) ; 
		layer_v1 :insertProp ( textbox_v5 ) ; 
		textbox_v5 :setString ( "Moai has installed correctly! Check out the samples folder.\n<c.0F0>Meow.<c>" ) ; 
		textbox_v5 :spool ( false ) ; 
		local thread_v6 = new_F556 ( ) 
		thread_v6 :run ( function ( ) 
			while true do 
				blockOnAction_F554 ( prop_v3 :moveRot ( 360 , 1.5 , nil ) ) ; 
				blockOnAction_F554 ( prop_v3 :moveRot ( -360 , 1.5 , nil ) ) ; 
			end 
		end ) ; 
	 end ; 
	__YU_LOADED.__main = func
	blockOnAction_F554=__YU_MODULE_LOADED["api"].blockOnAction_F554
	new_F556=__YU_MODULE_LOADED["api"].new_F556
	new_F1035=__YU_MODULE_LOADED["api"].new_F1035
	new_F1068=__YU_MODULE_LOADED["api"].new_F1068
	new_F1402=__YU_MODULE_LOADED["api"].new_F1402
	new_F1756=__YU_MODULE_LOADED["api"].new_F1756
	pushRenderPass_F1821=__YU_MODULE_LOADED["api"].pushRenderPass_F1821
	openWindow_F1834=__YU_MODULE_LOADED["api"].openWindow_F1834
	new_F1935=__YU_MODULE_LOADED["api"].new_F1935
	new_F2147=__YU_MODULE_LOADED["api"].new_F2147
	return func 
	end 
	return __YU_LOADED, __YU_LOADED.__main 
end 
return __YU_MODULE_LOADED["moai"].__main()
	