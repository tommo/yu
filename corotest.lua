 function ccreate(f)
	
	-- local t=coroutine.create(f)
	-- local cc={
		-- coro=t,
		-- nextLevel=false
	-- }
	
	return coroutine.create(f)
 end
 
 local currentCC
 local level=0
 function cresume(cc)
	level=level+1
	-- local coro=cc.coro
	-- local prevCC=currentCC
	-- currentCC.nextLevel=cc
	-- currentCC=cc
	local f,l=coroutine.resume(cc)
	-- currentCC=prevCC
	level=level-1
	-- print("LEVEL:",level)
	if type(l)=='number' then
		if l>0 then
			cyield(l-1)
			return cresume(cc)
		end
	end
	
 end
 
 function cyield(i)
	coroutine.yield(i)
 end
 
 
 function serverCoro()
	--load module
	local m=ccreate(moduleCoro)
	local i=0
	while true do
		i=i+1
		print("----server:",i)
		cresume(m)
		print("****server:",i)
		cyield()
	end
 end
 
 function moduleCoro()
	local f=ccreate(funcCoro)
	local i=0
	while true do
		i=i+1
		print("  --module:",i)
		cresume(f)
		print("  **module:",i)
		cyield()
	end
 end
 
 function funcCoro()
	for i=1,10 do
		print('    --func:',i)
		if i==3 then 
			cyield(2) 
		elseif i==2 then
			cyield(1)
		end
		print('    **func:',i)
		cyield()
		
	end
 end
 
 
 
 local s=ccreate(serverCoro)
 for i=1 , 10 do
	print('+'..i)
	cresume(s)
 end