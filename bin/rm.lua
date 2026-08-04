local file = args[1]
local sh_path = args[2]
local path = sh_path .. "/" .. args[1]
system.syscall("fs_rm",path)