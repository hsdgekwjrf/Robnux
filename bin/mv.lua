local file = args[1]
local sh_path = args[3]
local path = args[2]

local nowpath = sh_path .. "/" .. file
local newpath = sh_path .. "/" .. path
local v,err = system.syscall("fs_mv",{nowpath,newpath})
if v == -1 then
	system.print("Failed: "..err.."\n")
end