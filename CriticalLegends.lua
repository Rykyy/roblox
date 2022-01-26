-- // ADA TONG BUAHAHAHAHA \\ -- [Indonesia Bossque]

for _,patung in pairs(game:GetService("Workspace").Statues:GetDescendants()) do
    if patung.Name == "CombatStyle" and patung.Value == 33 then
        patung.Parent.Name = "StatueSolOfEclipseWarrior"
    end
end

for _,suara in pairs(game:GetService("Workspace").Sounds:GetChildren()) do
    suara.Volume = 0.2
end

--// Global Table \\--
_G.settingsTable = {
    toggle = false,
    allitem = false,
    item1 = "Select Items",
    item2 = "Select Items"
}

--// Global \\ --
getgenv().infpass = nil
getgenv().passitem = nil
getgenv().farm = nil
getgenv().zone = nil
getgenv().material = nil
getgenv().farmm = nil
getgenv().statlist = nil
getgenv().stat = nil
getgenv().spawns = nil
getgenv().statues = nil

-- // Variable \\ --
local plyr = game.Players.LocalPlayer
local namafile = plyr.DisplayName.."["..plyr.Name.."]".."_bmserverhop.CL"
local gameName = game:GetService('MarketplaceService'):GetProductInfo(game.PlaceId).Name
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StatsChange = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("StatsChange")
local Curr_Weapon = nil
local pesan = loadstring(game:HttpGet(("https://raw.githubusercontent.com/Rykyy/roblox/scripts/pesan.lua"),true))()

-- // Table \\ --
local bmTable = {"DIO's Bone", "Mana Water", "Mana Knife", "Wind Boots", "Holy Cross", "HP", "Crimson Heart", "Ring of Darkness", "Fighter Spirit", "Chop", "Icy Disable Scroll", "Shield Breaker", "Event Upgrade Ticket", "Crown of the King", "Ichor Torch", "Raging Storm Scroll", "Blood Thirst", "Floral Entrapment Scroll", "Health Drink", "Radis Diary", "Book of the Coven", "Lucky Gold Ticket"}
local itemTable = {}
local mobTable = {}
local materialTable = {}
local statuesTable = {}
local spawnsTable = {}


for _,o in pairs(game:GetService("ReplicatedStorage").Items.PassiveItems:GetChildren()) do
    for _,v in pairs(game:GetService("Players").LocalPlayer.PlayerData.Inventory:GetChildren()) do
        insert = true
        for _,v2 in pairs(itemTable) do if v2 == v.Name then insert = false end end
        if insert and v.Name == o.Name then table.insert(itemTable, v.Name) end
    end
end

for _,v in pairs(game:GetService("Workspace").Enemies:GetDescendants()) do
    if v.Name == "Model" then
        insert = true
        for _,v2 in pairs(mobTable) do if v2 == tostring(v.Value) then insert = false end end
        if insert then table.insert(mobTable, tostring(v.Value)) end
    end
end

for _,v in pairs(game:GetService("Workspace").MaterialGivers:GetChildren()) do
    if v.Name ~= "Iron" then
        table.insert(materialTable, v.Name)
    end
end

for _,v in pairs(game:GetService("Workspace").Statues:GetChildren()) do
    table.insert(statuesTable, v.Name);
end

for _,v in pairs(game:GetService("Workspace").Spawns:GetChildren()) do
    table.insert(spawnsTable, v.Name);
end

table.sort(itemTable)
table.sort(bmTable)
table.sort(materialTable)

-- // Function \\ --
function memuat()
    local HttpService = game:GetService("HttpService")
    if (readfile and isfile and isfile(namafile)) then
        _G.settingsTable = HttpService:JSONDecode(readfile(namafile))
    end
end

function menyimpan()
    local json
    local HttpService = game:GetService("HttpService")
    if (writefile) then
        json = HttpService:JSONEncode(_G.settingsTable)
        writefile(namafile, json)
    else
        pesan.msg("~~~ HAHAHAH UR EXECUTOR YOWAI")
    end
end
    
function tpto(part)
   plyr.Character.HumanoidRootPart.CFrame = part
end

