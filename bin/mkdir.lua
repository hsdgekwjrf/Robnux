local mkdir = {}
local system = nil

function mkdir.main(_system,args)
	system = _system
	
	local shpath = args[1]
	local dirname = args[2]
	local v,err = system.syscall("fs_mkdir",{args[1],args[2]})
	if v ~= 0 then
		system.print("Failed: "..err.."\n")
	end
end

return mkdir
