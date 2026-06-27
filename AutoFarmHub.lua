local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local mainFrame
local screenGuiRef
local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

local function createGui()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "AutoFarmHub"
    screenGui.ResetOnSpawn = false
    screenGui.IgnoreGuiInset = true
    screenGui.Parent = playerGui
    screenGuiRef = screenGui

    local main = Instance.new("Frame")
    main.Name = "Main"
    main.Size = UDim2.new(0, 450, 0, 350)
    main.Position = UDim2.new(0.5, -225, 0.5, -175)
    main.BackgroundColor3 = Color3.new(0.12, 0.12, 0.14)
    main.BorderSizePixel = 0
    main.ClipsDescendants = true
    main.Parent = screenGui

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = main

    local titleFrame = Instance.new("Frame")
    titleFrame.Name = "TitleFrame"
    titleFrame.Size = UDim2.new(1, 0, 0, 40)
    titleFrame.BackgroundColor3 = Color3.new(0.15, 0.15, 0.17)
    titleFrame.BorderSizePixel = 0
    titleFrame.Parent = main

    local titleCorner = Instance.new("UICorner")
    titleCorner.CornerRadius = UDim.new(0, 8)
    titleCorner.Parent = titleFrame

    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, -70, 0, 40)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = "AutoFarm Hub"
    titleLabel.TextColor3 = Color3.new(1, 1, 1)
    titleLabel.TextSize = 16
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.Parent = titleFrame

    local closeBtn = Instance.new("ImageButton")
    closeBtn.Name = "Close"
    closeBtn.Size = UDim2.fromOffset(30, 30)
    closeBtn.Position = UDim2.new(1, -35, 0, 5)
    closeBtn.BackgroundTransparency = 1
    closeBtn.Image = "rbxassetid://7733658504"
    closeBtn.ImageColor3 = Color3.new(1, 1, 1)
    closeBtn.ScaleType = Enum.ScaleType.Fit
    closeBtn.Parent = titleFrame
    closeBtn.MouseButton1Click:Connect(function()
        if mainFrame then mainFrame.Visible = false end
    end)

    local contentFrame = Instance.new("Frame")
    contentFrame.Name = "ContentFrame"
    contentFrame.Size = UDim2.new(1, 0, 1, -40)
    contentFrame.Position = UDim2.new(0, 0, 0, 40)
    contentFrame.BackgroundTransparency = 1
    contentFrame.Parent = main

    local listLayout = Instance.new("UIListLayout")
    listLayout.Padding = UDim.new(0, 10)
    listLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    listLayout.SortOrder = Enum.SortOrder.LayoutOrder
    listLayout.Parent = contentFrame

    local padding = Instance.new("UIPadding")
    padding.PaddingTop = UDim.new(0, 15)
    padding.Parent = contentFrame

    mainFrame = main
end

local function showHub()
    if (not mainFrame) or (not mainFrame.Parent) then
        createGui()
    else
        mainFrame.Visible = not mainFrame.Visible
    end
end

local function onCharacterAdded(char)
    char:WaitForChild("Humanoid", 5)

    local gui = playerGui:FindFirstChild("AutoFarmToolGui")
    if not gui then
        gui = Instance.new("ScreenGui")
        gui.Name = "AutoFarmToolGui"
        gui.ResetOnSpawn = false
        gui.Parent = playerGui

        local btn = Instance.new("TextButton")
        btn.Name = "ToggleBtn"
        btn.Size = UDim2.new(0, 120, 0, 40)
        btn.Position = UDim2.new(0, 10, 0.5, -20)
        btn.BackgroundColor3 = Color3.new(0.2, 0.6, 0.2)
        btn.BorderSizePixel = 0
        btn.Text = "AutoFarm"
        btn.TextColor3 = Color3.new(1, 1, 1)
        btn.TextSize = 18
        btn.Font = Enum.Font.GothamBold
        btn.Parent = gui
        btn.MouseButton1Click:Connect(showHub)

        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 8)
        corner.Parent = btn
    end

    local backpack = player:WaitForChild("Backpack", 5)
    if backpack and not backpack:FindFirstChild("AutoFarm") then
        local tool = Instance.new("Tool")
        tool.Name = "AutoFarm"
        tool.RequiresHandle = false

        local toggle = Instance.new("BoolValue")
        toggle.Name = "AutoFarmEnabled"
        toggle.Parent = tool

        local remote = Instance.new("RemoteEvent")
        remote.Name = "AutoFarmEvent"
        remote.Parent = tool

        tool.Activated:Connect(showHub)
        tool.Parent = backpack
    end
end

local function onPlayerAdded(plr)
    if plr == player then
        plr.CharacterAdded:Connect(onCharacterAdded)
        if plr.Character then
            onCharacterAdded(plr.Character)
        end
    end
end

Players.PlayerAdded:Connect(onPlayerAdded)
if player then
    onPlayerAdded(player)
end
