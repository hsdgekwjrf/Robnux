system.print("Welcome\n")
while true do
	system.print("[init] Loading Shell...\n")
	local rv,err = system.exec("rootfs/bin/sh")
	if rv == -1 then
		system.print("[init] Catched error: sh:"..err.."\n")
	end
	task.wait(1)
end