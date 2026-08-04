local sh_path = args[2]
local file = args[1]
local path = sh_path .. "/" .. file
local v,str = system.syscall("fs_read",path)
if v ~= 0 then
    system.print("Failed: "..str)
else
    system.print(str)
end
system.print("\n")