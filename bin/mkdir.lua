local shpath = args[2]
local dirname = args[1]
local v,err = system.syscall("fs_mkdir",{dirname,shpath})
if v ~= 0 then
	system.print("Failed: "..err.."\n")
end
