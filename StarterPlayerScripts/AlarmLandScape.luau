local player = game.Players.LocalPlayer
local gui = player:WaitForChild("PlayerGui"):WaitForChild("AlarmUI")

local function CheckOrientation()
	local size = workspace.CurrentCamera.ViewportSize

	if size.Y > size.X then
		-- 세로 상태
		gui.Enabled = true
	else
		-- 가로 상태
		gui.Enabled = false
	end
end

workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(CheckOrientation)

CheckOrientation()