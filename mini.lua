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
        Autofarm = Window:AddTab({Title = "Autofarm", Icon = "repeat"}),
        Credits = Window:AddTab({Title = "Credits", Icon = "book"}),
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

    local Players = game:GetService("Players")
    local VirtualUser = game:GetService("VirtualUser")
    local player = Players.LocalPlayer

    local secauto = Tabs.Autofarm:AddSection("Global")
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
