sh = {}
system = nil

local sh_spawn = "rootfs/"

function cmd_solve(str)

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
        local str = ""
        for i, value in ipairs(args) do
            str = str .. value .. " "
        end
        system.print(str.."\n")
    elseif cmd == "ls" then
        local path = sh_spawn
        if args[1] ~= nil then
            path = args[1]
        end
        local txts = system.syscall("fs_lsdir",path)
        for _, txt in ipairs(txts) do
            system.print(txt .. " ")
        end
        system.print("\n")
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
        system.print(sh_spawn .." $ ")
        sh_command = system.input()
        local cmd_table = {}
        cmd_table = cmd_solve(sh_command)
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