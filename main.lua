local ID = game.PlaceId
local baseURL = "https://raw.githubusercontent.com/1ellen/ellen-hub/refs/heads/main/"
local Players = game:GetService("Players")
local plr = Players.LocalPlayer

function GetGame()
    if ID == 109983668079237 then
        return "stealabrainrot.lua"
    elseif ID == 95031866873150 then
        return "limits.lua"
    else
        plr:Kick("Jogo sem suporte")
        return nil
    end
end

local gameScript = GetGame()

if gameScript then
    loadstring(game:HttpGet(baseURL .. gameScript))()
end

for _, v in next, getconnections(plr.Idled) do
    v:Disable()
end

local VirtualUser = game:GetService("VirtualUser")

if not plr then
    error("Falha ao obter referência: LocalPlayer")
end

plr.Idled:Connect(function()
    pcall(function()
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new())
    end)
end)
