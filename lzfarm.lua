local player = game.Players.LocalPlayer
local userId = player.UserId

local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager =
    loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager =
    loadstring(
    game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua")
)()
local Version = "Final"

if _G.Interface == nil then
    _G.Interface = true

    -- ====== PERSISTENCE MECHANISM ======
    local CONFIGURATION = {
        FOLDER_NAME = "CROW",
        SCRIPT_URL = "https://raw.githubusercontent.com/timegrocery/lazyfarm/refs/heads/main/lazyfarm.lua",
        FILE_EXTENSION = ".lua"
    }

    Fluent:Notify(
        {
            Title = "Loading interface...",
            Content = "Interface is loading, please wait.",
            Duration = 5
        }
    )

    local Window =
        Fluent:CreateWindow(
        {
            Title = game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name .. " | " .. Version,
            SubTitle = "Auto Update by archangel",
            TabWidth = 100,
            Size = UDim2.fromOffset(550, 400),
            Acrylic = false,
            Theme = "Darker",
            Transparency = "false",
            MinimizeKey = Enum.KeyCode.LeftControl
        }
    )

    local Tabs = {
        Player = Window:AddTab({Title = "Player", Icon = "user"}),
        World = Window:AddTab({Title = "World", Icon = "compass"}),
        Autofarm = Window:AddTab({Title = "Autofarm", Icon = "repeat"}),
        ESP = Window:AddTab({Title = "ESP", Icon = "eye"}),
        Misc = Window:AddTab({Title = "Server", Icon = "server"}),
        Credits = Window:AddTab({Title = "Credits", Icon = "book"}),
        UpdateLogs = Window:AddTab({Title = "Update Logs", Icon = "scroll"}),
        Settings = Window:AddTab({Title = "Settings", Icon = "settings"})
    }

    Tabs.Admin = Window:AddTab({Title = "Admin", Icon = "shield"})

    local Options = Fluent.Options

    Tabs.Player:AddParagraph(
        {
            Title = "Some features might not work together correctly.",
            Content = ""
        }
    )

    local secplayer = Tabs.Player:AddSection("Player")
    local player = game.Players.LocalPlayer
    local character = player.Character or player.CharacterAdded:Wait()
    local humanoid = character:WaitForChild("Humanoid")
    local rootPart = character:WaitForChild("HumanoidRootPart")
    local basespeed = 16
    local basejump = humanoid.JumpPower

    -- Movement variables
    local speedMultiplier = 1
    local moveConnection = nil

    -- Services
    local RunService = game:GetService("RunService")

    -- Function to apply CFrame movement
    local function applyMovement()
        if not rootPart or not humanoid then
            return
        end

        if humanoid.MoveDirection.Magnitude > 0 then
            -- Simple movement in the direction the character is moving
            local moveDirection = humanoid.MoveDirection
            local speed = basespeed * speedMultiplier / 60

            -- Move the character
            rootPart.CFrame = rootPart.CFrame + (moveDirection * speed)
        end
    end

    -- Disable default WalkSpeed
    humanoid.WalkSpeed = 0

    -- Start movement loop
    moveConnection = RunService.Heartbeat:Connect(applyMovement)

    -- Sliders
    local SliderSpeed =
        secplayer:AddSlider(
        "SliderSpeed",
        {
            Title = "Movement Speed",
            Description = "",
            Default = basespeed,
            Min = basespeed,
            Max = basespeed * 8,
            Rounding = 0,
            Callback = function(Value)
                speedMultiplier = Value / basespeed
            end
        }
    )

    local SliderJump =
        secplayer:AddSlider(
        "SliderJump",
        {
            Title = "Jump Power",
            Description = "",
            Default = basejump,
            Min = basejump,
            Max = basejump * 2,
            Rounding = 0,
            Callback = function(Value)
                humanoid.UseJumpPower = true
                humanoid.JumpPower = Value
            end
        }
    )

    -- Handle character respawn
    player.CharacterAdded:Connect(
        function(newCharacter)
            character = newCharacter
            humanoid = character:WaitForChild("Humanoid")
            rootPart = character:WaitForChild("HumanoidRootPart")

            -- Disable default WalkSpeed
            humanoid.WalkSpeed = 0

            -- Reconnect movement
            if moveConnection then
                moveConnection:Disconnect()
            end
            moveConnection = RunService.Heartbeat:Connect(applyMovement)

            -- Restore settings
            humanoid.UseJumpPower = true
            humanoid.JumpPower = SliderJump.Value
        end
    )

    local BuffDrop =
        secplayer:AddDropdown(
        "BuffDrop",
        {
            Title = "Buff Selection",
            Values = {"Luck", "EXP", "Coin", "Ghost Ship"},
            Multi = true,
            Default = {}
        }
    )

    secplayer:AddButton(
        {
            Title = "Add buff",
            Callback = function()
                local remotes =
                    game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("Guide"):WaitForChild(
                    "ChooseStarterBonus"
                )
                local ghostRemote = game:GetService("ReplicatedStorage").Remotes.WorldEvent.GhostShipBuff

                -- Get only the selected buffs (where State is true)
                for buffName, isSelected in pairs(BuffDrop.Value) do
                    if isSelected then -- Only process if the buff is selected
                        if buffName == "Luck" then
                            remotes:FireServer(161011)
                        elseif buffName == "EXP" then
                            remotes:FireServer(161012)
                        elseif buffName == "Coin" then
                            remotes:FireServer(161013)
                        elseif buffName == "Ghost Ship" then
                            ghostRemote:FireServer()
                        end
                    end
                end
            end
        }
    )

    local autoclikck = secplayer:AddToggle("autoclikck", {Title = "Autoclick", Default = false})
    autoclikck:OnChanged(
        function()
            if autoclikck.Value then
                while autoclikck.Value do
                    task.wait(0.1) -- Reduced frequency to avoid lag
                    game:GetService("Players").LocalPlayer.Character.Weapon:Activate()
                end
            end
        end
    )

    local playermisc = Tabs.Player:AddSection("Misc")

    local equipbest = playermisc:AddToggle("equipbest", {Title = "Always equip Best", Default = false})
    equipbest:OnChanged(
        function()
            if equipbest.Value then
                game:GetService("Players").LocalPlayer.PlayerGui.Main.Func.Tip.Visible = false
                while equipbest.Value do
                    task.wait(1) -- Reduced frequency to avoid lag
                    game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("Backpack"):WaitForChild(
                        "EquipBest"
                    ):FireServer()
                end
            else
                game:GetService("Players").LocalPlayer.PlayerGui.Main.Func.Tip.Visible = true
            end
        end
    )

    local togstat = playermisc:AddToggle("togstat", {Title = "Open Stats", Default = false})
    togstat:OnChanged(
        function()
            if togstat.Value then
                game:GetService("Players").LocalPlayer.PlayerGui.Main.Func.StatPoints.Visible = true
            else
                game:GetService("Players").LocalPlayer.PlayerGui.Main.Func.StatPoints.Visible = false
            end
        end
    )

    playermisc:AddButton(
        {
            Title = "Redeem all codes",
            Callback = function()
                -- Access the ModuleScript
                local moduleScript = game:GetService("ReplicatedStorage").Config.Planning.Config.CodeConfig

                -- Require the ModuleScript to access the table/data inside it
                local config = require(moduleScript)

                -- Function to recursively get all strings (excluding tables with a 'userId' greater than -1)
                local function fetchStrings(data)
                    local stringList = {}

                    -- Check if the data is a table
                    if type(data) == "table" then
                        -- Check if the table contains a 'userId' key, and ensure it's -1 or missing
                        if not data.userId or data.userId == -1 then
                            -- Iterate over all the keys in the table
                            for key, value in pairs(data) do
                                local nestedStrings = fetchStrings(value)
                                for _, str in ipairs(nestedStrings) do
                                    table.insert(stringList, str)
                                end
                            end
                        end
                    elseif type(data) == "string" then
                        -- If the data is a string, add it to the list
                        table.insert(stringList, data)
                    end

                    return stringList
                end

                -- Fetch the strings from the CodeConfig
                local strings = fetchStrings(config)

                -- If strings were found, fire the remote event with a 1 second delay between each
                if #strings > 0 then
                    for _, str in ipairs(strings) do
                        local args = {str} -- Passing each string as an argument
                        -- Wait for the remote event and fire it with the current string
                        game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("Code"):WaitForChild(
                            "CodeReward"
                        ):FireServer(unpack(args))

                        wait(3.5) -- Wait for 2.5 seconds before firing again
                    end
                end
            end
        }
    )

    local character = game.Players.LocalPlayer.Character or game.Players.LocalPlayer.CharacterAdded:Wait()

    playermisc:AddButton(
        {
            Title = "Unlock All Islands",
            Callback = function()
                local baseCFrame = character.HumanoidRootPart.CFrame
                for _, islands in pairs(workspace.Spawn:GetChildren()) do
                    character.HumanoidRootPart.Anchored = false
                    character:WaitForChild("HumanoidRootPart").CFrame = islands.CFrame
                    task.wait(1)
                end
                character.HumanoidRootPart.Anchored = false
                character.HumanoidRootPart.CFrame = baseCFrame
            end
        }
    )

    local Players = game:GetService("Players")
    local VirtualUser = game:GetService("VirtualUser")
    local player = Players.LocalPlayer
    local AntiAFKEnabled = false
    local AntiAFKLoop

    local Antiafk = playermisc:AddToggle("Antiafk", {Title = "Anti AFK", Default = false})
    Antiafk:OnChanged(
        function()
            AntiAFKEnabled = Options.Antiafk.Value
            if AntiAFKEnabled then
                AntiAFKLoop =
                    task.spawn(
                    function()
                        while AntiAFKEnabled do
                            VirtualUser:CaptureController()
                            VirtualUser:ClickButton2(Vector2.new())
                            task.wait(300)
                        end
                    end
                )
            else
                if AntiAFKLoop then
                    task.cancel(AntiAFKLoop)
                    AntiAFKLoop = nil
                end
            end
        end
    )

    player.Idled:Connect(
        function()
            if AntiAFKEnabled then
                VirtualUser:CaptureController()
                VirtualUser:ClickButton2(Vector2.new())
            end
        end
    )

    local secauto = Tabs.Autofarm:AddSection("Global")

    local autodelitem =
        secauto:AddDropdown(
        "Dropdown",
        {
            Title = "Auto remove item Rarity",
            Values = {
                "None",
                "Uncommon",
                "Rare",
                "Epic",
                "Legendary"
            },
            Multi = false,
            Default = 1
        }
    )

    autodelitem:OnChanged(
        function(Value)
            local rarityMap = {
                None = 1,
                Uncommon = 2,
                Rare = 3,
                Epic = 4,
                Legendary = 5
            }
            local selectedValue = rarityMap[Value]
            local args = {
                [1] = selectedValue
            }
            game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("RollChest"):WaitForChild(
                "SetAutoDelCmd"
            ):FireServer(unpack(args))
        end
    )

    local autochest = secauto:AddToggle("autochest", {Title = "Auto open Chest", Default = false})
    autochest:OnChanged(
        function()
            if autochest.Value then
                while autochest.Value do
                    task.wait()
                    local args = {
                        [1] = autochest.Value
                    }
                    game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("RollChest"):WaitForChild(
                        "SetAutoCmd"
                    ):FireServer(unpack(args))
                end
            else
                local args = {
                    [1] = autochest.Value
                }

                game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("RollChest"):WaitForChild(
                    "SetAutoCmd"
                ):FireServer(unpack(args))
            end
        end
    )

    local autosell =
        secauto:AddToggle(
        "autosell",
        {Title = "Auto Sell All", Description = "WARNING: this will delete youre locked items.", Default = false}
    )

    autosell:OnChanged(
        function()
            if autosell.Value then
                -- Start autoselling when toggled on
                while autosell.Value do
                    -- Generate the arguments for the server call
                    local args = {
                        [1] = {},
                        [3] = true -- Confirmation flag
                    }

                    -- Generate 6 pairs of random numbers to be sold
                    for i = 1, 1000 do
                        table.insert(
                            args[1],
                            {
                                [1] = math.random(0, 100), -- Random number between 1 and 100 for [1]
                                [2] = math.random(0, 100) -- Random number between 1 and 100 for [2]
                            }
                        )
                    end

                    -- Fire the Delete event with all the generated arguments at once
                    game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("Backpack"):WaitForChild(
                        "Delete"
                    ):FireServer(unpack(args))

                    -- Wait 1 second before repeating the process (selling all items again)
                    task.wait(5) -- Adjust the wait time as needed
                end
            end
        end
    )

    local autore = secauto:AddToggle("autorebirth", {Title = "Auto Rebirth", Default = false})
    autore:OnChanged(
        function()
            if autore.Value then
                while autore.Value do
                    task.wait(5) -- Reduced frequency to avoid lag
                    game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("Rebirth"):WaitForChild(
                        "TryRebirth"
                    ):FireServer()
                end
            end
        end
    )

    local Players = game:GetService("Players")
    local Workspace = game:GetService("Workspace")
    local RunService = game:GetService("RunService")
    local ReplicatedStorage = game:GetService("ReplicatedStorage")

    -- Advanced Dungeon Detection System
    local DungeonSystem = {
        -- State tracking
        inDungeon = false,
        dungeonStartTime = 0,
        completionTimestamp = 0,
        -- Transition detection variables
        transitionHistory = {},
        entityCountHistory = {},
        regionSnapshotHistory = {},
        regionPathSignatures = {},
        -- Configuration parameters
        detectionInterval = 1, -- Detection frequency (seconds)
        transitionCooldown = 3, -- Minimum time between transitions (seconds)
        completionConfirmDelay = 5, -- Time to confirm completion (seconds)
        maxHistoryLength = 10, -- Maximum history entries to keep
        safetyTimeout = 900, -- Maximum dungeon duration (seconds)
        -- Performance optimization
        lastCheckTime = 0,
        lastTransitionTime = 0,
        -- Debug flags
        enableLogging = true
    }

    -- Initialize the dungeon detection system
    function DungeonSystem:Initialize()
        self.regionPathSignatures = {}
        self.transitionHistory = {}
        self.entityCountHistory = {}
        self.regionSnapshotHistory = {}
        self.inDungeon = false
        self.lastCheckTime = 0
        self.lastTransitionTime = 0
        self.dungeonStartTime = 0
        self.completionTimestamp = 0
    end

    -- Log system activity if logging is enabled
    function DungeonSystem:Log(message, level)
        if self.enableLogging then
            local prefix = level and "[" .. level .. "] " or "[INFO] "
            print(prefix .. message)
        end
    end

    -- Comprehensive detection of dungeon presence using multiple strategies
    function DungeonSystem:IsDungeonActive()
        local regionFolder = Workspace:FindFirstChild("Region")
        if not regionFolder then
            return false
        end

        -- Strategy 1: Check existence of Dungeon objects in any region
        for _, region in ipairs(regionFolder:GetChildren()) do
            if region:FindFirstChild("Dungeon", true) then
                return true
            end
        end

        -- Strategy 2: Check for specific region names (Boss, Stage, Arena, etc.)
        for _, region in ipairs(regionFolder:GetChildren()) do
            local name = region.Name:lower()
            if name == "boss" or name:match("stage") or name:match("dungeon") or name:match("arena") then
                return true
            end
        end

        -- Strategy 3: Check for enemy presence
        local enemyFolder = Workspace:FindFirstChild("EnemyFolder")
        if enemyFolder and #enemyFolder:GetChildren() > 0 then
            -- Only consider it a dungeon if we've previously detected dungeon structures
            if #self.regionPathSignatures > 0 then
                return true
            end
        end

        return false
    end

    -- Create a comprehensive signature of the region structure for comparison
    function DungeonSystem:CaptureRegionSignature()
        local regionFolder = Workspace:FindFirstChild("Region")
        if not regionFolder then
            return {}
        end

        local signature = {}

        -- Generate path signatures for all regions
        local function buildPathSignature(instance, path)
            local currentPath = path and (path .. "/" .. instance.Name) or instance.Name

            -- Record this path
            table.insert(
                signature,
                {
                    path = currentPath,
                    className = instance.ClassName,
                    childCount = #instance:GetChildren(),
                    hasDungeon = instance:FindFirstChild("Dungeon") ~= nil,
                    isBoss = instance.Name:lower() == "boss"
                }
            )

            -- Process children recursively
            for _, child in ipairs(instance:GetChildren()) do
                buildPathSignature(child, currentPath)
            end
        end

        -- Start the recursive signature building
        for _, region in ipairs(regionFolder:GetChildren()) do
            buildPathSignature(region, "Region")
        end

        return signature
    end

    -- Compare two region signatures to detect structural changes
    function DungeonSystem:DetectStructuralChanges(oldSignature, newSignature)
        if #oldSignature == 0 or #newSignature == 0 then
            return true -- Always consider empty signature as change
        end

        -- Quick path length check
        if math.abs(#oldSignature - #newSignature) > 3 then
            return true -- Significant path count difference
        end

        -- Build dictionary of paths for efficient comparison
        local oldPaths = {}
        for _, entry in ipairs(oldSignature) do
            oldPaths[entry.path] = entry
        end

        -- Check for significant differences
        local changedPaths = 0
        local addedPaths = 0
        local removedPaths = 0

        for _, entry in ipairs(newSignature) do
            if oldPaths[entry.path] then
                -- Path exists in both, check for changes
                local oldEntry = oldPaths[entry.path]
                if
                    entry.hasDungeon ~= oldEntry.hasDungeon or entry.isBoss ~= oldEntry.isBoss or
                        math.abs(entry.childCount - oldEntry.childCount) > 2
                 then
                    changedPaths = changedPaths + 1
                end
                -- Mark as processed
                oldPaths[entry.path] = nil
            else
                -- Path in new but not in old
                addedPaths = addedPaths + 1
            end
        end

        -- Count paths in old that weren't in new
        for _ in pairs(oldPaths) do
            removedPaths = removedPaths + 1
        end

        -- Calculate change significance
        local totalChanges = changedPaths + addedPaths + removedPaths
        local changeRatio = totalChanges / math.max(#oldSignature, #newSignature)

        -- Significant structural change detection
        return changeRatio > 0.2 or totalChanges > 5
    end

    -- Find any boss instance in the workspace using multiple detection strategies
    function DungeonSystem:FindBossInstance()
        -- Strategy 1: Direct boss name search in Region folder
        local regionFolder = Workspace:FindFirstChild("Region")
        if regionFolder then
            for _, region in ipairs(regionFolder:GetChildren()) do
                if region.Name:lower() == "boss" then
                    return region, "Region/Boss"
                end

                -- Search children with "Boss" name
                local bossChild = region:FindFirstChild("Boss")
                if bossChild then
                    return bossChild, "Region/" .. region.Name .. "/Boss"
                end
            end
        end

        -- Strategy 2: Enemy folder search for boss
        local enemyFolder = Workspace:FindFirstChild("EnemyFolder")
        if enemyFolder then
            for _, enemy in ipairs(enemyFolder:GetChildren()) do
                if enemy.Name:lower():match("boss") then
                    return enemy, "EnemyFolder/Boss"
                end
            end
        end

        -- Strategy 3: Deep search for any boss-like object
        local function deepSearch(parent, path)
            for _, child in ipairs(parent:GetChildren()) do
                local childPath = path .. "/" .. child.Name
                if child.Name:lower():match("boss") then
                    return child, childPath
                end

                local foundBoss, bossPath = deepSearch(child, childPath)
                if foundBoss then
                    return foundBoss, bossPath
                end
            end
            return nil, nil
        end

        if regionFolder then
            local boss, path = deepSearch(regionFolder, "Region")
            if boss then
                return boss, path
            end
        end

        return nil, nil
    end

    -- Get the current count of active dungeon entities
    function DungeonSystem:GetEntityCount()
        local enemyFolder = Workspace:FindFirstChild("EnemyFolder")
        if not enemyFolder then
            return 0
        end

        local count = 0
        for _, enemy in ipairs(enemyFolder:GetChildren()) do
            local humanoid = enemy:FindFirstChildOfClass("Humanoid")
            if humanoid and humanoid.Health > 0 then
                count = count + 1
            end
        end

        return count
    end

    -- Update system state based on current game state
    function DungeonSystem:Update()
        local currentTime = tick()

        -- Rate-limit checks for performance
        if currentTime - self.lastCheckTime < self.detectionInterval then
            return false, "Cooling down"
        end
        self.lastCheckTime = currentTime

        -- Step 1: Detect current dungeon state
        local dungeonActive = self:IsDungeonActive()

        -- Step 2: Capture detailed snapshots
        local currentSignature = self:CaptureRegionSignature()
        local entityCount = self:GetEntityCount()
        local boss, bossPath = self:FindBossInstance()

        -- Step 3: Update history (limited length to prevent memory bloat)
        table.insert(self.regionSnapshotHistory, currentSignature)
        table.insert(self.entityCountHistory, entityCount)

        if #self.regionSnapshotHistory > self.maxHistoryLength then
            table.remove(self.regionSnapshotHistory, 1)
            table.remove(self.entityCountHistory, 1)
        end

        -- Step 4: Process dungeon entry/exit transitions
        if dungeonActive and not self.inDungeon then
            -- Entering dungeon
            self.inDungeon = true
            self.dungeonStartTime = currentTime
            self.lastTransitionTime = currentTime
            self.completionTimestamp = 0
            self:Log("⚔️ Dungeon engagement detected", "STATE")
            return true, "DungeonStart"
        elseif not dungeonActive and self.inDungeon then
            -- Exiting dungeon (immediate completion)
            self.inDungeon = false
            self:Log("🏆 Dungeon exit detected - possibly completed", "STATE")
            return true, "DungeonExit"
        end

        -- If not in dungeon, no further processing needed
        if not self.inDungeon then
            return false, "NotInDungeon"
        end

        -- Step 5: Detect structural changes indicating stage transitions
        local structuralChangeDetected = false
        if #self.regionSnapshotHistory >= 2 then
            local previousSignature = self.regionSnapshotHistory[#self.regionSnapshotHistory - 1]
            structuralChangeDetected = self:DetectStructuralChanges(previousSignature, currentSignature)

            if structuralChangeDetected and currentTime - self.lastTransitionTime > self.transitionCooldown then
                self.lastTransitionTime = currentTime
                table.insert(
                    self.transitionHistory,
                    {
                        time = currentTime,
                        entityCount = entityCount,
                        hasBoss = boss ~= nil
                    }
                )

                if #self.transitionHistory > self.maxHistoryLength then
                    table.remove(self.transitionHistory, 1)
                end

                self:Log("📊 Stage transition detected - dungeon progressing", "TRANSITION")
                if boss then
                    self:Log("👑 Boss detected at: " .. bossPath, "BOSS")
                end
                return true, "StageTransition"
            end
        end

        -- Step 6: Process potential dungeon completion
        local dungeonCompleted = false
        local completionReason = "Unknown"

        -- Method 1: No enemies for sustained period
        if entityCount == 0 and #self.entityCountHistory >= 3 then
            local allEmpty = true
            for i = #self.entityCountHistory - 2, #self.entityCountHistory do
                if self.entityCountHistory[i] > 0 then
                    allEmpty = false
                    break
                end
            end

            if allEmpty then
                if self.completionTimestamp == 0 then
                    self.completionTimestamp = currentTime
                elseif currentTime - self.completionTimestamp >= self.completionConfirmDelay then
                    dungeonCompleted = true
                    completionReason = "NoEnemies"
                end
            else
                self.completionTimestamp = 0
            end
        else
            self.completionTimestamp = 0
        end

        -- Method 2: Boss defeated
        if boss and boss:IsA("Model") then
            local bossHumanoid = boss:FindFirstChildOfClass("Humanoid")
            if bossHumanoid and bossHumanoid.Health <= 0 then
                dungeonCompleted = true
                completionReason = "BossDefeated"
            end
        end

        -- Method 3: Region structure indicates completion
        if #self.regionPathSignatures > 0 and #currentSignature == 0 then
            -- All dungeon structures disappeared
            dungeonCompleted = true
            completionReason = "StructureRemoved"
        end

        -- Method 4: Safety timeout
        if currentTime - self.dungeonStartTime > self.safetyTimeout then
            dungeonCompleted = true
            completionReason = "Timeout"
        end

        -- Process dungeon completion
        if dungeonCompleted then
            self.inDungeon = false
            self:Log("🏆 Dungeon completion detected - Reason: " .. completionReason, "COMPLETION")
            return true, "DungeonComplete"
        end

        return false, "NoChange"
    end

    -- Reset all dungeon state after completion
    function DungeonSystem:ResetState()
        self:Log("🔄 Resetting dungeon state", "SYSTEM")
        self.inDungeon = false
        self.completionTimestamp = 0
        -- Keep history for potential debugging, but mark state as reset
        return true
    end

    -- Check if we're in a boss area
    function DungeonSystem:IsInBossArea()
        local boss, _ = self:FindBossInstance()
        return boss ~= nil
    end

    -- Section 1: UI Component Initialization
    local secauto1 = Tabs.Autofarm:AddSection("Dungeon")

    local slidauto =
        secauto1:AddSlider(
        "slidauto",
        {
            Title = "Enemy Distance",
            Default = 5,
            Min = 1,
            Max = 15,
            Rounding = 1
        }
    )

    --     local combinedAutofarm = secauto1:AddToggle("combinedAutofarm", {
    --         Title = "Smart Dungeon Autofarm",
    --         Default = false
    --     })

    --     -- Section 2: State Management Variables
    --     local autofarmEnabled = false
    --     local heartbeatConnection = nil
    --     local targetEnemy = nil
    --     local cooldownTime = 0.15
    --     local lastLevelCheckTime = 0
    --     local levelCheckInterval = 30 -- Check for level-appropriate NPCs every 30 seconds

    --     -- Section 3: Data Structures - Island power thresholds and locations
    --     -- Section 3: Data Structures - Island power thresholds and locations
    -- local ISLANDS = {
    --     {
    --         name = "Island 1",
    --         minPower = 0,          -- Minimum power requirement for Island 1
    --         maxPower = 75_000,       -- Maximum effective power for Island 1
    --         location = CFrame.new(-1.00680757, 102.04232, -288.245911),
    --         npcBaseId = 101002,
    --         npcCount = 5
    --     },
    --     {
    --         name = "Island 2",
    --         minPower = 116_000,      -- Minimum power requirement for Island 2
    --         maxPower = 6_000_000,    -- Maximum effective power for Island 2
    --         location = CFrame.new(-834.775085, 54.813942, 1361.6803),
    --         npcBaseId = 101007,
    --         npcCount = 5
    --     },
    --     {
    --         name = "Island 3",
    --         minPower = 6_000_000,    -- Minimum power requirement for Island 3
    --         maxPower = 45_000_000,   -- Maximum effective power for Island 3
    --         location = CFrame.new(1828.25293, -119.801704, 2863.44824),
    --         npcBaseId = 101012,
    --         npcCount = 5
    --     },
    --     {
    --         name = "Island 4 (Part 1)",
    --         minPower = 65_000_000,   -- Minimum power requirement for Island 4 Part 1
    --         maxPower = 225_000_000,  -- Maximum effective power for Island 4 Part 1
    --         location = CFrame.new(3779.57349, 51.8931541, 1179.47632),
    --         npcBaseId = 101017,
    --         npcCount = 5
    --     },
    --     {
    --         name = "Island 4 (Part 2)",
    --         minPower = 345_000_000,  -- Minimum power requirement for Island 4 Part 2
    --         maxPower = math.huge,    -- No upper limit
    --         location = CFrame.new(3943.59766, 59.3501854, 1114.27197),
    --         npcBaseId = 101022,
    --         npcCount = 5
    --     }
    -- }

    --     -- Section 4: Utility Functions
    --     -- Function to parse the power text like "193k" into a number
    --     local function parsePower(powerText)
    --         if not powerText or type(powerText) ~= "string" then
    --             warn("Power text is nil or invalid: ", tostring(powerText))
    --             return 0
    --         end

    --         local num, suffix = powerText:match("([%d%.]+)([kKmMbB]?)")
    --         if not num then
    --             num, suffix = powerText:match("Power%s*([%d%.]+)([kKmMbB]?)")
    --         end

    --         num = tonumber(num)
    --         if not num then
    --             warn("Could not convert to number: " .. powerText)
    --             return 0
    --         end

    --         if suffix == "k" or suffix == "K" then
    --             return num * 1_000
    --         elseif suffix == "m" or suffix == "M" then
    --             return num * 1_000_000
    --         elseif suffix == "b" or suffix == "B" then
    --             return num * 1_000_000_000
    --         end
    --         return num
    --     end

    --     -- Function to safely get a UI element with proper error handling
    --     local function safeGetUIElement(parent, path)
    --         if not parent then return nil end

    --         local current = parent
    --         for _, name in ipairs(path) do
    --             if not current then return nil end
    --             current = current:FindFirstChild(name)
    --         end

    --         return current
    --     end

    --     -- Function to get the player's power using the exact path specified
    --     local function getPlayerPower()
    --         local player = Players.LocalPlayer
    --         local powerLabel = safeGetUIElement(player, {"PlayerGui", "Main", "HomePage", "Property", "PowerFrame", "Power", "Power"})

    --         if not powerLabel or not powerLabel:IsA("TextLabel") then
    --             warn("Power label not found or not a TextLabel")
    --             return 0
    --         end

    --         return parsePower(powerLabel.Text)
    --     end

    --     local function getIslandForPower(playerPower)
    --         -- Find the highest island where player meets the minimum power requirement
    --         for i, island in ipairs(ISLANDS) do
    --             if playerPower >= island.minPower then
    --                 if i < #ISLANDS and playerPower >= ISLANDS[i+1].minPower then
    --                     -- Continue to next island if player meets next island's requirement
    --                     continue
    --                 end
    --                 return island, i
    --             end
    --         end

    --         -- If player doesn't meet any island's requirements, return the first island
    --         return ISLANDS[1], 1
    --     end

    --     -- Section 6: Combat and Targeting Functions
    --     -- Function to safely acquire the tool (even if it changes)
    --     local function getWeapon(character)
    --         local tool = character:FindFirstChild("Weapon")
    --         if not tool then
    --             -- Wait for a child to be added; this may be a new tool
    --             tool = character.ChildAdded:Wait()
    --             -- Optionally check if the new child is the correct tool
    --         end
    --         return tool
    --     end

    --     -- Function to find the nearest enemy in EnemyFolder
    --     local function findNearestEnemy(humanoidRootPart)
    --         local closest, dist = nil, math.huge
    --         local enemyFolder = Workspace:FindFirstChild("EnemyFolder")
    --         if enemyFolder then
    --             for _, enemy in pairs(enemyFolder:GetChildren()) do
    --                 local enemyHumanoid = enemy:FindFirstChildOfClass("Humanoid")
    --                 local enemyRoot = enemy:FindFirstChild("HumanoidRootPart")
    --                 if enemyHumanoid and enemyRoot and enemyHumanoid.Health > 0 then
    --                     local mag = (humanoidRootPart.Position - enemyRoot.Position).Magnitude
    --                     if mag < dist then
    --                         closest, dist = enemy, mag
    --                     end
    --                 end
    --             end
    --         end
    --         return closest
    --     end

    --     -- Section 7: NPC Selection and Dungeon Initialization
    --     -- Function to find the best NPC and fire the event
    --     local function findBestNpcAndFireEvent()
    --         -- Don't execute if we're already in a dungeon
    --         if DungeonSystem.inDungeon then
    --             DungeonSystem:Log("⚔️ Already in dungeon - skipping NPC selection", "ACTION")
    --             return false
    --         end

    --         local player = Players.LocalPlayer
    --         -- Verify character exists
    --         if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then
    --             warn("Character or HumanoidRootPart not found. Waiting...")
    --             player.CharacterAdded:Wait()
    --             wait(1) -- Give time for character to fully load
    --             return false
    --         end

    --         local playerPower = getPlayerPower()
    --         if playerPower <= 0 then
    --             warn("Invalid player power detected. Please make sure your UI has loaded properly.")
    --             return false
    --         end

    --         DungeonSystem:Log("📊 Your current power: " .. tostring(playerPower), "POWER")

    --         -- Determine the appropriate island for the player's power
    --         local island, islandIndex = getIslandForPower(playerPower)
    --         DungeonSystem:Log(string.format("🌴 Selected %s for power level: %s", island.name, tostring(playerPower)), "ISLAND")

    --         -- Teleport to the island
    --         if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
    --             player.Character:SetPrimaryPartCFrame(island.location)
    --             DungeonSystem:Log("✈️ Teleported to " .. island.name, "MOVEMENT")
    --         else
    --             warn("Cannot teleport: Character or HumanoidRootPart not available")
    --             return false
    --         end

    --         -- Wait for NPCs to load after teleport
    --         wait(1.5)

    --         -- Scan and analyze NPCs on this island
    --         local visibleNpcs = {}
    --         local npcsFolder = Workspace:WaitForChild("NPCs")

    --         -- Loop through all NPCs in the workspace
    --         for _, npc in pairs(npcsFolder:GetChildren()) do
    --             if npc:IsA("Model") then
    --                 -- Try to find the power level text
    --                 local levelNeed = npc:FindFirstChild("LevelNeed", true)
    --                 if not levelNeed and npc:FindFirstChild("Talk") then
    --                     local talkPart = npc:FindFirstChild("Talk")
    --                     local gui = talkPart and talkPart:FindFirstChild("BillboardGui")
    --                     if gui then
    --                         local frame = gui:FindFirstChild("Frame")
    --                         if frame then
    --                             levelNeed = frame:FindFirstChild("LevelNeed")
    --                         end
    --                     end
    --                 end

    --                 -- If we found a valid power indicator
    --                 if levelNeed and (levelNeed:IsA("TextLabel") or levelNeed:IsA("TextButton")) and levelNeed.Text then
    --                     local power = parsePower(levelNeed.Text)
    --                     if power > 0 then
    --                         table.insert(visibleNpcs, {
    --                             model = npc,
    --                             name = npc.Name,
    --                             power = power
    --                         })
    --                     end
    --                 end
    --             end
    --         end

    --         -- Sort NPCs by power (ascending)
    --         table.sort(visibleNpcs, function(a, b)
    --             return a.power < b.power
    --         end)

    --         if #visibleNpcs == 0 then
    --             DungeonSystem:Log("⚠️ No NPCs found in the current area. Please wait or try again.", "WARNING")
    --             return false
    --         end

    --         -- Map NPC IDs based on power ranking
    --         local mappedNpcs = {}
    --         local npcBaseId = island.npcBaseId

    --         -- If we found fewer NPCs than expected
    --         local npcCount = math.min(#visibleNpcs, island.npcCount)

    --         -- Create mapping from lowest to highest power
    --         for i = 1, npcCount do
    --             local npcInfo = visibleNpcs[i]
    --             local npcId = npcBaseId + (i-1)  -- Calculate ID based on position (101002, 101003, etc.)

    --             table.insert(mappedNpcs, {
    --                 model = npcInfo.model,
    --                 name = npcInfo.name,
    --                 power = npcInfo.power,
    --                 id = npcId
    --             })

    --             DungeonSystem:Log(string.format("📊 Mapped NPC: %s (Power: %s, ID: %d)",
    --                 npcInfo.name, tostring(npcInfo.power), npcId), "NPC")
    --         end

    --         -- Find the strongest NPC the player can defeat based on power
    --         local bestNpc = nil
    --         for i = #mappedNpcs, 1, -1 do
    --             if mappedNpcs[i].power <= playerPower then
    --                 bestNpc = mappedNpcs[i]
    --                 break
    --             end
    --         end

    --         if bestNpc then
    --             DungeonSystem:Log(string.format("✅ Selected NPC: %s (Power: %s, ID: %d)",
    --                 bestNpc.name, tostring(bestNpc.power), bestNpc.id), "NPC")

    --             -- Teleport to the NPC's HumanoidRootPart immediately after
    --             local npcHumanoidRootPart = bestNpc.model:FindFirstChild("HumanoidRootPart")
    --             if npcHumanoidRootPart then
    --                 player.Character:SetPrimaryPartCFrame(npcHumanoidRootPart.CFrame)
    --                 DungeonSystem:Log("✈️ Teleported to NPC: " .. bestNpc.name, "MOVEMENT")
    --             else
    --                 warn("HumanoidRootPart not found for NPC: " .. bestNpc.name)
    --                 return false
    --             end

    --             -- Wait before firing the event
    --             wait(1)  -- Adjust this time as needed

    --             -- Fire the event once with the best NPC ID
    --             local remoteEvent = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Region"):WaitForChild("EnterRegion")
    --             local args = {
    --                 [1] = bestNpc.id
    --             }
    --             remoteEvent:FireServer(unpack(args))
    --             DungeonSystem:Log(string.format("🔥 Fired remote event with NPC ID: %d", bestNpc.id), "REMOTE")
    --             return true
    --         else
    --             DungeonSystem:Log("⛔ No suitable NPC found for your power level (" .. tostring(playerPower) .. ").", "WARNING")
    --             if #mappedNpcs > 0 then
    --                 DungeonSystem:Log("The lowest power NPC available requires: " .. tostring(mappedNpcs[1].power) .. " power.", "INFO")
    --             end
    --             return false
    --         end
    --     end

    --     -- Section 8: Character and Autofarm Management
    --     -- Function to initialize and start the autofarm logic for a given character
    --     local function startAutofarmForCharacter(character)
    --         local HumanoidRootPart = character:WaitForChild("HumanoidRootPart")
    --         local weapon = getWeapon(character)
    --         local attackCooldown = false

    --         -- Disconnect any previous heartbeat connection before starting a new one
    --         if heartbeatConnection then
    --             heartbeatConnection:Disconnect()
    --             heartbeatConnection = nil
    --         end

    --         -- Initialize the DungeonSystem
    --         DungeonSystem:Initialize()

    --         heartbeatConnection = RunService.Heartbeat:Connect(function()
    --             if not autofarmEnabled then
    --                 return
    --             end

    --             -- Let the DungeonSystem handle state detection
    --             local stateChanged, stateType = DungeonSystem:Update()

    --             -- Process state changes
    --             if stateChanged then
    --                 if stateType == "DungeonStart" then
    --                     -- Reset targeting
    --                     targetEnemy = nil
    --                     -- Prevent redundant NPC selection during dungeon
    --                     lastLevelCheckTime = tick() + levelCheckInterval

    --                 elseif stateType == "DungeonComplete" or stateType == "DungeonExit" then
    --                     -- Handle completion
    --                     DungeonSystem:ResetState()
    --                     targetEnemy = nil

    --                     -- Trigger new NPC finding after a cooldown
    --                     task.delay(5, function()
    --                         if autofarmEnabled then
    --                             lastLevelCheckTime = 0  -- Force immediate NPC check
    --                         end
    --                     end)

    --                 elseif stateType == "StageTransition" then
    --                     -- Optional: You can implement specific behavior for stage transitions
    --                     -- For example, re-target enemies or prepare for boss
    --                     if DungeonSystem:IsInBossArea() then
    --                         DungeonSystem:Log("🎯 Boss detected - adjusting combat strategy", "COMBAT")
    --                         -- Reset targeting to find the boss
    --                         targetEnemy = nil
    --                     end
    --                 end
    --             end

    --             -- NPC finding logic - only if not in dungeon
    --             local currentTime = tick()
    --             if currentTime - lastLevelCheckTime >= levelCheckInterval and not DungeonSystem.inDungeon then
    --                 lastLevelCheckTime = currentTime

    --                 task.spawn(function()
    --                     findBestNpcAndFireEvent()
    --                 end)
    --             end

    --             -- Reacquire the tool if it is missing or not parented to the character anymore
    --             if not weapon or not weapon:IsDescendantOf(character) then
    --                 weapon = getWeapon(character)
    --             end

    --             -- Find the nearest valid enemy if none exists or the current one is dead
    --             if not targetEnemy or not targetEnemy:FindFirstChild("Humanoid") or targetEnemy.Humanoid.Health <= 0 then
    --                 targetEnemy = findNearestEnemy(HumanoidRootPart)
    --             end

    --             if targetEnemy then
    --                 local enemyRoot = targetEnemy:FindFirstChild("HumanoidRootPart")
    --                 if enemyRoot then
    --                     local followDistance = slidauto.Value
    --                     -- Calculate a position behind the enemy based on its LookVector and desired distance
    --                     local behindPosition = enemyRoot.Position - enemyRoot.CFrame.LookVector * followDistance
    --                     local finalPos = Vector3.new(behindPosition.X, enemyRoot.Position.Y, behindPosition.Z)

    --                     -- Teleport the character's HumanoidRootPart behind the enemy and face it
    --                     HumanoidRootPart.CFrame = CFrame.new(finalPos, enemyRoot.Position)

    --                     -- If not in cooldown, activate the weapon
    --                     if not attackCooldown then
    --                         if weapon and weapon.Activate then
    --                             weapon:Activate()
    --                         end
    --                         attackCooldown = true
    --                         task.delay(cooldownTime, function()
    --                             attackCooldown = false
    --                         end)
    --                     end
    --                 end
    --             end
    --         end)

    --         -- Listen for character death so that the connection is cleaned up
    --         local humanoid = character:WaitForChild("Humanoid")
    --         humanoid.Died:Connect(function()
    --             if heartbeatConnection then
    --                 heartbeatConnection:Disconnect()
    --                 heartbeatConnection = nil
    --             end
    --             targetEnemy = nil
    --         end)
    --     end

    --     -- Section 9: Event Handlers and Initialization
    --     -- Handle toggle state changes for autofarming
    --     combinedAutofarm:OnChanged(function(enabled)
    --         autofarmEnabled = enabled

    --         if not autofarmEnabled then
    --             if heartbeatConnection then
    --                 heartbeatConnection:Disconnect()
    --                 heartbeatConnection = nil
    --             end
    --             -- Reset all state
    --             DungeonSystem:Initialize()
    --             targetEnemy = nil
    --             return
    --         end

    --         -- Initialize state variables for immediate execution
    --         lastLevelCheckTime = 0

    --         -- If enabled, initialize for the current character
    --         local character = Players.LocalPlayer.Character
    --         if character then
    --             startAutofarmForCharacter(character)
    --         end
    --     end)

    --     -- Listen for the LocalPlayer's character to be loaded/reloaded (e.g. after death)
    --     Players.LocalPlayer.CharacterAdded:Connect(function(character)
    --         if autofarmEnabled then
    --             startAutofarmForCharacter(character)
    --         end
    --     end)

    -- Use an array with numerical indices to maintain order
    local Dungeons = {
        {
            name = "Ancient Gladiator",
            difficulty = "Starter",
            npcBaseId = 101002,
            island = 1,
            isBoss = false
        },
        {
            name = "Holy Sect Exile",
            difficulty = "Medium",
            npcBaseId = 101003,
            island = 1,
            isBoss = false
        },
        {
            name = "Sacrificial Piece",
            difficulty = "Hard",
            npcBaseId = 101004,
            island = 1,
            isBoss = false
        },
        {
            name = "Mechanical Minion",
            difficulty = "Extreme",
            npcBaseId = 101005,
            island = 1,
            isBoss = false
        },
        {
            name = "Blade",
            difficulty = "",
            npcBaseId = 101006,
            island = 1,
            isBoss = true
        },
        {
            name = "Jungle Hunter",
            difficulty = "Starter",
            npcBaseId = 101007,
            island = 2,
            isBoss = false
        },
        {
            name = "Dual Edge Specter",
            difficulty = "Medium",
            npcBaseId = 101008,
            island = 2,
            isBoss = false
        },
        {
            name = "Rock Golem Sentinel",
            difficulty = "Hard",
            npcBaseId = 101009,
            island = 2,
            isBoss = false
        },
        {
            name = "Marooned Cavalier",
            difficulty = "Extreme",
            npcBaseId = 101010,
            island = 2,
            isBoss = false
        },
        {
            name = "Woodland Sovereign",
            difficulty = "",
            npcBaseId = 101011,
            island = 2,
            isBoss = true
        },
        {
            name = "Deep Sea Undead",
            difficulty = "Starter",
            npcBaseId = 101012,
            island = 3,
            isBoss = false
        },
        {
            name = "Guardian Priest",
            difficulty = "Medium",
            npcBaseId = 101013,
            island = 3,
            isBoss = false
        },
        {
            name = "Advanced Mecha MKII",
            difficulty = "Hard",
            npcBaseId = 101014,
            island = 3,
            isBoss = false
        },
        {
            name = "Abyssal High Priest",
            difficulty = "Extreme",
            npcBaseId = 101015,
            island = 3,
            isBoss = false
        },
        {
            name = "Prototype Zero",
            difficulty = "",
            npcBaseId = 101016,
            island = 3,
            isBoss = true
        },
        {
            name = "Infector",
            difficulty = "Starter",
            npcBaseId = 101017,
            island = 4,
            isBoss = false
        },
        {
            name = "Chaotic pathogen",
            difficulty = "Medium",
            npcBaseId = 101018,
            island = 4,
            isBoss = false
        },
        {
            name = "Cornelius",
            difficulty = "Hard",
            npcBaseId = 101019,
            island = 4,
            isBoss = false
        },
        {
            name = "Calamity",
            difficulty = "Extreme",
            npcBaseId = 101020,
            island = 4,
            isBoss = false
        },
        {
            name = "The Flame King",
            difficulty = "",
            npcBaseId = 101021,
            island = 4,
            isBoss = true
        },
        {
            name = "Templis Vigil",
            difficulty = "Starter",
            npcBaseId = 101022,
            island = 5,
            isBoss = false
        },
        {
            name = "Seraphic Ward",
            difficulty = "Medium",
            npcBaseId = 101023,
            island = 5,
            isBoss = false
        },
        {
            name = "Star Confessor",
            difficulty = "Hard",
            npcBaseId = 101024,
            island = 5,
            isBoss = false
        },
        {
            name = "Zenith Templar",
            difficulty = "Extreme",
            npcBaseId = 101025,
            island = 5,
            isBoss = false
        },
        {
            name = "Odyus Storm",
            difficulty = "",
            npcBaseId = 101026,
            island = 5, -- Fixed: was island 4, should be 5 based on position
            isBoss = true
        }
    }

    -- Create dropdown values in order with island and boss info
    local dropdownValues = {}
    for i, dungeon in ipairs(Dungeons) do
        local displayName = dungeon.name .. ", Island " .. dungeon.island .. ", Difficulty: " .. dungeon.difficulty
        if dungeon.isBoss then
            displayName = displayName .. " (Boss)"
        end
        table.insert(dropdownValues, displayName)
    end

    local Farmdrop =
        secauto1:AddDropdown(
        "Farmdrop",
        {
            Title = "Select Dungeon",
            Values = dropdownValues,
            Multi = false,
            Default = nil
        }
    )

    local startdungeon =
        secauto1:AddToggle("startdungeon", {Title = "Start Dungeon", Description = "Cooldown: 10s", Default = false})

    -- Variable to store the selected dungeon index
    local selectedDungeonIndex = nil

    -- Handle dropdown selection
    Farmdrop:OnChanged(
        function(value)
            -- Find the index of the selected dungeon
            for i, displayName in ipairs(dropdownValues) do
                if displayName == value then
                    selectedDungeonIndex = i
                    break
                end
            end
        end
    )

    -- Handle toggle to start dungeon
    startdungeon:OnChanged(
        function()
            if startdungeon.Value then
                while startdungeon.Value do
                    if selectedDungeonIndex and Dungeons[selectedDungeonIndex] then
                        local selectedDungeon = Dungeons[selectedDungeonIndex]
                        local args = {
                            selectedDungeon.npcBaseId
                        }
                        game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("Region"):WaitForChild(
                            "EnterRegion"
                        ):FireServer(unpack(args))
                    else
                        Fluent:Notify("No dungeon selected!", "Please Select a dungeon")
                    end
                    task.wait(10)
                end
            end
        end
    )

    local autodungeon = secauto1:AddToggle("autodungeon", {Title = "Autofarm Enemy", Default = false})

    local autoDungeonEnabled = false
    local heartbeatConnection = nil
    local characterAddedConnection = nil
    local targetEnemy = nil
    local cooldownTime = 0.15
    local attackCooldown = false

    -- Function to safely acquire the tool
    local function getWeapon(character)
        if not character or not character.Parent then
            return nil
        end

        -- First try to find existing weapon
        local tool = character:FindFirstChild("Weapon")
        if tool and tool.Parent == character then
            return tool
        end

        -- Check backpack as well
        local player = Players.LocalPlayer
        if player and player.Backpack then
            tool = player.Backpack:FindFirstChild("Weapon")
            if tool then
                -- Equip the tool
                local humanoid = character:FindFirstChildOfClass("Humanoid")
                if humanoid then
                    humanoid:EquipTool(tool)
                    return tool
                end
            end
        end

        -- Check for any tool in character
        for _, child in pairs(character:GetChildren()) do
            if child:IsA("Tool") then
                return child
            end
        end

        return nil
    end

    -- Function to validate enemy
    local function isValidEnemy(enemy)
        if not enemy or not enemy.Parent then
            return false
        end

        local humanoid = enemy:FindFirstChildOfClass("Humanoid")
        local enemyRoot = enemy:FindFirstChild("HumanoidRootPart")

        return humanoid and enemyRoot and humanoid.Health > 0
    end

    -- Function to find nearest enemy
    local function findNearestEnemy(character)
        if not character or not character:FindFirstChild("HumanoidRootPart") then
            return nil
        end

        local HumanoidRootPart = character.HumanoidRootPart
        local closest, dist = nil, math.huge
        local enemyFolder = workspace:FindFirstChild("EnemyFolder")

        if enemyFolder then
            for _, enemy in pairs(enemyFolder:GetChildren()) do
                if isValidEnemy(enemy) then
                    local enemyRoot = enemy.HumanoidRootPart
                    local mag = (HumanoidRootPart.Position - enemyRoot.Position).Magnitude
                    if mag < dist then
                        closest, dist = enemy, mag
                    end
                end
            end
        end

        return closest
    end

    -- Main autofarm function
    local function startAutofarm()
        -- Clean up previous connection
        if heartbeatConnection then
            heartbeatConnection:Disconnect()
            heartbeatConnection = nil
        end

        -- Create new heartbeat connection for constant positioning
        heartbeatConnection =
            RunService.Heartbeat:Connect(
            function()
                if not autoDungeonEnabled then
                    return
                end

                local success =
                    pcall(
                    function()
                        local player = Players.LocalPlayer
                        local character = player.Character

                        -- Validate character
                        if not character or not character.Parent or not character:FindFirstChild("HumanoidRootPart") then
                            return
                        end

                        local humanoid = character:FindFirstChildOfClass("Humanoid")
                        if not humanoid or humanoid.Health <= 0 then
                            return
                        end

                        local HumanoidRootPart = character.HumanoidRootPart
                        local weapon = getWeapon(character)

                        -- Validate or find new target
                        if not isValidEnemy(targetEnemy) then
                            targetEnemy = findNearestEnemy(character)
                        end

                        if targetEnemy and isValidEnemy(targetEnemy) then
                            local enemyRoot = targetEnemy.HumanoidRootPart
                            local followDistance = slidauto.Value or 10

                            -- Calculate position behind enemy
                            local behindPosition = enemyRoot.Position - enemyRoot.CFrame.LookVector * followDistance
                            local finalPos = Vector3.new(behindPosition.X, enemyRoot.Position.Y, behindPosition.Z)

                            -- Constantly teleport behind enemy
                            HumanoidRootPart.CFrame = CFrame.new(finalPos, enemyRoot.Position)

                            -- Attack if weapon available and not in cooldown
                            if weapon and weapon:FindFirstChild("Handle") and not attackCooldown then
                                weapon:Activate()
                                attackCooldown = true
                                task.spawn(
                                    function()
                                        task.wait(cooldownTime)
                                        attackCooldown = false
                                    end
                                )
                            end
                        else
                            -- No valid target, reset
                            targetEnemy = nil
                        end
                    end
                )

                if not success then
                -- Error occurred, continue anyway
                end
            end
        )
    end

    -- Handle toggle state changes
    autodungeon:OnChanged(
        function(enabled)
            autoDungeonEnabled = enabled

            if autoDungeonEnabled then
                startAutofarm()
            else
                -- Clean up when disabled
                if heartbeatConnection then
                    heartbeatConnection:Disconnect()
                    heartbeatConnection = nil
                end
                targetEnemy = nil
                attackCooldown = false
            end
        end
    )

    -- Handle character respawn
    if characterAddedConnection then
        characterAddedConnection:Disconnect()
    end

    characterAddedConnection =
        Players.LocalPlayer.CharacterAdded:Connect(
        function(character)
            if autoDungeonEnabled then
                -- Wait a bit for character to fully load
                task.wait(1)
                startAutofarm()
            end
        end
    )

    -- Start immediately if already enabled and character exists
    if autoDungeonEnabled and Players.LocalPlayer.Character then
        startAutofarm()
    end

    -- Clean up when script stops
    local function cleanup()
        autoDungeonEnabled = false
        targetEnemy = nil
        attackCooldown = false

        if heartbeatConnection then
            heartbeatConnection:Disconnect()
            heartbeatConnection = nil
        end

        if characterAddedConnection then
            characterAddedConnection:Disconnect()
            characterAddedConnection = nil
        end
    end

    -- Set up cleanup on script termination
    if getgenv then
        getgenv().AutofarmCleanup = cleanup
    end

    local services = {
        tween = game:GetService("TweenService"),
        rs = game:GetService("ReplicatedStorage"),
        players = game:GetService("Players"),
        runService = game:GetService("RunService")
    }

    -- Create a more discreet toggle
    local autocollectitems =
        secauto:AddToggle(
        "item_collection",
        {
            Title = "Autofarm Resources",
            Default = false
        }
    )

    local autocollectitemsns = autocollectitems -- Define the variable properly to reference the toggle state

    -- Configuration variables
    local config = {
        notificationSent = false,
        enabled = false,
        teleportDuration = math.random(80, 120) / 100, -- Random duration between 0.8-1.2s
        itemProcessDelay = math.random(40, 60) / 100, -- Random delay between 0.4-0.6s
        scanInterval = math.random(180, 220) / 100, -- Random interval between 1.8-2.2s
        maxCollectionDistance = 500, -- Maximum distance to travel for an item
        autoRespawnEnabled = true -- Always enable respawn teleportation
    }

    -- Create closure for the item finder to avoid exposing functionality
    local itemManager =
        (function()
        local function isValidTarget(instance)
            return (instance:IsA("BasePart") or
                (instance:IsA("Model") and (instance.PrimaryPart or #instance:GetChildren() > 0)))
        end

        local function getTargetPosition(target)
            if target:IsA("Model") then
                if target.PrimaryPart then
                    return target.PrimaryPart.Position
                else
                    for _, child in pairs(target:GetChildren()) do
                        if child:IsA("BasePart") then
                            return child.Position
                        end
                    end
                    return target:GetModelCFrame().Position
                end
            else
                return target.Position
            end
        end

        return {
            findItems = function()
                local collectables = {}
                local playerPosition =
                    services.players.LocalPlayer.Character and
                    services.players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and
                    services.players.LocalPlayer.Character.HumanoidRootPart.Position

                if not playerPosition then
                    return {}
                end

                for _, folder in ipairs(workspace:GetChildren()) do
                    if folder.Name == "Folder" then
                        for _, item in ipairs(folder:GetChildren()) do
                            if item:IsA("BasePart") or item:IsA("Model") then
                                local itemPosition
                                if item:IsA("Model") then
                                    if item.PrimaryPart then
                                        itemPosition = item.PrimaryPart.Position
                                    else
                                        for _, child in pairs(item:GetChildren()) do
                                            if child:IsA("BasePart") then
                                                itemPosition = child.Position
                                                break
                                            end
                                        end
                                    end
                                elseif item:IsA("BasePart") then
                                    itemPosition = item.Position
                                end

                                if itemPosition then
                                    local distance = (playerPosition - itemPosition).Magnitude
                                    if distance <= config.maxCollectionDistance then
                                        table.insert(
                                            collectables,
                                            {
                                                instance = item,
                                                position = itemPosition,
                                                name = item.Name,
                                                distance = distance
                                            }
                                        )
                                    end
                                end
                            end
                        end
                    end
                end

                table.sort(
                    collectables,
                    function(a, b)
                        return a.distance < b.distance
                    end
                )

                return collectables
            end
        }
    end)()

    -- Movement system with unpredictable patterns and anchoring
    local movementSystem =
        (function()
        local lastTween = nil

        -- Function to anchor/unanchor the character
        local function setAnchorState(character, state)
            if not character then
                return
            end

            local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
            if not humanoidRootPart then
                return
            end

            -- Set anchored state
            humanoidRootPart.Anchored = false

            -- Also set velocity to zero when anchoring to prevent momentum
            if state then
                humanoidRootPart.Velocity = Vector3.new(0, 0, 0)
            end
        end

        local function addRandomOffset(position)
            return position +
                Vector3.new(math.random(-30, 30) / 100, math.random(-10, 40) / 100, math.random(-30, 30) / 100)
        end

        -- Improved tween function with anchoring for smoother teleportation
        local function tweenToPosition(targetPosition, customDuration)
            local character = services.players.LocalPlayer.Character
            if not character then
                return false
            end

            local humanoid = character:FindFirstChild("Humanoid")
            local rootPart = character:FindFirstChild("HumanoidRootPart")
            if not (humanoid and rootPart) then
                return false
            end

            if lastTween and lastTween.PlaybackState == Enum.PlaybackState.Playing then
                lastTween:Cancel()
            end

            -- Anchor character before teleporting
            setAnchorState(character, false)

            local distance = (rootPart.Position - targetPosition).Magnitude

            -- Calculate a reasonable duration based on distance
            local duration = customDuration or (math.min(distance / 40, 5) + (math.random(20, 40) / 100))

            local easingStyles = {
                Enum.EasingStyle.Quad,
                Enum.EasingStyle.Cubic,
                Enum.EasingStyle.Sine
            }

            local easingDirections = {
                Enum.EasingDirection.Out,
                Enum.EasingDirection.InOut
            }

            local tweenInfo =
                TweenInfo.new(
                duration,
                easingStyles[math.random(1, #easingStyles)],
                easingDirections[math.random(1, #easingDirections)],
                0,
                false,
                0.05 + (math.random(5, 15) / 100)
            )

            local destination = CFrame.new(targetPosition)
            lastTween = services.tween:Create(rootPart, tweenInfo, {CFrame = destination})
            lastTween:Play()

            local completed = false
            lastTween.Completed:Connect(
                function()
                    completed = true
                    -- Unanchor character after tweening is complete
                    setAnchorState(character, false)
                end
            )

            local startTime = tick()
            while not completed and (tick() - startTime) < (duration + 1) do
                task.wait(0.05)

                if
                    not (character and character:IsDescendantOf(workspace) and rootPart and
                        rootPart:IsDescendantOf(character))
                 then
                    setAnchorState(character, false) -- Make sure to unanchor if something goes wrong
                    return false
                end
            end

            task.wait(math.random(5, 15) / 100)
            return true
        end

        return {
            moveToTarget = function(targetPosition)
                local character = services.players.LocalPlayer.Character
                if not character then
                    return false
                end

                local rootPart = character:FindFirstChild("HumanoidRootPart")
                if not rootPart then
                    return false
                end

                local distance = (rootPart.Position - targetPosition).Magnitude
                if distance > config.maxCollectionDistance then
                    return false
                end

                local destinationWithOffset = addRandomOffset(targetPosition)
                return tweenToPosition(destinationWithOffset)
            end,
            -- Exposing the tweenToPosition function for external use
            tweenToPosition = tweenToPosition,
            -- Expose anchor function
            setAnchorState = setAnchorState
        }
    end)()

    -- Item interaction system
    local interactionSystem =
        (function()
        return {
            collectItem = function(itemInfo)
                if itemInfo.instance and itemInfo.instance:IsDescendantOf(workspace) then
                    task.wait(math.random(20, 40) / 100)
                    return true
                end
                return false
            end
        }
    end)()

    -- Notification system with reduced frequency
    local function showNotification(title, content)
        if not config.notificationSent then
            Fluent:Notify(
                {
                    Title = title,
                    Content = content,
                    Duration = 3
                }
            )
            config.notificationSent = true
        end
    end

    -- Main loop with improved logic flow and detection avoidance
    local function startItemCollection()
        local function collectionCycle()
            if not autocollectitemsns.Value then
                config.enabled = false
                return
            end

            local itemsToCollect = itemManager.findItems()
            local character = services.players.LocalPlayer.Character

            if #itemsToCollect == 0 then
                showNotification("Status Update", "Searching...")
                -- Tween to location instead of instant teleport
                if character and character:FindFirstChild("HumanoidRootPart") then
                    game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("Challenge"):WaitForChild(
                        "Teleport"
                    ):FireServer()
                end

                local nextCheckDelay = config.scanInterval + math.random(-30, 50) / 100
                task.delay(nextCheckDelay, collectionCycle)
                return
            end

            config.notificationSent = false

            for i, itemInfo in ipairs(itemsToCollect) do
                if not autocollectitemsns.Value then
                    config.enabled = false
                    return
                end

                if movementSystem.moveToTarget(itemInfo.position) then
                    interactionSystem.collectItem(itemInfo)
                    local itemDelay = config.itemProcessDelay + math.random(-10, 10) / 100
                    task.wait(itemDelay)
                end

                if i % 3 == 0 then
                    task.wait(math.random(10, 30) / 100)
                end
            end

            local nextCycleDelay = config.scanInterval + math.random(-20, 30) / 100
            task.delay(nextCycleDelay, collectionCycle)
        end

        task.spawn(collectionCycle)
    end

    -- Toggle handler with tweened teleport logic
    local initialPosition = nil
    local teleportPosition = Vector3.new(-1209, 158, 3599) -- The teleport position when toggle is turned on

    autocollectitems:OnChanged(
        function()
            local character = services.players.LocalPlayer.Character
            if autocollectitems.Value then
                -- Store initial position before teleport
                if character and character:FindFirstChild("HumanoidRootPart") then
                    initialPosition = character.HumanoidRootPart.Position
                end

                -- Tween to the predefined position instead of instant teleport
                if character and character:FindFirstChild("HumanoidRootPart") then
                    showNotification("Status Update", "Moving to farming area...")
                    game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("Challenge"):WaitForChild(
                        "Teleport"
                    ):FireServer()

                    -- Wait for tween to complete plus a small delay before starting collection
                    task.wait(2.5)
                    showNotification("Status Update", "Starting collection...")
                end

                -- Start item collection
                if not config.enabled then
                    config.enabled = true
                    startItemCollection()
                end
            else
                -- Return to initial position using tween if toggle is off
                if initialPosition then
                    local character = services.players.LocalPlayer.Character
                    if character and character:FindFirstChild("HumanoidRootPart") then
                        showNotification("Status Update", "Returning to original position...")
                        character.HumanoidRootPart.CFrame = CFrame.new(initialPosition)
                    end
                end

                config.enabled = false
            end
        end
    )

    -- Setup respawn handling - works regardless of how many times player dies
    local function setupRespawnHandler()
        -- Connect to current character if it exists
        local player = services.players.LocalPlayer
        if player.Character then
            local humanoid = player.Character:FindFirstChild("Humanoid")
            if humanoid then
                humanoid.Died:Connect(
                    function()
                        if autocollectitemsns.Value or config.autoRespawnEnabled then
                            task.wait(3) -- Wait a bit longer for respawn
                            -- Teleport to farm area after respawn
                            local function attemptTeleportAfterRespawn()
                                local character = player.Character
                                if character and character:FindFirstChild("HumanoidRootPart") then
                                    -- Use tween instead of instant teleport
                                    showNotification("Status Update", "Respawned - returning to farm area...")
                                    game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild(
                                        "Challenge"
                                    ):WaitForChild("Teleport"):FireServer()
                                    return true
                                end
                                return false
                            end

                            -- Try multiple times to ensure teleportation works
                            local maxAttempts = 10
                            local attempts = 0
                            local function tryRespawnTeleport()
                                attempts = attempts + 1
                                if attempts > maxAttempts then
                                    return
                                end

                                if not attemptTeleportAfterRespawn() then
                                    -- If failed, try again in a second
                                    task.wait(1)
                                    tryRespawnTeleport()
                                end
                            end

                            tryRespawnTeleport()
                        end
                    end
                )
            end
        end

        -- Connect to future characters
        player.CharacterAdded:Connect(
            function(character)
                -- When a new character is added after death
                if autocollectitemsns.Value or config.autoRespawnEnabled then
                    -- Wait for humanoid and root part
                    local humanoid = character:WaitForChild("Humanoid", 5)
                    local rootPart = character:WaitForChild("HumanoidRootPart", 5)

                    if humanoid and rootPart then
                        task.wait(1) -- Wait for character to fully load

                        -- Teleport back to farming area before starting item collection
                        showNotification("Status Update", "Respawned - returning to farm area...")
                        game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("Challenge"):WaitForChild(
                            "Teleport"
                        ):FireServer()

                        -- Setup death handler for this character
                        humanoid.Died:Connect(
                            function()
                                if autocollectitemsns.Value or config.autoRespawnEnabled then
                                -- This death handler will be triggered when this character dies
                                -- The CharacterAdded connection above will handle the next respawn
                                end
                            end
                        )
                    end
                end
            end
        )
    end

    if autocollectitemsns.Value then
        setupRespawnHandler()
    end

    local sectele = Tabs.World:AddSection("Teleport")

    -- Get the names of all islands in workspace.Spawn
    local islandNames = {}
    for _, island in pairs(workspace.Spawn:GetChildren()) do
        table.insert(islandNames, island.Name)
    end

    -- Add "GhostIsland" explicitly to the islandNames list
    table.insert(islandNames, "GhostIsland")

    -- Create the dropdown with island names
    local teleportdrop =
        sectele:AddDropdown(
        "teleportdrop",
        {
            Title = "Islands:",
            Values = islandNames,
            Multi = false,
            Default = "" -- Empty string for no default selection
        }
    )

    -- Teleport function
    local function teleportToIsland(islandName)
        local character = game.Players.LocalPlayer.Character
        if character and character:FindFirstChild("HumanoidRootPart") then
            local selectedIsland = workspace.Spawn:FindFirstChild(islandName)

            if selectedIsland then
                -- Teleport to the selected island
                character.HumanoidRootPart.CFrame = selectedIsland.CFrame
            elseif islandName == "GhostIsland" then
                -- Special case for GhostIsland
                character.HumanoidRootPart.CFrame =
                    CFrame.new(
                    -4925.82422,
                    57.0164528,
                    -453.611359,
                    0.108480982,
                    2.34560051e-08,
                    -0.994098544,
                    -1.04054667e-08,
                    1,
                    2.24597549e-08,
                    0.994098544,
                    7.90760346e-09,
                    0.108480982
                )
            end
        end
    end

    -- Dropdown change handler
    teleportdrop:OnChanged(
        function(Value)
            if Value and Value ~= "" then
                teleportToIsland(Value)
            end
        end
    )

    -- Populate dropdown with the names of subfolders in 'workspace.WorldEvent'
    local worldEventFolder = workspace:WaitForChild("WorldEvent")
    local folderNames = {}

    -- Iterate through subfolders in 'WorldEvent'
    for _, subfolder in pairs(worldEventFolder:GetChildren()) do
        if subfolder:IsA("Folder") then
            -- Add the folder name to the dropdown list
            table.insert(folderNames, subfolder.Name)
        end
    end

    -- Now create the dropdown with the gathered folder names
    local worldeventdrop =
        sectele:AddDropdown(
        "worldeventdrop",
        {
            Title = "World Events:",
            Values = folderNames, -- Use the populated list of folder names
            Multi = false,
            Default = ""
        }
    )

    -- When the dropdown value changes
    worldeventdrop:OnChanged(
        function(Value)
            local selectedFolder = worldEventFolder:FindFirstChild(Value)
            if selectedFolder then
                -- Look for the first model in the selected folder
                for _, item in pairs(selectedFolder:GetChildren()) do
                    if item:IsA("Model") and item.PrimaryPart then
                        -- Teleport to the model's PrimaryPart
                        local character = game.Players.LocalPlayer.Character
                        if character and character.PrimaryPart then
                            character:SetPrimaryPartCFrame(item.PrimaryPart.CFrame + Vector3.new(0, 30, 0))
                        end
                        break -- Teleport to the first model found
                    end
                end
            end
        end
    )

    -- World Event Notification System
    -- Implements efficient event detection and notification with minimal overhead
    local eventnotif =
        sectele:AddToggle(
        "eventnotif",
        {
            Title = "World Event Notifier",
            Default = false
        }
    )

    -- Notification system state management
    local notificationState = {
        connection = nil,
        detectedEvents = {},
        isActive = false
    }

    -- Validates if a folder contains valid event models
    local function hasValidEventModels(folder)
        for _, item in pairs(folder:GetChildren()) do
            if item:IsA("Model") and item.PrimaryPart then
                return true
            end
        end
        return false
    end

    -- Creates and displays a notification for specified event names
    local function notifyEvents(title, eventNames)
        if #eventNames == 0 then
            return
        end

        local eventList = table.concat(eventNames, ", ")
        Fluent:Notify(
            {
                Title = title,
                Content = "Event" .. (#eventNames > 1 and "s: " or ": ") .. eventList,
                Duration = math.min(5 + #eventNames, 10) -- Scale duration with event count, max 10 seconds
            }
        )
    end

    -- Handles notification system activation/deactivation
    eventnotif:OnChanged(
        function()
            local isEnabled = eventnotif.Value

            -- Clean up previous state if it exists
            if notificationState.connection then
                notificationState.connection:Disconnect()
                notificationState.connection = nil
            end

            -- Update internal state
            notificationState.isActive = isEnabled
            notificationState.detectedEvents = {}

            if not isEnabled then
                return
            end

            -- Process existing events (check once for any that are already present)
            local existingEvents = {}
            for _, folder in pairs(worldEventFolder:GetChildren()) do
                if folder:IsA("Folder") and hasValidEventModels(folder) then
                    table.insert(existingEvents, folder.Name)
                    notificationState.detectedEvents[folder.Name] = true
                end
            end

            -- Notify about existing events if any
            if #existingEvents > 0 then
                notifyEvents("Active World Events", existingEvents)
            end

            -- Set up monitoring for new events being added
            notificationState.connection =
                worldEventFolder.ChildAdded:Connect(
                function(newFolder)
                    if not notificationState.isActive then
                        return
                    end

                    -- Validate that this is an event folder with valid models
                    if not newFolder:IsA("Folder") then
                        return
                    end

                    -- Wait briefly to allow models to be added to the folder
                    task.delay(
                        0.5,
                        function()
                            -- Skip if already processed or no longer active
                            if not notificationState.isActive or notificationState.detectedEvents[newFolder.Name] then
                                return
                            end

                            -- Verify folder has valid models
                            if hasValidEventModels(newFolder) then
                                notificationState.detectedEvents[newFolder.Name] = true
                                notifyEvents("New World Event Detected", {newFolder.Name})
                            end
                        end
                    )
                end
            )
        end
    )

    local secweather = Tabs.World:AddSection("Weather")
    local weathers = workspace.WeatherValues

    local weathertog = secweather:AddToggle("weathertog", {Title = "Fog", Default = false})
    weathertog:OnChanged(
        function()
            weathers.Fog.Value = weathertog.Value
        end
    )

    local weathertog = secweather:AddToggle("weathertog", {Title = "Rain", Default = false})
    weathertog:OnChanged(
        function()
            weathers.Rain.Value = weathertog.Value
        end
    )

    local weathertog = secweather:AddToggle("weathertog", {Title = "Snow", Default = false})
    weathertog:OnChanged(
        function()
            weathers.Snow.Value = weathertog.Value
        end
    )

    local weathertog = secweather:AddToggle("weathertog", {Title = "Thunderstorm", Default = false})
    weathertog:OnChanged(
        function()
            weathers.Thunderstorm.Value = weathertog.Value
        end
    )

    local secesp = Tabs.ESP:AddSection("Resource")
    local secesp2 = Tabs.ESP:AddSection("Player")

    -- Default ESP settings for parts/models
    local fillColor = Color3.fromRGB(255, 255, 255)
    local outlineColor = Color3.fromRGB(255, 255, 255)
    local fillEnabled = false
    local outlineEnabled = false

    -- Default ESP settings for players
    local playerFillColor = Color3.fromRGB(255, 255, 255)
    local playerOutlineColor = Color3.fromRGB(255, 255, 255)
    local playerFillEnabled = false
    local playerOutlineEnabled = false

    -- Function to create the ESP highlight for parts and models
    local function createESPForObject(object)
        -- If it's a BasePart
        if object:IsA("BasePart") then
            -- If it's a Model
            -- Check if it's already inside a model
            local model = object.Parent
            if not model:IsA("Model") then
                model = Instance.new("Model")
                model.Name = object.Name
                model.Parent = object.Parent
                object.Parent = model
            end

            -- Check if the part already has a highlight, create if not
            local highlight = model:FindFirstChild("ESP_Highlight")
            if not highlight then
                highlight = Instance.new("Highlight")
                highlight.Name = "ESP_Highlight"
                highlight.FillColor = fillColor
                highlight.OutlineColor = outlineColor
                highlight.FillTransparency = fillEnabled and 0.5 or 1
                highlight.OutlineTransparency = outlineEnabled and 0 or 1
                highlight.Parent = model
            end
        elseif object:IsA("Model") then
            -- Check if the model already has a highlight
            local highlight = object:FindFirstChild("ESP_Highlight")
            if not highlight then
                highlight = Instance.new("Highlight")
                highlight.Name = "ESP_Highlight"
                highlight.FillColor = fillColor
                highlight.OutlineColor = outlineColor
                highlight.FillTransparency = fillEnabled and 0.5 or 1
                highlight.OutlineTransparency = outlineEnabled and 0 or 1
                highlight.Parent = object
            end
        end
    end

    -- Function to update highlights for models and parts
    local function updateHighlightForObject(object)
        local highlight = object:FindFirstChild("ESP_Highlight")
        if highlight then
            highlight.FillColor = fillColor
            highlight.OutlineColor = outlineColor
            highlight.FillTransparency = fillEnabled and 0.5 or 1
            highlight.OutlineTransparency = outlineEnabled and 0 or 1
        end
    end

    -- Function to ensure that all parts/models in folders have ESP
    local function checkAndWrapPartsAndModelsInFolders()
        for _, folder in ipairs(workspace:GetChildren()) do
            if folder.Name == "Folder" and #folder:GetChildren() > 0 then
                for _, object in ipairs(folder:GetChildren()) do
                    createESPForObject(object) -- Add ESP to parts/models
                    updateHighlightForObject(object) -- Update highlight settings
                end
            end
        end
    end

    -- Function to monitor newly added objects in folders
    local function monitorNewObjectsInFolders()
        -- Listen for new folders being added to the workspace
        workspace.ChildAdded:Connect(
            function(child)
                if child:IsA("Folder") and child.Name == "Folder" then
                    -- Listen for new parts/models added inside the folder
                    child.ChildAdded:Connect(
                        function(object)
                            if #child:GetChildren() > 0 then
                                createESPForObject(object)
                                updateHighlightForObject(object)
                            end
                        end
                    )

                    -- Apply ESP to existing parts/models if the folder has children
                    if #child:GetChildren() > 0 then
                        for _, object in ipairs(child:GetChildren()) do
                            createESPForObject(object)
                            updateHighlightForObject(object)
                        end
                    end
                end
            end
        )

        -- Listen for new parts/models added inside existing folders
        for _, folder in ipairs(workspace:GetChildren()) do
            if folder:IsA("Folder") and folder.Name == "Folder" and #folder:GetChildren() > 0 then
                folder.ChildAdded:Connect(
                    function(object)
                        createESPForObject(object)
                        updateHighlightForObject(object)
                    end
                )

                -- Apply to existing parts/models in the folder if it has children
                if #folder:GetChildren() > 0 then
                    for _, object in ipairs(folder:GetChildren()) do
                        createESPForObject(object)
                        updateHighlightForObject(object)
                    end
                end
            end
        end
    end

    -- Function to add a highlight to the player's character (excluding the local player)
    local function addPlayerHighlight(character)
        if character ~= game.Players.LocalPlayer.Character then -- Skip the local player's character
            if not character:FindFirstChild("ESP_Highlight") then
                local highlight = Instance.new("Highlight")
                highlight.Name = "ESP_Highlight"
                highlight.FillColor = playerFillColor
                highlight.OutlineColor = playerOutlineColor
                highlight.FillTransparency = playerFillEnabled and 0.5 or 1
                highlight.OutlineTransparency = playerOutlineEnabled and 0 or 1
                highlight.Parent = character
            end
        end
    end

    -- Set up ESP for all players (non-local)
    for _, player in ipairs(game.Players:GetPlayers()) do
        if player.Character and player ~= game.Players.LocalPlayer then -- Exclude local player
            addPlayerHighlight(player.Character)
        end

        player.CharacterAdded:Connect(
            function(character)
                if player ~= game.Players.LocalPlayer then -- Exclude local player
                    addPlayerHighlight(character)
                end
            end
        )
    end

    game.Players.PlayerAdded:Connect(
        function(player)
            player.CharacterAdded:Connect(
                function(character)
                    if player ~= game.Players.LocalPlayer then -- Exclude local player
                        addPlayerHighlight(character)
                    end
                end
            )
        end
    )

    game.Players.PlayerRemoving:Connect(
        function(player)
            if player.Character and player ~= game.Players.LocalPlayer then -- Exclude local player
                local highlight = player.Character:FindFirstChild("ESP_Highlight")
                if highlight then
                    highlight:Destroy()
                end
            end
        end
    )

    -- UI controls for Resource section (secesp)
    local FillColorPicker =
        secesp:AddColorpicker(
        "FillColorPicker",
        {
            Title = "Fill Color",
            Default = fillColor
        }
    )
    FillColorPicker:OnChanged(
        function(newColor)
            fillColor = newColor
            checkAndWrapPartsAndModelsInFolders() -- Reapply to all parts and models
        end
    )

    local OutlineColorPicker =
        secesp:AddColorpicker(
        "OutlineColorPicker",
        {
            Title = "Outline Color",
            Default = outlineColor
        }
    )
    OutlineColorPicker:OnChanged(
        function(newColor)
            outlineColor = newColor
            checkAndWrapPartsAndModelsInFolders() -- Reapply to all parts and models
        end
    )

    local fillToggle = secesp:AddToggle("FillToggle", {Title = "Enable Fill", Default = fillEnabled})
    fillToggle:OnChanged(
        function(enabled)
            fillEnabled = enabled
            checkAndWrapPartsAndModelsInFolders() -- Reapply to all parts and models
        end
    )

    local outlineToggle = secesp:AddToggle("OutlineToggle", {Title = "Enable Outline", Default = outlineEnabled})
    outlineToggle:OnChanged(
        function(enabled)
            outlineEnabled = enabled
            checkAndWrapPartsAndModelsInFolders() -- Reapply to all parts and models
        end
    )

    -- UI controls for Player section (secesp2)
    local playerFillColorPicker =
        secesp2:AddColorpicker(
        "PlayerFillColorPicker",
        {
            Title = "Player Fill Color",
            Default = playerFillColor
        }
    )
    playerFillColorPicker:OnChanged(
        function(newColor)
            playerFillColor = newColor
            for _, player in ipairs(game.Players:GetPlayers()) do
                if player.Character then
                    local highlight = player.Character:FindFirstChild("ESP_Highlight")
                    if highlight then
                        highlight.FillColor = playerFillColor
                    end
                end
            end
        end
    )

    local playerOutlineColorPicker =
        secesp2:AddColorpicker(
        "PlayerOutlineColorPicker",
        {
            Title = "Player Outline Color",
            Default = playerOutlineColor
        }
    )
    playerOutlineColorPicker:OnChanged(
        function(newColor)
            playerOutlineColor = newColor
            for _, player in ipairs(game.Players:GetPlayers()) do
                if player.Character then
                    local highlight = player.Character:FindFirstChild("ESP_Highlight")
                    if highlight then
                        highlight.OutlineColor = playerOutlineColor
                    end
                end
            end
        end
    )

    local playerFillToggle = secesp2:AddToggle("PlayerFillToggle", {Title = "Enable Fill", Default = playerFillEnabled})
    playerFillToggle:OnChanged(
        function(enabled)
            playerFillEnabled = enabled
            for _, player in ipairs(game.Players:GetPlayers()) do
                if player.Character then
                    local highlight = player.Character:FindFirstChild("ESP_Highlight")
                    if highlight then
                        highlight.FillTransparency = playerFillEnabled and 0.5 or 1
                    end
                end
            end
        end
    )

    local playerOutlineToggle =
        secesp2:AddToggle("PlayerOutlineToggle", {Title = "Enable Outline", Default = playerOutlineEnabled})
    playerOutlineToggle:OnChanged(
        function(enabled)
            playerOutlineEnabled = enabled
            for _, player in ipairs(game.Players:GetPlayers()) do
                if player.Character then
                    local highlight = player.Character:FindFirstChild("ESP_Highlight")
                    if highlight then
                        highlight.OutlineTransparency = playerOutlineEnabled and 0 or 1
                    end
                end
            end
        end
    )

    -- Initial check for existing parts and models in folders
    checkAndWrapPartsAndModelsInFolders()

    -- Run continuous check in a non-blocking manner
    task.spawn(
        function()
            while true do
                checkAndWrapPartsAndModelsInFolders()
                task.wait(1) -- Check every second for new objects
            end
        end
    )

    -- Call the function to monitor new resources being added
    monitorNewObjectsInFolders()

    local miscserver = Tabs.Misc:AddSection("Servers")
    local Player = game:GetService("Players").LocalPlayer

    local function formatServerTime(timeString)
        local hours, minutes, seconds = timeString:match("(%d+):(%d+):(%d+)")
        if hours and minutes and seconds then
            return string.format("%02dh %02dm %02ds", tonumber(hours), tonumber(minutes), tonumber(seconds))
        else
            return "Invalid Time"
        end
    end

    local function getServerInfo()
        local serverInfo = {
            playerCount = #game:GetService("Players"):GetPlayers(),
            ping = 0,
            maxPlayers = game:GetService("Players").MaxPlayers
        }

        local success, response =
            pcall(
            function()
                return game:HttpGet(
                    "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"
                )
            end
        )

        if success then
            local decoded = game:GetService("HttpService"):JSONDecode(response)
            if decoded and decoded.data then
                for _, server in ipairs(decoded.data) do
                    if server.id == game.JobId then
                        serverInfo.playerCount = server.playing or serverInfo.playerCount
                        serverInfo.maxPlayers = server.maxPlayers or serverInfo.maxPlayers
                        serverInfo.ping = server.ping or 0
                        break
                    end
                end
            end
        end

        return serverInfo
    end

    local function getPlayerPing()
        local playerPingSeconds = Player:GetNetworkPing()
        local playerPingMs = playerPingSeconds * 1000 * 2
        return math.floor(playerPingMs)
    end

    local function getServerTimeText()
        if
            Player.PlayerGui and Player.PlayerGui:FindFirstChild("Others") and
                Player.PlayerGui.Others:FindFirstChild("ServerTime")
         then
            return Player.PlayerGui.Others.ServerTime.Text or "00:00:00"
        end
        return "00:00:00"
    end

    local infoParagraph =
        miscserver:AddParagraph(
        {
            Title = "Server Uptime: Loading... | Player Count: N/A | Max Players: N/A | Ping: N/A ms",
            Content = ""
        }
    )

    local updateInterval = 10 -- Reduced update frequency to avoid lag
    local lastUpdateTime = tick()

    game:GetService("RunService").Heartbeat:Connect(
        function()
            if tick() - lastUpdateTime >= updateInterval then
                lastUpdateTime = tick()
                local serverInfo = getServerInfo()
                local playerPing = getPlayerPing()
                local uptime = formatServerTime(getServerTimeText())
                infoParagraph:SetTitle(
                    "Server Uptime: " ..
                        uptime ..
                            " | Player Count: " ..
                                serverInfo.playerCount ..
                                    "/" .. serverInfo.maxPlayers .. " | Ping: " .. playerPing .. " ms"
                )
            end
        end
    )

    local SVD =
        miscserver:AddDropdown(
        "Server List",
        {
            Title = "Server Browser",
            Values = {},
            Multi = false,
            Default = nil
        }
    )

    local function getServerList()
        local serverList = {}
        local success, response =
            pcall(
            function()
                return game:HttpGet(
                    "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"
                )
            end
        )

        if success then
            local decoded = game:GetService("HttpService"):JSONDecode(response)
            if decoded and decoded.data then
                for _, server in ipairs(decoded.data) do
                    if server.id ~= game.JobId then
                        table.insert(
                            serverList,
                            {
                                id = server.id,
                                playing = server.playing or 0,
                                maxPlayers = server.maxPlayers or 0,
                                ping = server.ping or 0
                            }
                        )
                    end
                end
            end
        end

        return serverList
    end

    _G.ServerIDs = {}
    local servers = getServerList()
    local serverOptions = {}

    for _, server in ipairs(servers) do
        local option = string.format("Players: %d/%d | Ping: %dms", server.playing, server.maxPlayers, server.ping)
        table.insert(serverOptions, option)
        _G.ServerIDs[option] = server.id
    end

    if #serverOptions > 0 then
        SVD:SetValues(serverOptions)
    else
        SVD:SetValues({"No servers available"})
    end

    SVD:OnChanged(
        function(Value)
            local serverId = _G.ServerIDs[Value]
            if serverId then
                Fluent:Notify(
                    {
                        Title = "Teleporting",
                        Content = "Joining server...",
                        Duration = 3
                    }
                )
                pcall(
                    function()
                        game:GetService("TeleportService"):TeleportToPlaceInstance(
                            game.PlaceId,
                            serverId,
                            game.Players.LocalPlayer
                        )
                    end
                )
            end
        end
    )

    miscserver:AddButton(
        {
            Title = "Copy Server ID: " .. tostring(game.JobId),
            Callback = function()
                pcall(
                    function()
                        setclipboard(tostring(game.JobId))
                    end
                )
                Fluent:Notify(
                    {
                        Title = "Server ID Copied",
                        Content = "Server ID: " .. tostring(game.JobId) .. " copied to clipboard.",
                        Duration = 3
                    }
                )
            end
        }
    )

    miscserver:AddButton(
        {
            Title = "Rejoin",
            Description = "",
            Callback = function()
                local TeleportService = game:GetService("TeleportService")
                local Players = game:GetService("Players")
                local LocalPlayer = Players.LocalPlayer
                pcall(
                    function()
                        TeleportService:Teleport(game.PlaceId, LocalPlayer)
                    end
                )
            end
        }
    )

    miscserver:AddButton(
        {
            Title = "Server Hop",
            Description = "",
            Callback = function()
                local TeleportService = game:GetService("TeleportService")
                local HttpService = game:GetService("HttpService")
                local Players = game:GetService("Players")
                local LocalPlayer = Players.LocalPlayer

                Fluent:Notify(
                    {
                        Title = "Server Hop",
                        Content = "Finding a populated server...",
                        Duration = 2
                    }
                )

                local apiUrl =
                    "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Desc&limit=100"
                local success, result =
                    pcall(
                    function()
                        return HttpService:JSONDecode(game:HttpGet(apiUrl))
                    end
                )

                if success and result and result.data then
                    local validServers = {}
                    for _, server in ipairs(result.data) do
                        if server.id ~= game.JobId and server.playing < server.maxPlayers then
                            table.insert(validServers, server)
                        end
                    end

                    table.sort(
                        validServers,
                        function(a, b)
                            return a.playing > b.playing
                        end
                    )

                    if #validServers > 0 then
                        local topServerCount = math.min(3, #validServers)
                        local serverIndex = math.random(1, topServerCount)
                        local server = validServers[serverIndex]

                        Fluent:Notify(
                            {
                                Title = "Server Hop",
                                Content = "Joining server with " ..
                                    server.playing .. "/" .. server.maxPlayers .. " players",
                                Duration = 2
                            }
                        )

                        TeleportService:TeleportToPlaceInstance(game.PlaceId, server.id, LocalPlayer)
                    else
                        Fluent:Notify(
                            {
                                Title = "Server Hop",
                                Content = "No servers found. Joining random server...",
                                Duration = 2
                            }
                        )

                        TeleportService:Teleport(game.PlaceId, LocalPlayer)
                    end
                else
                    Fluent:Notify(
                        {
                            Title = "Server Hop",
                            Content = "Joining random server...",
                            Duration = 2
                        }
                    )

                    TeleportService:Teleport(game.PlaceId, LocalPlayer)
                end
            end
        }
    )

    local secCredits = Tabs.Credits:AddSection("Credits")

    secCredits:AddParagraph(
        {
            Title = "By archangel",
            Content = ""
        }
    )

    secCredits:AddButton(
        {
            Title = "Facebook",
            Description = "",
            Callback = function()
                setclipboard("fb.com/hoanokhongmau")
                Fluent:Notify(
                    {
                        Title = "Facebook Link Copied",
                        Content = "Copied my contact",
                        Duration = 3
                    }
                )
            end
        }
    )

    secCredits:AddButton(
        {
            Title = "Discord Server",
            Description = "",
            Callback = function()
                Fluent:Notify(
                    {
                        Title = "Not updated",
                        Content = "Not available",
                        Duration = 2
                    }
                )
            end
        }
    )

    Tabs.UpdateLogs:AddParagraph(
        {
            Title = "Version: 1.0.0",
            Content = "\nBeta version"
        }
    )

    -- Implementation for script persistence with teleport queueing
    local function implementPersistentScript()
        -- Step 1: Validate environment and prepare main folder
        if not isfolder(CONFIGURATION.FOLDER_NAME) then
            local success, errorMessage = pcall(makefolder, CONFIGURATION.FOLDER_NAME)

            if not success then
                warn("[ERROR] Failed to create main directory structure: " .. tostring(errorMessage))
                return false
            end
        end

        -- Create games folder if it doesn't exist
        local gamesFolder = CONFIGURATION.FOLDER_NAME .. "/games"
        if not isfolder(gamesFolder) then
            local success, errorMessage = pcall(makefolder, gamesFolder)

            if not success then
                warn("[ERROR] Failed to create games directory: " .. tostring(errorMessage))
                return false
            end
        end

        -- Step 2: Get current game name and ID
        local currentGameId = tostring(game.PlaceId)
        local currentGameName = game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name

        -- Sanitize game name to be folder-friendly (remove special characters)
        local sanitizedGameName = currentGameName:gsub("[^%w%s_-]", ""):gsub("%s+", "_")

        -- Create game-specific folder using game name
        local gameSpecificFolder = gamesFolder .. "/" .. sanitizedGameName

        -- Create game-specific folder if it doesn't exist
        if not isfolder(gameSpecificFolder) then
            local success, errorMessage = pcall(makefolder, gameSpecificFolder)

            if not success then
                warn("[ERROR] Failed to create game-specific directory: " .. tostring(errorMessage))
                return false
            end
        end

        -- Step 3: Generate target filepath using game ID for the filename in the game name folder
        local targetFilePath = gameSpecificFolder .. "/" .. currentGameId .. CONFIGURATION.FILE_EXTENSION

        -- Step 4: Prepare script content with proper variable reference
        local scriptContent = 'loadstring(game:HttpGet("' .. CONFIGURATION.SCRIPT_URL .. '"))()'

        -- Step 5: Write file with error handling
        local writeSuccess, writeError =
            pcall(
            function()
                writefile(targetFilePath, scriptContent)
            end
        )

        if not writeSuccess then
            warn("[ERROR] Failed to write script file: " .. tostring(writeError))
            return false
        end

        -- Step 6: Prepare teleport queue script that will execute after teleport
        local teleportScript =
            [[
        -- Wait for game to load properly
        if not game:IsLoaded() then
            game.Loaded:Wait()
        end
        
        -- Small delay to ensure services are available
        task.wait(1)
        
        -- Execute the Arise script
        loadstring(game:HttpGet("]] ..
            CONFIGURATION.SCRIPT_URL ..
                [["))()
        
        -- Re-queue for future teleports
        queue_on_teleport([=[
            loadstring(game:HttpGet("]] ..
                    CONFIGURATION.SCRIPT_URL ..
                        [["))()
            loadstring(readfile("]=] .. targetFilePath .. [=["))()
        ]=])
    ]]

        -- Step 7: Queue the teleport script
        local queueSuccess, queueError =
            pcall(
            function()
                queue_on_teleport(teleportScript)
            end
        )

        if not queueSuccess then
            warn("[ERROR] Failed to queue script for teleport: " .. tostring(queueError))
            return false
        end

        -- Step 8: Return operation results
        return {
            success = true,
            filePath = targetFilePath,
            gameId = currentGameId,
            gameName = currentGameName,
            gameFolder = gameSpecificFolder,
            message = "Script successfully saved and queued for teleport persistence"
        }
    end

    -- ====== UI CONFIGURATION SECTION ======
    -- Addons:
    -- SaveManager (Allows you to have a configuration system)
    -- InterfaceManager (Allows you to have a interface managment system)

    -- Hand the library over to our managers
    SaveManager:SetLibrary(Fluent)
    InterfaceManager:SetLibrary(Fluent)

    -- Ignore keys that are used by ThemeManager.
    -- (we dont want configs to save themes, do we?)
    SaveManager:IgnoreThemeSettings()

    -- You can add indexes of elements the save manager should ignore
    SaveManager:SetIgnoreIndexes({})

    -- use case for doing it this way:
    -- a script hub could have themes in a global folder
    -- and game configs in a separate folder per game
    InterfaceManager:SetFolder("CROW")
    SaveManager:SetFolder("CROW/games")

    Window:SelectTab(1)

    InterfaceManager:BuildInterfaceSection(Tabs.Settings)
    SaveManager:BuildConfigSection(Tabs.Settings)

    -- You can use the SaveManager:LoadAutoloadConfig() to load a config
    -- which has been marked to be one that auto loads!
    SaveManager:LoadAutoloadConfig()

    -- ====== EXECUTE PERSISTENCE MECHANISM ======
    -- Execute implementation and handle result
    local result = implementPersistentScript()

    -- Provide execution feedback
    if result and result.success then
    else
        warn("[ERROR] Failed to implement script persistence")

        Fluent:Notify(
            {
                Title = "Persistence System",
                Content = "Failed to enable script persistence",
                Duration = 5
            }
        )
    end

    Fluent:Notify(
        {
            Title = game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name .. " | " .. Version,
            Content = "The script has been loaded.",
            Duration = 8
        }
    )
else
    Fluent:Notify(
        {
            Title = "Interface",
            Content = "This script is already running.",
            Duration = 3
        }
    )
end
