sh = {}
system = nil

local sh_spawn = "rootfs/"

function cmd_slove(str)

    local cmd_tmp = {}
	string.gsub(str,'[^ ]+',function(tmp1) 
		table.insert(cmd_tmp,tmp1) 
	end)
    return cmd_tmp
end

function cmd_runner(cmd,args)
    if cmd == "clear" then
        system.clear()
    elseif cmd == "echo" then
        system.print(args[1])
    else
        local return_v = system.exec("rootfs/bin/"..cmd,args)
        if return_v == -1 then
            local return_v2 = system.exec(sh_spawn .. cmd,args)
            if return_v2 == -1 then
                system.print("No such file or command: ".. cmd .."\n")
            end
        end
    end
end

local ver = "0.1.0 ,alpha.1"

function sh.main(_system)
    system = _system
    system.print("BSEG Shell version".. ver .."\n")
    while true do
        local sh_command = ""
        system.print("$ ")
        sh_command = system.input()
        local cmd_table = {}
        cmd_table = cmd_slove(sh_command)
        local args = {}
        for i, value in ipairs(cmd_table) do
            if i > 1 then
                table.insert(args,value)
            end
        end
        cmd_runner(cmd_table[1], args)
    end
    
end

return sh