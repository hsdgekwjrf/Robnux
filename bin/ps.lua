local ps = {}
local system = nil

function ps.main(_system)
	system = _system
	local _table = system.syscall("get_process_table")
	for i in ipairs(_table) do
		system.print("PID:".._table[i][1].."  Name:".._table[i][3].."\n")
	end
end

return ps
