local pid = args[1]
system = _system
if pid == nil or pid == "" or pid == " " then
	system.print("kill [PID]\n")
	return -1
end
local v,err = system.syscall("kill_process",tonumber(pid))
if v ~= 0 then
	system.print("Failed: "..err.."\n")
end