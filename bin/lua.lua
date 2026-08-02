lua = {}
system = nil
fenv=nil

local function run(code)
	local com,err = loadstring(code)
	if tostring(err) ~= "nil" then
		system.print("\n"..tostring(err).."\n")
	end
	
	pcall(function()
		local v,err = pcall(setfenv(com,fenv))
		if not v then
			system.print("\n"..err.."\n")
			return 0
		end
	end)
	
end

function lua.main(_system)
	system = _system
	fenv = {
		system=system,
		assert=assert,
		buffer=buffer,
		bit32=bit32,
		coroutine=coroutine,
		debug=debug,
		error=error,
		getmetatable=getmetatable,
		gcinfo=gcinfo,
		ipairs=ipairs,
		loadstring=loadstring,
		math=math,
		next=next,
		os=os,
		pcall=pcall,
		pairs=pairs,
		rawlen=rawlen,
		rawget=rawget,
		rawset=rawset,
		task=task,
		table=table,
		type=type,
		typeof=typeof,
		tostring=tostring,
		tonumber=tonumber,
		utf8=utf8,
		unpack=unpack,
		vector=vector,
		xpcall=xpcall,
		_G=nil,
		_VERSION="Lua 5.1"
		
	}
	fenv._G=fenv
	system.print("Lua 5.1 REPL Shell\nType \"exit\" to exit.\n")
	while true do
		system.print("lua> ")
		local code = system.input()
		if code == "exit" then
			system.print("\n")
			return 0
		end
		system.print("\n")
		if code ~= "" and code ~= " " and code ~= nil then
			run(code)
		end
		
		system.print("\n")
	end

end

return lua