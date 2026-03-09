--// BLOX FRUITS AUTO CHEST FARM + UI

repeat task.wait() until game:IsLoaded()

local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local collected = {}
local visitedServers = {}

--================ AUTO JOIN MARINES =================--

task.spawn(function()

    repeat task.wait(1)

        if not player.Team then
            pcall(function()
                ReplicatedStorage.Remotes.CommF_:InvokeServer("SetTeam","Marines")
            end)
        end

    until player.Team ~= nil

end)

--================ AUTO REJOIN =================--

game.CoreGui.RobloxPromptGui.promptOverlay.ChildAdded:Connect(function(v)

    if v.Name == "ErrorPrompt" then
        task.wait(2)
        TeleportService:Teleport(game.PlaceId)
    end

end)

--================ UI =================--

local gui = Instance.new("ScreenGui",game.CoreGui)
gui.Name = "H_Farm_UI"

local title = Instance.new("TextLabel",gui)
title.Size = UDim2.new(0,220,0,120)
title.AnchorPoint = Vector2.new(0.5,0.5)
title.Position = UDim2.new(0.5,0,0.45,0)
title.BackgroundTransparency = 1
title.Text = "H"
title.TextScaled = true
title.Font = Enum.Font.FredokaOne
title.TextColor3 = Color3.fromRGB(255,255,255)

local stroke = Instance.new("UIStroke",title)
stroke.Thickness = 6
stroke.Color = Color3.fromRGB(0,255,255)

local beliText = Instance.new("TextLabel",gui)
beliText.Size = UDim2.new(0,400,0,40)
beliText.AnchorPoint = Vector2.new(0.5,0.5)
beliText.Position = UDim2.new(0.5,0,0.55,0)
beliText.BackgroundTransparency = 1
beliText.TextScaled = true
beliText.Font = Enum.Font.FredokaOne

--================ RAINBOW BELI =================--

task.spawn(function()

    local hue = 0

    while task.wait() do

        hue = hue + 0.01
        if hue > 1 then
            hue = 0
        end

        beliText.TextColor3 = Color3.fromHSV(hue,1,1)

    end

end)

--================ BELI DISPLAY =================--

task.spawn(function()

    repeat task.wait() until player:FindFirstChild("Data")

    while task.wait(1) do

        local beli = player.Data.Beli.Value
        beliText.Text = "Beli : "..beli

    end

end)

--================ WAIT CHARACTER =================--

repeat task.wait() until player.Character
repeat task.wait() until player.Character:FindFirstChild("HumanoidRootPart")

--================ FIND CHESTS =================--

local function getChestList()

    local list = {}

    for _,v in pairs(workspace:GetDescendants()) do

        if string.find(v.Name,"Chest") and not collected[v] then

            local part

            if v:IsA("Model") then
                part = v:FindFirstChildWhichIsA("BasePart")
            elseif v:IsA("BasePart") then
                part = v
            end

            if part and part.Parent then
                table.insert(list,part)
            end

        end

    end

    return list

end

--================ SERVER HOP =================--

local function serverHop()

    local req = game:HttpGet(
        "https://games.roblox.com/v1/games/"..
        game.PlaceId..
        "/servers/Public?sortOrder=Asc&limit=100"
    )

    local data = HttpService:JSONDecode(req)

    for _,v in pairs(data.data) do

        if v.playing < v.maxPlayers and not visitedServers[v.id] then

            visitedServers[v.id] = true

            TeleportService:TeleportToPlaceInstance(game.PlaceId,v.id,player)

            break

        end

    end

end

--================ AUTO CHEST =================--

while task.wait(0.08) do

    local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then continue end

    local chests = getChestList()

    if #chests == 0 then

        task.wait(2)
        serverHop()

    else

        for _,chest in ipairs(chests) do

            if chest and chest.Parent then

                collected[chest.Parent or chest] = true

                hrp.CFrame = chest.CFrame + Vector3.new(0,3,0)

                task.wait(0.07)

            end

        end

    end

end
