local efi = {}


	function efi.main()
		local kernel = require(script.Parent.kernel)
		kernel.kernel_init(
			workspace.Part1.SurfaceGui.TextLabel
			,workspace.Part1.SurfaceGui.TextBox
			,workspace.Part1.SurfaceGui.TextButton
			,workspace.Folder
		)
	end
return efi
