init = {}
system = nil

function init.main(_system)
    system = _system
    system.print("Welcome\n")
    system.print("Loading Shell...\n")
    while true do
        system.exec("rootfs/bin/sh.lua")
    end
    
end

return init