-- TODOS:
-- Coins ESP
-- Expand Throw Hitbox
-- Shoot Murderer & Shoot Keybind & Shoot Hitbox
-- Self Destruct, Labs
-- Check if firetouchinterest exists (UNC check basically)
-- Fix Autofarm loop mechanism
-- Add hide character from lobby

local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Remotes = game:GetService("ReplicatedStorage").Remotes
local PlayerData = {}
local IsFarming = false

getgenv().Relper = {
    Config = {},
    Events = {},
    Esps = {}
}

local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

local function StartAutoFarm()
    local Config = getgenv().Relper.Config
    if Config["Toggle:AutofarmCoin"] and not IsFarming then
        IsFarming = true

        local Character = LocalPlayer.Character
        local Map = GetMap()

        while Character and Map and IsFarming do
            local Humanoid = Character:FindFirstChildWhichIsA("Humanoid")
            local PrimaryPart = Character.PrimaryPart
            local MinDistance = math.huge
            local CoinContainer = Map:WaitForChild("CoinContainer")
            local Coin = nil

            -- Most likely dead
            if not PrimaryPart then
                IsFarming = false
                return
            end

            for i, v in pairs(CoinContainer:GetChildren()) do
                if v.Name ~= "Coin_Server" or not v:FindFirstChildWhichIsA("TouchTransmitter") or not v:FindFirstChild("CoinVisual") then
                    continue
                end

                local Distance = LocalPlayer:DistanceFromCharacter(v.Position)
                if Distance < MinDistance then
                    Coin = v
                    MinDistance = Distance
                end
            end

            if Coin then
                local Gravity = Workspace.Gravity
                Workspace.Gravity = 0
                Humanoid.Sit = true
                PrimaryPart.AssemblyLinearVelocity = Vector3.new(0, 0, 0)

                local Parts = {}
    			for i, v in pairs(Map:GetDescendants()) do
    				if v:IsA("BasePart") and v.CanCollide then
    					v.CanCollide = false
    					table.insert(Parts, v)
    				end
    			end

                local Hide = Config["Toggle:AutofarmHideCharacter"]

                local Offset = Hide and CFrame.new(0, -5, 0) or CFrame.new(0, Humanoid.HipHeight, 0)
                local Tween = TweenService:Create(PrimaryPart, TweenInfo.new(MinDistance / (Config["Slider:AutofarmSpeed"] or 20)), {
                    CFrame = Coin:GetPivot() * Offset
                })
                Tween:Play()
                Tween.Completed:Wait()

                firetouchinterest(PrimaryPart, Coin, 1)
                firetouchinterest(PrimaryPart, Coin, 0)

                task.wait(Config["Slider:AutofarmInterval"] or 0.5)

                Workspace.Gravity = Gravity
                Humanoid.Sit = false

                for i, v in pairs(Parts) do
                    v.CanCollide = true
                end
            else
                task.wait(Config["Slider:AutofarmInterval"] or 0.5)
            end
        end

        IsFarming = false
    end
end

local Window = Rayfield:CreateWindow({
	Name = "Relper - Murder Mystery 2",
	LoadingTitle = "Relper",
	LoadingSubtitle = "Murder Mystery 2",
	ConfigurationSaving = {
		Enabled = true,
		FolderName = "Relper",
		FileName = "MM2"
	},
	KeySystem = false
})

-- Rayfield:Notify("Title Example", "Content/Description Example", 4483362458) -- Notfication -- Title, Content, Image

local VisualsTab = Window:CreateTab("Visuals", 4483362458)

VisualsTab:CreateSection("Players")

VisualsTab:CreateToggle({
	Name = "Murderer ESP",
	CurrentValue = true,
	Flag = "Toggle:MurdererESP",
	Callback = function(Value)
		getgenv().Relper.Config["Toggle:MurdererESP"] = Value
		update_esp()
	end
})

VisualsTab:CreateToggle({
	Name = "Sheriff / Hero ESP",
	CurrentValue = true,
	Flag = "Toggle:SheriffESP",
	Callback = function(Value)
		getgenv().Relper.Config["Toggle:SheriffESP"] = Value
		update_esp()
	end
})

