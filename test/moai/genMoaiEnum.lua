local output=io.open('moaiEnum.yu', 'w')

local format=string.format

local function genEnum(clas, enumName, items)
	output:write(format('enum %s {\n', enumName))
	for i, item in ipairs(items) do
		output:write(format('\t %s = %d,\n', item, clas[item]))
	end
	output:write('}\n')
end


genEnum(MOAIEaseType, 'MOAIEaseType', {
		'EASE_IN',
		'EASE_OUT',
		'FLAT',
		'LINEAR',
		'SHARP_EASE_IN',
		'SHARP_EASE_OUT',
		'SHARP_SMOOTH',
		'SMOOTH',
		'SOFT_EASE_IN',
		'SOFT_EASE_OUT',
		'SOFT_SMOOTH',
	}
)

genEnum(MOAIFileStream, 'MOAIFileStreamMode', {
		'READ',
		'READ_WRITE',
		'READ_WRITE_AFFIRM',
		'READ_WRITE_NEW',
		'WRITE',
	}
)


genEnum(MOAIAnimCurve, 'MOAIAnimCurveMode', {
		'CLAMP',
		'WRAP',
		'MIRROR',
		'APPEND',
	}
)



output:close()