function shop() -- Inf Yield Server Hop
    local x = {}
    for _, v in ipairs(game:GetService("HttpService"):JSONDecode(game:HttpGetAsync("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100")).data) do
        if type(v) == "table" and v.maxPlayers > v.playing and v.id ~= game.JobId then
           x[#x + 1] = v.id
        end
    end
    if #x > 0 then
       game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, x[math.random(1, #x)])
       wait(5)
       game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, x[math.random(1, #x)])
	else
        pesan.msg("~~~","~~~",2.5)
	end
end

function bmTp() -- Made By Opyy#????
    repeat wait() until game:IsLoaded() and game:GetService("Players")

    while wait() do
        if _G.settingsTable.toggle then
            if _G.settingsTable.item1 ~= "Select Items" or _G.settingsTable.item2 ~= "Select Items" or _G.settingsTable.allitem == true then
                if not game:GetService("Workspace").Stalls["Black Market"]:FindFirstChild("Grani") then
                    wait(1)
                    pesan.msg("Black Market Hop Notification!","Black Market Not Found", 2.5)
                    wait(1)
                    shop()
                end
                for i,v in pairs(game:GetService("Workspace").Stalls["Black Market"]:GetDescendants()) do
                    if v.ClassName == "MeshPart" and v.Name ~= "Grani" then
                        if _G.settingsTable.allitem == true then
                            pesan.msg("Black Market Hop Notification!","Found the Black Market\nItem Name : "..v.Name, 2.5)
                            wait(1)
                            tpto(v.CFrame)
                        elseif _G.settingsTable.allitem == false then
                            if _G.settingsTable.item1 ~= "Select Items" or _G.settingsTable.item1 ~= "Select Items" then
                                if v.Name == _G.settingsTable.item1 or v.Name == _G.settingsTable.item2 then
                                    pesan.msg("Black Market Hop Notification!","Found the Black Market\nItem Name : "..v.Name, 2.5)
                                    wait(1)
                                    tpto(v.CFrame)
                                elseif v.Name ~= _G.settingsTable.item1 and v.Name ~= _G.settingsTable.item2 then
                                    pesan.msg("Notification!","Found the Black Market\nBut the item is not the same as the one you choose\nItem Name : "..v.Name)
                                    wait(1)
                                    shop()
                                end
                            end
                        end
                    end
                end
            elseif _G.settingsTable.item1 == "Select Items" and _G.settingsTable.item2 == "Select Items" and _G.settingsTable.allitem == false then
                pesan.msg("Black Market Hop Notification!", "Select Items Or Turn On All Items Pls!", 2.5)
                return
            end
        end
    end 
end

function infPass() -- Made By Idk Who??
    while wait() do
        if getgenv().infpass then
            if getgenv().passitem ~= nil and getgenv().passitem ~= "Select Passive Items" then
                for i,v in pairs(plyr.Character.PassiveItems:GetChildren()) do
                    if v.ClassName == "Script" then
                        v:Destroy()
                    end
                end
                tpto(game:GetService("Workspace").Arsenals["Trading Sky"].Base.CFrame)
                game:GetService("ReplicatedStorage").Remotes.ItemSetup:FireServer(getgenv().passitem)
            else
                pesan.msg("Inf Passive Items Notification!", "Select Passive Items Pls!", 2.5)
                return
            end
        end
    end
end

function farmMob()
    local gOdMoDe
    gOdMoDe = hookmetamethod(game, "__namecall", function(self, ...)
        local method = getnamecallmethod()
        local args = {...}

        if not checkcaller() and self.Name == "Damage" and args[3] ~= nil and method == "FireServer" then
            return;
        end

        return gOdMoDe(self, ...)
    end)
    
    while task.wait() do
        if getgenv().farm then
            if getgenv().mob ~= nil and getgenv().mob ~= "Select Mob" then
                for x,EnemyName in pairs(game:GetService("ReplicatedStorage").Enemy:GetDescendants()) do
                    if EnemyName.Name == getgenv().mob then
                        for x,e in pairs(game:GetService("Workspace").Enemies:GetChildren()) do
                            for x, Enemy in pairs(e:GetChildren()) do
                                if Enemy.Name ~= "Tier" then
                                    if Enemy.Model.Value == EnemyName and getgenv().farm and getgenv().mob ~= "Select Mob" then
                                    tpto(Enemy.EnemyLocation.CFrame)
                                        wait(0.2)
                                        local Curr_Enemy = Enemy:FindFirstChild(tostring(Enemy.Model.Value), true)
                                        if Curr_Enemy then
                                            Enemy.CombatTrigger:FireServer("Solo")
                                            repeat
                                                local Curr_Enemy = Enemy:FindFirstChild(tostring(Enemy.Model.Value), true)
                                                game:GetService("ReplicatedStorage").Remotes.Damage:FireServer(Curr_Enemy, Curr_Weapon)
                                                wait(0.5);
                                            until Curr_Enemy == nil or not getgenv().farm or getgenv().mob == "Select Mob"
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            else
                pesan.msg("Farming Notification!","Select Mob Pls!", 2.5)
                return
            end
        end
    end
end

game.Workspace.ChildAdded:Connect(function(child)
    if child.ClassName == "Folder" and child.Name == "CombatFolder" then
        for x,v in pairs(child:GetChildren()) do
            if v.ClassName == "Folder" then
                v.ChildAdded:Connect(function(weapon)
                    Curr_Weapon = weapon;
                end)
            end
        end
    end;
end);

function materialFarm()
    while wait() do
        if getgenv().farmm then
            if getgenv().material ~= nil and getgenv().material ~= "Select Material" then
                for i,v in pairs(game:GetService("Workspace").MaterialGivers[getgenv().material]:GetDescendants()) do
                    if v.ClassName == "TouchTransmitter" then
                        firetouchinterest(plyr.Character.HumanoidRootPart, v.Parent, 0)
                        wait()
                        firetouchinterest(plyr.Character.HumanoidRootPart, v.Parent, 1)
                    end
                end                          
            else
                pesan.msg("Material Notification!!", "Select Material Pls!", 2.5)
                return
            end
        end
    end
end

function addStat()
    while wait() do
        if getgenv().stat then
            if getgenv().statlist ~= nil and getgenv().statlist ~= "Select Stats" then
                game:GetService("ReplicatedStorage").Remotes.StatsChange:FireServer(getgenv().statlist)
            else
                pesan.msg("Stats Notification!", "Select Stats Pls", 2.5)
                return
            end
        end
    end
end

game:GetService("Workspace").Stalls["Black Market"].ChildAdded:Connect(function(v)
    pesan.msg("Black Market Notification!", "Black Market Spawned", 2.5)
end)

game:GetService("Workspace").Stalls["Black Market"].ChildRemoved:Connect(function()
    pesan.msg("Black Market Notification!", "Black Market Despawned!", 2.5)  
end)

memuat()


-- // Library Ui \\ --
local library = loadstring(game:HttpGet("https://raw.githubusercontent.com/Rykyy/roblox/scripts/uilibrary.lua"))()
local window = library:CreateWindow("Critical Legends")
local bmhop = library:CreateWindow("BM Server Hop")
local teleports = library:CreateWindow("Character Teleports")

local farm = window:AddFolder("Auto Farm")
local material = window:AddFolder("Auto Collect Material")
local stats = window:AddFolder("Auto Stats")
local misc = window:AddFolder("Misc")

pesan.msg(gameName, "This Script Made By Rykyy#0001\n".."~~~"..plyr.DisplayName.."~~~ Thanks For Using My Script.", 10)

farm:AddList({text = "Mob List", values = mobTable , value = "Select Mob", flag = "mob_list", callback = function(selected)
    getgenv().mob = selected
end})

farm:AddToggle({text = "Enabled", state = false, flag = "enabled_f", callback = function(bool)
    getgenv().farm = bool

    if bool then
        farmMob()
    end
end})

farm:AddButton({text = "Collect Chest", callback = function()
    local chests = game.Workspace.Chests:GetChildren()
    for i,v in pairs(chests) do
        if not v:FindFirstChild("Open") then
            firetouchinterest(plyr.Character.HumanoidRootPart, v.Giver, 0)
            firetouchinterest(plyr.Character.HumanoidRootPart, v.Giver, 1)
        end
    end
end})

material:AddList({text = "Material List", values = materialTable , value = "Select Material", flag = "material_list", callback = function(selected)
    getgenv().material = selected
end})

material:AddToggle({text = "Collect", state = false , flag = "enabled_m", callback = function(bool)
    getgenv().farmm = bool
    
    if bool then
        materialFarm()
    end
end})


stats:AddList({text = "Stats List", values = {"Damage", "Shield", "Health", "Mana", "Magic"}, value = "Select Stats", flag = "stat_list", callback = function(selected)
    getgenv().statlist = selected
end})

stats:AddToggle({text = "Enabled", state = false, flag = "enabled_s", callback = function(bool)
    getgenv().stat = bool
    
    if bool then
        addStat()
    end
end})

misc:AddLabel({text = "~~Inf Passive Items"})

misc:AddList({text = "List of passive items you have", values = itemTable, value = "Select Passive Items", flag = "passiveitem_list", callback = function(selected)
    getgenv().passitem = selected

    if getgenv().passitem ~= "Shadow Fruit" and getgenv().passitem ~= "Heart Fruit" and getgenv().passitem ~= "Select Passive Items" then
        pesan.msg("Inf Passive Items Notification!", "It is recommended that you choose Shadow Fruit for damage and magic or heart fruit for health and mana", 5)
        pesan.msg("Inf Passive Items Notification!", "You Can Get Shadow Fruit And Heart Fruit On Chest\nDIO's Bone Not Recommended because it causes bugs", 5.5)
    end
end})

misc:AddToggle({text = "Enabled", state = false, flag = "enabled_p", callback = function(bool)
    getgenv().infpass = bool

    if getgenv().infpass and getgenv().passitem ~= nil and getgenv().passitem ~= "Select Passive Items" then
        pesan.msg("Infinity PassiveItem Notification!", "If you feel your stats are enough. Please Press Active Infinity Passive!", 30)
    end

    if bool then
        infPass()
    end    
end})

misc:AddButton({text = "Active Inf Passive Items", callback = function()
    if getgenv().passitem ~= nil and getgenv().passitem ~= "Select Passive Items" then
        pesan.msg("Inf Passive Items Notification!", "This function aims not to raise your level so that your infinity passive items can be used for a long time", 5)
        pesan.msg("Inf Passive Items Notification!", "If you want to level up, please exit the game and re-enter the game, then kill any mobs", 5)

        local old
        old = hookmetamethod(game,"__namecall",function(self,...)
        local method = getnamecallmethod()
        if method:lower() == "fireserver" and not checkcaller() then
            local args = {...}
            if (tostring(self) == "StatsChange" and args[1] == "Level") then
                return nil
            end
        end
        return old(self,...)
        end)
    end
end})

misc:AddLabel({text = "~~Players"})

misc:AddSlider({text = "WalkSpeed", min = 16, max = 250, value = 16, callback = function(s)
    plyr.Character.Humanoid.WalkSpeed = s
end})

misc:AddSlider({text = "JumpPower", min = 50, max = 250, value = 50, callback = function(s)
    plyr.Character.Humanoid.JumpPower = s
end})

misc:AddLabel({text = "~~Ui Settings"})

misc:AddBind({text = "Ui Toggle", key = Enum.KeyCode.RightAlt, callback = function()
    library:ToggleUi()
end})

misc:AddButton({text = "Destroy UI", callback = function()
    library:Close()
end})

teleports:AddList({text = "Statues", values = statuesTable, value = "Select Statues", flag = "statue_list", callback = function(selected)
    getgenv().statues = selected
end})

teleports:AddButton({text = "Tp To Statue", callback = function()

    if getgenv().statues ~= nil and getgenv().statues ~= "Select Statues" then
        for i,v in pairs(game:GetService("Workspace").Statues[getgenv().statues]:GetDescendants()) do
            if v.ClassName == "Attachment" then
                tpto(v.Parent.CFrame)
            end
        end
    else
        pesan.msg("Teleport Statues Notification!", "Select Statues Pls!", 2.5)
    end
end})

teleports:AddList({text = "Spawns", values = spawnsTable, value = "Select Spawns", flag = "spawn_list", callback = function(selected)
    getgenv().spawns = selected
end})

teleports:AddButton({text = "Tp To Spawns", callback = function()

    if getgenv().spawns ~= nil and getgenv().spawns ~= "Select Spawns" then
        tpto(game:GetService("Workspace").Spawns[getgenv().spawns].CFrame)
    else
        pesan.msg("Teleport Spawns Notification!", "Select Spawns Pls!", 2.5)
    end
end})

bmhop:AddList({text = "First Item", values = bmTable, value = _G.settingsTable.item1, flag = "item1_list", callback = function(selected)
    _G.settingsTable.item1 = selected
    menyimpan()
end})


bmhop:AddList({text = "Second Item", values = bmTable, value = _G.settingsTable.item2, flag = "item2_list", callback = function(selected)
    _G.settingsTable.item2 = selected
    menyimpan()
end})

bmhop:AddToggle({text = "All Items", state = _G.settingsTable.allitem, flag = "all_item", callback = function(bool)
    _G.settingsTable.allitem = bool
    menyimpan()
    if bool then
        pesan.msg("Black Market Hop Notification!", "If All Items is true then the items you selected does not work", 2.5)
    end
end})

bmhop:AddToggle({text = "Enabled", state = _G.settingsTable.toggle, flag = "enabled_x", callback = function(bool)
    _G.settingsTable.toggle = bool
    menyimpan()
    if bool then
        bmTp()
    end
end})

bmhop:AddButton({text = "Server Hop", callback = function() shop() end})

library:Init()