VisualsTab:CreateToggle({
	Name = "Innocent ESP",
	CurrentValue = true,
	Flag = "Toggle:InnocentESP",
	Callback = function(Value)
		getgenv().Relper.Config["Toggle:InnocentESP"] = Value
		update_esp()
	end
})

VisualsTab:CreateToggle({
	Name = "Exclude Self from ESP",
	CurrentValue = true,
	Flag = "Toggle:HideSelfESP",
	Callback = function(Value)
		getgenv().Relper.Config["Toggle:HideSelfESP"] = Value
		update_esp()
	end
})

VisualsTab:CreateToggle({
	Name = "Treat Hero as Sheriff",
	CurrentValue = false,
	Flag = "Toggle:TreatHeroAsSheriff",
	Callback = function(Value)
		getgenv().Relper.Config["Toggle:TreatHeroAsSheriff"] = Value
		update_esp()
	end
})

VisualsTab:CreateToggle({
	Name = "Extend FOV",
	CurrentValue = true,
	Flag = "Toggle:ExtendFOV",
	Callback = function(Value)
	    if Value then
	        LocalPlayer.CameraMaxZoomDistance = 100
	    else
	        LocalPlayer.CameraMaxZoomDistance = 15
	    end
	end
})

VisualsTab:CreateSection("Objects")

VisualsTab:CreateToggle({
	Name = "Dropped Gun ESP",
	CurrentValue = true,
	Flag = "Toggle:GunESP",
	Callback = function(Value)
		getgenv().Relper.Config["Toggle:GunESP"] = Value
		if Value then
		    local Map = GetMap()
		    if Map then
                local GunDrop = Map:FindFirstChild("GunDrop")
                if GunDrop then
                    local Gui = LocalPlayer:FindFirstChildWhichIsA("PlayerGui")
                    local GunESP = Gui:FindFirstChild("GunESP")
                    if GunESP then
                        GunESP.Adornee = GunDrop
                    else
                        -- Had to do this due to Highlight bugs
                        local Highlight = Instance.new("Highlight", Gui)
                        Highlight.Name = "GunESP"
                        Highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                        Highlight.Adornee = GunDrop
                        Highlight.FillColor = Color3.fromRGB(255, 255, 0)
                        Highlight.FillTransparency = 0.2
                    end
                end
            end
        else
            local Gui = LocalPlayer:FindFirstChildWhichIsA("PlayerGui")
            local GunESP = Gui:FindFirstChild("GunESP")
            if GunESP then
                GunESP:Destroy()
            end
        end
	end
})

VisualsTab:CreateToggle({
	Name = "Coins ESP",
	CurrentValue = false,
	Flag = "Toggle:CoinESP",
	Callback = function(Value)
		-- TODO
	end
})

local MurdererTab = Window:CreateTab("Murderer", 4483362458)

MurdererTab:CreateSection("Stab")

MurdererTab:CreateToggle({
	Name = "Auto Stab",
	CurrentValue = true,
	Flag = "Toggle:AutoStab",
	Callback = function(Value)
		getgenv().Relper.Config["Toggle:AutoStab"] = Value
	end
})

MurdererTab:CreateSlider({
	Name = "Auto Stab Distance",
	Range = {0, 25},
	Increment = 1,
	Suffix = "studs",
	CurrentValue = 7,
	Flag = "Slider:AutoStabDistance",
	Callback = function(Value)
		getgenv().Relper.Config["Slider:AutoStabDistance"] = Value
	end
})

MurdererTab:CreateToggle({
	Name = "Only on Hand",
	CurrentValue = true,
	Flag = "Toggle:AutoStabOnlyOnHand",
	Callback = function(Value)
		getgenv().Relper.Config["Toggle:AutoStabOnlyOnHand"] = Value
	end
})

MurdererTab:CreateToggle({
	Name = "Expand Stab Hitbox",
	CurrentValue = true,
	Flag = "Toggle:StabHitbox",
	Callback = function(Value)
		getgenv().Relper.Config["Toggle:StabHitbox"] = Value
	end
})

MurdererTab:CreateSlider({
	Name = "Stab Hitbox Size",
	Range = {0, 25},
	Increment = 1,
	Suffix = "studs",
	CurrentValue = 7,
	Flag = "Slider:StabHitboxSize",
	Callback = function(Value)
		getgenv().Relper.Config["Slider:StabHitboxSize"] = Value
	end
})

