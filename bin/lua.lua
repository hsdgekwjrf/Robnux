while true do
	system.print("lua> ")
	local code = system.input()
	if code == "exit" then
		system.print("\n")
		return 0
	end
	system.print("\n")
	if code ~= "" and code ~= " " and code ~= nil then
		system.syscall("fs_mk",{"lua_tmp","rootfs/tmp"})
		system.syscall("fs_write",{"rootfs/tmp/lua_tmp",code})
		local v,err = system.exec("rootfs/tmp/lua_tmp")
		if v ~= 0 then
			system.print("\n"..err.."\n")
		end
	end
		
	system.print("\n")
end