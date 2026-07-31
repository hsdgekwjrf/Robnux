init = {}
system = nil
kernel = nil
function init.main(_kernel,_system)
	kernel = _kernel
	system = _system
	system.print("Welcome\n")
	
	while true do
		system.print("[init] Loading Shell...\n")
		local rv,err = system.exec("rootfs/bin/sh",system)
		if rv == -1 then
			system.print("[init] Catched error: sh:"..err.."\n")
		end
	end

end

return init