MurdererTab:CreateSection("Throw")

MurdererTab:CreateToggle({
	Name = "Expand Throw Hitbox",
	CurrentValue = true,
	Flag = "Toggle:ThrowHitbox",
	Callback = function(Value)
		getgenv().Relper.Config["Toggle:ThrowHitbox"] = Value
	end
})

MurdererTab:CreateSlider({
	Name = "Throw Hitbox Size",
	Range = {0, 25},
	Increment = 1,
	Suffix = "studs",
	CurrentValue = 7,
	Flag = "Slider:ThrowHitboxSize",
	Callback = function(Value)
		getgenv().Relper.Config["Slider:ThrowHitboxSize"] = Value
	end
})

MurdererTab:CreateSection("Blatant")

MurdererTab:CreateToggle({
	Name = "Auto Kill Sheriff / Hero",
	CurrentValue = false,
	Flag = "Toggle:AutoKillSheriff",
	Callback = function(Value)
		getgenv().Relper.Config["Toggle:AutoKillSheriff"] = Value
	end
})

MurdererTab:CreateButton({
	Name = "Kill Sheriff / Hero",
	Callback = function()
		if not PlayerData[LocalPlayer.Name] or PlayerData[LocalPlayer.Name].Role ~= "Murderer" then
            return
        end

        local Character = LocalPlayer.Character
        local Knife = get_knife(LocalPlayer)

        if Character and Knife and (not OnlyOnHand or Knife.Parent == Character) then
	        update_playerdata()
            local Humanoid = Character:FindFirstChildWhichIsA("Humanoid")
            local Equipped = true
            if Knife.Parent == LocalPlayer.Backpack then
                Equipped = false
                Humanoid:EquipTool(Knife)
                RunService.RenderStepped:Wait()
            end

            Knife.Stab:FireServer()
            for i, v in pairs(Players:GetPlayers()) do
                if v ~= LocalPlayer and v.Character and PlayerData[v.Name] and not PlayerData[v.Name].Died and (PlayerData[v.Name].Role == "Sheriff" or PlayerData[v.Name].Role == "Hero") then
                    firetouchinterest(v.Character.PrimaryPart, Knife.Handle, 0)
                    break
                end
            end

            if not Equipped then
                wait(LocalPlayer:GetNetworkPing() * 5)
                Humanoid:UnequipTools()
            end
        end
	end
})

MurdererTab:CreateButton({
	Name = "Kill Innocents",
	Callback = function()
		if not PlayerData[LocalPlayer.Name] or PlayerData[LocalPlayer.Name].Role ~= "Murderer" then
            return
        end

        local Character = LocalPlayer.Character
        local Knife = get_knife(LocalPlayer)

        if Character and Knife and (not OnlyOnHand or Knife.Parent == Character) then
	        update_playerdata()
            local Humanoid = Character:FindFirstChildWhichIsA("Humanoid")
            local Equipped = true
            if Knife.Parent == LocalPlayer.Backpack then
                Equipped = false
                Humanoid:EquipTool(Knife)
                RunService.RenderStepped:Wait()
            end

            Knife.Stab:FireServer()
            for i, v in pairs(Players:GetPlayers()) do
                if v ~= LocalPlayer and v.Character and PlayerData[v.Name] and not PlayerData[v.Name].Died and PlayerData[v.Name].Role == "Innocent" then
                    firetouchinterest(v.Character.PrimaryPart, Knife.Handle, 0)
                end
            end

            if not Equipped then
                wait(LocalPlayer:GetNetworkPing() * 5)
                Humanoid:UnequipTools()
            end
        end
	end
})

