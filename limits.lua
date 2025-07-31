local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()
local Window = WindUI:CreateWindow({
    Title = "Ellen Hub",
    Icon = "code",
    Author = "1ellen",
    Folder = "EllenHub",
    Size = UDim2.fromOffset(620, 460),
    Transparent = true,
    Theme = "Dark",
    Resizable = true,
    SideBarWidth = 200,
    BackgroundImageTransparency = 0.42,
    HideSearchBar = true,
    ScrollBarEnabled = false,
    User = {
        Enabled = true,
        Anonymous = false,
        Callback = function()
            print("clicked")
        end,
    },
})

--// Interface

local Tab_LocalPlayer = Window:Tab({ Title = "LocalPlayer", Icon = "panel-right", Locked = false })
local Tab_GunMod = Window:Tab({ Title = "Gun Mod", Icon = "cog", Locked = true })
local Tab_ESP = Window:Tab({ Title = "ESP", Icon = "monitor", Locked = false })
local Tab_Map = Window:Tab({ Title = "Map", Icon = "map", Locked = true })
Window:SelectTab(1)

--// Serviços
local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

--// LocalPlayer: Code

--// Inf Jump

local InfJump = false

local InfJumpToggle = Tab_LocalPlayer:Toggle({
    Title = "Infinite jump",
    Desc = "",
    Icon = "check",
    Type = "Checkbox",
    Default = false,
    Callback = function(state) 
       InfJump = state
     end
})

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if not InfJump then return end
	if gameProcessed then return end
	if input.KeyCode == Enum.KeyCode.Space then
		local char = Player.Character or Player.CharacterAdded:Wait()
		local humanoid = char:FindFirstChildOfClass("Humanoid")
		if humanoid then
			humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
		end
	end
end)

--// Noclip
local Noclipping = false
local NoclipConnection

local noclipWhitelist = {
	"Head",
	"Torso",
	"Left Leg",
	"Right Leg",
	"HumanoidRootPart"
}

local function isWhitelisted(part)
	for _, name in ipairs(noclipWhitelist) do
		if part.Name == name then
			return true
		end
	end
	return false
end

local function toggleNoclipLoop(state)
	if NoclipConnection then
		NoclipConnection:Disconnect()
		NoclipConnection = nil
	end

	if state then
		NoclipConnection = RunService.Stepped:Connect(function()
			local char = Player.Character
			if not char then return end

			for _, part in ipairs(char:GetDescendants()) do
				if part:IsA("BasePart") and isWhitelisted(part) then
					part.CanCollide = false
				end
			end
		end)
	end
end

Player.CharacterAdded:Connect(function(char)
	if Noclipping then
		task.wait(.5)
		toggleNoclipLoop(true)
	end
end)

local NoclipToggle = Tab_LocalPlayer:Toggle({
	Title = "Noclip",
	Desc = "",
	Icon = "check",
	Type = "Checkbox",
	Default = false,
	Callback = function(state)
		Noclipping = state
		toggleNoclipLoop(state)
	end
})

--// WalkSpeed

--[[ local WalkspeedSlider = Tab_LocalPlayer:Slider({
    Title = "Walkspeed",
    Step = 1,

    Value = {
        Min = 16,
        Max = 100,
        Default = 16,
    },
    Callback = function(value)
        Player.Character:WaitForChild("Humanoid").WalkSpeed = value
    end
}) 

--// Jump Power
 local JumppowerSlider = Tab_LocalPlayer:Slider({
    Title = "Jump Power",
    Step = 1,

    Value = {
        Min = 50,
        Max = 300,
        Default = 50,
    },
    Callback = function(value)
        Player.Character:WaitForChild("Humanoid").JumpPower = value
    end
}) ]]

--// ESP: Code

local ShowName = false
local ShowHP = false
local ShowTool = false
local ShowRole = false
local ShowHighlight = false

-- Objetos de ESP
local ESPObjects = {}
local HighlightObjects = {}

-- Limpa ESPs criados
local function clearESP()
	for _, obj in pairs(ESPObjects) do
		if obj and obj.Parent then
			obj:Destroy()
		end
	end
	table.clear(ESPObjects)
end

-- Limpa Highlights
local function clearHighlights()
	for _, obj in pairs(HighlightObjects) do
		if obj and obj.Parent then
			obj:Destroy()
		end
	end
	table.clear(HighlightObjects)
