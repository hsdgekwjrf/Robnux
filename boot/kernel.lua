--[[
Robnux Kernel 
By BSEG

     *
     /\
    / .\
   /   ==>  ,
--/      \--O
 /        \
 ----------
   |    |
   L    L

]]--




local oslogo = nil
local system = nil
kernel = {}
kernel.screen_textLabel = nil
kernel.keyboard_textBox = nil
kernel.keyboard_enter = nil
kernel.fs_root = nil
kernel.enter_event = nil

local ScriptEditorService = game:GetService("ScriptEditorService")


function kernel.dev(cmd,arg)
	if cmd == "clearscreen" then
		kernel.screen_textLabel.Text = ""
		return 0
	end
	if cmd == "getinput" then
		local tmp1 = kernel.keyboard_textBox.Text
		kernel.keyboard_textBox.Text = ""
		kernel.syscall("dev_output",tmp1)
		return tmp1
		
	end
	if cmd == "output" then
		kernel.screen_textLabel.Text = kernel.screen_textLabel.Text .. arg
		return 0
	end
end

function kernel.fs_get_path(real_path) -- return os path
	local kernel_path = ""
	local path_tmp = {}
	while true do
		if real_path == kernel.fs_root then
			table.insert(path_tmp,1,"rootfs")
			break
		end
		table.insert(path_tmp,1,real_path.Name)
		real_path = real_path.Parent
		
	end
	if real_path == nil then
		return nil
	end
	for num,value in pairs(path_tmp) do
		kernel_path = kernel_path .. value .. "/"
	end
	return kernel_path
end

function kernel.exec(path,args)
	local success,err = pcall(function()
		local r_path = kernel.fs_to_path(path)
		local __exec = require(r_path)
		__exec.main(args,system)
	end)
	if not success then
		return -1
	end
end

function kernel.fs_to_path(kernel_path) -- return roblox path
	local real_path = kernel.fs_root
	local path_tmp = {}
	string.gsub(kernel_path,'[^/]+',function(tmp1) 
		table.insert(path_tmp,tmp1) 
	end)

	for num,value in pairs(path_tmp) do
		if value == "rootfs" then
			real_path = kernel.fs_root
		elseif value == ".." then
			if real_path == kernel.fs_root then
				real_path = kernel.fs_root
			else
				real_path = real_path.Parent
			end
		elseif value == "." then
			real_path = real_path
		else
			real_path = real_path:FindFirstChild(value)
		end

	end

	return real_path
end



function kernel.panic(reason)
	kernel.dev("output","Kernel Panic: "..reason.."\n")
	system = nil
	kernel.dev("output","Will reboot in 3 seconds...\n")
	task.wait(3)
	kernel.kernel_init(kernel.screen_textLabel,kernel.keyboard_textBox,kernel.keyboard_enter,kernel.fs_root)
	return -1
end

function kernel.rm_last(str)
	local path = kernel.fs_to_path(str)
	path =path.Parent
	return kernel.fs_get_path(path)
end

function kernel.create_process(path,args)
	local process = task.spawn(function()
		kernel.exec(path,args)
	end)
	return process
end

function kernel.filesystem(cmd,arg)
	if cmd == "mk" then
		local file = Instance.new("ModuleScript")
		file.Name = arg
		file.Parent = kernel.fs_to_path(kernel.rm_last(arg))
		return file
	elseif cmd == "rm" then
		kernel.fs_to_path(arg):Remove()
		return 0
	elseif cmd == "mkdir" then
		local file = Instance.new("Folder")
		file.Name = arg
		file.Parent = kernel.fs_to_path(arg)
		return file
	elseif cmd == "rmdir" then
		kernel.fs_to_path(arg):Remove()
	elseif cmd == "write_add" then
		local script = kernel.fs_to_path(arg[1]).Source
		kernel.fs_to_path(arg[1]).Source = script..arg[2]
		
	elseif cmd == "write" then
		kernel.fs_to_path(arg[1]).Source = arg[2]
		
	elseif cmd == "read" then
		local script = kernel.fs_to_path(arg).Source
		return script
		
	elseif cmd == "lsdir" then
		local _tmp = {}
		local return_v = pcall(function()
			_tmp = kernel.fs_to_path(arg):GetChildren()
		end)
		if return_v == false then
			return -1
		end

		--print(_tmp)
		local __tmp = {}
		for i,value in pairs(_tmp) do
			table.insert(__tmp,value.Name)
		end
		return __tmp
	else
		kernel.panic("filesystem: Bad command")
	end
	return 0
end

function kernel.syscall(cmd,arg)
	if cmd == "exec" then
		return kernel.exec(arg[1],arg[2])
	elseif cmd == "create_process" then
		return kernel.create_process(arg[1],arg[2])
	elseif cmd == "fs_mk" then
		return kernel.filesystem("mk",arg)
	elseif cmd == "fs_rm" then
		return kernel.filesystem("rm",arg)
	elseif cmd ==  "fs_mkdir" then
		return kernel.filesystem("mkdir",arg)
	elseif cmd == "fs_write" then
		return kernel.filesystem("write",arg)
	elseif cmd == "fs_rmdir" then
		return kernel.filesystem("rmdir",arg)
	elseif cmd == "fs_read" then
		return kernel.filesystem("read",arg)
	elseif cmd == "fs_lsdir" then
		return kernel.filesystem("lsdir",arg)
	elseif cmd == "dev_clearscreen" then
		return kernel.dev("clearscreen",arg)
	elseif cmd == "dev_getinput" then
		return kernel.dev("getinput",arg)
	elseif cmd == "dev_output" then
		return kernel.dev("output",arg)
	else
		return kernel.panic("Bad Syscall: \""..cmd.."\"")
	end
end

function kernel.init(init_program)

	kernel.syscall("dev_output","Loading init...\n")
	local success,err = pcall (function()
		local __init = require(init_program);
		kernel.syscall("dev_clearscreen")
		__init.main(kernel,system)

	end)
	if not success then
		return kernel.panic("rootfs/bin/init NOT FOUND or CAN NOT RUN\n".."[ERROR] "..err)
	end
	return -1

end

function kernel.kernel_init(screen_textLabel,keyboard_textBox,keyboard_enter,fs_root)

	--device init
	kernel.screen_textLabel = screen_textLabel
	kernel.keyboard_textBox = keyboard_textBox
	kernel.keyboard_enter = keyboard_enter
	kernel.enter_event = kernel.keyboard_enter.MouseButton1Click
	kernel.fs_root = fs_root
	--kernel init
	kernel.syscall("dev_clearscreen",0)
	kernel.syscall("dev_output","Loading Robnux kernel...")
	local success,err = pcall(function()
		oslogo = script.Parent.oslogo.Value
		kernel.syscall("dev_output"," [ OK ] \n")
		--kernel.dev("output",oslogo.."\n")
	end)
	if not success then
		kernel.syscall("dev_output"," [FAILED] \n")
		kernel.panic("Failed to load kernel.\n[ERROR] "..err)
	end
	kernel.syscall("dev_output","Loading library rootfs/bin/system ...")
	local success,err = pcall(function()
		local __system = require(fs_root.lib.system);
		system = __system
		system.init(kernel)
	end)
	if not success then
		kernel.panic("Failed to load rootfs/bin/system.\n[ERROR] "..err)
	else
		system.print(" [ OK ]\n")
	end
	kernel.init(fs_root.bin.init)
end

return kernel