MurdererTab:CreateButton({
	Name = "Kill All",
	Callback = function()
        if not PlayerData[LocalPlayer.Name] or PlayerData[LocalPlayer.Name].Role ~= "Murderer" then
            return
        end

        local Character = LocalPlayer.Character
        local Knife = get_knife(LocalPlayer)

        if Character and Knife and (not OnlyOnHand or Knife.Parent == Character) then
	        update_playerdata()
            local Humanoid = Character:FindFirstChildWhichIsA("Humanoid")
            local Equipped = true
            if Knife.Parent == LocalPlayer.Backpack then
                Equipped = false
                Humanoid:EquipTool(Knife)
                RunService.RenderStepped:Wait()
            end

            Knife.Stab:FireServer()
            for i, v in pairs(Players:GetPlayers()) do
                if v ~= LocalPlayer and v.Character and PlayerData[v.Name] and not PlayerData[v.Name].Died then
                    firetouchinterest(v.Character.PrimaryPart, Knife.Handle, 0)
                end
            end

            if not Equipped then
                wait(LocalPlayer:GetNetworkPing() * 5)
                Humanoid:UnequipTools()
            end
        end
	end
})

local SheriffTab = Window:CreateTab("Sheriff", 4483362458)

SheriffTab:CreateSection("Shoot")

SheriffTab:CreateToggle({
	Name = "Shoot Murderer",
	CurrentValue = true,
	Flag = "Toggle:ShootMurderer",
	Callback = function(Value)
		getgenv().Relper.Config["Toggle:ShootMurderer"] = Value
	end
})

SheriffTab:CreateKeybind({
	Name = "Shoot Keybind",
	CurrentKeybind = "E",
	HoldToInteract = false,
	Flag = "Keybind:ShootMurderer",
	Callback = function(Keybind)
		getgenv().Relper.Config["Keybind:ShootMurderer"] = Value
	end
})

SheriffTab:CreateToggle({
	Name = "Expand Shoot Hitbox",
	CurrentValue = true,
	Flag = "Toggle:ShootHitbox",
	Callback = function(Value)
		getgenv().Relper.Config["Toggle:ShootHitbox"] = Value
	end
})

SheriffTab:CreateSlider({
	Name = "Shoot Hitbox Size",
	Range = {0, 25},
	Increment = 1,
	Suffix = "studs",
	CurrentValue = 7,
	Flag = "Slider:ShootHitboxSize",
	Callback = function(Value)
		getgenv().Relper.Config["Slider:ShootHitboxSize"] = Value
	end
})

SheriffTab:CreateSection("Dropped Gun")

SheriffTab:CreateButton({
	Name = "Grab Gun",
	Callback = function(Value)
	    local Character = LocalPlayer.Character
		if not Character or not PlayerData[LocalPlayer.Name] or PlayerData[LocalPlayer.Name].Role ~= "Innocent" then
		    return
		end

        local Map = GetMap()
        if Map then
            local GunDrop = Map:FindFirstChild("GunDrop")
            if GunDrop then
                firetouchinterest(Character.PrimaryPart, GunDrop, 0)
            end
        end
	end
})

SheriffTab:CreateToggle({
	Name = "Auto Grab Gun",
	CurrentValue = false,
	Flag = "Toggle:AutoGrabGun",
	Callback = function(Value)
		getgenv().Relper.Config["Toggle:AutoGrabGun"] = Value
	end
})

SheriffTab:CreateToggle({
	Name = "Expand Dropped Gun Hitbox",
	CurrentValue = true,
	Flag = "Toggle:DroppedGunHitbox",
	Callback = function(Value)
	    getgenv().Relper.Config["Toggle:DroppedGunHitbox"] = Value
	end
})

SheriffTab:CreateSlider({
	Name = "Dropped Gun Hitbox Size",
	Range = {0, 25},
	Increment = 1,
	Suffix = "studs",
	CurrentValue = 10,
	Flag = "Slider:DroppedGunHitboxSize",
	Callback = function(Value)
		getgenv().Relper.Config["Slider:DroppedGunHitboxSize"] = Value
	end
})

SheriffTab:CreateSection("Blatant")

