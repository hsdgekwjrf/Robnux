local system = {}
local kernel = nil
local tmp_input_sign = false
local tmp_enter_sign = false
local tmp_str1 = ""

function system.print(str)
	kernel.syscall("dev_output",str)
end

function system.init(__kernel)
	kernel = __kernel
	
	__kernel.enter_event:Connect(function()
		local str = kernel.syscall("dev_getinput")
		tmp_str1 = str
		tmp_enter_sign = true
	end)
	
	system.print("Loaded Module: rootfs/lib/system")
	
	
end

function system.input(str)
	tmp_input_sign = true
	local str = ""
	while tmp_input_sign do
		task.wait(0.1)
		if tmp_enter_sign then
			tmp_input_sign = false
			tmp_enter_sign = false
			str = tmp_str1
		end
	end
	return str
	
end

function system.exec(path,args)
	kernel.exec(path,args)
end
function system.create_process(path,args)
	kernel.create_process(path,args)
end

function system.clear()
	kernel.syscall("dev_clearscreen",0)
end

function system.syscall(cmd,arg)
	return kernel.syscall(cmd,arg)
end

function system.import(path)
	return require(kernel.fs_to_path(path))
	
end

return system
