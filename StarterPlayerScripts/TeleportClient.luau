local ReplicatedStorage = game:GetService("ReplicatedStorage")

local remote = ReplicatedStorage:WaitForChild("RemoteEvents"):WaitForChild("WallZoneEvent")

local gui = script.Parent
local frame = gui:WaitForChild("Frame")
local confirmButton = frame:WaitForChild("ConfirmButton")
local cancelButton = frame:WaitForChild("CancelButton")

local SoundManager = require(ReplicatedStorage.SoundManager)

-- 서버에서 UI 열라는 신호 받기
remote.OnClientEvent:Connect(function(action)

	if action == "OpenUI" then
		gui.Enabled = true
		
		-- ?? 추가
		SoundManager.Play("Panel_Open")
	end
end)

-- 확인 버튼 클릭
confirmButton.MouseButton1Click:Connect(function()

	gui.Enabled = false
	
	SoundManager.Play("Panel_Confirm")
	
	remote:FireServer("EnterWallZone")

end)

-- 취소 버튼 클릭
cancelButton.MouseButton1Click:Connect(function()

	SoundManager.Play("Panel_Cancel")

	gui.Enabled = false

end)