SheriffTab:CreateButton({
	Name = "Kill Murderer",
	Callback = function()
	    if not PlayerData[LocalPlayer.Name] or not (PlayerData[LocalPlayer.Name].Role == "Sheriff" or PlayerData[LocalPlayer.Name].Role == "Hero") then
            return
        end

        local Character = LocalPlayer.Character
        local Humanoid = Character:FindFirstChildWhichIsA("Humanoid")
        local PrimaryPart = Character.PrimaryPart
        local Gun = get_gun(LocalPlayer)

        if Character and Gun then
	        update_playerdata()
	        wait(1)

            local Murderer = nil
            for i, v in pairs(PlayerData) do
                if v.Role == "Murderer" then
                    Murderer = Players:FindFirstChild(i)
                    break
                end
            end

            if not Murderer or not Murderer.Character then
                return
            end

            local UpperTorso = Murderer.Character:FindFirstChild("UpperTorso")
            if not UpperTorso then
                UpperTorso = Murderer.Character.PrimaryPart
            end

            local CurrentCFrame = PrimaryPart.CFrame
            PrimaryPart.CFrame = UpperTorso.CFrame * CFrame.new(0, 0, 3)

            local Equipped = true
            if Gun.Parent == LocalPlayer.Backpack then
                Equipped = false
                Humanoid:EquipTool(Gun)
            end

            wait(LocalPlayer:GetNetworkPing() * 3)

            -- Had to do this due to InvokeServer blocking the thread until gun reload
            spawn(function()
                Gun.KnifeLocal.CreateBeam.RemoteFunction:InvokeServer(
                    1,
                    predict_position(Murderer),
                    "AH2"
                )
            end)

            wait(LocalPlayer:GetNetworkPing() * 3)

            if not Equipped then
                Humanoid:UnequipTools()
            end
            PrimaryPart.CFrame = CurrentCFrame
        end
	end
})

SheriffTab:CreateParagraph({ Title = "Note", Content = "Since gun shots are server-sided, your character will teleport to the back of the murderer. Therefore, it will not work if the murderer has his back against a wall, and obviously it can not protect you from death." })

local AutofarmTab = Window:CreateTab("Autofarm", 4483362458)

AutofarmTab:CreateSection("Farm Drops")

AutofarmTab:CreateToggle({
	Name = "Farm Coins",
	CurrentValue = false,
	Flag = "Toggle:AutofarmCoin",
	Callback = function(Value)
		getgenv().Relper.Config["Toggle:AutofarmCoin"] = Value

		if not IsFarming and PlayerData[LocalPlayer.Name] and not PlayerData[LocalPlayer.Name].Dead then
            StartAutoFarm()
        end
	end
})

AutofarmTab:CreateSlider({
	Name = "Farm Speed",
	Range = {10, 50},
	Increment = 1,
	Suffix = "studs",
	CurrentValue = 20,
	Flag = "Slider:AutofarmSpeed",
	Callback = function(Value)
		getgenv().Relper.Config["Slider:AutofarmSpeed"] = Value
	end
})

AutofarmTab:CreateSlider({
	Name = "Farm Interval",
	Range = {0, 3},
	Increment = 0.1,
	Suffix = "seconds",
	CurrentValue = 0.5,
	Flag = "Slider:AutofarmInterval",
	Callback = function(Value)
		getgenv().Relper.Config["Slider:AutofarmInterval"] = Value
	end
})

AutofarmTab:CreateToggle({
	Name = "Hide Character",
	CurrentValue = false,
	Flag = "Toggle:AutofarmHideCharacter",
	Callback = function(Value)
		getgenv().Relper.Config["Toggle:AutofarmHideCharacter"] = Value
	end
})

AutofarmTab:CreateToggle({
	Name = "Reset after done",
	CurrentValue = true,
	Flag = "Toggle:AutofarmResetAfterDone",
	Callback = function(Value)
		getgenv().Relper.Config["Toggle:AutofarmResetAfterDone"] = Value
	end
})

local SettingsTab = Window:CreateTab("Settings", 4483362458)

SettingsTab:CreateSection("UI")

SettingsTab:CreateParagraph({ Title = "UI Library: Rayfield", Content = "https://sirius.menu/rayfield" })

SettingsTab:CreateButton({
	Name = "Self Destruct",
	Callback = function()
	    for i, v in pairs(getgenv().Relper.Esps) do
            v:Destroy()
	    end

		LocalPlayer.CameraMaxZoomDistance = 15

		local Gui = LocalPlayer:FindFirstChildWhichIsA("PlayerGui")
        local GunESP = Gui:FindFirstChild("GunESP")
        if GunESP then
            GunESP:Destroy()
        end

		Rayfield:Destroy()
	end
})

