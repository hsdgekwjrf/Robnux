mv = {}
system = nil

function mv.main(_system,args)
	system = _system

	local file = args[1]
	local sh_path = args[3]
	local path = args[2]

	local nowpath = sh_path .. "/" .. file
	local newpath = sh_path .. "/" .. path
	system.syscall("fs_mv",{nowpath,newpath})

end

return mv