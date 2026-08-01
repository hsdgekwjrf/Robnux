rm = {}
system = nil

function rm.main(_system,args)
	local file = args[1]
	local sh_path = args[2]
	system = _system
	local path = sh_path .. "/" .. args[1]
	system.syscall("fs_rm",path)

end

return rm