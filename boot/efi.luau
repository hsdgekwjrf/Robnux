local efi = {}


function efi.main()
	local kernel = require(script.Parent.kernel)
	kernel.kernel_init(
		script.Parent.Parent.Parent.Screen.SurfaceGui.TextLabel
		,script.Parent.Parent.Parent.Screen.SurfaceGui.TextBox
		,script.Parent.Parent.Parent.Screen.SurfaceGui.TextButton
		,script.Parent.Parent
	)
end
return efi