end

-- Cria ESP visual
local function createESPForCharacter(character, player)
	local head = character:FindFirstChild("Head")
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if not head or not humanoid then return end

	-- Remove ESP antigo se existir
	for _, gui in ipairs(head:GetChildren()) do
		if gui:IsA("BillboardGui") and gui.Name == "ESP_GUI" then
			gui:Destroy()
		end
	end

	local billboard = Instance.new("BillboardGui")
	billboard.Name = "ESP_GUI"
	billboard.AlwaysOnTop = true
	billboard.Size = UDim2.new(0, 200, 0, 100)
	billboard.StudsOffset = Vector3.new(0, 3, 0)
	billboard.Parent = head

	local y = 0
	local hpLabel, toolLabel, roleLabel

	if ShowName then
		local nameLabel = Instance.new("TextLabel")
		nameLabel.Size = UDim2.new(1, 0, 0.25, 0)
		nameLabel.Position = UDim2.new(0, 0, y, 0)
		nameLabel.BackgroundTransparency = 1
		nameLabel.TextColor3 = Color3.new(1, 1, 1)
		nameLabel.TextStrokeTransparency = 0
		nameLabel.TextScaled = true
		nameLabel.Font = Enum.Font.RobotoMono
		nameLabel.Text = player.Name
		nameLabel.Parent = billboard
		y += 0.25
	end

	if ShowHP then
		hpLabel = Instance.new("TextLabel")
		hpLabel.Size = UDim2.new(1, 0, 0.25, 0)
		hpLabel.Position = UDim2.new(0, 0, y, 0)
		hpLabel.BackgroundTransparency = 1
		hpLabel.TextColor3 = Color3.new(1, 1, 1)
		hpLabel.TextStrokeTransparency = 0
		hpLabel.TextScaled = true
		hpLabel.Font = Enum.Font.RobotoMono
		hpLabel.Text = "HP: 100"
		hpLabel.Parent = billboard
		y += 0.25
	end

	if ShowTool then
		toolLabel = Instance.new("TextLabel")
		toolLabel.Size = UDim2.new(1, 0, 0.25, 0)
		toolLabel.Position = UDim2.new(0, 0, y, 0)
		toolLabel.BackgroundTransparency = 1
		toolLabel.TextColor3 = Color3.new(1, 1, 1)
		toolLabel.TextStrokeTransparency = 0
		toolLabel.TextScaled = true
		toolLabel.Font = Enum.Font.RobotoMono
		toolLabel.Text = "Tool: None"
		toolLabel.Parent = billboard
		y += 0.25
	end

	if ShowRole then
		roleLabel = Instance.new("TextLabel")
		roleLabel.Size = UDim2.new(1, 0, 0.25, 0)
		roleLabel.Position = UDim2.new(0, 0, y, 0)
		roleLabel.BackgroundTransparency = 1
		roleLabel.TextColor3 = Color3.new(1, 1, 1)
		roleLabel.TextStrokeTransparency = 0
		roleLabel.TextScaled = true
		roleLabel.Font = Enum.Font.RobotoMono
		roleLabel.Text = "Role: Unknown"
		roleLabel.Parent = billboard

		local function updateRole()
			local role = player:GetAttribute("Role")
			roleLabel.Text = "Role: " .. (role or "Unknown")
		end

		player:GetAttributeChangedSignal("Role"):Connect(updateRole)
		updateRole()
	end

	local conn
	conn = RunService.RenderStepped:Connect(function()
		if not billboard or not billboard.Parent or humanoid.Health <= 0 then
			if conn then conn:Disconnect() end
			if billboard then billboard:Destroy() end
			return
		end

		if hpLabel then
			hpLabel.Text = "HP: " .. math.floor(humanoid.Health)
		end

		if toolLabel then
			local tool = character:FindFirstChildOfClass("Tool")
			toolLabel.Text = "Tool: " .. (tool and tool.Name or "None")
		end
	end)

	table.insert(ESPObjects, billboard)
end

