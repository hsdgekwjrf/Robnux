local sh_path = args[2]
local file = args[1]
local v,err = system.syscall("fs_mk",{file,sh_path})
if v ~= 0 then
    system.print("Failed: "..err)
end
system.print("\n")
