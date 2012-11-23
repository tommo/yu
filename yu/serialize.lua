require "yu.visitor"
require "yu.type"

local is=yu.is
local getTypeDecl,newTypeRef=yu.getTypeDecl,yu.newTypeRef
local ipairs,print=ipairs,print

module("yu",package.seeall)

local pre={}
local post={}

function newNodeSerialzer(  )
	return yu.newVisitor({
			pre=pre,
			post=post,
		})
end

function pre.any( vi,n )
	-- body
end