-- Cria destaque com Highlight
local function createHighlight(character, player)
	if not character then return end

	for _, obj in ipairs(character:GetChildren()) do
		if obj:IsA("Highlight") and obj.Name == "ESP_Highlight" then
			obj:Destroy()
		end
	end

	local hl = Instance.new("Highlight")
	hl.Name = "ESP_Highlight"
	hl.Adornee = character
	hl.FillTransparency = 0.8
	hl.OutlineTransparency = 0
	hl.Parent = character

	local function updateColor()
		local role = player:GetAttribute("Role")
		if role == "Shooter" or role == "Mafia" then
			hl.FillColor = Color3.fromRGB(255, 0, 0)
			hl.OutlineColor = Color3.fromRGB(255, 0, 0)
		elseif role == "Guards" then
			hl.FillColor = Color3.fromRGB(0, 0, 255)
			hl.OutlineColor = Color3.fromRGB(0, 0, 255)
		elseif role == "Bystander" then
			hl.FillColor = Color3.fromRGB(255, 255, 255)
			hl.OutlineColor = Color3.fromRGB(255, 255, 255)
		else
			hl.FillColor = Color3.fromRGB(150, 150, 150)
			hl.OutlineColor = Color3.fromRGB(150, 150, 150)
		end
	end

	player:GetAttributeChangedSignal("Role"):Connect(updateColor)
	updateColor()

	character.ChildAdded:Connect(function(child)
		if child:IsA("Tool") then
			updateColor()
		end
	end)

	character.ChildRemoved:Connect(function(child)
		if child:IsA("Tool") then
			task.wait(0.1)
			updateColor()
		end
	end)

	table.insert(HighlightObjects, hl)
end

-- Aplica ESP a um jogador
local function applyToPlayer(plr)
	if plr == Players.LocalPlayer then return end

	local function applyToChar(char)
		if ShowName or ShowHP or ShowTool or ShowRole then
			createESPForCharacter(char, plr)
		end
		if ShowHighlight then
			createHighlight(char, plr)
		end
	end

	if plr.Character then
		applyToChar(plr.Character)
	end

	plr.CharacterAdded:Connect(function(char)
		task.wait(0.5)
		applyToChar(char)
	end)
end

-- Aplica para todos os jogadores
local function applyAll()
	for _, plr in ipairs(Players:GetPlayers()) do
		applyToPlayer(plr)
	end
end

-- Novo jogador
Players.PlayerAdded:Connect(function(plr)
	plr.CharacterAdded:Connect(function()
		task.wait(1)
		applyToPlayer(plr)
	end)
end)

-- Atualiza ESP
local function refreshESP()
	clearESP()
	clearHighlights()
	applyAll()
end

--// UI Toggles
local ShowNameToggle = Tab_ESP:Toggle({
	Title = "Name ESP",
	Icon = "check",
	Default = false,
	Callback = function(state)
		ShowName = state
		refreshESP()
	end
})

local HPToggle = Tab_ESP:Toggle({
	Title = "Health ESP",
	Icon = "check",
	Default = false,
	Callback = function(state)
		ShowHP = state
		refreshESP()
	end
})

local ToolEspToggle = Tab_ESP:Toggle({
	Title = "Tool ESP",
	Icon = "check",
	Default = false,
	Callback = function(state)
		ShowTool = state
		refreshESP()
	end
})

local RoleEspToggle = Tab_ESP:Toggle({
	Title = "Role ESP",
	Icon = "check",
	Default = false,
	Callback = function(state)
		ShowRole = state
		refreshESP()
	end
})

local HighlightToggle = Tab_ESP:Toggle({
	Title = "Highlight Players",
	Icon = "check",
	Default = false,
	Callback = function(state)
		ShowHighlight = state
		refreshESP()
	end
})

--// Map
local Baseplate = workspace:WaitForChild("Baseplate")
local LastPosition

local SafePlaceButton = Tab_Map:Button({
    Title = "TP (Safe Place)",
    Desc = "Teleporta para a base segura",
    Locked = false,
    Callback = function()
        local character = game:GetService("Players").LocalPlayer.Character
        local rootPart = character and character:FindFirstChild("HumanoidRootPart")
        if rootPart and Baseplate then
            LastPosition = rootPart.CFrame
            rootPart.CFrame = Baseplate.CFrame + Vector3.new(0, 5, 0)
        end
    end
})


local TpBackButton = Tab_Map:Button({
    Title = "TP Back",
    Desc = "",
    Locked = false,
    Callback = function()
        local character = game:GetService("Players").LocalPlayer.Character
        local rootPart = character and character:FindFirstChild("HumanoidRootPart")
        if rootPart and LastPosition then
            rootPart.CFrame = LastPosition
        end
    end
})