SettingsTab:CreateSection("Labs")

SettingsTab:CreateLabel("Functions below are only for experimental use thus can be unstable!")

SettingsTab:CreateToggle({
	Name = "Use Throw on Murderer Blatant",
	CurrentValue = false,
	Flag = "Toggle:Experimental:ThrowOnBlatant",
	Callback = function(Value)
		getgenv().Relper.Config["Toggle:Experimental:ThrowOnBlatant"] = Value
	end
})

SettingsTab:CreateToggle({
	Name = "Cast Ray on Sheriff Shoot",
	CurrentValue = false,
	Flag = "Toggle:Experimental:RayCastOnShoot",
	Callback = function(Value)
		getgenv().Relper.Config["Toggle:RayCastOnShoot"] = Value
	end
})

-- Backend

RunService.Heartbeat:Connect(function(step)
    local Config = getgenv().Relper.Config

    if Config["Toggle:AutoStab"] and PlayerData[LocalPlayer.Name] and PlayerData[LocalPlayer.Name].Role == "Murderer" then
        local Distance = Config["Slider:AutoStabDistance"]
        local OnlyOnHand = Config["Toggle:AutoStabOnlyOnHand"]
		local Character = LocalPlayer.Character
        local Knife = get_knife(LocalPlayer)

        if Character and Knife and (not OnlyOnHand or Knife.Parent == Character) then
            local Humanoid = Character:FindFirstChildWhichIsA("Humanoid")
            local Position = Character.PrimaryPart.Position
            for i, v in pairs(Players:GetPlayers()) do
                if v ~= LocalPlayer and v.Character and PlayerData[v.Name] and not PlayerData[v.Name].Died and v:DistanceFromCharacter(Position) <= Distance then
                    local Equipped = true
                    if Knife.Parent == LocalPlayer.Backpack then
                        Equipped = false
                        Humanoid:EquipTool(Knife)
                        RunService.RenderStepped:Wait()
                    end

                    Knife.Stab:FireServer()

                    firetouchinterest(v.Character.PrimaryPart, Knife.Handle, 0)

                    if not Equipped then
                        Humanoid:UnequipTools()
                    end
                end
            end
        end
    end

    if Config["Toggle:AutoKillSheriff"] and PlayerData[LocalPlayer.Name] and PlayerData[LocalPlayer.Name].Role == "Murderer" then
		local Character = LocalPlayer.Character
        local Knife = get_knife(LocalPlayer)

        if Character and Knife then
            local Humanoid = Character:FindFirstChildWhichIsA("Humanoid")
            for i, v in pairs(Players:GetPlayers()) do
                if v ~= LocalPlayer and v.Character and PlayerData[v.Name] and not PlayerData[v.Name].Died and (PlayerData[v.Name].Role == "Sheriff" or PlayerData[v.Name].Role == "Hero") then
                    local Equipped = true
                    if Knife.Parent == LocalPlayer.Backpack then
                        Equipped = false
                        Humanoid:EquipTool(Knife)
                        RunService.RenderStepped:Wait()
                    end

                    Knife.Stab:FireServer()

                    firetouchinterest(v.Character.PrimaryPart, Knife.Handle, 0)

                    if not Equipped then
                        Humanoid:UnequipTools()
                    end
                end
            end
        end
    end

    if Config["Toggle:DroppedGunHitbox"] and PlayerData[LocalPlayer.Name] and PlayerData[LocalPlayer.Name].Role == "Innocent" then
        local Distance = Config["Slider:DroppedGunHitboxSize"]
        local Character = LocalPlayer.Character
        local Map = GetMap()
        if Map then
            local GunDrop = Map:FindFirstChild("GunDrop")

    		if Character and GunDrop then
    		    local PrimaryPart = Character.PrimaryPart
    		    if LocalPlayer:DistanceFromCharacter(GunDrop.Position) <= Distance then
    		        firetouchinterest(Character.PrimaryPart, GunDrop, 0)
    		    end
    		end
    	end
    end

    -- shoot Murderer
end)

