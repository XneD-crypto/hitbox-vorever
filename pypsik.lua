-- Roblox Script (KRNL Injector)
-- Creates a draggable GUI for setting universal hitbox size with auto-reapply and white transparent hitboxes

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

-- Current hitbox size storage
local CurrentHitboxSize = 5
local ActiveHitboxes = {}

-- Create ScreenGui
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "HitboxControl"
ScreenGui.Parent = game.CoreGui
ScreenGui.ResetOnSpawn = false

-- Create Main Frame
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 180, 0, 130)
MainFrame.Position = UDim2.new(0.5, -90, 0.5, -65)
MainFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
MainFrame.Active = true
MainFrame.Draggable = false
MainFrame.Parent = ScreenGui

-- Create Corner UI
local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 8)
UICorner.Parent = MainFrame

-- Create Size Input Box
local SizeBox = Instance.new("TextBox")
SizeBox.Name = "SizeBox"
SizeBox.Size = UDim2.new(0, 160, 0, 25)
SizeBox.Position = UDim2.new(0, 10, 0, 10)
SizeBox.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
SizeBox.TextColor3 = Color3.fromRGB(255, 255, 255)
SizeBox.PlaceholderText = "Enter size (0-40)"
SizeBox.Text = "5"
SizeBox.Font = Enum.Font.Gotham
SizeBox.TextSize = 12
SizeBox.Parent = MainFrame

-- Create Hitbox Button (Smaller)
local HitboxButton = Instance.new("TextButton")
HitboxButton.Name = "HitboxButton"
HitboxButton.Size = UDim2.new(0, 160, 0, 30)
HitboxButton.Position = UDim2.new(0, 10, 0, 45)
HitboxButton.BackgroundColor3 = Color3.fromRGB(0, 85, 255)
HitboxButton.TextColor3 = Color3.fromRGB(255, 255, 255)
HitboxButton.Text = "HITBOX ALL"
HitboxButton.Font = Enum.Font.GothamBold
HitboxButton.TextSize = 14
HitboxButton.Parent = MainFrame

-- Create Status Label
local StatusLabel = Instance.new("TextLabel")
StatusLabel.Name = "StatusLabel"
StatusLabel.Size = UDim2.new(0, 160, 0, 25)
StatusLabel.Position = UDim2.new(0, 10, 0, 85)
StatusLabel.BackgroundTransparency = 1
StatusLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
StatusLabel.Text = "Status: Ready"
StatusLabel.Font = Enum.Font.Gotham
StatusLabel.TextSize = 11
StatusLabel.Parent = MainFrame

-- Touch Drag Logic
local dragging = false
local dragInput, dragStart, startPos

local function update(input)
    local delta = input.Position - dragStart
    MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
end

MainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
        
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

MainFrame.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        update(input)
    end
end)

-- Function to apply hitbox to a player
local function applyHitboxToPlayer(player, size)
    if player.Character then
        local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid.HipHeight = size
        end
        
        local rootPart = player.Character:FindFirstChild("HumanoidRootPart")
        if rootPart then
            rootPart.Size = Vector3.new(size, size, size)
            rootPart.Transparency = 0.8  -- More transparent
            rootPart.BrickColor = BrickColor.new("White")  -- White color
            rootPart.Material = Enum.Material.Neon
        end
    end
end

-- Function to monitor player respawns
local function monitorPlayerRespawn(player)
    player.CharacterAdded:Connect(function(character)
        wait(1) -- Wait for character to fully load
        if CurrentHitboxSize > 0 then
            applyHitboxToPlayer(player, CurrentHitboxSize)
        end
    end)
end

-- Apply hitbox to all players and monitor them
HitboxButton.MouseButton1Click:Connect(function()
    local size = tonumber(SizeBox.Text)
    
    if not size then
        StatusLabel.Text = "Status: Invalid number"
        return
    end
    
    if size < 0 or size > 40 then
        StatusLabel.Text = "Status: Size must be 0-40"
        return
    end
    
    CurrentHitboxSize = size
    StatusLabel.Text = "Status: Applying..."
    
    -- Apply to all current players
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            applyHitboxToPlayer(player, size)
            ActiveHitboxes[player] = true
            monitorPlayerRespawn(player) -- Ensure monitoring is set up
        end
    end
    
    StatusLabel.Text = "Status: Hitbox Applied!"
    wait(2)
    StatusLabel.Text = "Status: Ready"
end)

-- Monitor new players joining and apply hitbox automatically
Players.PlayerAdded:Connect(function(player)
    monitorPlayerRespawn(player)
    if CurrentHitboxSize > 0 then
        wait(3) -- Wait for player to load
        applyHitboxToPlayer(player, CurrentHitboxSize)
        ActiveHitboxes[player] = true
    end
end)

-- Monitor all existing players and apply hitbox if size is set
for _, player in pairs(Players:GetPlayers()) do
    if player ~= LocalPlayer then
        monitorPlayerRespawn(player)
        if CurrentHitboxSize > 0 then
            applyHitboxToPlayer(player, CurrentHitboxSize)
            ActiveHitboxes[player] = true
        end
    end
end
