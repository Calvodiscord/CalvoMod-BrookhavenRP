-- SERVICES
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer and LocalPlayer:FindFirstChild("PlayerGui")

if not LocalPlayer or not PlayerGui then return end

-- THEME
local theme = {
    background = Color3.fromRGB(30, 32, 37),
    sidebar = Color3.fromRGB(20, 22, 27),   
    card = Color3.fromRGB(40, 42, 47),      
    primaryText = Color3.fromRGB(230, 230, 230),
    secondaryText = Color3.fromRGB(150, 150, 150),
    accent = Color3.fromRGB(88, 101, 242),  
    close = Color3.fromRGB(237, 66, 69),
    W = 800, 
    H = 500, 
    SIDEBAR_W = 180, 
    PADDING = 15,
}

-- FUNÇÕES AUXILIARES
local function split(inputstr, sep)
    if sep == nil then sep = "%s" end
    local t = {}
    for str in string.gmatch(inputstr, "([^" .. sep .. "]+)") do
        table.insert(t, str)
    end
    return t
end

local commands = {}
local noclipConnection = nil

local function getPlayers(targetName)
    local targets = {}
    if not targetName then targetName = "me" end
    local lowerTargetName = targetName:lower()
    if lowerTargetName == "me" or lowerTargetName == "eu" then
        table.insert(targets, LocalPlayer)
    elseif lowerTargetName == "all" or lowerTargetName == "todos" then
        for _, player in ipairs(Players:GetPlayers()) do
            table.insert(targets, player)
        end
    else
        for _, player in ipairs(Players:GetPlayers()) do
            if player.Name:lower():match("^" .. lowerTargetName) then
                table.insert(targets, player)
            end
        end
    end
    return targets
end

-- DEFINIÇÃO DOS COMANDOS
commands.fly = {
    func = function(args)
        local targets = getPlayers(args[1] or "me")
        for _, player in ipairs(targets) do
            local char = player.Character
            if char and char:FindFirstChild("HumanoidRootPart") then
                if char:FindFirstChild("BodyGyro") then return end
                local HRP = char.HumanoidRootPart
                local speed = tonumber(args[2]) or 50
                local gyro = Instance.new("BodyGyro", HRP); gyro.P = 50000; gyro.maxTorque = Vector3.new(9e9, 9e9, 9e9); gyro.CFrame = HRP.CFrame
                local vel = Instance.new("BodyVelocity", HRP); vel.velocity = Vector3.new(0, 0.1, 0); vel.maxForce = Vector3.new(9e9, 9e9, 9e9)
                char.Humanoid.PlatformStand = true
            end
        end
    end
}
commands.unfly = {
    func = function(args)
        local targets = getPlayers(args[1] or "me")
        for _, player in ipairs(targets) do
            local char = player.Character
            if char then
                if char.HumanoidRootPart:FindFirstChild("BodyGyro") then char.HumanoidRootPart.BodyGyro:Destroy() end
                if char.HumanoidRootPart:FindFirstChild("BodyVelocity") then char.HumanoidRootPart.BodyVelocity:Destroy() end
                char.Humanoid.PlatformStand = false
            end
        end
    end
}
commands.noclip = {
    func = function(args)
        if noclipConnection then
            noclipConnection:Disconnect(); noclipConnection = nil
        else
            noclipConnection = RunService.Stepped:Connect(function()
                local char = LocalPlayer.Character
                if char then
                    for _, part in ipairs(char:GetDescendants()) do
                        if part:IsA("BasePart") and part.CanCollide then part.CanCollide = false end
                    end
                end
            end)
        end
    end
}
commands.speed = {
    func = function(args)
        local targets = getPlayers(args[1] or "me")
        local speedValue = tonumber(args[2]) or 100
        for _, player in ipairs(targets) do
            if player.Character and player.Character:FindFirstChild("Humanoid") then
                player.Character.Humanoid.WalkSpeed = speedValue
            end
        end
    end
}
commands.jump = {
    func = function(args)
        local targets = getPlayers(args[1] or "me")
        local power = tonumber(args[2]) or 100
        for _, player in ipairs(targets) do
            if player.Character and player.Character:FindFirstChild("Humanoid") then
                player.Character.Humanoid.JumpPower = power
            end
        end
    end
}
commands.kill = {
    func = function(args)
        local targets = getPlayers(args[1] or "me")
        for _, player in ipairs(targets) do
            if player.Character and player.Character:FindFirstChild("Humanoid") then
                player.Character.Humanoid.Health = 0
            end
        end
    end
}

