sh = {}
system = nil

local sh_spawn = "rootfs"
local sign_exit = false

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


		if txts == -1 then
			system.print("Directory not found: ".. path .."\n")
		else
			for _, txt in ipairs(txts) do
				system.print(txt .. " ")
			end
			system.print("\n")
		end
	elseif cmd == "cd" then

		local cd_tmp = sh_spawn

		if args[1] == nil then
			system.print("cd [DIR] \n ")
		else
			sh_spawn = sh_spawn .. "/" .. args[1]
		end
		if system.syscall("fs_lsdir",sh_spawn) == -1 then
			system.print("Directory not found: ".. args[1] .."\n")
			sh_spawn = cd_tmp
		end

		sh_spawn = system.syscall("fs_getminpath",sh_spawn)
	elseif cmd == "exit" or cmd == "quit" then
		sign_exit = true
	elseif cmd == "" or cmd == " " or cmd=="\n" or cmd==nil then
		--none
	else
		table.insert(args,sh_spawn)
		local return_v,err = system.exec("rootfs/bin/"..cmd,args)
		if return_v == -1 then
			local return_v2,err = system.exec(sh_spawn .. "/" .. cmd,args)
			if return_v2 and err ~= "success" then
				system.print("Can not run this command: ".. cmd .."\n")
				system.print("More info: "..err.."\n")
			end
		end
	end
	return 0
end

local ver = "0.1.0 ,alpha.3"

function sh.main(_system)
	system = _system
	system.print("BSEG Shell version".. ver .."\n")
	while true do
		local cmd_table = {"",""}
		local sh_command = ""
		system.print(sh_spawn .." $ ")
		sh_command = system.input()
		if sh_command == nil then
			sh_command = ""
			
		else
			
			cmd_table = cmd_solve(sh_command)
		end
		
		local args = {}
		for i, value in ipairs(cmd_table) do
			if i > 1 then
				table.insert(args,value)
			end
		end
		system.print("\n")
		cmd_runner(cmd_table[1], args)
		if sign_exit then
			break
		end
	end

end

return sh