function GetMap()
    for i, v in pairs(Workspace:GetChildren()) do
        if v:FindFirstChild("Base") and (v:FindFirstChild("CoinAreas") or v:FindFirstChild("CoinContainer")) and v:FindFirstChild("Spawns") then
            return v
        end
    end
end

function get_knife(player)
    local Character = player.Character
    if not Character then
        return nil
    end

    local Knife = Character:FindFirstChildWhichIsA("Tool")
    if Knife then
        if Knife:GetAttribute("IsKnife") then
            return Knife
        end
    end

    for i, v in pairs(player.Backpack:GetChildren()) do
        if v:GetAttribute("IsKnife") then
            return v
        end
    end
end

function get_gun(player)
    local Character = player.Character
    if not Character then
        return nil
    end

    local Gun = Character:FindFirstChildWhichIsA("Tool")
    if Gun then
        if Gun:GetAttribute("IsGun") then
            return Gun
        end
    end

    for i, v in pairs(player.Backpack:GetChildren()) do
        if v:GetAttribute("IsGun") then
            return v
        end
    end
end

function predict_position(player)
    local Character = player.Character
    if not Character then
        return Vector3.new(0, 0, 0)
    end

    local Humanoid = Character:FindFirstChildWhichIsA("Humanoid")
    local UpperTorso = Character:FindFirstChild("UpperTorso")
    if not UpperTorso then
        UpperTorso = Character.PrimaryPart
    end

    local Velocity = UpperTorso.AssemblyLinearVelocity
    local Predicted = Velocity.Y
    if Character:FindFirstChildWhichIsA("Humanoid"):GetState() == Enum.HumanoidStateType.Freefall then
        Predicted = predict_y_while_jumping(Velocity.Y)
    end

    -- return UpperTorso.Position + Velocity * Vector3.new(0, Velocity.Y > 10 and 0.4 or 0.5, 0) * LocalPlayer:GetNetworkPing() + Humanoid.MoveDirection * LocalPlayer:GetNetworkPing() * 16
    return UpperTorso.Position + Vector3.new(0, Predicted, 0) + Humanoid.MoveDirection * LocalPlayer:GetNetworkPing() * 16
end

function predict_y_while_jumping(YVelocity)
    YVelocity = math.min(math.max(-52, YVelocity), 52)
    local Ping = LocalPlayer:GetNetworkPing()
    local JumpState = math.acos(YVelocity / 52) / math.pi
    -- local CurrentYOffset = math.sin(JumpState * math.pi)
    -- local PredictedYOffset = (math.sin((JumpState + Ping * 2) * math.pi) + 1)
    -- print(JumpState, PredictedYOffset, CurrentYOffset)
    -- return 4
    local CurrentYOffset = (0.5 - math.abs(-0.5 + JumpState)) * 8
    local PredictedYOffset = (0.5 - math.abs(-0.5 + (((JumpState / 2 + Ping) * 2) % 1))) * 8
    print(CurrentYOffset, PredictedYOffset, Ping)
    return PredictedYOffset - CurrentYOffset
    -- return (PredictedYOffset - CurrentYOffset) * 8
end

function handle_esp(data)
    for i, v in pairs(getgenv().Relper.Esps) do
        v:Destroy()
    end

    getgenv().Relper.Esps = {}
    local Config = getgenv().Relper.Config
    for i, v in pairs(PlayerData) do
        if Config["Toggle:HideSelfESP"] and i == LocalPlayer.Name then
            continue
        elseif v.Role == "Murderer" and not Config["Toggle:MurdererESP"] then
            continue
        elseif (v.Role == "Sheriff" or v.Role == "Hero") and not Config["Toggle:SheriffESP"] then
            continue
        elseif v.Role == "Innocent" and not Config["Toggle:InnocentESP"] then
            continue
        end

        local Player = Players:FindFirstChild(i)
        if v.Dead or not Player or not Player.Character then
            continue
        end

        local Highlight = Instance.new("Highlight", Player.Character)
        Highlight.Name = "PlayerESP"
        Highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        Highlight.Adornee = Player.Character
        Highlight.FillTransparency = 0.3

        if v.Role == "Murderer" then
            Highlight.FillColor = Color3.fromRGB(255, 0, 0)
        elseif v.Role == "Sheriff" or (Config["Toggle:TreatHeroAsSheriff"] and v.Role == "Hero") then
            Highlight.FillColor = Color3.fromRGB(0, 0, 255)
        elseif v.Role == "Hero" then
            Highlight.FillColor = Color3.fromRGB(255, 255, 0)
        elseif v.Role == "Innocent" then
            Highlight.FillColor = Color3.fromRGB(0, 255, 0)
            Highlight.FillTransparency = 0.8
        end

        table.insert(getgenv().Relper.Esps, Highlight)
    end
