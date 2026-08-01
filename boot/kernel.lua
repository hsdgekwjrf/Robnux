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
kernel.version = [[
Made By BSEG
Robnux Kernel 0.1.0, alpha.1
Standard-Core
]]

local pids = {
	--{pid,process}
}

local function get_new_pid()
	local pids_table = {}
	for i in ipairs(pids) do

		table.insert(pids_table,pids[i][1])
	end
	local returnpid = 0
	local notgot = true
	while notgot do
		local newpid = math.random(2,10000)
		local tmp = true
		for i in ipairs(pids_table) do
			if newpid == pids_table[i] then
				tmp = false
				break
			end
		end
		if tmp then
			notgot = false
			returnpid = newpid
		end
	end
	return returnpid
end

local function check_process()
	local checked_init = false
	for i=#pids,1,-1 do

		local status = coroutine.status(pids[i][2])
		if status == "dead" then
			table.remove(pids,i)
		elseif pids[i][1] == 1 then
			checked_init = true
		end
	end
	return checked_init
end

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
		if args == nil then
			__exec.main(system)
		else
			__exec.main(system,args)
		end

	end)
	if not success then
		return -1,err
	else
		return 0,"success"
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

function kernel.kill_process(pid)
	local checked = false
	local table_spawn = 0
	for i in ipairs(pids) do
		if pids[i][1] == pid then	
			checked = true
			table_spawn = i
		end
	end
	if not checked then
		return -1,"No Process: "..tostring(pid)
	end
	local v,err = pcall(coroutine.close,pids[table_spawn][2])
	if not v then
		return -1,err
	end
	return 0
end

function kernel.create_process(path,name,args)
	local process = task.spawn(function()
		kernel.exec(path,args)
	end)

	local pid = get_new_pid()
	table.insert(pids,{pid,process,name})	
	return {pid,process,name}
end

function kernel.filesystem(cmd,arg)
	if cmd == "mk" then
		local file = Instance.new("ModuleScript")
		file.Name = arg
		file.Parent = kernel.fs_to_path(kernel.rm_last(arg))
		return file
	elseif cmd == "rm" then
		kernel.fs_to_path(arg):Remove()
		--kernel.fs_to_path(arg).Parent = nil
		return 0
	elseif cmd == "mkdir" then
		local file = Instance.new("Folder")
		file.Name = arg
		file.Parent = kernel.fs_to_path(arg)
		return file
	elseif cmd == "write_add" then
		local script = kernel.fs_to_path(arg[1]).Source
		kernel.fs_to_path(arg[1]).Source = script..arg[2]

	elseif cmd == "write" then
		kernel.fs_to_path(arg[1]).Source = arg[2]

	elseif cmd == "read" then
		local script = kernel.fs_to_path(arg).Source
		return script
	elseif cmd == "mv" then
		local file = kernel.fs_to_path(arg[1])
		local parent = kernel.fs_to_path(arg[2])
		if parent.ClassName ~= "Folder" then
			return -1,"Not a Folder"
		end
		file.Parent = parent
		return 0

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
	elseif cmd == "getminpath" then
		return kernel.fs_get_path(kernel.fs_to_path(arg))
	else
		kernel.panic("filesystem: Bad command")
	end
	return 0
end

function kernel.syscall(cmd,arg)
	if cmd == "exec"              then return kernel.exec(arg[1],arg[2])
	elseif cmd == "create_process"    then return kernel.create_process(arg[1],arg[2],arg[3])
	elseif cmd == "get_process_table" then return pids
	elseif cmd == "kill_process"      then return kernel.kill_process(arg)
	elseif cmd == "fs_mk"             then return kernel.filesystem("mk",arg)
	elseif cmd == "fs_rm"             then return kernel.filesystem("rm",arg)
	elseif cmd == "fs_mkdir"          then return kernel.filesystem("mkdir",arg)
	elseif cmd == "fs_write"          then return kernel.filesystem("write",arg)
	elseif cmd == "fs_read"           then return kernel.filesystem("read",arg)
	elseif cmd == "fs_lsdir"          then return kernel.filesystem("lsdir",arg)
	elseif cmd == "dev_clearscreen"   then return kernel.dev("clearscreen",arg)
	elseif cmd == "dev_getinput"      then return kernel.dev("getinput",arg)
	elseif cmd == "dev_output"        then return kernel.dev("output",arg)
	elseif cmd == "fs_getminpath"     then return kernel.filesystem("getminpath",arg)
	elseif cmd == "fs_mv"             then return kernel.filesystem("mv",arg)
	else return kernel.panic("Bad Syscall: \""..cmd.."\"")	
	end
end

function kernel.init(init_program)

	kernel.syscall("dev_output","Loading init...\n")
	local success,err = pcall (function()
		local __init = require(init_program);
		--kernel.syscall("dev_clearscreen")

		local init_process = task.spawn(function()
			__init.main(kernel,system)
		end)

		table.insert(pids,{1,init_process,"init"})

		while true do
			local init_running = check_process()
			if not init_running then
				kernel.panic("rootfs/bin/init exited.")
				break
			end
			task.wait(1)
		end

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
	kernel.syscall("dev_output","Initialized devices.")
	--kernel init
	kernel.syscall("dev_clearscreen",0)
	kernel.syscall("dev_output","Loading Robnux kernel...")
	local success,err = pcall(function()
		oslogo = script.Parent.oslogo.Value
		kernel.syscall("dev_output"," [ OK ] \n")
		--kernel.dev("output",oslogo.."\n")
		kernel.syscall("dev_output",kernel.version .. "\n")
	end)
	if not success then
		kernel.syscall("dev_output"," [FAILED] \n")
		kernel.panic("Failed to load kernel.\n[ERROR] "..err)
	end
	kernel.syscall("dev_output","Loading library rootfs/bin/system ...\n")
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