-- INTERFACE PRINCIPAL
local function loadCalvoMod()
    local ScreenGui = Instance.new("ScreenGui"); 
    ScreenGui.ResetOnSpawn = false; 
    ScreenGui.Parent = PlayerGui
    
    local MainFrame = Instance.new("Frame"); 
    MainFrame.Size = UDim2.new(0, theme.W, 0, theme.H)
    MainFrame.Position = UDim2.new(0.5, -theme.W/2, 0.5, -theme.H/2) 
    MainFrame.BackgroundColor3 = theme.background
    MainFrame.BorderSizePixel = 0
    MainFrame.Active = true
    MainFrame.Parent = ScreenGui
    
    local Sidebar = Instance.new("Frame")
    Sidebar.Size = UDim2.new(0, theme.SIDEBAR_W, 1, 0)
    Sidebar.BackgroundColor3 = theme.sidebar
    Sidebar.BorderSizePixel = 0
    Sidebar.Parent = MainFrame
    
    local SidebarHeader = Instance.new("Frame")
    SidebarHeader.Size = UDim2.new(1, 0, 0, 60)
    SidebarHeader.BackgroundColor3 = theme.sidebar
    SidebarHeader.Parent = Sidebar
    local HeaderLabel = Instance.new("TextLabel")
    HeaderLabel.Text = "CALVO MOD"
    HeaderLabel.Size = UDim2.new(1, 0, 1, 0)
    HeaderLabel.TextXAlignment = Enum.TextXAlignment.Left
    HeaderLabel.Position = UDim2.new(0, theme.PADDING, 0, 0)
    HeaderLabel.Font = Enum.Font.GothamBold
    HeaderLabel.TextColor3 = theme.primaryText
    HeaderLabel.TextSize = 20
    HeaderLabel.BackgroundTransparency = 1
    HeaderLabel.Parent = SidebarHeader
    
    local TabContainer = Instance.new("Frame")
    TabContainer.Size = UDim2.new(1, 0, 1, -120)
    TabContainer.Position = UDim2.new(0, 0, 0, 60)
    TabContainer.BackgroundTransparency = 1
    TabContainer.Parent = Sidebar
    
    local TabListLayout = Instance.new("UIListLayout")
    TabListLayout.Padding = UDim.new(0, 5)
    TabListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    TabListLayout.Parent = TabContainer
    
    local Footer = Instance.new("Frame")
    Footer.Size = UDim2.new(1, 0, 0, 60)
    Footer.Position = UDim2.new(0, 0, 1, -60)
    Footer.BackgroundColor3 = theme.sidebar
    Footer.Parent = Sidebar
    
    local DisconnectButton = Instance.new("TextButton")
    DisconnectButton.Size = UDim2.new(1, -theme.PADDING*2, 0, 30)
    DisconnectButton.Position = UDim2.new(0.5, - (theme.SIDEBAR_W/2 - theme.PADDING), 0.5, 0)
    DisconnectButton.Text = "Disconnect"
    DisconnectButton.Font = Enum.Font.Gotham
    DisconnectButton.TextColor3 = Color3.fromRGB(237, 66, 69)
    DisconnectButton.TextSize = 16
    DisconnectButton.BackgroundTransparency = 1
    DisconnectButton.Parent = Footer
    DisconnectButton.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)
    
    local ContentPanel = Instance.new("Frame")
    ContentPanel.Size = UDim2.new(1, -theme.SIDEBAR_W, 1, 0)
    ContentPanel.Position = UDim2.new(0, theme.SIDEBAR_W, 0, 0)
    ContentPanel.BackgroundColor3 = theme.background
    ContentPanel.BorderSizePixel = 0
    ContentPanel.Parent = MainFrame

    local PageContainer = Instance.new("Frame")
    PageContainer.Size = UDim2.new(1, -theme.PADDING*2, 1, -theme.PADDING*2)
    PageContainer.Position = UDim2.new(0, theme.PADDING, 0, theme.PADDING)
    PageContainer.BackgroundTransparency = 1
    PageContainer.Parent = ContentPanel
    
    local TABS = {
        Main = {Name = "Main", Icon = "⚡", Page = nil}, 
        Teleports = {Name = "Teleports", Icon = "📍", Page = nil},
        Visuals = {Name = "Visuals", Icon = "👁️", Page = nil},
        Settings = {Name = "Settings", Icon = "⚙️", Page = nil},
    }
    
    local currentTab = nil
    
    local function selectTab(tabName, tabButton)
        if currentTab == tabName then return end
        
        for _, tab in pairs(TABS) do
            if tab.Page then tab.Page.Visible = false end
            if tab.Button then
                tab.Button.BackgroundColor3 = theme.sidebar
                tab.Button.TextColor3 = theme.secondaryText
                tab.Button:FindFirstChild("IconLabel").TextColor3 = theme.secondaryText
            end
        end
        
        local tab = TABS[tabName]
        if tab.Page then tab.Page.Visible = true end
        
        tabButton.BackgroundColor3 = theme.accent
        tabButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        tabButton:FindFirstChild("IconLabel").TextColor3 = Color3.fromRGB(255, 255, 255)
        
        currentTab = tabName
    end
    
    for name, data in pairs(TABS) do
        local page = Instance.new("ScrollingFrame")
        page.Name = name .. "Page"
        page.Size = UDim2.new(1, 0, 1, 0)
        page.BackgroundTransparency = 1
        page.Visible = false
        page.CanvasSize = UDim2.new(0,0,0,0)
        page.Parent = PageContainer
        data.Page = page

        local ContentLayout = Instance.new("UIListLayout")
        ContentLayout.Padding = UDim.new(0, theme.PADDING)
        ContentLayout.SortOrder = Enum.SortOrder.LayoutOrder
        ContentLayout.Parent = page
        
        local PageTitle = Instance.new("TextLabel")
        PageTitle.Size = UDim2.new(1, 0, 0, 40)
        PageTitle.Text = name .. " Controls" 
        PageTitle.TextXAlignment = Enum.TextXAlignment.Left
        PageTitle.Font = Enum.Font.GothamBold
        PageTitle.TextColor3 = theme.primaryText
        PageTitle.TextSize = 24
        PageTitle.BackgroundTransparency = 1
        PageTitle.LayoutOrder = 1 
        PageTitle.Parent = page
        
        local tabButton = Instance.new("TextButton")
        local UICorner = Instance.new("UICorner", tabButton); UICorner.CornerRadius = UDim.new(0, 5)
        tabButton.Name = name .. "Button"
        tabButton.Size = UDim2.new(1, -10, 0, 35)
        tabButton.Position = UDim2.new(0, 5, 0, 0)
        tabButton.Text = "        " .. name 
        tabButton.Font = Enum.Font.Gotham
        tabButton.TextColor3 = theme.secondaryText
        tabButton.TextSize = 16
        tabButton.TextXAlignment = Enum.TextXAlignment.Left
        tabButton.BackgroundColor3 = theme.sidebar
        tabButton.BorderSizePixel = 0
        
        local IconLabel = Instance.new("TextLabel")
        IconLabel.Name = "IconLabel"
        IconLabel.Size = UDim2.new(0, 30, 1, 0)
        IconLabel.Position = UDim2.new(0, 10, 0, 0)
        IconLabel.Text = data.Icon
        IconLabel.Font = Enum.Font.Robloxian
        IconLabel.TextColor3 = theme.secondaryText
        IconLabel.TextSize = 20
        IconLabel.BackgroundTransparency = 1
        IconLabel.Parent = tabButton

        tabButton.Parent = TabContainer
        data.Button = tabButton 

        tabButton.MouseButton1Click:Connect(function()
            selectTab(name, tabButton)
        end)
    end
    
    local MainControls = TABS.Main.Page
    
    local AttributesCard = Instance.new("Frame")
    AttributesCard.Size = UDim2.new(1, 0, 0, 180) 
    AttributesCard.BackgroundColor3 = theme.card
    local UICorner = Instance.new("UICorner", AttributesCard); UICorner.CornerRadius = UDim.new(0, 8)
    AttributesCard.LayoutOrder = 2
    AttributesCard.Parent = MainControls
    
    local AttTitle = Instance.new("TextLabel")
    AttTitle.Text = "⚡ Attributes"
    AttTitle.TextXAlignment = Enum.TextXAlignment.Left
    AttTitle.Position = UDim2.new(0, 15, 0, 10)
    AttTitle.Size = UDim2.new(1, -30, 0, 20)
    AttTitle.Font = Enum.Font.GothamBold
    AttTitle.TextColor3 = Color3.fromRGB(150, 150, 255)
    AttTitle.TextSize = 16
    AttTitle.BackgroundTransparency = 1
    AttTitle.Parent = AttributesCard
    
    local ResetButton = Instance.new("TextButton")
    ResetButton.Size = UDim2.new(1, -30, 0, 30)
    ResetButton.Position = UDim2.new(0.5, -300/2, 0, 140)
    ResetButton.Text = "RESET DEFAULTS"
    ResetButton.Font = Enum.Font.GothamBold
    ResetButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    ResetButton.TextSize = 14
    ResetButton.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
    local UICorner = Instance.new("UICorner", ResetButton); UICorner.CornerRadius = UDim.new(0, 5)
    ResetButton.Parent = AttributesCard
    ResetButton.MouseButton1Click:Connect(function()
        commands.speed.func({"me", 16})
        commands.jump.func({"me", 50})
    end)
    
    local ActionsCard = Instance.new("Frame")
    ActionsCard.Size = UDim2.new(1, 0, 0, 150) 
    ActionsCard.BackgroundColor3 = theme.card
    local UICorner = Instance.new("UICorner", ActionsCard); UICorner.CornerRadius = UDim.new(0, 8)
    ActionsCard.LayoutOrder = 3
    ActionsCard.Parent = MainControls

    local ActionTitle = Instance.new("TextLabel")
    ActionTitle.Text = "👤 Character Actions"
    ActionTitle.TextXAlignment = Enum.TextXAlignment.Left
    ActionTitle.Position = UDim2.new(0, 15, 0, 10)
    ActionTitle.Size = UDim2.new(1, -30, 0, 20)
    ActionTitle.Font = Enum.Font.GothamBold
    ActionTitle.TextColor3 = Color3.fromRGB(150, 150, 255)
    ActionTitle.TextSize = 16
    ActionTitle.BackgroundTransparency = 1
    ActionTitle.Parent = ActionsCard
    
    local ButtonContainer = Instance.new("Frame")
    ButtonContainer.Size = UDim2.new(1, -30, 0, 100) 
    ButtonContainer.Position = UDim2.new(0, 15, 0, 40)
    ButtonContainer.BackgroundTransparency = 1
    ButtonContainer.Parent = ActionsCard
    
    local Grid = Instance.new("UIGridLayout") 
    Grid.CellSize = UDim2.new(0.5, -5, 0.5, -5) 
    Grid.CellPadding = UDim2.new(0, 10, 0, 10)
    Grid.FillDirection = Enum.FillDirection.Horizontal
    Grid.StartCorner = Enum.StartCorner.TopLeft
    Grid.Parent = ButtonContainer

    local FlyButton = Instance.new("TextButton")
    FlyButton.Text = "✈️ Fly"
    FlyButton.Size = UDim2.new(1, 0, 1, 0)
    FlyButton.Font = Enum.Font.GothamBold
    FlyButton.TextColor3 = theme.primaryText
    FlyButton.TextSize = 16
    FlyButton.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
    local UICorner = Instance.new("UICorner", FlyButton); UICorner.CornerRadius = UDim.new(0, 5)
    FlyButton.Parent = ButtonContainer
    
    local isFlying = false
    FlyButton.MouseButton1Click:Connect(function()
        isFlying = not isFlying
        if isFlying then
            commands.fly.func({"me"})
            FlyButton.BackgroundColor3 = theme.accent
        else
            commands.unfly.func({"me"})
            FlyButton.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
        end
    end)
    
    local NoclipButton = Instance.new("TextButton")
    NoclipButton.Text = "👻 Noclip"
    NoclipButton.Size = UDim2.new(1, 0, 1, 0) 
    NoclipButton.Font = Enum.Font.GothamBold
    NoclipButton.TextColor3 = theme.primaryText
    NoclipButton.TextSize = 16
    NoclipButton.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
    local UICorner = Instance.new("UICorner", NoclipButton); UICorner.CornerRadius = UDim.new(0, 5)
    NoclipButton.Parent = ButtonContainer

    local isNoclipping = false
    NoclipButton.MouseButton1Click:Connect(function()
        isNoclipping = not isNoclipping
        commands.noclip.func({}) 
        if isNoclipping then
            NoclipButton.BackgroundColor3 = theme.accent
        else
            NoclipButton.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
        end
    end)

    RunService.Heartbeat:Wait()
    MainControls.CanvasSize = UDim2.new(0, 0, 0, MainControls:FindFirstChildOfClass("UIListLayout").AbsoluteContentSize.Y + 20)

    MainFrame.Visible = true 
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if not gameProcessed and input.KeyCode == Enum.KeyCode.RightControl then
            MainFrame.Visible = not MainFrame.Visible
        end
    end)
    
    local dragging = false
    local dragStart = Vector2.new(0, 0)
    local frameStart = UDim2.new(0,0,0,0)
    
    Sidebar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = UserInputService:GetMouseLocation()
            frameStart = MainFrame.Position
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = UserInputService:GetMouseLocation() - dragStart
            MainFrame.Position = frameStart + UDim2.new(0, delta.X, 0, delta.Y)
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
    
    selectTab("Main", TABS.Main.Button) 
end

-- INICIA O MOD
loadCalvoMod()