end

function update_playerdata()
    PlayerData = Remotes.Gameplay.GetCurrentPlayerData:InvokeServer()
    return PlayerData
end

function update_esp()
    update_playerdata()
    handle_esp(PlayerData)
end

update_playerdata()

getgenv().Relper.Events.OnPlayerData = Remotes.Gameplay.PlayerDataChanged.OnClientEvent:Connect(function(data)
    PlayerData = data
    handle_esp(PlayerData)
end)

getgenv().Relper.Events.OnCoinCollected = Remotes.Gameplay.CoinCollected.OnClientEvent:Connect(function(Currency, CurrentCoins, MaxCoins)
    local Config = getgenv().Relper.Config
    if CurrentCoins == MaxCoins and Config["Toggle:AutofarmCoin"] and Config["Toggle:AutofarmResetAfterDone"] then
        local Character = LocalPlayer.Character
        if Character then
            local Humanoid = Character:FindFirstChildWhichIsA("Humanoid")
            local PrimaryPart = Character.PrimaryPart
            local Map = GetMap()

            -- Teleport to nearest spawn to reduce round time
            if Map and PrimaryPart and PlayerData[LocalPlayer.Name] and (PlayerData[LocalPlayer.Name].Role == "Sheriff" or PlayerData[LocalPlayer.Name].Role == "Hero") then
                local Spawn = nil
                local MinDistance = math.huge
                for i, v in pairs(Map.Spawns:GetChildren()) do
                    local Distance = LocalPlayer:DistanceFromCharacter(v.Position)
                    if Distance < MinDistance then
                        MinDistance = Distance
                        Spawn = v
                    end
                end

                if Spawn then
                    local Tween = TweenService:Create(PrimaryPart, TweenInfo.new(MinDistance / (Config["Slider:AutofarmSpeed"] or 20)), {
                        CFrame = Spawn.CFrame * CFrame.new(0, Humanoid.HipHeight, 0)
                    })
                    Tween:Play()
                    Tween.Completed:Wait()
                end
            end

            Humanoid.Health = 0
        end
    end
end)

getgenv().Relper.Events.OnCoinsStart = Remotes.Gameplay.CoinsStarted.OnClientEvent:Connect(StartAutoFarm)

getgenv().Relper.Events.OnRoundEnd = Remotes.Gameplay.VictoryScreen.OnClientEvent:Connect(function()
    IsFarming = false
end)

getgenv().Relper.Events.OnGunDrop = Workspace.DescendantAdded:Connect(function(descendant)
    if descendant.Name == "GunDrop" then
        local Config = getgenv().Relper.Config

        if Config["Toggle:AutoGrabGun"] and PlayerData[LocalPlayer.Name] and PlayerData[LocalPlayer.Name].Role == "Innocent" then
            local Character = LocalPlayer.Character
    		if Character then
    		    firetouchinterest(Character.PrimaryPart, descendant, 0)
    		end
        elseif Config["Toggle:GunESP"] then
            local Gui = LocalPlayer:FindFirstChildWhichIsA("PlayerGui")
            local GunESP = Gui:FindFirstChild("GunESP")
            if GunESP then
                GunESP.Adornee = descendant
            else
                -- Had to do this due to Highlight bugs
                local Highlight = Instance.new("Highlight", Gui)
                Highlight.Name = "GunESP"
                Highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                Highlight.Adornee = descendant
                Highlight.FillColor = Color3.fromRGB(255, 255, 0)
                Highlight.FillTransparency = 0.2
            end
        end
    end
end)

getgenv().Relper.Events.OnGunGrab = Workspace.DescendantRemoving:Connect(function(descendant)
    if descendant.Name == "GunDrop" then
        update_esp()
    end
end)