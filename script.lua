-- tools.lua

local function createTeleportTool(player)
    local tool = Instance.new("Tool")
    tool.Name = "TeleportTool"
    tool.Parent = player.Backpack
    tool.ToolTip = "Click to teleport to a location"
    
    local handle = Instance.new("Part")
    handle.Name = "Handle"
    handle.Parent = tool
    handle.Size = Vector3.new(1, 1, 3)
    handle.BrickColor = BrickColor.new("Royal purple")
    handle.Material = Enum.Material.Neon
    
    tool.Activated:Connect(function()
        local mouse = player:GetMouse()
        local target = mouse.Hit.Position
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            player.Character.HumanoidRootPart.CFrame = CFrame.new(target)
            print("Teleported to clicked location!")
        else
            warn("Player character or HumanoidRootPart not found!")
        end
    end)

    return tool
end

return createTeleportTool
