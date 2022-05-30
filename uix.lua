    -- Wait game
    repeat wait() until game:IsLoaded() and game:GetService("Players").LocalPlayer:FindFirstChild("PlayerGui")

    -- Fix mouse icon
    game:GetService("UserInputService").MouseIconEnabled = true

    -- Anti AFK
    game:GetService("Players").LocalPlayer.Idled:connect(function()
        game:service("VirtualUser"):ClickButton2(Vector2.new())
    end)

    -- Variables
    local player = game:GetService("Players").LocalPlayer
    local mouse = player:GetMouse()
    local UserData = game:HttpGet("https://users.roblox.com/v1/users/".. player.UserId)

    local VirtualUser = game:service("VirtualUser")
    local input = game:GetService("UserInputService")
    local run = game:GetService("RunService")
    local tween = game:GetService("TweenService")
    local tweeninfo = TweenInfo.new

    local utility = {}

    -- Themes
    local objects = {}
    local themes


    do
        function utility:Create(instance, properties, children)
            local object = Instance.new(instance)
            
            for i, v in pairs(properties or {}) do
                object[i] = v
                
                if typeof(v) == "Color3" or v == themes.Transparency then -- save for theme changer later
                    local theme = utility:Find(themes, v)
                    
                    if theme then
                        objects[theme] = objects[theme] or {}
                        objects[theme][i] = objects[theme][i] or setmetatable({}, {_mode = "k"})
                        
                        table.insert(objects[theme][i], object)
                    end
                end
            end
            
            for i, module in pairs(children or {}) do
                module.Parent = object
            end
            
            return object
        end
        function utility:Tween(instance, properties, duration, ...)
            local Tween = tween:Create(instance, tweeninfo(duration, ...), properties)
            Tween:Play()
            return Tween
        end
        function utility:Wait()
            run.RenderStepped:Wait()
            return true
        end
        function utility:Find(table, value) -- table.find doesn't work for dictionaries
            for i, v in  pairs(table) do
                if v == value then
                    return i
                end
            end
        end
        function utility:Sort(pattern, values)
            local new = {}
            pattern = pattern:lower()
            
            if pattern == "" then
                return values
            end
            
            for i, value in pairs(values) do
                if tostring(value):lower():find(pattern) then
                    table.insert(new, value)
                end
            end
            
            return new
        end
        function utility:Pop(object, shrink)
            local clone = object:Clone()
            
            clone.AnchorPoint = Vector2.new(0.5, 0.5)
            clone.Size = clone.Size - UDim2.new(0, shrink, 0, shrink)
            clone.Position = UDim2.new(0.5, 0, 0.5, 0)
            
            clone.Parent = object
            clone:ClearAllChildren()
            
            object.ImageTransparency = 1
            utility:Tween(clone, {Size = object.Size}, 0.2)
            
            spawn(function()
                wait(0.2)
            
                object.ImageTransparency = themes.Transparency
                clone:Destroy()
            end)
            
            return clone
        end
        function utility:InitializeKeybind()
            self.keybinds = {}
            self.ended = {}
            
            input.InputBegan:Connect(function(key,proc)
                if self.keybinds[key.KeyCode] and not proc then
                    for i, bind in pairs(self.keybinds[key.KeyCode]) do
                        bind()
                    end
                end
            end)
            
            input.InputEnded:Connect(function(key)
                if key.UserInputType == Enum.UserInputType.MouseButton1 then
                    for i, callback in pairs(self.ended) do
                        callback()
                    end
                end
            end)
        end
        function utility:BindToKey(key, callback)
            
            self.keybinds[key] = self.keybinds[key] or {}
            
            table.insert(self.keybinds[key], callback)
            
            return {
                UnBind = function()
                    for i, bind in pairs(self.keybinds[key]) do
                        if bind == callback then
                            table.remove(self.keybinds[key], i)
                        end
                    end
                end
            }
        end
        function utility:KeyPressed() -- yield until next key is pressed
            local key = input.InputBegan:Wait()
            
            while key.UserInputType ~= Enum.UserInputType.Keyboard	 do
                key = input.InputBegan:Wait()
            end
            
            wait() -- overlapping connection
            
            return key
        end
        function utility:DraggingEnabled(frame, parent)
        
            parent = parent or frame
            
            -- stolen from wally or kiriot, kek
            local dragging = false
            local dragInput, mousePos, framePos

            frame.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    dragging = true
                    mousePos = input.Position
                    framePos = parent.Position
                    
                    input.Changed:Connect(function()
                        if input.UserInputState == Enum.UserInputState.End then
                            dragging = false
                        end
                    end)
                end
            end)

            frame.InputChanged:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseMovement then
                    dragInput = input
                end
            end)

            input.InputChanged:Connect(function(input)
                if input == dragInput and dragging then
                    local delta = input.Position - mousePos
                    parent.Position  = UDim2.new(framePos.X.Scale, framePos.X.Offset + delta.X, framePos.Y.Scale, framePos.Y.Offset + delta.Y)
                end
            end)

        end
        function utility:DraggingEnded(callback)
            table.insert(self.ended, callback)
        end
        function utility:colorToHex(color)
            local int = math.floor(color.r * 255) * 256 ^ 2 + math.floor(color.g * 255) * 256 + math.floor(color.b * 255)
            local current = int
            local final = ""
            local hexChar = {
                "A",
                "B",
                "C",
                "D",
                "E",
                "F",
            }
            repeat
                local remainder = current % 16
                local char = tostring(remainder)
                if remainder >= 10 then
                    char = hexChar[1 + remainder - 10]
                end
                current = math.floor(current / 16)
                final = final .. char
            until current <= 0
            return "#" .. string.reverse(final)
        end

        function utility:TextEffect(TextLabel, delay)
            TextLabel.Visible = true
            local displayText = TextLabel.Text
            displayText = displayText:gsub("<br%s*/>", "\n")
            displayText:gsub("<[^<>]->", "")
            local index = 0
            for i, v in utf8.graphemes(displayText) do
                index = index + 1
                TextLabel.MaxVisibleGraphemes = index
                task.wait(delay)
            end
        end

    end

    -- classes
    local UI
    local library = {
        Icons = {
            ["activity"] = "rbxassetid://7733655755",
            ["add"] = "rbxassetid://3944675151",
            ["add-circle"] = "rbxassetid://3605017115",
            ["AED"] = "rbxassetid://4370336019",
            ["airplane"] = "rbxassetid://4483363527",
            ["airplay"] = "rbxassetid://7733655834",
            ["alarm-check"] = "rbxassetid://7733655912",
            ["alarm-clock"] = "rbxassetid://7733656100",
            ["alarm-clock-off"] = "rbxassetid://7733656003",
            ["alarm-minus"] = "rbxassetid://7733656164",
            ["alarm-plus"] = "rbxassetid://7733658066",
            ["album"] = "rbxassetid://7733658133",
            ["album-2"] = "rbxassetid://4400695581",
            ["alert"] = "rbxassetid://4370336704",
            ["alert-circle"] = "rbxassetid://7733658271",
            ["alert-octagon"] = "rbxassetid://7733658335",
            ["alert-triangle"] = "rbxassetid://7733658504",
            ["align-center"] = "rbxassetid://7733909776",
            ["align-justify"] = "rbxassetid://7733661326",
            ["align-left"] = "rbxassetid://7733911357",
            ["align-right"] = "rbxassetid://7733663582",
            ["anchor"] = "rbxassetid://7733911490",
            ["android"] = "rbxassetid://3944664684",
            ["android-head"] = "rbxassetid://4450736564",
            ["aperture"] = "rbxassetid://7733666258",
            ["apps"] = "rbxassetid://4483364237",
            ["archive"] = "rbxassetid://7733911621",
            ["arrow-big-down"] = "rbxassetid://7733668653",
            ["arrow-big-left"] = "rbxassetid://7733911731",
            ["arrow-big-right"] = "rbxassetid://7733671493",
            ["arrow-big-up"] = "rbxassetid://7733671663",
            ["arrow-down"] = "rbxassetid://7733672933",
            ["arrow-down-circle"] = "rbxassetid://7733671763",
            ["arrow-down-left"] = "rbxassetid://7733672282",
            ["arrow-down-right"] = "rbxassetid://7733672831",
            ["arrow-left"] = "rbxassetid://7733673136",
            ["arrow-left-circle"] = "rbxassetid://7733673056",
            ["arrow-right"] = "rbxassetid://7733673345",
            ["arrow-right-circle"] = "rbxassetid://7733673229",
            ["arrow-up"] = "rbxassetid://7733673717",
            ["arrow-up-circle"] = "rbxassetid://7733673466",
            ["arrow-up-left"] = "rbxassetid://7733673539",
            ["arrow-up-right"] = "rbxassetid://7733673646",
            ["asterisk"] = "rbxassetid://7733673800",
            ["at-sign"] = "rbxassetid://7733673907",
            ["attachment"] = "rbxassetid://4483345278",
            ["award"] = "rbxassetid://7733673987",
            ["axe"] = "rbxassetid://7733674079",
            ["back"] = "rbxassetid://4370337241",
            ["backspace"] = "rbxassetid://4483345463",
            ["backup"] = "rbxassetid://4335477481",
            ["backup-restore"] = "rbxassetid://4400696294",
            ["banknote"] = "rbxassetid://7733674153",
            ["bar-chart"] = "rbxassetid://7733674319",
            ["bar-chart-2"] = "rbxassetid://7733674239",
            ["barcode"] = "rbxassetid://4384394779",
            ["battery"] = "rbxassetid://7733674820",
            ["battery-charging"] = "rbxassetid://7733674402",
            ["battery-full"] = "rbxassetid://7733674503",
            ["battery-low"] = "rbxassetid://7733674589",
            ["battery-medium"] = "rbxassetid://7733674731",
            ["beaker"] = "rbxassetid://7733674922",
            ["bell"] = "rbxassetid://7733911828",
            ["bell-minus"] = "rbxassetid://7733675028",
            ["bell-off"] = "rbxassetid://7733675107",
            ["bell-plus"] = "rbxassetid://7733675181",
            ["bell-ring"] = "rbxassetid://7733675275",
            ["bike"] = "rbxassetid://7733678330",
            ["binary"] = "rbxassetid://7733678388",
            ["block"] = "rbxassetid://3944675664",
            ["bluetooth"] = "rbxassetid://7733687147",
            ["bluetooth-connected"] = "rbxassetid://7734110952",
            ["bluetooth-off"] = "rbxassetid://7733914252",
            ["bluetooth-searching"] = "rbxassetid://7733914320",
            ["blur"] = "rbxassetid://4400696929",
            ["blur-linear"] = "rbxassetid://4400698359",
            ["blur-off"] = "rbxassetid://4400697855",
            ["blur-radial"] = "rbxassetid://4400698963",
            ["book"] = "rbxassetid://7733914390",
            ["book-2"] = "rbxassetid://4330060040",
            ["book-open"] = "rbxassetid://7733687281",
            ["bookmark"] = "rbxassetid://7733692043",
            ["bookmark-2"] = "rbxassetid://3605522284",
            ["bookmark-minus"] = "rbxassetid://7733689754",
            ["bookmark-plus"] = "rbxassetid://7734111084",
            ["border-all"] = "rbxassetid://4483364408",
            ["bot"] = "rbxassetid://7733916988",
            ["box"] = "rbxassetid://7733917120",
            ["box-select"] = "rbxassetid://7733696665",
            ["briefcase"] = "rbxassetid://7733919017",
            ["brush"] = "rbxassetid://7733701455",
            ["bug"] = "rbxassetid://7733701545",
            ["building"] = "rbxassetid://7733701625",
            ["bus"] = "rbxassetid://7733701715",
            ["calculator"] = "rbxassetid://7733919105",
            ["calendar"] = "rbxassetid://7733919198",
            ["camera"] = "rbxassetid://7733708692",
            ["camera-off"] = "rbxassetid://7733919260",
            ["cancel"] = "rbxassetid://4400699701",
            ["candle"] = "rbxassetid://4483345607",
            ["car"] = "rbxassetid://7733708835",
            ["cast"] = "rbxassetid://7733919326",
            ["CD"] = "rbxassetid://7734110220",
            ["cellphone"] = "rbxassetid://4384403999",
            ["charging"] = "rbxassetid://4370338095",
            ["check"] = "rbxassetid://7733715400",
            ["check-circle"] = "rbxassetid://7733919427",
            ["check-circle-2"] = "rbxassetid://7733710700",
            ["check-square"] = "rbxassetid://7733919526",
            ["chevron-down"] = "rbxassetid://7733717447",
            ["chevron-left"] = "rbxassetid://7733717651",
            ["chevron-right"] = "rbxassetid://7733717755",
            ["chevron-up"] = "rbxassetid://7733919605",
            ["chevrons-down"] = "rbxassetid://7733720604",
            ["chevrons-down-up"] = "rbxassetid://7733720483",
            ["chevrons-left"] = "rbxassetid://7733720701",
            ["chevrons-right"] = "rbxassetid://7733919682",
            ["chevrons-up"] = "rbxassetid://7733723433",
            ["chevrons-up-down"] = "rbxassetid://7733723321",
            ["chrome"] = "rbxassetid://7733919783",
            ["circle"] = "rbxassetid://7733919881",
            ["clear"] = "rbxassetid://3944676352",
            ["clipboard"] = "rbxassetid://7733734762",
            ["clipboard-check"] = "rbxassetid://7733919947",
            ["clipboard-list"] = "rbxassetid://7733920117",
            ["clipboard-x"] = "rbxassetid://7733734668",
            ["clock"] = "rbxassetid://7733734848",
            ["cloud"] = "rbxassetid://7733746980",
            ["cloud-2"] = "rbxassetid://4384402413",
            ["cloud-alert"] = "rbxassetid://4384402990",
            ["cloud-check"] = "rbxassetid://4384403532",
            ["cloud-drizzle"] = "rbxassetid://7733920226",
            ["cloud-fog"] = "rbxassetid://7733920317",
            ["cloud-hail"] = "rbxassetid://7733920444",
            ["cloud-lightning"] = "rbxassetid://7733741741",
            ["cloud-moon"] = "rbxassetid://7733920519",
            ["cloud-off"] = "rbxassetid://7733745572",
            ["cloud-rain"] = "rbxassetid://7733746651",
            ["cloud-rain-wind"] = "rbxassetid://7733746456",
            ["cloud-snow"] = "rbxassetid://7733746798",
            ["cloud-sun"] = "rbxassetid://7733746880",
            ["clover"] = "rbxassetid://7733747233",
            ["code"] = "rbxassetid://7733749837",
            ["code-2"] = "rbxassetid://7733920644",
            ["codepen"] = "rbxassetid://7733920768",
            ["codesandbox"] = "rbxassetid://7733752575",
            ["coffee"] = "rbxassetid://7733752630",
            ["cogs"] = "rbxassetid://4483345737",
            ["coins"] = "rbxassetid://7743866529",
            ["coins-2"] = "rbxassetid://4483345875",
            ["columns"] = "rbxassetid://7733757178",
            ["command"] = "rbxassetid://7733924046",
            ["commute"] = "rbxassetid://4335478275",
            ["compare"] = "rbxassetid://4483363084",
            ["compass"] = "rbxassetid://7733924216",
            ["contact"] = "rbxassetid://7743866666",
            ["contacts"] = "rbxassetid://4384401919",
            ["contrast"] = "rbxassetid://7733764005",
            ["copy"] = "rbxassetid://7733764083",
            ["copyleft"] = "rbxassetid://7733764196",
            ["copyright"] = "rbxassetid://7733764275",
            ["copyright-2"] = "rbxassetid://3944676934",
            ["corner-down-left"] = "rbxassetid://7733764327",
            ["corner-down-right"] = "rbxassetid://7733764385",
            ["corner-left-down"] = "rbxassetid://7733764448",
            ["corner-left-up"] = "rbxassetid://7733764536",
            ["corner-right-down"] = "rbxassetid://7733764605",
            ["corner-right-up"] = "rbxassetid://7733764680",
            ["corner-up-left"] = "rbxassetid://7733764800",
            ["corner-up-right"] = "rbxassetid://7733764915",
            ["cpu"] = "rbxassetid://7733765045",
            ["create"] = "rbxassetid://3944677737",
            ["creation"] = "rbxassetid://4483362748",
            ["crop"] = "rbxassetid://7733765140",
            ["cross"] = "rbxassetid://7733765224",
            ["crosshair"] = "rbxassetid://7733765307",
            ["crosshairs"] = "rbxassetid://4483345998",
            ["crown"] = "rbxassetid://7733765398",
            ["cube-scan"] = "rbxassetid://4483362458",
            ["currency"] = "rbxassetid://7733765592",
            ["database"] = "rbxassetid://7743866778",
            ["delete"] = "rbxassetid://7733768142",
            ["delete-2"] = "rbxassetid://4483361337",
            ["delete-outline"] = "rbxassetid://4483362299",
            ["delta"] = "rbxassetid://4400700924",
            ["diskette"] = "rbxassetid://7072729672",
            ["divide"] = "rbxassetid://7733769365",
            ["divide-circle"] = "rbxassetid://7733769152",
            ["divide-square"] = "rbxassetid://7733769261",
            ["dollar-sign"] = "rbxassetid://7733770599",
            ["dollar-sign-2"] = "rbxassetid://4400700509",
            ["done"] = "rbxassetid://3944680095",
            ["dots-horizontal"] = "rbxassetid://4384401360",
            ["download"] = "rbxassetid://7733770755",
            ["download-cloud"] = "rbxassetid://7733770689",
            ["dribbble"] = "rbxassetid://7733770843",
            ["droplet"] = "rbxassetid://7733770982",
            ["droplets"] = "rbxassetid://7733771078",
            ["edit"] = "rbxassetid://7733771472",
            ["edit-2"] = "rbxassetid://7733771217",
            ["edit-3"] = "rbxassetid://7733771361",
            ["edit-4"] = "rbxassetid://4370186570",
            ["electricity"] = "rbxassetid://7733771628",
            ["electricity-off"] = "rbxassetid://7733771563",
            ["equal"] = "rbxassetid://7733771811",
            ["equal-not"] = "rbxassetid://7733771726",
            ["equalizer"] = "rbxassetid://4384400812",
            ["error"] = "rbxassetid://3944669799",
            ["euro"] = "rbxassetid://7733771891",
            ["expand"] = "rbxassetid://7733771982",
            ["explore"] = "rbxassetid://4335479121",
            ["explore-off"] = "rbxassetid://4335479658",
            ["export"] = "rbxassetid://4400701343",
            ["extension"] = "rbxassetid://4335480353",
            ["external-link"] = "rbxassetid://7743866903",
            ["eye"] = "rbxassetid://7733774602",
            ["eye-off"] = "rbxassetid://7733774495",
            ["face"] = "rbxassetid://4335480896",
            ["face-id"] = "rbxassetid://4370335364",
            ["fast-forward"] = "rbxassetid://7743867090",
            ["favorite"] = "rbxassetid://4370033185",
            ["favorite-border"] = "rbxassetid://4335482118",
            ["feather"] = "rbxassetid://7733777166",
            ["figma"] = "rbxassetid://7743867310",
            ["file"] = "rbxassetid://7733793319",
            ["file-check"] = "rbxassetid://7733779668",
            ["file-check-2"] = "rbxassetid://7733779610",
            ["file-code"] = "rbxassetid://7733779730",
            ["file-digit"] = "rbxassetid://7733935829",
            ["file-input"] = "rbxassetid://7733935917",
            ["file-minus"] = "rbxassetid://7733936115",
            ["file-minus-2"] = "rbxassetid://7733936010",
            ["file-output"] = "rbxassetid://7733788742",
            ["file-plus"] = "rbxassetid://7733788885",
            ["file-plus-2"] = "rbxassetid://7733788816",
            ["file-search"] = "rbxassetid://7733788966",
            ["file-text"] = "rbxassetid://7733789088",
            ["file-x"] = "rbxassetid://7733938136",
            ["file-x-2"] = "rbxassetid://7743867554",
            ["files"] = "rbxassetid://7743867811",
            ["film"] = "rbxassetid://7733942579",
            ["filter"] = "rbxassetid://7733798407",
            ["filter_sort"] = "rbxassetid://4370342507",
            ["fingerprint"] = "rbxassetid://3944703587",
            ["flag"] = "rbxassetid://7733798691",
            ["flag-2"] = "rbxassetid://3944688398",
            ["flag-triangle-left"] = "rbxassetid://7733798509",
            ["flag-triangle-right"] = "rbxassetid://7733798634",
            ["flame"] = "rbxassetid://7733798747",
            ["flashlight"] = "rbxassetid://7733798851",
            ["flashlight-off"] = "rbxassetid://7733798799",
            ["flask-conical"] = "rbxassetid://7733798901",
            ["flask-round"] = "rbxassetid://7733798957",
            ["flower"] = "rbxassetid://4483346149",
            ["folder"] = "rbxassetid://7733799185",
            ["folder-minus"] = "rbxassetid://7733799022",
            ["folder-plus"] = "rbxassetid://7733799092",
            ["forest"] = "rbxassetid://4370343755",
            ["form-input"] = "rbxassetid://7733799275",
            ["forward"] = "rbxassetid://7733799371",
            ["framer"] = "rbxassetid://7733799486",
            ["frown"] = "rbxassetid://7733799591",
            ["function-square"] = "rbxassetid://7733799682",
            ["gamepad"] = "rbxassetid://7733799901",
            ["gamepad-2"] = "rbxassetid://7733799795",
            ["gamepad-3"] = "rbxassetid://4384396122",
            ["gamepad-circle"] = "rbxassetid://4384396714",
            ["gauge"] = "rbxassetid://7733799969",
            ["gavel"] = "rbxassetid://7733800044",
            ["gem"] = "rbxassetid://7733942651",
            ["ghost"] = "rbxassetid://7743868000",
            ["GIF"] = "rbxassetid://3610246221",
            ["gift"] = "rbxassetid://7733946818",
            ["gift-2"] = "rbxassetid://4370344279",
            ["gift-card"] = "rbxassetid://7733945018",
            ["git-branch"] = "rbxassetid://7733949149",
            ["git-branch-plus"] = "rbxassetid://7743868200",
            ["git-commit"] = "rbxassetid://7743868360",
            ["git-merge"] = "rbxassetid://7733952195",
            ["git-pull-request"] = "rbxassetid://7733952287",
            ["github"] = "rbxassetid://7733954058",
            ["gitlab"] = "rbxassetid://7733954246",
            ["glasses"] = "rbxassetid://7733954403",
            ["globe"] = "rbxassetid://7733954760",
            ["globe-2"] = "rbxassetid://7733954611",
            ["globe-3"] = "rbxassetid://4370344717",
            ["grab"] = "rbxassetid://7733954884",
            ["grade"] = "rbxassetid://4335482575",
            ["graduation-cap"] = "rbxassetid://7733955058",
            ["grid"] = "rbxassetid://7733955179",
            ["grip-horizontal"] = "rbxassetid://7733955302",
            ["grip-vertical"] = "rbxassetid://7733955410",
            ["hammer"] = "rbxassetid://7733955511",
            ["hand"] = "rbxassetid://7733955740",
            ["hand-metal"] = "rbxassetid://7733955664",
            ["hard-drive"] = "rbxassetid://7733955793",
            ["hard-hat"] = "rbxassetid://7733955850",
            ["hash"] = "rbxassetid://7733955906",
            ["haze"] = "rbxassetid://7733955969",
            ["headphones"] = "rbxassetid://7733956063",
            ["heart"] = "rbxassetid://7733956134",
            ["heart-pulse"] = "rbxassetid://4483346354",
            ["help-circle"] = "rbxassetid://7733956210",
            ["hexagon"] = "rbxassetid://7743868527",
            ["highlighter"] = "rbxassetid://7743868648",
            ["history"] = "rbxassetid://7733960880",
            ["home"] = "rbxassetid://7733960981",
            ["home-2"] = "rbxassetid://4370345144",
            ["http"] = "rbxassetid://3610248649",
            ["image"] = "rbxassetid://7733964126",
            ["image-minus"] = "rbxassetid://7733963797",
            ["image-off"] = "rbxassetid://7733963907",
            ["image-plus"] = "rbxassetid://7733964016",
            ["import"] = "rbxassetid://7733964240",
            ["inbox"] = "rbxassetid://7733964370",
            ["indent"] = "rbxassetid://7733964452",
            ["indian-rupee"] = "rbxassetid://7733964536",
            ["infinity"] = "rbxassetid://7733964640",
            ["infinity-2"] = "rbxassetid://4370345701",
            ["info"] = "rbxassetid://7733964719",
            ["inspect"] = "rbxassetid://7733964808",
            ["italic"] = "rbxassetid://7733964917",
            ["jersey-pound"] = "rbxassetid://7733965029",
            ["key"] = "rbxassetid://7733965118",
            ["king"] = "rbxassetid://4370316039",
            ["knight"] = "rbxassetid://4370316596",
            ["landmark"] = "rbxassetid://7733965184",
            ["language"] = "rbxassetid://3610245066",
            ["languages"] = "rbxassetid://7733965249",
            ["laptop"] = "rbxassetid://7733965386",
            ["laptop-2"] = "rbxassetid://7733965313",
            ["lasso"] = "rbxassetid://7733967892",
            ["lasso-select"] = "rbxassetid://7743868832",
            ["layers"] = "rbxassetid://7743868936",
            ["layers-2"] = "rbxassetid://4384400106",
            ["layout"] = "rbxassetid://7733970543",
            ["layout-dashboard"] = "rbxassetid://7733970318",
            ["layout-grid"] = "rbxassetid://7733970390",
            ["layout-list"] = "rbxassetid://7733970442",
            ["layout-template"] = "rbxassetid://7733970494",
            ["library"] = "rbxassetid://7743869054",
            ["life-buoy"] = "rbxassetid://7733973479",
            ["lightbulb"] = "rbxassetid://7733975185",
            ["lightbulb-off"] = "rbxassetid://7733975123",
            ["link"] = "rbxassetid://7733978098",
            ["link-2"] = "rbxassetid://7743869163",
            ["link-2-off"] = "rbxassetid://7733975283",
            ["link-3"] = "rbxassetid://4503342956",
            ["link-off"] = "rbxassetid://3944689656",
            ["list"] = "rbxassetid://7743869612",
            ["list-checks"] = "rbxassetid://7743869317",
            ["list-minus"] = "rbxassetid://7733980795",
            ["list-ordered"] = "rbxassetid://7743869411",
            ["list-plus"] = "rbxassetid://7733984995",
            ["list-x"] = "rbxassetid://7743869517",
            ["loader"] = "rbxassetid://7733992358",
            ["loader-2"] = "rbxassetid://7733989869",
            ["locate"] = "rbxassetid://7733992469",
            ["locate-fixed"] = "rbxassetid://7733992424",
            ["lock"] = "rbxassetid://7733992528",
            ["lock-2"] = "rbxassetid://3610239960",
            ["lock-open"] = "rbxassetid://3610242099",
            ["log-in"] = "rbxassetid://7733992604",
            ["log-out"] = "rbxassetid://7733992677",
            ["mail"] = "rbxassetid://7733992732",
            ["map"] = "rbxassetid://7733992829",
            ["map-pin"] = "rbxassetid://7733992789",
            ["maximize"] = "rbxassetid://7733992982",
            ["maximize-2"] = "rbxassetid://7733992901",
            ["megaphone"] = "rbxassetid://7733993049",
            ["meh"] = "rbxassetid://7733993147",
            ["memory"] = "rbxassetid://4384394237",
            ["menu"] = "rbxassetid://7733993211",
            ["menu-2"] = "rbxassetid://4370318685",
            ["menu-four"] = "rbxassetid://4370319235",
            ["message-circle"] = "rbxassetid://7733993311",
            ["message-square"] = "rbxassetid://7733993369",
            ["mic"] = "rbxassetid://7743869805",
            ["mic-off"] = "rbxassetid://7743869714",
            ["minimize"] = "rbxassetid://7733997941",
            ["minimize-2"] = "rbxassetid://7733997870",
            ["minus"] = "rbxassetid://7734000129",
            ["minus-circle"] = "rbxassetid://7733998053",
            ["minus-square"] = "rbxassetid://7743869899",
            ["monitor"] = "rbxassetid://7734002839",
            ["monitor-off"] = "rbxassetid://7734000184",
            ["monitor-speaker"] = "rbxassetid://7743869988",
            ["moon"] = "rbxassetid://7743870134",
            ["more-horizontal"] = "rbxassetid://7734006080",
            ["more-vertical"] = "rbxassetid://7734006187",
            ["mountain"] = "rbxassetid://7734008868",
            ["mountain-snow"] = "rbxassetid://7743870286",
            ["mouse-pointer"] = "rbxassetid://7743870392",
            ["mouse-pointer-2"] = "rbxassetid://7734010405",
            ["mouse-pointer-click"] = "rbxassetid://7734010488",
            ["move"] = "rbxassetid://7743870731",
            ["move-diagonal"] = "rbxassetid://7743870505",
            ["move-diagonal-2"] = "rbxassetid://7734013178",
            ["move-horizontal"] = "rbxassetid://7734016210",
            ["move-vertical"] = "rbxassetid://7743870608",
            ["music"] = "rbxassetid://7734020554",
            ["navigation"] = "rbxassetid://7734020989",
            ["navigation-2"] = "rbxassetid://7734020942",
            ["network"] = "rbxassetid://7734021047",
            ["notification"] = "rbxassetid://3944670656",
            ["octagon"] = "rbxassetid://7734021165",
            ["on-charge"] = "rbxassetid://7734021231",
            ["online"] = "rbxassetid://4370317928",
            ["opacity"] = "rbxassetid://4335483334",
            ["option"] = "rbxassetid://7734021300",
            ["outdent"] = "rbxassetid://7734021384",
            ["package"] = "rbxassetid://7734021469",
            ["paint"] = "rbxassetid://4384393547",
            ["palette"] = "rbxassetid://7734021595",
            ["palette-2"] = "rbxassetid://4335483762",
            ["palette-swatch"] = "rbxassetid://4400704299",
            ["palm-scan"] = "rbxassetid://4370334869",
            ["paperclip"] = "rbxassetid://7734021680",
            ["pause"] = "rbxassetid://7734021897",
            ["pause-circle"] = "rbxassetid://7734021767",
            ["pause-octagon"] = "rbxassetid://7734021827",
            ["pen-tool"] = "rbxassetid://7734022041",
            ["pencil"] = "rbxassetid://7734022107",
            ["percent"] = "rbxassetid://7743870852",
            ["person-standing"] = "rbxassetid://7743871002",
            ["pets"] = "rbxassetid://3610237052",
            ["phone"] = "rbxassetid://7734032056",
            ["phone-2"] = "rbxassetid://4506892591",
            ["phone-call"] = "rbxassetid://7734027264",
            ["phone-forwarded"] = "rbxassetid://7734027345",
            ["phone-incoming"] = "rbxassetid://7743871120",
            ["phone-missed"] = "rbxassetid://7734029465",
            ["phone-off"] = "rbxassetid://7734029534",
            ["phone-outgoing"] = "rbxassetid://7743871253",
            ["photo-camera"] = "rbxassetid://4335484343",
            ["pie-chart"] = "rbxassetid://7734034378",
            ["piggy-bank"] = "rbxassetid://7734034513",
            ["pin"] = "rbxassetid://4384392959",
            ["pipette"] = "rbxassetid://7743871384",
            ["plane"] = "rbxassetid://7734037723",
            ["play"] = "rbxassetid://7743871480",
            ["play-circle"] = "rbxassetid://7734037784",
            ["plus"] = "rbxassetid://7734042071",
            ["plus-circle"] = "rbxassetid://7734040271",
            ["plus-square"] = "rbxassetid://7734040369",
            ["pocket"] = "rbxassetid://7734042139",
            ["podcast"] = "rbxassetid://7734042234",
            ["pointer"] = "rbxassetid://7734042307",
            ["pound-sterling"] = "rbxassetid://7734042354",
            ["power"] = "rbxassetid://7734042493",
            ["power-off"] = "rbxassetid://7734042423",
            ["print"] = "rbxassetid://4377193226",
            ["printer"] = "rbxassetid://7734042580",
            ["qr-code"] = "rbxassetid://7743871575",
            ["QRcode-scan"] = "rbxassetid://4384395384",
            ["quote"] = "rbxassetid://7734045100",
            ["radar"] = "rbxassetid://4384392464",
            ["radio"] = "rbxassetid://7743871662",
            ["radio-2"] = "rbxassetid://4370305054",
            ["radio-receiver"] = "rbxassetid://7734045155",
            ["radio-tower"] = "rbxassetid://4370305588",
            ["redo"] = "rbxassetid://7743871739",
            ["redo-2"] = "rbxassetid://3944702361",
            ["refresh"] = "rbxassetid://4335476290",
            ["refresh-ccw"] = "rbxassetid://7734050715",
            ["refresh-cw"] = "rbxassetid://7734051052",
            ["regex"] = "rbxassetid://7734051188",
            ["remove"] = "rbxassetid://4370317406",
            ["repeat"] = "rbxassetid://7734051454",
            ["repeat-1"] = "rbxassetid://7734051342",
            ["reply"] = "rbxassetid://7734051594",
            ["reply-2"] = "rbxassetid://3944691398",
            ["reply-all"] = "rbxassetid://7734051524",
            ["reply-all-2"] = "rbxassetid://3944691867",
            ["restart"] = "rbxassetid://4370306254",
            ["rewind"] = "rbxassetid://7734051670",
            ["rhombus"] = "rbxassetid://4384405947",
            ["rocking-chair"] = "rbxassetid://7734051769",
            ["rotate-90"] = "rbxassetid://4384406773",
            ["rotate-ccw"] = "rbxassetid://7734051861",
            ["rotate-cw"] = "rbxassetid://7734051957",
            ["rss"] = "rbxassetid://7734052075",
            ["ruler"] = "rbxassetid://7734052157",
            ["russian-ruble"] = "rbxassetid://7734052248",
            ["save"] = "rbxassetid://7734052335",
            ["scale"] = "rbxassetid://7734052454",
            ["schedule"] = "rbxassetid://4335484884",
            ["scissors"] = "rbxassetid://7734052570",
            ["screen-share"] = "rbxassetid://7734052814",
            ["screen-share-off"] = "rbxassetid://7734052653",
            ["search"] = "rbxassetid://7734052925",
            ["search-2"] = "rbxassetid://3605509925",
            ["send"] = "rbxassetid://7734053039",
            ["send-2"] = "rbxassetid://3944690667",
            ["separator-horizontal"] = "rbxassetid://7734053146",
            ["separator-vertical"] = "rbxassetid://7734053213",
            ["server"] = "rbxassetid://7734053426",
            ["server-crash"] = "rbxassetid://7734053281",
            ["server-off"] = "rbxassetid://7734053361",
            ["settings"] = "rbxassetid://7734053495",
            ["settings-2"] = "rbxassetid://3605022185",
            ["share"] = "rbxassetid://7734053697",
            ["share-2"] = "rbxassetid://7734053595",
            ["sheet"] = "rbxassetid://7743871876",
            ["shield"] = "rbxassetid://7734056608",
            ["shield-alert"] = "rbxassetid://7734056326",
            ["shield-check"] = "rbxassetid://7734056411",
            ["shield-close"] = "rbxassetid://7734056470",
            ["shield-off"] = "rbxassetid://7734056540",
            ["shirt"] = "rbxassetid://7734056672",
            ["shopping-bag"] = "rbxassetid://7734056747",
            ["shopping-cart"] = "rbxassetid://7734056813",
            ["shovel"] = "rbxassetid://7734056878",
            ["shrink"] = "rbxassetid://7734056971",
            ["shuffle"] = "rbxassetid://7734057059",
            ["sidebar"] = "rbxassetid://7734058260",
            ["sidebar-close"] = "rbxassetid://7734058092",
            ["sidebar-open"] = "rbxassetid://7734058165",
            ["sigma"] = "rbxassetid://7734058345",
            ["skip-back"] = "rbxassetid://7734058404",
            ["skip-forward"] = "rbxassetid://7734058495",
            ["skip-next"] = "rbxassetid://4384407160",
            ["skip-previous"] = "rbxassetid://4384407582",
            ["skull"] = "rbxassetid://7734058599",
            ["slack"] = "rbxassetid://7072722471",
            ["slash"] = "rbxassetid://7072722603",
            ["sliders"] = "rbxassetid://7734058803",
            ["smartphone"] = "rbxassetid://7734058979",
            ["smartphone-charging"] = "rbxassetid://7734058894",
            ["smile"] = "rbxassetid://7734059095",
            ["snowflake"] = "rbxassetid://7734059180",
            ["snowflake-2"] = "rbxassetid://4384392025",
            ["sort"] = "rbxassetid://3944704135",
            ["sort-asc"] = "rbxassetid://7734060715",
            ["sort-desc"] = "rbxassetid://7743871973",
            ["speaker"] = "rbxassetid://7734063416",
            ["speech"] = "rbxassetid://4370313618",
            ["sprout"] = "rbxassetid://7743872071",
            ["square"] = "rbxassetid://7743872181",
            ["stack"] = "rbxassetid://4370346095",
            ["star"] = "rbxassetid://7734068321",
            ["star-half"] = "rbxassetid://7734068258",
            ["stop-circle"] = "rbxassetid://7734068379",
            ["strikethrough"] = "rbxassetid://7734068425",
            ["sun"] = "rbxassetid://7734068495",
            ["sunrise"] = "rbxassetid://7743872365",
            ["sunset"] = "rbxassetid://7734070982",
            ["swiss-franc"] = "rbxassetid://7734071038",
            ["switch"] = "rbxassetid://4400702457",
            ["switch-camera"] = "rbxassetid://7743872492",
            ["switch-off"] = "rbxassetid://4400702947",
            ["synchronize"] = "rbxassetid://4370226511",
            ["table"] = "rbxassetid://7734073253",
            ["tablet"] = "rbxassetid://7743872620",
            ["tag"] = "rbxassetid://7734075797",
            ["target"] = "rbxassetid://7743872758",
            ["taxi"] = "rbxassetid://4506892784",
            ["tent"] = "rbxassetid://7734078943",
            ["terminal"] = "rbxassetid://7743872929",
            ["terminal-square"] = "rbxassetid://7734079055",
            ["texture"] = "rbxassetid://4335485422",
            ["thermometer"] = "rbxassetid://7734084149",
            ["thermometer-snowflake"] = "rbxassetid://7743873074",
            ["thermometer-sun"] = "rbxassetid://7734084018",
            ["thumbs-down"] = "rbxassetid://7734084236",
            ["thumbs-up"] = "rbxassetid://7743873212",
            ["ticket"] = "rbxassetid://7734086558",
            ["timer"] = "rbxassetid://7743873443",
            ["timer-2"] = "rbxassetid://4335485957",
            ["timer-off"] = "rbxassetid://4335486524",
            ["timer-reset"] = "rbxassetid://7743873336",
            ["toggle-left"] = "rbxassetid://7734091286",
            ["toggle-right"] = "rbxassetid://7743873539",
            ["tonality"] = "rbxassetid://4335487169",
            ["tool"] = "rbxassetid://7072723685",
            ["tornado"] = "rbxassetid://7743873633",
            ["transform"] = "rbxassetid://4335487866",
            ["translate"] = "rbxassetid://4335488543",
            ["trash"] = "rbxassetid://7743873871",
            ["trash-2"] = "rbxassetid://7743873772",
            ["trello"] = "rbxassetid://7743873996",
            ["trend-down"] = "rbxassetid://3944704985",
            ["trend-flat"] = "rbxassetid://3944705374",
            ["trend-up"] = "rbxassetid://3944705939",
            ["trending-down"] = "rbxassetid://7743874143",
            ["trending-up"] = "rbxassetid://7743874262",
            ["triangle"] = "rbxassetid://7743874367",
            ["truck"] = "rbxassetid://7743874482",
            ["tune"] = "rbxassetid://4335489011",
            ["tv"] = "rbxassetid://7743874674",
            ["tv-2"] = "rbxassetid://7743874599",
            ["type"] = "rbxassetid://7743874740",
            ["typing"] = "rbxassetid://4370314188",
            ["umbrella"] = "rbxassetid://7743874820",
            ["underline"] = "rbxassetid://7743874904",
            ["undo"] = "rbxassetid://7743874974",
            ["undo-2"] = "rbxassetid://3944702835",
            ["unfold-less"] = "rbxassetid://4400703447",
            ["unfold-more"] = "rbxassetid://4400703888",
            ["unlink"] = "rbxassetid://7743875149",
            ["unlink-2"] = "rbxassetid://7743875069",
            ["unlock"] = "rbxassetid://7743875263",
            ["upgrade"] = "rbxassetid://4370346582",
            ["upload"] = "rbxassetid://7743875428",
            ["upload-cloud"] = "rbxassetid://7743875358",
            ["user"] = "rbxassetid://7743875962",
            ["user-check"] = "rbxassetid://7743875503",
            ["user-minus"] = "rbxassetid://7743875629",
            ["user-plus"] = "rbxassetid://7743875759",
            ["user-x"] = "rbxassetid://7743875879",
            ["users"] = "rbxassetid://7743876054",
            ["verified"] = "rbxassetid://7743876142",
            ["verified-user"] = "rbxassetid://4335489513",
            ["vibrate"] = "rbxassetid://7743876302",
            ["video"] = "rbxassetid://7743876610",
            ["video-off"] = "rbxassetid://7743876466",
            ["view"] = "rbxassetid://7743876754",
            ["visibility"] = "rbxassetid://3610254229",
            ["visibility-off"] = "rbxassetid://3610254425",
            ["voicemail"] = "rbxassetid://7743876916",
            ["volume"] = "rbxassetid://7743877487",
            ["volume-1"] = "rbxassetid://7743877081",
            ["volume-2"] = "rbxassetid://7743877250",
            ["volume-x"] = "rbxassetid://7743877381",
            ["vote"] = "rbxassetid://4400704837",
            ["wallet"] = "rbxassetid://7743877573",
            ["warning"] = "rbxassetid://3944668821",
            ["watch"] = "rbxassetid://7743877668",
            ["watch-2"] = "rbxassetid://4384391488",
            ["webcam"] = "rbxassetid://7743877896",
            ["wet"] = "rbxassetid://4370347078",
            ["wifi"] = "rbxassetid://7743878148",
            ["wifi-off"] = "rbxassetid://7743878056",
            ["wind"] = "rbxassetid://7743878264",
            ["wrench"] = "rbxassetid://7743878358",
            ["x"] = "rbxassetid://7743878857",
            ["x-circle"] = "rbxassetid://7743878496",
            ["x-octagon"] = "rbxassetid://7743878618",
            ["x-square"] = "rbxassetid://7743878737",
            ["zoom-in"] = "rbxassetid://7743878977",
            ["zoom-in-2"] = "rbxassetid://3610253578",
            ["zoom-out"] = "rbxassetid://7743879082",
            ["zoom-out-2"] = "rbxassetid://3610253853",
        },

    } -- main
    local page = {}
    local section = {}
    local SearchModules = {}

    do
        library.__index = library
        page.__index = page
        section.__index = section

        themes = {
            Background = Color3.fromRGB(24, 24, 24),
            Glow = Color3.fromRGB(0, 0, 0),
            Accent = Color3.fromRGB(255,255,255),
            LightContrast = Color3.fromRGB(20, 20, 20),
            DarkContrast = Color3.fromRGB(14, 14, 14),
            TextColor = Color3.fromRGB(255, 255, 255),
            Transparency = 0.1
        }

        -- new classes

        function library.new(config)
            local config = config or {}
            local title, icon, textlabel = config.Title or game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name, config.icon or "rbxassetid://7122342585", config.textlabel
            local container = utility:Create("ScreenGui", {
                Name = title,
                Parent = game.CoreGui
            }, {
                utility:Create("ImageButton", {
                    Name = "Main",
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0.1, 0, .5 - (.5 / 2), 0),
                    Size = UDim2.new(0, 511, 0, 428),
                    Image = "rbxassetid://4641149554",
                    ImageColor3 = themes.Background,
                    ImageTransparency = themes.Transparency + .1,
                    ScaleType = Enum.ScaleType.Slice,
                    SliceCenter = Rect.new(4, 4, 296, 296),
                    Visible = true
                }, {
                    utility:Create("ImageLabel", {
                        Name = "Glow",
                        BackgroundTransparency = 1,
                        Position = UDim2.new(0, -15, 0, -15),
                        Size = UDim2.new(1, 30, 1, 30),
                        ZIndex = 0,
                        Image = "rbxassetid://5028857084",
                        ImageColor3 = themes.Glow,
                        ScaleType = Enum.ScaleType.Slice,
                        SliceCenter = Rect.new(24, 24, 276, 276)
                    }),
                    utility:Create("ImageLabel", {
                        Name = "Pages",
                        BackgroundTransparency = 1,
                        ClipsDescendants = true,
                        Size = UDim2.new(0, 40, 1, 0),
                        ZIndex = 4,
                        Image = "rbxassetid://4641149554",
                        ImageColor3 = themes.DarkContrast,
                        ImageTransparency = themes.Transparency,
                        ScaleType = Enum.ScaleType.Slice,
                        SliceCenter = Rect.new(4, 4, 296, 296)
                    }, {
                        utility:Create("ScrollingFrame", {
                            Name = "Pages_Container",
                            Active = true,
                            BackgroundTransparency = 1,
                            Position = UDim2.new(0, 0, 0, 10),
                            Size = UDim2.new(1, 0, 1, -20),
                            ZIndex = 4,
                            CanvasSize = UDim2.new(0, 0, 0, 314),
                            ScrollBarThickness = 0
                        }, {
                            utility:Create("UIListLayout", {
                                SortOrder = Enum.SortOrder.LayoutOrder,
                                Padding = UDim.new(0, 10)
                            }),
                            utility:Create("TextButton", {
                                Name = "Menu",
                                BackgroundTransparency = 1,
                                BorderSizePixel = 0,
                                Size = UDim2.new(1, 0, 0, 26),
                                ZIndex = 4,
                                AutoButtonColor = false,
                                Font = Enum.Font.Gotham,
                                Text = "",
                                TextSize = 14
                            }, {
                                utility:Create("TextLabel", {
                                    Name = "Title",
                                    AnchorPoint = Vector2.new(0, 0.5),
                                    BackgroundTransparency = 1,
                                    Position = UDim2.new(0, 32, 0.5, 0),
                                    AutomaticSize = Enum.AutomaticSize.XY,
                                    SizeConstraint = Enum.SizeConstraint.RelativeYY,
                                    Font = Enum.Font.Gotham,
                                    RichText = true,
                                    Text = "<b>" .. title .. "</b>",
                                    TextColor3 = themes.TextColor,
                                    TextSize = 14,
                                    ZIndex = 4,
                                    TextTransparency = 1,
                                    TextXAlignment = Enum.TextXAlignment.Left
                                }, {
                                    icon and utility:Create("ImageLabel", {
                                        Name = "Icon",
                                        AnchorPoint = Vector2.new(0, 0.5),
                                        BackgroundTransparency = 1,
                                        ImageTransparency = 1,
                                        Position = UDim2.new(0, -20, 0.5, 0),
                                        Size = UDim2.new(0, 16, 0, 16),
                                        ZIndex = 4,
                                        Image = icon,
                                        ImageColor3 = themes.TextColor,
                                    }) or {}
                                }),
                                utility:Create("ImageLabel", {
                                    Name = "Icon",
                                    AnchorPoint = Vector2.new(0, 0.5),
                                    BackgroundTransparency = 1,
                                    Position = UDim2.new(1, -28, 0.5, 0),
                                    Size = UDim2.new(0, 16, 0, 16),
                                    ZIndex = 4,
                                    Image = "rbxassetid://2038908845",
                                    ImageColor3 = themes.TextColor,
                                })
                            })
                        }),
                        utility:Create("ScrollingFrame", {
                            Name = "Pages_BottomContainer",
                            Active = true,
                            BackgroundTransparency = 1,
                            Position = UDim2.new(0, 0, 0, 10),
                            Size = UDim2.new(1, 0, 1, -20),
                            ZIndex = 4,
                            CanvasSize = UDim2.new(0, 0, 0, 314),
                            ScrollBarThickness = 0
                        }, {
                            utility:Create("UIListLayout", {
                                SortOrder = Enum.SortOrder.LayoutOrder,
                                Padding = UDim.new(0, 10),
                                VerticalAlignment = Enum.VerticalAlignment.Bottom
                            }),

                        })
                    })
                })
            })
            if config.welcome == true then
                container.Main.Visible = false
                utility:Create("Frame", { -- UI
                    Parent = container,
                    Size = UDim2.new(0, 380, 0, 200),
                    BackgroundColor3 = themes.Background,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0.5, 0, 0.5, 0),
                    AnchorPoint = Vector2.new(0.5, 0.5),
                }, {
                    utility:Create("ImageLabel", {
                        Name = "WelcomeIcon",
                        Image = config.welcomeicon,
                        BackgroundTransparency = 1,
                        Size = UDim2.new(0,50,0,50),
                        ImageColor3 = themes.Accent,
                        Visible = false
                    }),
                    utility:Create("UICorner", {
                        CornerRadius = UDim.new(0, 8),
                    }),
                    utility:Create("Frame", { -- Square 1
                        Name = "Square_1",
                        BackgroundColor3 = themes.Background,
                        BackgroundTransparency = 1,
                        ZIndex = 2,
                        Size = UDim2.new(0, 200, 0, 200),
                        AnchorPoint = Vector2.new(0.5, 0),
                        Position = UDim2.new(0.5, 0, 0, 0),
                    }, {
                        utility:Create("UICorner", {
                            CornerRadius = UDim.new(0, 8),
                        }),
                    }),
                    utility:Create("Frame", { -- Square 2
                        Name = "Square_2",
                        BackgroundColor3 = Color3.fromRGB(255, 0, 0),
                        BackgroundTransparency = 1,
                        ZIndex = 1,
                        Size = UDim2.new(0, 200, 0, 200),
                        AnchorPoint = Vector2.new(0.5, 0),
                        Position = UDim2.new(0.5, 0, 0, 0),
                    }, {
                        utility:Create("UICorner", {
                            CornerRadius = UDim.new(0, 8),
                        })
                    }),
                    utility:Create("Frame", {
                        Size = UDim2.new(1, 0, 1, 0),
                        BackgroundTransparency = 1,
                    }, {
                        utility:Create("UIPadding", {
                            PaddingTop = UDim.new(0, 15),
                            PaddingBottom = UDim.new(0, 15),
                            PaddingLeft = UDim.new(0, 15),
                            PaddingRight = UDim.new(0, 15),
                        }),
                        utility:Create("TextLabel", {
                            Name = "WelcomeLabel",
                            AnchorPoint = Vector2.new(0.5, 0.5),
                            Position = UDim2.new(0.5, 0, 0.5, 0),
                            Size = UDim2.new(1, 0, 0, 50),
                            BackgroundTransparency = 1,
                            LayoutOrder = 1,
                            RichText = true,
                            TextColor3 = Color3.fromRGB(255, 0, 0),
                            Text = config.welcomelabel,
                            Visible = false,
                            MaxVisibleGraphemes = 1,
                            TextYAlignment = Enum.TextYAlignment.Center,
                            TextSize = 25,
                            Font = Enum.Font.SciFi,
                        }),
                    })
                })

                utility:Tween(container.Frame.Square_1, { BackgroundTransparency = 0 }, 0.3).Completed:Wait()
                utility:Tween(container.Frame.Square_2, { BackgroundTransparency = 0.5 }, 0.3)

                local Tween = utility:Tween(
                    container.Frame,
                    { Rotation = 360 },
                    1,
                    Enum.EasingStyle.Linear,
                    Enum.EasingDirection.In,
                    -1
                )



                utility:Tween(container.Frame, { Rotation = 0 }, 0.3)
                utility:Tween(container.Frame.Square_1, { Rotation = 180 }, 0.3)
                utility:Tween(container.Frame.Square_2, { Rotation = 180 }, 0.3).Completed:Wait()

                utility:Tween(container.Frame.Square_1, { Rotation = 45 }, 0.8)
                utility:Tween(container.Frame.Square_2, { Rotation = 45 }, 0.8).Completed:Wait()

                utility:Tween(
                    container.Frame.Square_1,
                    { Position = UDim2.new(0, 0, 0, 0), AnchorPoint = Vector2.new(0, 0) },
                    0.2
                )
                utility:Tween(
                    container.Frame.Square_2,
                    { Position = UDim2.new(1, 0, 0, 0), AnchorPoint = Vector2.new(1, 0) },
                    0.2
                )
                task.wait(1)

                utility:Tween(
                    container.Frame.Square_1,
                    { Position = UDim2.new(0.5, 0, 0, 0), AnchorPoint = Vector2.new(0.5, 0) },
                    0.2
                )
                utility:Tween(
                    container.Frame.Square_2,
                    { Position = UDim2.new(0.5, 0, 0, 0), AnchorPoint = Vector2.new(0.5, 0) },
                    0.2 
                ).Completed:Wait()

                utility:Tween(container.Frame.Square_1, { Rotation = 0 }, 0.3)
                utility:Tween(container.Frame.Square_2, { Rotation = 0 }, 0.3).Completed:Wait()

                utility:Tween(container.Frame.Square_1, { Size = UDim2.new(1, 0, 1, 0) }, 0.2)
                utility:Tween(container.Frame.Square_2, { Size = UDim2.new(1, 0, 1, 0) }, 0.2)

                utility:Tween(container.Frame, { Size = UDim2.new(0, 380, 0, 220) }, 0.2).Completed:Wait()

                container.Frame.BackgroundTransparency = 0
                task.wait()
                container.Frame.Square_1:Destroy()
                container.Frame.Square_2:Destroy()
                container.Frame.WelcomeIcon.Visible = true

                utility:TextEffect(container.Frame.Frame.WelcomeLabel, config.delay)

                container.Frame:Destroy()

                container.Main.Visible = true
            end
            local Menu = container.Main.Pages.Pages_Container.Menu
            Menu.MouseButton1Click:Connect(function()
                if container.Main.Pages.Size == UDim2.new(0, 40, 1, 0) then
                    local time = ((Menu.Title.AbsoluteSize.X + Menu.Title.Icon.AbsoluteSize.X + 60) - container.Main.Pages.Size.X.Offset) / 200
                    container.Main.Pages:TweenSize(UDim2.new(0, Menu.Title.AbsoluteSize.X + Menu.Title.Icon.AbsoluteSize.X + 60, 1, 0), Enum.EasingDirection.In, Enum.EasingStyle.Sine, time, true, function()
                        if time - 0.2 > 0.5 then time -=  0.2 end
                        game:GetService("TweenService"):Create(Menu.Title, TweenInfo.new(time - 0.3),{TextTransparency = 0}):Play()
                        game:GetService("TweenService"):Create(Menu.Title.Icon, TweenInfo.new(time - 0.3),{ImageTransparency = 0}):Play()
                    end)
                    game:GetService("TweenService"):Create(container.Main.Pages, TweenInfo.new(time),{ImageTransparency = 0}):Play()
                else
                    local time = (container.Main.Pages.Size.X.Offset - UDim2.new(0, 40, 1, 0).X.Offset) / 200
                    container.Main.Pages:TweenSize(UDim2.new(0, 40, 1, 0), Enum.EasingDirection.In, Enum.EasingStyle.Sine, time, true, function()
                        game:GetService("TweenService"):Create(container.Main.Pages, TweenInfo.new(time),{ImageTransparency = themes.Transparency}):Play()
                        game:GetService("TweenService"):Create(Menu.Title, TweenInfo.new(time),{TextTransparency = 1}):Play()
                        game:GetService("TweenService"):Create(Menu.Title.Icon, TweenInfo.new(time),{ImageTransparency = 1}):Play()
                    end)
                    game:GetService("TweenService"):Create(Menu.Title, TweenInfo.new(time),{TextTransparency = 1}):Play()
                    game:GetService("TweenService"):Create(Menu.Title.Icon, TweenInfo.new(time),{ImageTransparency = 1}):Play()
                end
            end)

            utility:InitializeKeybind()
            utility:DraggingEnabled(container.Main, container.Main)
            UI = container

            return setmetatable({
                container = container,
                pagesContainer = container.Main.Pages.Pages_Container,
                bottompagesContainer = container.Main.Pages.Pages_BottomContainer,
                pages = {}
            }, library)
        end

        function page.new(config)
            local library, title, position, icon = config.library, config.Title or "", config.Position == Enum.VerticalAlignment.Bottom and config.library.bottompagesContainer or config.library.pagesContainer, config.icon or "rbxassetid://7618136617"
            local button = utility:Create("TextButton", {
                Name = title,
                Parent = position,
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
                Size = UDim2.new(1, 0, 0, 26),
                ZIndex = 4,
                AutoButtonColor = false,
                Font = Enum.Font.Gotham,
                Text = "",
                TextSize = 14
            }, {
                utility:Create("TextLabel", {
                    Name = "Title",
                    AnchorPoint = Vector2.new(0, 0.5),
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 40, 0.5, 0),
                    Size = UDim2.new(0, 76, 1, 0),
                    ZIndex = 4,
                    Font = Enum.Font.Gotham,
                    Text = title,
                    TextColor3 = themes.TextColor,
                    TextSize = 12,
                    TextTransparency = 0.65,
                    TextXAlignment = Enum.TextXAlignment.Left
                }),
                icon and utility:Create("ImageLabel", {
                    Name = "Icon",
                    AnchorPoint = Vector2.new(0, 0.5),
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 12, 0.5, 0),
                    Size = UDim2.new(0, 16, 0, 16),
                    ZIndex = 4,
                    Image = icon,
                    ImageColor3 = themes.TextColor,
                    ImageTransparency = 0.64
                }) or {}
            })
            local container = utility:Create("ScrollingFrame", {
                Name = title,
                Parent = library.container.Main,
                Active = true,
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
                Position = UDim2.new(0, 48, 0, 8),
                Size = UDim2.new(1, -56, 1, -16),
                CanvasSize = UDim2.new(0, 0, 0, 466),
                ScrollBarThickness = 3,
                ScrollBarImageColor3 = themes.TextColor,
                Visible = false
            }, {
                utility:Create("UIListLayout", {
                    SortOrder = Enum.SortOrder.LayoutOrder,
                    Padding = UDim.new(0, 10)
                })
            })
            
            return setmetatable({
                library = library,
                container = container,
                button = button,
                sections = {}
            }, page)
        end

        function page.Search(config)
            local config = config or {}
            local title = "Search"
            local icon = 2512702176
            local library = config.library
            local button = utility:Create("TextButton", {
                Name = title,
                Parent = library.pagesContainer,
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
                Size = UDim2.new(1, 0, 0, 26),
                ZIndex = 4,
                AutoButtonColor = false,
                Font = Enum.Font.Gotham,
                Text = "",
                TextSize = 14
            }, {
                utility:Create("TextBox", {
                    Name = "Title",
                    AnchorPoint = Vector2.new(0, 0.5),
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 40, 0.5, 0),
                    Size = UDim2.new(0, 76, 1, 0),
                    ZIndex = 4,
                    Font = Enum.Font.GothamSemibold,
                    Text = "",
                    PlaceholderText = "Search...",
                    TextColor3 = themes.TextColor,
                    TextSize = 12,
                    TextXAlignment = Enum.TextXAlignment.Left,
                }),
                icon and utility:Create("ImageLabel", {
                    Name = "Icon",
                    AnchorPoint = Vector2.new(0, 0.5),
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 12, 0.5, 0),
                    Size = UDim2.new(0, 16, 0, 16),
                    ZIndex = 4,
                    Image = "rbxassetid://" .. tostring(icon),
                    ImageColor3 = themes.TextColor,
                    ImageTransparency = 0.64
                }) or {}
            })
            local container = utility:Create("ScrollingFrame", {
                Name = title,
                Parent = library.container.Main,
                Active = true,
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
                Position = UDim2.new(0, 48, 0, 8),
                Size = UDim2.new(1, -56, 1, -16),
                CanvasSize = UDim2.new(0, 0, 0, 466),
                ScrollBarThickness = 3,
                ScrollBarImageColor3 = themes.TextColor,
                Visible = false
            }, {
                utility:Create("UIListLayout", {
                    SortOrder = Enum.SortOrder.LayoutOrder,
                    Padding = UDim.new(0, 10)
                })
            })
            
            return setmetatable({
                library = library,
                container = container,
                button = button,
                textbox = button.Title,
                sections = {}
            }, page)
        end
        function page.Settings(config)
            local config = config or {}
            local title = "Settings"
            local icon = 1204397029
            local library = config.library
            local button = utility:Create("TextButton", {
                Name = title,
                Parent = library.bottompagesContainer,
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
                Size = UDim2.new(1, 0, 0, 26),
                ZIndex = 4,
                AutoButtonColor = false,
                Font = Enum.Font.Gotham,
                Text = "",
                TextSize = 14
            }, {
                utility:Create("TextLabel", {
                    Name = "Title",
                    AnchorPoint = Vector2.new(0, 0.5),
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 40, 0.5, 0),
                    Size = UDim2.new(0, 76, 1, 0),
                    ZIndex = 4,
                    Font = Enum.Font.Gotham,
                    Text = title,
                    TextColor3 = themes.TextColor,
                    TextSize = 12,
                    TextTransparency = 0.65,
                    TextXAlignment = Enum.TextXAlignment.Left
                }),
                icon and utility:Create("ImageLabel", {
                    Name = "Icon",
                    AnchorPoint = Vector2.new(0, 0.5),
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 12, 0.5, 0),
                    Size = UDim2.new(0, 16, 0, 16),
                    ZIndex = 4,
                    Image = "rbxassetid://" .. tostring(icon),
                    ImageColor3 = themes.TextColor,
                    ImageTransparency = 0.64
                }) or {}
            })
            local container = utility:Create("ScrollingFrame", {
                Name = title,
                Parent = library.container.Main,
                Active = true,
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
                Position = UDim2.new(0, 48, 0, 8),
                Size = UDim2.new(1, -56, 1, -16),
                CanvasSize = UDim2.new(0, 0, 0, 466),
                ScrollBarThickness = 3,
                ScrollBarImageColor3 = themes.TextColor,
                Visible = false
            }, {
                utility:Create("UIListLayout", {
                    SortOrder = Enum.SortOrder.LayoutOrder,
                    Padding = UDim.new(0, 10)
                })
            })
            
            return setmetatable({
                library = library,
                container = container,
                button = button,
                sections = {}
            }, page)
        end
        function page.User(config)
            local config = config or {}
            local icon = 6971939218
            local library = config.library
            local button = utility:Create("TextButton", {
                Name = "User",
                Parent = library.bottompagesContainer,
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
                Size = UDim2.new(1, 0, 0, 26),
                ZIndex = 4,
                AutoButtonColor = false,
                Font = Enum.Font.Gotham,
                Text = "",
                TextSize = 14
            }, {
                utility:Create("Frame", {
                    Name = "Title",
                    BackgroundTransparency = 1,
                    AnchorPoint = Vector2.new(0, 0.5),
                    Position = UDim2.new(0, 40, 0.5, 0),
                    Size = UDim2.new(1, -40, 1, 0),
                    ZIndex = 4,
                }, {
                    utility:Create("UIListLayout", {
                        SortOrder = Enum.SortOrder.LayoutOrder,
                        Padding = UDim.new(0, 0),
                        VerticalAlignment = Enum.VerticalAlignment.Center
                    }),
                    utility:Create("TextLabel", {
                        Name = "plrName",
                        BackgroundTransparency = 1,
                        AnchorPoint = Vector2.new(0, 0.5),
                        Size = UDim2.new(1, 0, 0, 12),
                        ZIndex = 4,
                        Font = Enum.Font.Gotham,
                        RichText = true,
                        Text = "<b>" .. player.DisplayName .. "</b>",
                        TextColor3 = themes.TextColor,
                        TextSize = 12,
                        TextTransparency = 0.65,
                        TextXAlignment = Enum.TextXAlignment.Left
                    }),
                    utility:Create("TextButton", {
                        Name = "Premium",
                        BackgroundTransparency = 1,
                        AnchorPoint = Vector2.new(0, 0.5),
                        Size = UDim2.new(1, 0, 0, 12),
                        ZIndex = 4,
                        Font = Enum.Font.Gotham,
                        RichText = true,
                        Text = "<u>Get Premium</u>",
                        TextColor3 = themes.TextColor,
                        TextSize = 12,
                        TextTransparency = 0.65,
                        TextXAlignment = Enum.TextXAlignment.Left
                    })
                }),
                icon and utility:Create("ImageButton", {
                    Name = "Icon",
                    AnchorPoint = Vector2.new(0, 0.5),
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 12, 0.5, 0),
                    Size = UDim2.new(0, 16, 0, 16),
                    ZIndex = 4,
                    Image = "rbxassetid://" .. tostring(icon),
                    ImageColor3 = themes.TextColor,
                    ImageTransparency = 0.64
                }) or {}
            })

            local container = utility:Create("ScrollingFrame", {
                Name = "User",
                Parent = library.container.Main,
                Active = true,
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
                Position = UDim2.new(0, 48, 0, 8),
                Size = UDim2.new(1, -56, 1, -16),
                CanvasSize = UDim2.new(0, 0, 0, 466),
                ScrollBarThickness = 3,
                ScrollBarImageColor3 = themes.TextColor,
                Visible = false
            }, {
                utility:Create("UIListLayout", {
                    SortOrder = Enum.SortOrder.LayoutOrder,
                    Padding = UDim.new(0, 10)
                })
            })

            return setmetatable({
                library = library,
                container = container,
                button = button,
                close = button.Icon,
                premium = button.Title.Premium,
                sections = {}
            }, page)
        end

        -- classes
        function section.new(config)
            local config = config or {}
            local container = utility:Create("ImageLabel", {
                Name = config.Title,
                Parent = config.page.container,
                BackgroundTransparency = 1,
                Size = UDim2.new(1, -10, 0, 28),
                ZIndex = 2,
                Image = "rbxassetid://5028857472",
                ImageColor3 = themes.LightContrast,
                ImageTransparency = themes.Transparency,
                ScaleType = Enum.ScaleType.Slice,
                SliceCenter = Rect.new(4, 4, 296, 296),
                ClipsDescendants = true
            }, {
                utility:Create("Frame", {
                    Name = "Container",
                    Active = true,
                    BackgroundTransparency = 1,
                    BorderSizePixel = 0,
                    Position = UDim2.new(0, 8, 0, 8),
                    Size = UDim2.new(1, -16, 1, -16)
                }, {
                    titleLabel = utility:Create("TextLabel", {
                        Name = "Title",
                        Visible = config.Title and config.Title ~= "" and true or false,
                        BackgroundTransparency = 1,
                        Size = config.Title and config.Title ~= "" and UDim2.new(1, 0, 0, 20) or UDim2.new(0, 0, 0, 0),
                        ZIndex = 2,
                        Font = Enum.Font.GothamSemibold,
                        Text = config.Title,
                        RichText = true,
                        TextColor3 = themes.TextColor,
                        TextSize = 12,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        TextTransparency = 1
                    }),
                    utility:Create("UIListLayout", {
                        SortOrder = Enum.SortOrder.LayoutOrder,
                        Padding = UDim.new(0, 4)
                    })
                })
            })
            return setmetatable({
                page = config.page,
                container = container.Container,
                colorpickers = {},
                modules = {},
                binds = {},
                lists = {},
            }, section) 
        end
        function library:addPage(config)
            local config = config or {}
            config["library"] = self
            local page = page.new(config)
            local button = page.button

            button.MouseButton1Click:Connect(function()
                self:SelectPage(page, true)
            end)
            
            return page
        end
        function library:nahthismadebyikky(config)
            local config = config or {}
            local t = 5
            local tick = tick
                
            self:setTheme({Theme = "Transparency", Color = 0.01})

            local connection
            connection = game:GetService("RunService"):BindToRenderStep("Rainbow", 1000, function()
                if UI and config.Enabled == true then
                    pcall(function()
                        local hue = tick() % t / t
                        local color = Color3.fromHSV(hue, 1, 1)
                        self:setTheme({Theme = "Glow", Color = color})
                        self:setTheme({Theme = "TextColor", Color = color})
                    end)
                end
                if not UI and connection then
                    pcall(function()
                        connection:Disconnect()
                    end)
                end
            end)

            return page
        end
        function library:addSettings()
        
            local page = page.Settings({library = self})
            local button = page.button

            button.MouseButton1Click:Connect(function()
                self:SelectPage(page, true)
            end)
            
            -- variables

            local Section = page:addSection({Title = "<b>Ui Settings</b>"})
            Section:addKeybind({Title = "Toggle Ui", Default = Enum.KeyCode.RightAlt, Callback = function()
                self:toggle()
            end})
            Section:addButton({Title = "Destroy Gui", Callback = function()
                self:toggle()
                UI:Destroy()
            end})
            return page
        end
        function library:addInfo()
            local page = page.new({library = self, Position = Enum.VerticalAlignment.Bottom, Title = "Info", icon = 322206910})
            local button = page.button
            local Section = page:addSection()
            Section:addLabel("<font size='14'><b>Credits</b></font>")
            Section:addLabel("This script was made by <b>Ikky#8337</b>")
            Section:addLabel(utility:Create("TextLabel", {Text="v 3.0", TextXAlignment=Enum.TextXAlignment.Right}))
            button.MouseButton1Click:Connect(function()
                self:SelectPage(page, true)
            end)
            
            return page
        end
        function page:addSection(config)
            local config = config or {}
            config["page"] = self
            local section = section.new(config)
            
            table.insert(self.sections, section)
            
            return section
        end

        -- functions

        function library:Close()
            if self:Check() then
                UI:Destroy()
            end
        end

        function library:expandUI()
            local Menu = self.container.Main.Pages.Pages_Container.Menu
            if self.container.Main.Pages.Size == UDim2.new(0, 40, 1, 0) then
                local time = ((Menu.Title.AbsoluteSize.X + Menu.Title.Icon.AbsoluteSize.X + 60) - self.container.Main.Pages.Size.X.Offset) / 200
                self.container.Main.Pages:TweenSize(UDim2.new(0, Menu.Title.AbsoluteSize.X + Menu.Title.Icon.AbsoluteSize.X + 60, 1, 0), Enum.EasingDirection.In, Enum.EasingStyle.Sine, time, true, function()
                    if time - 0.2 > 0.5 then time -=  0.2 end
                    game:GetService("TweenService"):Create(Menu.Title, TweenInfo.new(time - 0.3),{TextTransparency = 0}):Play()
                    game:GetService("TweenService"):Create(Menu.Title.Icon, TweenInfo.new(time - 0.3),{ImageTransparency = 0}):Play()
                end)
                game:GetService("TweenService"):Create(self.container.Main.Pages, TweenInfo.new(time),{ImageTransparency = 0}):Play()
            else
                local time = (self.container.Main.Pages.Size.X.Offset - UDim2.new(0, 40, 1, 0).X.Offset) / 200
                self.container.Main.Pages:TweenSize(UDim2.new(0, 40, 1, 0), Enum.EasingDirection.In, Enum.EasingStyle.Sine, time, true, function()
                    game:GetService("TweenService"):Create(self.container.Main.Pages, TweenInfo.new(time),{ImageTransparency = themes.Transparency}):Play()
                    game:GetService("TweenService"):Create(Menu.Title, TweenInfo.new(time),{TextTransparency = 1}):Play()
                    game:GetService("TweenService"):Create(Menu.Title.Icon, TweenInfo.new(time),{ImageTransparency = 1}):Play()
                end)
                game:GetService("TweenService"):Create(Menu.Title, TweenInfo.new(time),{TextTransparency = 1}):Play()
                game:GetService("TweenService"):Create(Menu.Title.Icon, TweenInfo.new(time),{ImageTransparency = 1}):Play()
            end
        end

        function library:setTheme(config)
            for property, objects in pairs(objects[config.Theme]) do
                for i, object in pairs(objects) do
                    if not object.Parent or (object.Name == "Button" and object.Parent.Name == "ColorPicker") then
                        objects[i] = nil -- i can do this because weak tables :D
                    else
                        if config.Theme == "Transparency" then
                            if object.Name == "Pages" then
                                if object.Size == UDim2.new(0, 40, 1, 0) then
                                    object[property] = config.Color
                                end
                            else
                                object[property] = config.Color
                            end
                        else
                            object[property] = config.Color
                        end
                    end
                end
            end
            themes[config.Theme] = config.Color
        end

        function library:toggle()

            if self.toggling then return end
            
            self.toggling = true
            
            local container = self.container:FindFirstChild("Main")
            if not container then return end
            local Pages = container.Pages

            local function hasProperty(object, prop)
                local t = object[prop]
            end
            
            if self.position then
                utility:Tween(container, {
                    Size = UDim2.new(0, 511, 0, 428),
                    Position = self.position
                }, 0.2)
                
                wait(0.2)

                utility:Tween(Pages, {Size = UDim2.new(0, 40, 1, 0)}, .2)
                utility:Tween(Pages.Pages_Container.Menu.Title, {TextTransparency = 1}, 0)
                utility:Tween(Pages.Pages_Container.Menu.Title.Icon, {ImageTransparency = 1}, 0)
                
                wait(0.2)

                container.ClipsDescendants = false
                self.position = nil

                for _, v in pairs(Pages:GetDescendants()) do
                    local success = pcall(function() hasProperty(v, "Visible") end)
                    if success then
                        v.Visible = true
                    end
                end
                utility:Tween(Pages, {ImageTransparency = themes.Transparency}, 0)
            else
                for _, v in pairs(Pages:GetDescendants()) do
                    local success = pcall(function() hasProperty(v, "Visible") end)
                    if success then
                        v.Visible = false
                    end
                end
                utility:Tween(Pages, {ImageTransparency = 0}, 0.2)
                wait(0.2)
                self.position = container.Position
                container.ClipsDescendants = true
                
                utility:Tween(Pages, {Size = UDim2.new(1, 0, 1, 0)}, 0.2)
                wait(0.2)
                
                utility:Tween(container, {
                    Size = UDim2.new(0, 511, 0, 0),
                    Position = self.position + UDim2.new(0, 0, 0, 428)
                }, 0.2)
                wait(0.2)
            end
            
            self.toggling = false
        end

        -- new modules

        function library:Notify(config)
            local config = config or {}
        
            -- overwrite last notification
            if self.activeNotification then
                self.activeNotification = self.activeNotification()
            end
            
            -- standard create
            local notification = utility:Create("ImageLabel", {
                Name = "Notification",
                Parent = self.container,
                BackgroundTransparency = 1,
                Size = UDim2.new(0, 200, 0, 60),
                Image = "rbxassetid://5028857472",
                ImageColor3 = themes.Background,
                ImageTransparency = themes.Transparency,
                ScaleType = Enum.ScaleType.Slice,
                SliceCenter = Rect.new(4, 4, 296, 296),
                ZIndex = 3,
                ClipsDescendants = true
            }, {
                utility:Create("ImageLabel", {
                    Name = "Flash",
                    Size = UDim2.new(1, 0, 1, 0),
                    BackgroundTransparency = 1,
                    Image = "rbxassetid://4641149554",
                    ImageColor3 = themes.TextColor,
                    ZIndex = 5
                }),
                utility:Create("ImageLabel", {
                    Name = "Glow",
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, -15, 0, -15),
                    Size = UDim2.new(1, 30, 1, 30),
                    ZIndex = 2,
                    Image = "rbxassetid://5028857084",
                    ImageColor3 = themes.Glow,
                    ScaleType = Enum.ScaleType.Slice,
                    SliceCenter = Rect.new(24, 24, 276, 276)
                }),
                utility:Create("TextLabel", {
                    Name = "Title",
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 10, 0, 8),
                    Size = UDim2.new(1, -40, 0, 16),
                    ZIndex = 4,
                    Font = Enum.Font.GothamSemibold,
                    TextColor3 = themes.TextColor,
                    TextSize = 14.000,
                    TextXAlignment = Enum.TextXAlignment.Left
                }),
                utility:Create("TextLabel", {
                    Name = "Text",
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 10, 1, -24),
                    Size = UDim2.new(1, -40, 0, 16),
                    ZIndex = 4,
                    Font = Enum.Font.Gotham,
                    TextColor3 = themes.TextColor,
                    TextSize = 12.000,
                    TextXAlignment = Enum.TextXAlignment.Left
                }),
                utility:Create("ImageButton", {
                    Name = "Decline",
                    BackgroundTransparency = 1,
                    Position = UDim2.new(1, -26, 1, -50),
                    Size = UDim2.new(0, 16, 0, 16),
                    Image = "rbxassetid://5012538583",
                    ImageColor3 = themes.TextColor,
                    ZIndex = 4
                })
            })
            
            -- dragging
            utility:DraggingEnabled(notification)
            
            -- position and size
            config.Title = config.Title or "Notification"
            config.Text = config.Text or ""
            
            notification.Title.Text = config.Title
            notification.Text.Text = config.Text
            
            local padding = 10
            local textSize = game:GetService("TextService"):GetTextSize(config.Text, 12, Enum.Font.Gotham, Vector2.new(math.huge, 16))
            
            notification.Position = library.lastNotification or UDim2.new(0, padding, 1, -(notification.AbsoluteSize.Y + padding))
            notification.Size = UDim2.new(0, 0, 0, 60)
            
            utility:Tween(notification, {Size = UDim2.new(0, textSize.X + 70, 0, 60)}, 0.2)
            wait(0.2)
            
            notification.ClipsDescendants = false
            utility:Tween(notification.Flash, {
                Size = UDim2.new(0, 0, 0, 60),
                Position = UDim2.new(1, 0, 0, 0)
            }, 0.2)
            
            -- callbacks
            local active = true
            local close = function()
            
                if not active then
                    return
                end
                
                active = false
                notification.ClipsDescendants = true
                
                library.lastNotification = notification.Position
                notification.Flash.Position = UDim2.new(0, 0, 0, 0)
                utility:Tween(notification.Flash, {Size = UDim2.new(1, 0, 1, 0)}, 0.2)
                
                wait(0.2)
                utility:Tween(notification, {
                    Size = UDim2.new(0, 0, 0, 60),
                    Position = notification.Position + UDim2.new(0, textSize.X + 70, 0, 0)
                }, 0.2)
                
                wait(0.2)
                notification:Destroy()
            end
            
            self.activeNotification = close
                    
            notification.Decline.MouseButton1Click:Connect(function()
            
                if not active then 
                    return
                end
                
                close()
            end)
            if config.Time then
                wait(config.Time)
                if not active then 
                    return
                end
                pcall(function()
                    close()
                end)
            end
        end
        function library:NotifyQuestion(config)
            local config = config or {}
        
            -- overwrite last notification
            if self.activeNotification then
                self.activeNotification = self.activeNotification()
            end
            
            -- standard create
            local notificationQuestion = utility:Create("ImageLabel", {
                Name = "Notification",
                Parent = self.container,
                BackgroundTransparency = 1,
                Size = UDim2.new(0, 200, 0, 60),
                Image = "rbxassetid://5028857472",
                ImageColor3 = themes.Background,
                ImageTransparency = themes.Transparency,
                ScaleType = Enum.ScaleType.Slice,
                SliceCenter = Rect.new(4, 4, 296, 296),
                ZIndex = 3,
                ClipsDescendants = true
            }, {
                utility:Create("ImageLabel", {
                    Name = "Flash",
                    Size = UDim2.new(1, 0, 1, 0),
                    BackgroundTransparency = 1,
                    Image = "rbxassetid://4641149554",
                    ImageColor3 = themes.TextColor,
                    ZIndex = 5
                }),
                utility:Create("ImageLabel", {
                    Name = "Glow",
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, -15, 0, -15),
                    Size = UDim2.new(1, 30, 1, 30),
                    ZIndex = 2,
                    Image = "rbxassetid://5028857084",
                    ImageColor3 = themes.Glow,
                    ScaleType = Enum.ScaleType.Slice,
                    SliceCenter = Rect.new(24, 24, 276, 276)
                }),
                utility:Create("TextLabel", {
                    Name = "Title",
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 10, 0, 8),
                    Size = UDim2.new(1, -40, 0, 16),
                    ZIndex = 4,
                    Font = Enum.Font.GothamSemibold,
                    TextColor3 = themes.TextColor,
                    TextSize = 14.000,
                    TextXAlignment = Enum.TextXAlignment.Left
                }),
                utility:Create("TextLabel", {
                    Name = "Text",
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 10, 1, -24),
                    Size = UDim2.new(1, -40, 0, 16),
                    ZIndex = 4,
                    Font = Enum.Font.Gotham,
                    TextColor3 = themes.TextColor,
                    TextSize = 12.000,
                    TextXAlignment = Enum.TextXAlignment.Left
                }),
                utility:Create("ImageButton", {
                    Name = "Accept",
                    BackgroundTransparency = 1,
                    Position = UDim2.new(1, -26, 0, 8),
                    Size = UDim2.new(0, 16, 0, 16),
                    Image = "rbxassetid://5012538259",
                    ImageColor3 = themes.TextColor,
                    ZIndex = 4
                }),
                utility:Create("ImageButton", {
                    Name = "Decline",
                    BackgroundTransparency = 1,
                    Position = UDim2.new(1, -26, 1, -24),
                    Size = UDim2.new(0, 16, 0, 16),
                    Image = "rbxassetid://5012538583",
                    ImageColor3 = themes.TextColor,
                    ZIndex = 4
                })
            })
            
            -- dragging
            utility:DraggingEnabled(notificationQuestion)
            
            -- position and size
            config.Title = config.Title or "NotificationQuestion"
            config.Text = config.Text or ""
            
            notificationQuestion.Title.Text = config.Title
            notificationQuestion.Text.Text = config.Text
            
            local padding = 10
            local textSize = game:GetService("TextService"):GetTextSize(config.Text, 12, Enum.Font.Gotham, Vector2.new(math.huge, 16))
            
            notificationQuestion.Position = library.lastNotification or UDim2.new(0, padding, 1, -(notificationQuestion.AbsoluteSize.Y + padding))
            notificationQuestion.Size = UDim2.new(0, 0, 0, 60)
            
            utility:Tween(notificationQuestion, {Size = UDim2.new(0, textSize.X + 70, 0, 60)}, 0.2)
            wait(0.2)
            
            notificationQuestion.ClipsDescendants = false
            utility:Tween(notificationQuestion.Flash, {
                Size = UDim2.new(0, 0, 0, 60),
                Position = UDim2.new(1, 0, 0, 0)
            }, 0.2)
            
            -- callbacks
            local active = true
            local close = function()
            
                if not active then
                    return
                end
                
                active = false
                notificationQuestion.ClipsDescendants = true
                
                library.lastNotification = notificationQuestion.Position
                notificationQuestion.Flash.Position = UDim2.new(0, 0, 0, 0)
                utility:Tween(notificationQuestion.Flash, {Size = UDim2.new(1, 0, 1, 0)}, 0.2)
                
                wait(0.2)
                utility:Tween(notificationQuestion, {
                    Size = UDim2.new(0, 0, 0, 60),
                    Position = notificationQuestion.Position + UDim2.new(0, textSize.X + 70, 0, 0)
                }, 0.2)
                
                wait(0.2)
                notificationQuestion:Destroy()
            end
            
            self.activeNotification = close
            
            notificationQuestion.Accept.MouseButton1Click:Connect(function()
                if not active then 
                    return
                end
                
                if config.Callback then
                    config.Callback(true)
                end
                
                close()
            end)
            
            notificationQuestion.Decline.MouseButton1Click:Connect(function()
                if not active then 
                    return
                end
                
                if config.Callback then
                    config.Callback(false)
                end
                
                close()
            end)
            if config.Time then
                wait(config.Time)
                if not active then 
                    return
                end
                pcall(function()
                    close()
                end)
            end
        end

        function section:addModule(module, ...)
            if tostring(module) == "addButton" then
                self:addButton(...)
            elseif tostring(module) == "addToggle" then
                self:addToggle(...)
            elseif tostring(module) == "addTextbox" then
                self:addTextbox(...)
            elseif tostring(module) == "addKeybind" then
                self:addKeybind(...)
            elseif tostring(module) == "addColorPicker" then
                self:addColorPicker(...)
            elseif tostring(module) == "addSlider" then
                self:addSlider(...)
            elseif tostring(module) == "addDropdown" then
                self:addDropdown(...)
            end
        end

        function section:addLabel(Label)
            if not Label or type(Label) == "string" then
                local label = utility:Create("TextLabel", {
                    Name = "Label",
                    Parent = self.container,
                    BackgroundTransparency = 1,
                    TextSize = 12,
                    Size = UDim2.new(1, 0, 0, 12),
                    ZIndex = 3,
                    Font = Enum.Font.Gotham,
                    TextColor3 = themes.TextColor,
                    TextWrapped = true,
                    RichText = true,
                    TextYAlignment = 0,
                    TextTransparency = 0.10000000149012
                })
            
                local sizeY = 0
                for i = 1, Label:len() do
                    label.Text = Label:sub(1, i)
                    label.Size = UDim2.new(1, 0, 0, label.TextBounds.Y)
                end

                label:GetPropertyChangedSignal("Size"):Connect(function()
                    self:Resize()
                end)

                table.insert(self.modules, label)
                return label
            elseif type(Label) ~= "string" and Label:IsA("TextLabel") then
                local Text = Label.Text
                Label.Name = "Label"
                Label.Parent = self.container
                Label.BackgroundTransparency = 1
                Label.TextSize = Label.TextSize or 12
                Label.Size = UDim2.new(1, 0, 0, Label.TextSize)
                Label.ZIndex = 3
                Label.RichText = true
                Label.Font = Label.Font or Enum.Font.Gotham
                Label.TextColor3 = themes.TextColor
                Label.TextWrapped = true
                Label.TextYAlignment = 0
                Label.TextTransparency = 0.10000000149012
        
                local sizeY = 0
                for i = 1, Text:len() do
                    Label.Text = Text:sub(1, i)
                    Label.Size = UDim2.new(1, 0, 0, Label.TextBounds.Y)
                end

                Label:GetPropertyChangedSignal("Size"):Connect(function()
                    self:Resize()
                end)

                table.insert(self.modules, Label)
                return Label
            end
        end

        function section:addButton(config)
            local config = config or {}
            local title, callback, search, ToolTipText = config.Title or "Button", config.Callback or function()end, config.Search or false, config.ToolTipText
            local button = utility:Create("ImageButton", {
                Name = "Button",
                Parent = self.container,
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
                Size = UDim2.new(1, 0, 0, 30),
                ZIndex = 2,
                Image = "rbxassetid://5028857472",
                ImageColor3 = themes.DarkContrast,
                ImageTransparency = themes.Transparency,
                ScaleType = Enum.ScaleType.Slice,
                SliceCenter = Rect.new(2, 2, 298, 298)
            }, {
                utility:Create("TextLabel", {
                    Name = "Title",
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 1, 0),
                    ZIndex = 3,
                    Font = Enum.Font.Gotham,
                    Text = title,
                    TextColor3 = themes.TextColor,
                    TextSize = 12,
                    TextTransparency = 0.10000000149012
                })
            })
            
            if ToolTipText then
                local container = utility:Create("ImageLabel", {
                    Name = "ToolTip",
                    Parent = self.page.library.container,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(0, 0, 0, 30),
                    Image = "rbxassetid://4641149554",
                    ImageColor3 = themes.Background,
                    ImageTransparency = themes.Transparency
                }, {
                    utility:Create("TextLabel", {
                        Name = "Text",
                        BackgroundTransparency = 1,
                        Visible = false,
                        Size = UDim2.new(1, 0, 0, 30),
                        ZIndex = 3,
                        Font = Enum.Font.Gotham,
                        Text = ToolTipText,
                        TextColor3 = themes.TextColor,
                        TextSize = 12,
                        TextTransparency = 0.10000000149012
                    })
                })
                local textSize = game:GetService("TextService"):GetTextSize(ToolTipText, 12, Enum.Font.Gotham, Vector2.new(math.huge, 16))

                button.MouseEnter:Connect(function()
                    container.Position = UDim2.new(0, button.AbsolutePosition.X + button.AbsoluteSize.X + 30, 0, button.AbsolutePosition.Y)
                    container:TweenSize(UDim2.new(0, textSize.X + 70, 0, 30), Enum.EasingDirection.In,	Enum.EasingStyle.Sine, .8, true, function()
                        if container.Size == UDim2.new(0, textSize.X + 70, 0, 30) then
                            container.Text.Visible = true
                        end
                    end)                
                end)
                button.MouseLeave:Connect(function()
                    container:TweenSize(UDim2.new(0, 0, 0, 30), Enum.EasingDirection.In, Enum.EasingStyle.Sine, .5, true, function()
                        container.Text.Visible = false
                    end)
                    container.Text.Visible = false
                end)
            end

            table.insert(self.modules, button)
            --self:Resize()
                
            local text = button.Title
            local debounce

            button.MouseButton1Click:Connect(function()
                
                if debounce then
                    return
                end
                
                -- animation
                utility:Pop(button, 10)
                
                debounce = true
                text.TextSize = 0
                utility:Tween(button.Title, {TextSize = 14}, 0.2)
                
                wait(0.2)
                utility:Tween(button.Title, {TextSize = 12}, 0.2)
                
                if callback then
                    callback(function(...)
                        self:updateButton(button, ...)
                    end)
                end
                
                debounce = false
            end)
            if search then
                config.Title, config.Callback, config.Search, config.ToolTipText = title, callback, search, ToolTipText
                table.insert(SearchModules, {class = "addButton", variables = config})
            end
            return button
        end

        function section:addToggle(config)
            local config = config or {}
            local title, default, callback, search, ToolTipText = config.Title or "Toggle", config.Default or false, config.Callback or function()end, config.Search or false, config.ToolTipText
            local toggle = utility:Create("ImageButton", {
                Name = "Toggle",
                Parent = self.container,
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
                Size = UDim2.new(1, 0, 0, 30),
                ZIndex = 2,
                Image = "rbxassetid://5028857472",
                ImageColor3 = themes.DarkContrast,
                ImageTransparency = themes.Transparency,
                ScaleType = Enum.ScaleType.Slice,
                SliceCenter = Rect.new(2, 2, 298, 298)
            },{
                utility:Create("TextLabel", {
                    Name = "Title",
                    AnchorPoint = Vector2.new(0, 0.5),
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 10, 0.5, 1),
                    Size = UDim2.new(0.5, 0, 1, 0),
                    ZIndex = 3,
                    Font = Enum.Font.Gotham,
                    Text = title,
                    TextColor3 = themes.TextColor,
                    TextSize = 12,
                    TextTransparency = 0.10000000149012,
                    TextXAlignment = Enum.TextXAlignment.Left
                }),
                utility:Create("ImageLabel", {
                    Name = "Button",
                    BackgroundTransparency = 1,
                    BorderSizePixel = 0,
                    Position = UDim2.new(1, -50, 0.5, -8),
                    Size = UDim2.new(0, 40, 0, 16),
                    ZIndex = 2,
                    Image = "rbxassetid://5028857472",
                    ImageColor3 = themes.LightContrast,
                    ImageTransparency = themes.Transparency,
                    ScaleType = Enum.ScaleType.Slice,
                    SliceCenter = Rect.new(2, 2, 298, 298)
                }, {
                    utility:Create("ImageLabel", {
                        Name = "Frame",
                        BackgroundTransparency = 1,
                        Position = UDim2.new(0, 2, 0.5, -6),
                        Size = UDim2.new(1, -22, 1, -4),
                        ZIndex = 2,
                        Image = "rbxassetid://5028857472",
                        ImageColor3 = themes.TextColor,
                        ScaleType = Enum.ScaleType.Slice,
                        SliceCenter = Rect.new(2, 2, 298, 298)
                    })
                })
            })
            
            if ToolTipText then
                local container = utility:Create("ImageLabel", {
                    Name = "ToolTip",
                    Parent = self.page.library.container,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(0, 0, 0, 30),
                    Image = "rbxassetid://4641149554",
                    ImageColor3 = themes.Background,
                    ImageTransparency = themes.Transparency
                }, {
                    utility:Create("TextLabel", {
                        Name = "Text",
                        BackgroundTransparency = 1,
                        Visible = false,
                        Size = UDim2.new(1, 0, 0, 30),
                        ZIndex = 3,
                        Font = Enum.Font.Gotham,
                        Text = ToolTipText,
                        TextColor3 = themes.TextColor,
                        TextSize = 12,
                        TextTransparency = 0.10000000149012
                    })
                })
                local textSize = game:GetService("TextService"):GetTextSize(ToolTipText, 12, Enum.Font.Gotham, Vector2.new(math.huge, 16))

                toggle.MouseEnter:Connect(function()
                    container.Position = UDim2.new(0, toggle.AbsolutePosition.X + toggle.AbsoluteSize.X + 30, 0, toggle.AbsolutePosition.Y)
                    container:TweenSize(UDim2.new(0, textSize.X + 70, 0, 30), Enum.EasingDirection.In,	Enum.EasingStyle.Sine, .8, true, function()
                        if container.Size == UDim2.new(0, textSize.X + 70, 0, 30) then
                            container.Text.Visible = true
                        end
                    end)                
                end)
                toggle.MouseLeave:Connect(function()
                    container:TweenSize(UDim2.new(0, 0, 0, 30), Enum.EasingDirection.In, Enum.EasingStyle.Sine, .5, true, function()
                        container.Text.Visible = false
                    end)
                    container.Text.Visible = false
                end)
            end

            table.insert(self.modules, toggle)
            --self:Resize()
            
            local active = default
            self:updateToggle(toggle, nil, active)
            
            toggle.MouseButton1Click:Connect(function()
                active = not active
                self:updateToggle(toggle, nil, active)
                
                if callback then
                    callback(active, function(...)
                        self:updateToggle(toggle, ...)
                    end)
                end
            end)
            
            if search then
                config.Title, config.Default, config.Callback, config.Search, config.ToolTipText = title, default, callback, search, ToolTipText
                table.insert(SearchModules, {class = "addToggle", variables = config})
            end
            return toggle
        end

        function section:addTextbox(config)
            local config = config or {}
            local title, default, callback, search, ToolTipText = config.Title or "Textbox", config.Default, config.Callback or function()end, config.Search or false, config.ToolTipText
            local textbox = utility:Create("ImageButton", {
                Name = "Textbox",
                Parent = self.container,
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
                Size = UDim2.new(1, 0, 0, 30),
                ZIndex = 2,
                Image = "rbxassetid://5028857472",
                ImageColor3 = themes.DarkContrast,
                ImageTransparency = themes.Transparency,
                ScaleType = Enum.ScaleType.Slice,
                SliceCenter = Rect.new(2, 2, 298, 298)
            }, {
                utility:Create("TextLabel", {
                    Name = "Title",
                    AnchorPoint = Vector2.new(0, 0.5),
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 10, 0.5, 1),
                    Size = UDim2.new(0.5, 0, 1, 0),
                    ZIndex = 3,
                    Font = Enum.Font.Gotham,
                    Text = title,
                    TextColor3 = themes.TextColor,
                    TextSize = 12,
                    TextTransparency = 0.10000000149012,
                    TextXAlignment = Enum.TextXAlignment.Left
                }),
                utility:Create("ImageLabel", {
                    Name = "Button",
                    BackgroundTransparency = 1,
                    Position = UDim2.new(1, -110, 0.5, -8),
                    Size = UDim2.new(0, 100, 0, 16),
                    ZIndex = 2,
                    Image = "rbxassetid://5028857472",
                    ImageColor3 = themes.LightContrast,
                    ImageTransparency = themes.Transparency,
                    ScaleType = Enum.ScaleType.Slice,
                    SliceCenter = Rect.new(2, 2, 298, 298)
                }, {
                    utility:Create("TextBox", {
                        Name = "Textbox",
                        BackgroundTransparency = 1,
                        TextTruncate = Enum.TextTruncate.AtEnd,
                        Position = UDim2.new(0, 5, 0, 0),
                        Size = UDim2.new(1, -10, 1, 0),
                        ZIndex = 3,
                        Font = Enum.Font.GothamSemibold,
                        Text = default or "",
                        TextColor3 = themes.TextColor,
                        TextSize = 11
                    })
                })
            })
            
            if ToolTipText then
                local container = utility:Create("ImageLabel", {
                Name = "ToolTip",
                Parent = self.page.library.container,
                BackgroundTransparency = 1,
                Size = UDim2.new(0, 0, 0, 30),
                Image = "rbxassetid://4641149554",
                ImageColor3 = themes.Background,
                ImageTransparency = themes.Transparency
                }, {
                    utility:Create("TextLabel", {
                        Name = "Text",
                        BackgroundTransparency = 1,
                        Visible = false,
                        Size = UDim2.new(1, 0, 0, 30),
                        ZIndex = 3,
                        Font = Enum.Font.Gotham,
                        Text = ToolTipText,
                        TextColor3 = themes.TextColor,
                        TextSize = 12,
                        TextTransparency = 0.10000000149012
                    })
                })

                local textSize = game:GetService("TextService"):GetTextSize(ToolTipText, 12, Enum.Font.Gotham, Vector2.new(math.huge, 16))

                textbox.MouseEnter:Connect(function()
                    container.Position = UDim2.new(0, textbox.AbsolutePosition.X + textbox.AbsoluteSize.X + 30, 0, textbox.AbsolutePosition.Y)
                    container:TweenSize(UDim2.new(0, textSize.X + 70, 0, 30), Enum.EasingDirection.In,	Enum.EasingStyle.Sine, .8, true, function()
                        if container.Size == UDim2.new(0, textSize.X + 70, 0, 30) then
                            container.Text.Visible = true
                        end
                    end)                
                end)
                textbox.MouseLeave:Connect(function()
                    container:TweenSize(UDim2.new(0, 0, 0, 30), Enum.EasingDirection.In, Enum.EasingStyle.Sine, .5, true, function()
                        container.Text.Visible = false
                    end)
                    container.Text.Visible = false
                end)
            end
            
            table.insert(self.modules, textbox)
            --self:Resize()
            
            local button = textbox.Button
            local input = button.Textbox
            
            textbox.MouseButton1Click:Connect(function()
            
                if textbox.Button.Size ~= UDim2.new(0, 100, 0, 16) then
                    return
                end
                
                utility:Tween(textbox.Button, {
                    Size = UDim2.new(0, 200, 0, 16),
                    Position = UDim2.new(1, -210, 0.5, -8)
                }, 0.2)
                
                wait()

                input.TextXAlignment = Enum.TextXAlignment.Left
                input:CaptureFocus()
            end)
            
            input:GetPropertyChangedSignal("Text"):Connect(function()
                
                if button.ImageTransparency == themes.Transparency and (button.Size == UDim2.new(0, 200, 0, 16) or button.Size == UDim2.new(0, 100, 0, 16)) then -- i know, i dont like this either
                    utility:Pop(button, 10)
                end
                
                if callback then
                    callback(input.Text, nil, function(...)
                        self:updateTextbox(textbox, ...)
                    end)
                end
            end)
            
            input.FocusLost:Connect(function()
                
                input.TextXAlignment = Enum.TextXAlignment.Center
                
                utility:Tween(textbox.Button, {
                    Size = UDim2.new(0, 100, 0, 16),
                    Position = UDim2.new(1, -110, 0.5, -8)
                }, 0.2)
                
                if callback then
                    callback(input.Text, true, function(...)
                        self:updateTextbox(textbox, ...)
                    end)
                end
            end)
            
            if search then
                config.Title, config.Default, config.Callback, config.Search, config.ToolTipText = title, default, callback, search, ToolTipText
                table.insert(SearchModules, {class = "addTextbox", variables = config})
            end
            return textbox
        end

        function section:addKeybind(config)
            local config = config or {}
            local title, default, callback, changedCallback, search, ToolTipText = config.Title or "Keybind", config.Default, config.Callback or function()end, config.ChangedCallback or function()end, config.Search or false, config.ToolTipText
            local keybind = utility:Create("ImageButton", {
                Name = "Keybind",
                Parent = self.container,
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
                Size = UDim2.new(1, 0, 0, 30),
                ZIndex = 2,
                Image = "rbxassetid://5028857472",
                ImageColor3 = themes.DarkContrast,
                ImageTransparency = themes.Transparency,
                ScaleType = Enum.ScaleType.Slice,
                SliceCenter = Rect.new(2, 2, 298, 298)
            }, {
                utility:Create("TextLabel", {
                    Name = "Title",
                    AnchorPoint = Vector2.new(0, 0.5),
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 10, 0.5, 1),
                    Size = UDim2.new(1, 0, 1, 0),
                    ZIndex = 3,
                    Font = Enum.Font.Gotham,
                    Text = title,
                    TextColor3 = themes.TextColor,
                    TextSize = 12,
                    TextTransparency = 0.10000000149012,
                    TextXAlignment = Enum.TextXAlignment.Left
                }),
                utility:Create("ImageLabel", {
                    Name = "Button",
                    BackgroundTransparency = 1,
                    Position = UDim2.new(1, -110, 0.5, -8),
                    Size = UDim2.new(0, 100, 0, 16),
                    ZIndex = 2,
                    Image = "rbxassetid://5028857472",
                    ImageColor3 = themes.LightContrast,
                    ImageTransparency = themes.Transparency,
                    ScaleType = Enum.ScaleType.Slice,
                    SliceCenter = Rect.new(2, 2, 298, 298)
                }, {
                    utility:Create("TextLabel", {
                        Name = "Text",
                        BackgroundTransparency = 1,
                        ClipsDescendants = true,
                        Size = UDim2.new(1, 0, 1, 0),
                        ZIndex = 3,
                        Font = Enum.Font.GothamSemibold,
                        Text = default and default.Name or "None",
                        TextColor3 = themes.TextColor,
                        TextSize = 11
                    })
                })
            })

            if ToolTipText then
                local container = utility:Create("ImageLabel", {
                    Name = "ToolTip",
                    Parent = self.page.library.container,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(0, 0, 0, 30),
                    Image = "rbxassetid://4641149554",
                    ImageColor3 = themes.Background,
                    ImageTransparency = themes.Transparency
                }, {
                    utility:Create("TextLabel", {
                        Name = "Text",
                        BackgroundTransparency = 1,
                        Visible = false,
                        Size = UDim2.new(1, 0, 0, 30),
                        ZIndex = 3,
                        Font = Enum.Font.Gotham,
                        Text = ToolTipText,
                        TextColor3 = themes.TextColor,
                        TextSize = 12,
                        TextTransparency = 0.10000000149012
                    })
                })
                local textSize = game:GetService("TextService"):GetTextSize(ToolTipText, 12, Enum.Font.Gotham, Vector2.new(math.huge, 16))

                keybind.MouseEnter:Connect(function()
                    container.Position = UDim2.new(0, keybind.AbsolutePosition.X + keybind.AbsoluteSize.X + 30, 0, keybind.AbsolutePosition.Y)
                    container:TweenSize(UDim2.new(0, textSize.X + 70, 0, 30), Enum.EasingDirection.In,	Enum.EasingStyle.Sine, .8, true, function()
                        if container.Size == UDim2.new(0, textSize.X + 70, 0, 30) then
                            container.Text.Visible = true
                        end
                    end)                
                end)
                keybind.MouseLeave:Connect(function()
                    container:TweenSize(UDim2.new(0, 0, 0, 30), Enum.EasingDirection.In, Enum.EasingStyle.Sine, .5, true, function()
                        container.Text.Visible = false
                    end)
                    container.Text.Visible = false
                end)
            end
            
            table.insert(self.modules, keybind)
            --self:Resize()
            
            local text = keybind.Button.Text
            local button = keybind.Button
            
            local animate = function()
                if button.ImageTransparency == themes.Transparency then
                    utility:Pop(button, 10)
                end
            end
            
            self.binds[keybind] = {callback = function()
                animate()
                
                if callback then
                    callback(function(...)
                        self:updateKeybind(keybind, ...)
                    end)
                end
            end}
            
            if default and callback then
                self:updateKeybind(keybind, nil, default)
            end
            
            keybind.MouseButton1Click:Connect(function()
                
                animate()
                
                if self.binds[keybind].connection then -- unbind
                    return self:updateKeybind(keybind)
                end
                
                if text.Text == "None" then -- new bind
                    text.Text = "..."
                    
                    local key = utility:KeyPressed()
                    
                    self:updateKeybind(keybind, nil, key.KeyCode)
                    animate()
                    
                    if changedCallback then
                        changedCallback(key, function(...)
                            self:updateKeybind(keybind, ...)
                        end)
                    end
                end
            end)
            
            if search then
                config.Title, config.Default, config.Callback, config.ChangedCallback, config.Search, config.ToolTipText = title, default, callback, changedCallback, search, ToolTipText
                table.insert(SearchModules, {class = "addKeybind", variables = config})
            end
            return keybind
        end

        function section:addColorPicker(config)
            local config = config or {}
            local title, default, callback, search, ToolTipText = config.Title or "ColorPicker", config.Default or Color3.new(1, 1, 1), config.Callback or function()end, config.Search or false, config.ToolTipText
            local colorpicker = utility:Create("ImageButton", {
                Name = "ColorPicker",
                Parent = self.container,
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
                Size = UDim2.new(1, 0, 0, 30),
                ZIndex = 2,
                Image = "rbxassetid://5028857472",
                ImageColor3 = themes.DarkContrast,
                ImageTransparency = themes.Transparency,
                ScaleType = Enum.ScaleType.Slice,
                SliceCenter = Rect.new(2, 2, 298, 298)
            },{
                utility:Create("TextLabel", {
                    Name = "Title",
                    AnchorPoint = Vector2.new(0, 0.5),
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 10, 0.5, 1),
                    Size = UDim2.new(0.5, 0, 1, 0),
                    ZIndex = 3,
                    Font = Enum.Font.Gotham,
                    Text = title,
                    TextColor3 = themes.TextColor,
                    TextSize = 12,
                    TextTransparency = 0.10000000149012,
                    TextXAlignment = Enum.TextXAlignment.Left
                }),
                utility:Create("ImageButton", {
                    Name = "Button",
                    BackgroundTransparency = 1,
                    BorderSizePixel = 0,
                    Position = UDim2.new(1, -50, 0.5, -7),
                    Size = UDim2.new(0, 40, 0, 14),
                    ZIndex = 2,
                    Image = "rbxassetid://5028857472",
                    ImageColor3 = Color3.fromRGB(255, 255, 255),
                    ScaleType = Enum.ScaleType.Slice,
                    SliceCenter = Rect.new(2, 2, 298, 298)
                })
            })

            if ToolTipText then
                local container = utility:Create("ImageLabel", {
                    Name = "ToolTip",
                    Parent = self.page.library.container,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(0, 0, 0, 30),
                    Image = "rbxassetid://4641149554",
                    ImageColor3 = themes.Background,
                    ImageTransparency = themes.Transparency
                }, {
                    utility:Create("TextLabel", {
                        Name = "Text",
                        BackgroundTransparency = 1,
                        Visible = false,
                        Size = UDim2.new(1, 0, 0, 30),
                        ZIndex = 3,
                        Font = Enum.Font.Gotham,
                        Text = ToolTipText,
                        TextColor3 = themes.TextColor,
                        TextSize = 12,
                        TextTransparency = 0.10000000149012
                    })
                })
                local textSize = game:GetService("TextService"):GetTextSize(ToolTipText, 12, Enum.Font.Gotham, Vector2.new(math.huge, 16))

                colorpicker.MouseEnter:Connect(function()
                    container.Position = UDim2.new(0, colorpicker.AbsolutePosition.X + colorpicker.AbsoluteSize.X + 30, 0, colorpicker.AbsolutePosition.Y)
                    container:TweenSize(UDim2.new(0, textSize.X + 70, 0, 30), Enum.EasingDirection.In,	Enum.EasingStyle.Sine, .8, true, function()
                        if container.Size == UDim2.new(0, textSize.X + 70, 0, 30) then
                            container.Text.Visible = true
                        end
                    end)                
                end)
                colorpicker.MouseLeave:Connect(function()
                    container:TweenSize(UDim2.new(0, 0, 0, 30), Enum.EasingDirection.In, Enum.EasingStyle.Sine, .5, true, function()
                        container.Text.Visible = false
                    end)
                    container.Text.Visible = false
                end)
            end
            
            local tab = utility:Create("ImageLabel", {
                Name = "ColorPicker",
                Parent = self.page.library.container,
                BackgroundTransparency = 1,
                Position = UDim2.new(0.75, 0, 0.400000006, 0),
                Selectable = true,
                AnchorPoint = Vector2.new(0.5, 0.5),
                Size = UDim2.new(0, 162, 0, 169),
                Image = "rbxassetid://5028857472",
                ImageColor3 = themes.Background,
                ImageTransparency = themes.Transparency,
                ScaleType = Enum.ScaleType.Slice,
                SliceCenter = Rect.new(2, 2, 298, 298),
                Visible = false,
            }, {
                utility:Create("ImageLabel", {
                    Name = "Glow",
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, -15, 0, -15),
                    Size = UDim2.new(1, 30, 1, 30),
                    ZIndex = 0,
                    Image = "rbxassetid://5028857084",
                    ImageColor3 = themes.Glow,
                    ScaleType = Enum.ScaleType.Slice,
                    SliceCenter = Rect.new(22, 22, 278, 278)
                }),
                utility:Create("TextLabel", {
                    Name = "Title",
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 10, 0, 8),
                    Size = UDim2.new(1, -40, 0, 16),
                    ZIndex = 2,
                    Font = Enum.Font.GothamSemibold,
                    Text = title,
                    TextColor3 = themes.TextColor,
                    TextSize = 14,
                    TextXAlignment = Enum.TextXAlignment.Left
                }),
                utility:Create("ImageButton", {
                    Name = "Close",
                    BackgroundTransparency = 1,
                    Position = UDim2.new(1, -26, 0, 8),
                    Size = UDim2.new(0, 16, 0, 16),
                    ZIndex = 2,
                    Image = "rbxassetid://5012538583",
                    ImageColor3 = themes.TextColor
                }), 
                utility:Create("Frame", {
                    Name = "Container",
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 8, 0, 32),
                    Size = UDim2.new(1, -18, 1, -40)
                }, {
                    utility:Create("UIListLayout", {
                        SortOrder = Enum.SortOrder.LayoutOrder,
                        Padding = UDim.new(0, 6)
                    }),
                    utility:Create("ImageButton", {
                        Name = "Canvas",
                        BackgroundTransparency = 1,
                        BorderColor3 = themes.LightContrast,
                        Size = UDim2.new(1, 0, 0, 60),
                        AutoButtonColor = false,
                        Image = "rbxassetid://5108535320",
                        ImageColor3 = Color3.fromRGB(255, 0, 0),
                        ScaleType = Enum.ScaleType.Slice,
                        SliceCenter = Rect.new(2, 2, 298, 298)
                    }, {
                        utility:Create("ImageLabel", {
                            Name = "White_Overlay",
                            BackgroundTransparency = 1,
                            Size = UDim2.new(1, 0, 0, 60),
                            Image = "rbxassetid://5107152351",
                            SliceCenter = Rect.new(2, 2, 298, 298)
                        }),
                        utility:Create("ImageLabel", {
                            Name = "Black_Overlay",
                            BackgroundTransparency = 1,
                            Size = UDim2.new(1, 0, 0, 60),
                            Image = "rbxassetid://5107152095",
                            SliceCenter = Rect.new(2, 2, 298, 298)
                        }),
                        utility:Create("ImageLabel", {
                            Name = "Cursor",
                            BackgroundColor3 = themes.TextColor,
                            AnchorPoint = Vector2.new(0.5, 0.5),
                            BackgroundTransparency = 1.000,
                            Size = UDim2.new(0, 10, 0, 10),
                            Position = UDim2.new(0, 0, 0, 0),
                            Image = "rbxassetid://5100115962",
                            SliceCenter = Rect.new(2, 2, 298, 298)
                        })
                    }),
                    utility:Create("ImageButton", {
                        Name = "Color",
                        BackgroundTransparency = 1,
                        BorderSizePixel = 0,
                        Position = UDim2.new(0, 0, 0, 4),
                        Selectable = false,
                        Size = UDim2.new(1, 0, 0, 16),
                        ZIndex = 2,
                        AutoButtonColor = false,
                        Image = "rbxassetid://5028857472",
                        ScaleType = Enum.ScaleType.Slice,
                        SliceCenter = Rect.new(2, 2, 298, 298)
                    }, {
                        utility:Create("Frame", {
                            Name = "Select",
                            BackgroundColor3 = themes.TextColor,
                            BorderSizePixel = 1,
                            Position = UDim2.new(1, 0, 0, 0),
                            Size = UDim2.new(0, 2, 1, 0),
                            ZIndex = 2
                        }),
                        utility:Create("UIGradient", { -- rainbow canvas
                            Color = ColorSequence.new({
                                ColorSequenceKeypoint.new(0.00, Color3.fromRGB(255, 0, 0)), 
                                ColorSequenceKeypoint.new(0.17, Color3.fromRGB(255, 255, 0)), 
                                ColorSequenceKeypoint.new(0.33, Color3.fromRGB(0, 255, 0)), 
                                ColorSequenceKeypoint.new(0.50, Color3.fromRGB(0, 255, 255)), 
                                ColorSequenceKeypoint.new(0.66, Color3.fromRGB(0, 0, 255)), 
                                ColorSequenceKeypoint.new(0.82, Color3.fromRGB(255, 0, 255)), 
                                ColorSequenceKeypoint.new(1.00, Color3.fromRGB(255, 0, 0))
                            })
                        })
                    }),
                    utility:Create("Frame", {
                        Name = "Inputs",
                        BackgroundTransparency = 1,
                        Position = UDim2.new(0, 10, 0, 158),
                        Size = UDim2.new(1, 0, 0, 16)
                    }, {
                        utility:Create("UIListLayout", {
                            FillDirection = Enum.FillDirection.Horizontal,
                            SortOrder = Enum.SortOrder.LayoutOrder,
                            Padding = UDim.new(0, 6)
                        }),
                        utility:Create("ImageLabel", {
                            Name = "R",
                            BackgroundTransparency = 1,
                            BorderSizePixel = 0,
                            Size = UDim2.new(0.305, 0, 1, 0),
                            ZIndex = 2,
                            Image = "rbxassetid://5028857472",
                            ImageColor3 = themes.DarkContrast,
                            ImageTransparency = themes.Transparency,
                            ScaleType = Enum.ScaleType.Slice,
                            SliceCenter = Rect.new(2, 2, 298, 298)
                        }, {
                            utility:Create("TextLabel", {
                                Name = "Text",
                                BackgroundTransparency = 1,
                                Size = UDim2.new(0.400000006, 0, 1, 0),
                                ZIndex = 2,
                                Font = Enum.Font.Gotham,
                                Text = "R:",
                                TextColor3 = themes.TextColor,
                                TextSize = 10.000
                            }),
                            utility:Create("TextBox", {
                                Name = "Textbox",
                                BackgroundTransparency = 1,
                                Position = UDim2.new(0.300000012, 0, 0, 0),
                                Size = UDim2.new(0.600000024, 0, 1, 0),
                                ZIndex = 2,
                                Font = Enum.Font.Gotham,
                                PlaceholderColor3 = themes.DarkContrast,
                                Text = "255",
                                TextColor3 = themes.TextColor,
                                TextSize = 10.000
                            })
                        }),
                        utility:Create("ImageLabel", {
                            Name = "G",
                            BackgroundTransparency = 1,
                            BorderSizePixel = 0,
                            Size = UDim2.new(0.305, 0, 1, 0),
                            ZIndex = 2,
                            Image = "rbxassetid://5028857472",
                            ImageColor3 = themes.DarkContrast,
                            ImageTransparency = themes.Transparency,
                            ScaleType = Enum.ScaleType.Slice,
                            SliceCenter = Rect.new(2, 2, 298, 298)
                        }, {
                            utility:Create("TextLabel", {
                                Name = "Text",
                                BackgroundTransparency = 1,
                                ZIndex = 2,
                                Size = UDim2.new(0.400000006, 0, 1, 0),
                                Font = Enum.Font.Gotham,
                                Text = "G:",
                                TextColor3 = themes.TextColor,
                                TextSize = 10.000
                            }),
                            utility:Create("TextBox", {
                                Name = "Textbox",
                                BackgroundTransparency = 1,
                                Position = UDim2.new(0.300000012, 0, 0, 0),
                                Size = UDim2.new(0.600000024, 0, 1, 0),
                                ZIndex = 2,
                                Font = Enum.Font.Gotham,
                                Text = "255",
                                TextColor3 = themes.TextColor,
                                TextSize = 10.000
                            })
                        }),
                        utility:Create("ImageLabel", {
                            Name = "B",
                            BackgroundTransparency = 1,
                            BorderSizePixel = 0,
                            Size = UDim2.new(0.305, 0, 1, 0),
                            ZIndex = 2,
                            Image = "rbxassetid://5028857472",
                            ImageColor3 = themes.DarkContrast,
                            ImageTransparency = themes.Transparency,
                            ScaleType = Enum.ScaleType.Slice,
                            SliceCenter = Rect.new(2, 2, 298, 298)
                        }, {
                            utility:Create("TextLabel", {
                                Name = "Text",
                                BackgroundTransparency = 1,
                                Size = UDim2.new(0.400000006, 0, 1, 0),
                                ZIndex = 2,
                                Font = Enum.Font.Gotham,
                                Text = "B:",
                                TextColor3 = themes.TextColor,
                                TextSize = 10.000
                            }),
                            utility:Create("TextBox", {
                                Name = "Textbox",
                                BackgroundTransparency = 1,
                                Position = UDim2.new(0.300000012, 0, 0, 0),
                                Size = UDim2.new(0.600000024, 0, 1, 0),
                                ZIndex = 2,
                                Font = Enum.Font.Gotham,
                                Text = "255",
                                TextColor3 = themes.TextColor,
                                TextSize = 10.000
                            })
                        }),
                    }),
                    utility:Create("ImageButton", {
                        Name = "Button",
                        BackgroundTransparency = 1,
                        BorderSizePixel = 0,
                        Size = UDim2.new(1, 0, 0, 20),
                        ZIndex = 2,
                        Image = "rbxassetid://5028857472",
                        ImageColor3 = themes.DarkContrast,
                        ImageTransparency = themes.Transparency,
                        ScaleType = Enum.ScaleType.Slice,
                        SliceCenter = Rect.new(2, 2, 298, 298)
                    }, {
                        utility:Create("TextLabel", {
                            Name = "Text",
                            BackgroundTransparency = 1,
                            Size = UDim2.new(1, 0, 1, 0),
                            ZIndex = 3,
                            Font = Enum.Font.Gotham,
                            Text = "Submit",
                            TextColor3 = themes.TextColor,
                            TextSize = 11.000
                        })
                    })
                })
            })
            
            utility:DraggingEnabled(tab)
            table.insert(self.modules, colorpicker)
            --self:Resize()
            
            local allowed = {
                [""] = true
            }
            
            local canvas = tab.Container.Canvas
            local color = tab.Container.Color
            
            local canvasSize, canvasPosition = canvas.AbsoluteSize, canvas.AbsolutePosition
            local colorSize, colorPosition = color.AbsoluteSize, color.AbsolutePosition
            
            local draggingColor, draggingCanvas
            
            local color3 = default or Color3.fromRGB(255, 255, 255)
            local hue, sat, brightness = 0, 0, 1
            local rgb = {
                r = 255,
                g = 255,
                b = 255
            }
            
            self.colorpickers[colorpicker] = {
                tab = tab,
                callback = function(prop, value)
                    rgb[prop] = value
                    hue, sat, brightness = Color3.toHSV(Color3.fromRGB(rgb.r, rgb.g, rgb.b))
                end
            }
            
            local callback = function(value)
                if callback then
                    callback(value, function(...)
                        self:updateColorPicker(colorpicker, ...)
                    end)
                end
            end
            
            utility:DraggingEnded(function()
                draggingColor, draggingCanvas = false, false
            end)
            
            if default then
                self:updateColorPicker(colorpicker, nil, default)
                
                hue, sat, brightness = Color3.toHSV(default)
                default = Color3.fromHSV(hue, sat, brightness)
                
                for i, prop in pairs({"r", "g", "b"}) do
                    rgb[prop] = default[prop:upper()] * 255
                end
            end
            
            for i, container in pairs(tab.Container.Inputs:GetChildren()) do -- i know what you are about to say, so shut up
                if container:IsA("ImageLabel") then
                    local textbox = container.Textbox
                    local focused
                    
                    textbox.Focused:Connect(function()
                        focused = true
                    end)
                    
                    textbox.FocusLost:Connect(function()
                        focused = false
                        
                        if not tonumber(textbox.Text) then
                            textbox.Text = math.floor(rgb[container.Name:lower()])
                        end
                    end)
                    
                    textbox:GetPropertyChangedSignal("Text"):Connect(function()
                        local text = textbox.Text
                        
                        if not allowed[text] and not tonumber(text) then
                            textbox.Text = text:sub(1, #text - 1)
                        elseif focused and not allowed[text] then
                            rgb[container.Name:lower()] = math.clamp(tonumber(textbox.Text), 0, 255)
                            
                            local color3 = Color3.fromRGB(rgb.r, rgb.g, rgb.b)
                            hue, sat, brightness = Color3.toHSV(color3)
                            
                            self:updateColorPicker(colorpicker, nil, color3)
                            callback(color3)
                        end
                    end)
                end
            end
            
            canvas.MouseButton1Down:Connect(function()
                draggingCanvas = true
                
                while draggingCanvas do
                    
                    local x, y = mouse.X, mouse.Y
                    
                    sat = math.clamp((x - canvasPosition.X) / canvasSize.X, 0, 1)
                    brightness = 1 - math.clamp((y - canvasPosition.Y) / canvasSize.Y, 0, 1)
                    
                    color3 = Color3.fromHSV(hue, sat, brightness)
                    
                    for i, prop in pairs({"r", "g", "b"}) do
                        rgb[prop] = color3[prop:upper()] * 255
                    end
                    
                    self:updateColorPicker(colorpicker, nil, {hue, sat, brightness}) -- roblox is literally retarded
                    utility:Tween(canvas.Cursor, {Position = UDim2.new(sat, 0, 1 - brightness, 0)}, 0.1) -- overwrite
                    
                    callback(color3)
                    utility:Wait()
                end
            end)
            
            color.MouseButton1Down:Connect(function()
                draggingColor = true
                
                while draggingColor do
                
                    hue = 1 - math.clamp(1 - ((mouse.X - colorPosition.X) / colorSize.X), 0, 1)
                    color3 = Color3.fromHSV(hue, sat, brightness)
                    
                    for i, prop in pairs({"r", "g", "b"}) do
                        rgb[prop] = color3[prop:upper()] * 255
                    end
                    
                    local x = hue -- hue is updated
                    self:updateColorPicker(colorpicker, nil, {hue, sat, brightness}) -- roblox is literally retarded
                    utility:Tween(tab.Container.Color.Select, {Position = UDim2.new(x, 0, 0, 0)}, 0.1) -- overwrite
                    
                    callback(color3)
                    utility:Wait()
                end
            end)
            
            -- click events
            local button = colorpicker.Button
            local toggle, debounce, animate
            
            lastColor = Color3.fromHSV(hue, sat, brightness)
            animate = function(visible, overwrite)
                
                if overwrite then
                
                    if not toggle then
                        return
                    end
                    
                    if debounce then
                        while debounce do
                            utility:Wait()
                        end
                    end
                elseif not overwrite then
                    if debounce then 
                        return 
                    end
                    
                    if button.ImageTransparency == themes.Transparency then
                        utility:Pop(button, 10)
                    end
                end
                
                toggle = visible
                debounce = true
                
                if visible then
                
                    if self.page.library.activePicker and self.page.library.activePicker ~= animate then
                        self.page.library.activePicker(nil, true)
                    end
                    
                    self.page.library.activePicker = animate
                    lastColor = Color3.fromHSV(hue, sat, brightness)
                    
                    local x1, x2 = button.AbsoluteSize.X / 2, 162--tab.AbsoluteSize.X
                    local px, py = button.AbsolutePosition.X, button.AbsolutePosition.Y
                    
                    tab.ClipsDescendants = true
                    tab.Visible = true
                    tab.Size = UDim2.new(0, 0, 0, 0)
                    
                    tab.Position = UDim2.new(0, x1 + x2 + px, 0, py)
                    utility:Tween(tab, {Size = UDim2.new(0, 162, 0, 169)}, 0.2)
                    
                    -- update size and position
                    wait(0.2)
                    tab.ClipsDescendants = false
                    
                    canvasSize, canvasPosition = canvas.AbsoluteSize, canvas.AbsolutePosition
                    colorSize, colorPosition = color.AbsoluteSize, color.AbsolutePosition
                else
                    utility:Tween(tab, {Size = UDim2.new(0, 0, 0, 0)}, 0.2)
                    tab.ClipsDescendants = true
                    
                    wait(0.2)
                    tab.Visible = false
                end
                
                debounce = false
            end
            
            local toggleTab = function()
                animate(not toggle)
            end
            
            button.MouseButton1Click:Connect(toggleTab)
            colorpicker.MouseButton1Click:Connect(toggleTab)
            
            tab.Container.Button.MouseButton1Click:Connect(function()
                animate()
            end)
            
            tab.Close.MouseButton1Click:Connect(function()
                self:updateColorPicker(colorpicker, nil, lastColor)
                animate()
            end)
            
            if search then
                config.Title, config.Default, config.Callback, config.Search, config.ToolTipText = title, default, callback, search, ToolTipText
                table.insert(SearchModules, {class = "addColorPicker", variables = config})
            end
            return colorpicker
        end

        function section:addSlider(config)
            local config = config or {}
            local title, default, min, max, inc, callback, search, ToolTipText = config.Title or "Slider", config.Default or 0, config.Min or 0, config.Max or 1, config.Increment or 1, config.Callback or function()end, config.Search or false, config.ToolTipText
            local slider = utility:Create("ImageButton", {
                Name = "Slider",
                Parent = self.container,
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
                Position = UDim2.new(0.292817682, 0, 0.299145311, 0),
                Size = UDim2.new(1, 0, 0, 50),
                ZIndex = 2,
                Image = "rbxassetid://5028857472",
                ImageColor3 = themes.DarkContrast,
                ImageTransparency = themes.Transparency,
                ScaleType = Enum.ScaleType.Slice,
                SliceCenter = Rect.new(2, 2, 298, 298)
            }, {
                utility:Create("TextLabel", {
                    Name = "Title",
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 10, 0, 6),
                    Size = UDim2.new(0.5, 0, 0, 16),
                    ZIndex = 3,
                    Font = Enum.Font.Gotham,
                    Text = title,
                    TextColor3 = themes.TextColor,
                    TextSize = 12,
                    TextTransparency = 0.10000000149012,
                    TextXAlignment = Enum.TextXAlignment.Left
                }),
                utility:Create("TextBox", {
                    Name = "TextBox",
                    BackgroundTransparency = 1,
                    BorderSizePixel = 0,
                    Position = UDim2.new(1, -30, 0, 6),
                    Size = UDim2.new(0, 20, 0, 16),
                    ZIndex = 3,
                    Font = Enum.Font.GothamSemibold,
                    Text = default or min,
                    TextColor3 = themes.TextColor,
                    TextSize = 12,
                    TextXAlignment = Enum.TextXAlignment.Right
                }),
                utility:Create("TextLabel", {
                    Name = "Slider",
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 10, 0, 28),
                    Size = UDim2.new(1, -20, 0, 16),
                    ZIndex = 3,
                    Text = "",
                }, {
                    utility:Create("ImageLabel", {
                        Name = "Bar",
                        AnchorPoint = Vector2.new(0, 0.5),
                        BackgroundTransparency = 1,
                        Position = UDim2.new(0, 0, 0.5, 0),
                        Size = UDim2.new(1, 0, 0, 4),
                        ZIndex = 3,
                        Image = "rbxassetid://5028857472",
                        ImageColor3 = themes.LightContrast,
                        ScaleType = Enum.ScaleType.Slice,
                        SliceCenter = Rect.new(2, 2, 298, 298)
                    }, {
                        utility:Create("ImageLabel", {
                            Name = "Fill",
                            BackgroundTransparency = 1,
                            Size = UDim2.new(0, 0, 0, 0),
                            ZIndex = 3,
                            Image = "rbxassetid://5028857472",
                            ImageColor3 = themes.TextColor,
                            ScaleType = Enum.ScaleType.Slice,
                            SliceCenter = Rect.new(2, 2, 298, 298)
                        }, {
                            utility:Create("ImageLabel", {
                                Name = "Circle",
                                AnchorPoint = Vector2.new(0.5, 0.5),
                                BackgroundTransparency = 1,
                                ImageTransparency = 1.000,
                                ImageColor3 = themes.TextColor,
                                Position = UDim2.new(1, 0, 0.5, 0),
                                Size = UDim2.new(0, 10, 0, 10),
                                ZIndex = 3,
                                Image = "rbxassetid://4608020054"
                            })
                        })
                    })
                })
            })

            if ToolTipText then
                local container = utility:Create("ImageLabel", {
                    Name = "ToolTip",
                    Parent = self.page.library.container,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(0, 0, 0, 30),
                    Image = "rbxassetid://4641149554",
                    ImageColor3 = themes.Background,
                    ImageTransparency = themes.Transparency
                }, {
                    utility:Create("TextLabel", {
                        Name = "Text",
                        BackgroundTransparency = 1,
                        Visible = false,
                        Size = UDim2.new(1, 0, 0, 30),
                        ZIndex = 3,
                        Font = Enum.Font.Gotham,
                        Text = ToolTipText,
                        TextColor3 = themes.TextColor,
                        TextSize = 12,
                        TextTransparency = 0.10000000149012
                    })
                })
                local textSize = game:GetService("TextService"):GetTextSize(ToolTipText, 12, Enum.Font.Gotham, Vector2.new(math.huge, 16))

                slider.MouseEnter:Connect(function()
                    container.Position = UDim2.new(0, slider.AbsolutePosition.X + slider.AbsoluteSize.X + 30, 0, slider.AbsolutePosition.Y)
                    container:TweenSize(UDim2.new(0, textSize.X + 70, 0, 30), Enum.EasingDirection.In,	Enum.EasingStyle.Sine, .8, true, function()
                        if container.Size == UDim2.new(0, textSize.X + 70, 0, 30) then
                            container.Text.Visible = true
                        end
                    end)                
                end)
                slider.MouseLeave:Connect(function()
                    container:TweenSize(UDim2.new(0, 0, 0, 30), Enum.EasingDirection.In, Enum.EasingStyle.Sine, .5, true, function()
                        container.Text.Visible = false
                    end)
                    container.Text.Visible = false
                end)
            end
            
            table.insert(self.modules, slider)
            --self:Resize()
            
            local allowed = {
                [""] = true,
                ["-"] = true
            }
            
            local textbox = slider.TextBox
            local fill = slider.Slider.Bar.Fill
            local circle = slider.Slider.Bar.Fill.Circle
            
            local value = default or min
            local dragging, last
            
            local callback = function(value)
                if callback then
                    callback(value, function(...)
                        self:updateSlider(slider, ...)
                    end)
                end
            end

            self:updateSlider(slider, nil, value, min, max, inc)
            
            utility:DraggingEnded(function()
                dragging = false
            end)

            slider.MouseButton1Down:Connect(function(input)
                dragging = true
                
                while dragging do
                    utility:Tween(circle, {ImageTransparency = 0}, 0.1)
                    
                    value = self:updateSlider(slider, nil, nil, min, max, inc, value)
                    callback(value)
                    
                    utility:Wait()
                end
                
                wait(0.5)
                utility:Tween(circle, {ImageTransparency = 1}, 0.2)
            end)
            
            textbox.FocusLost:Connect(function()
                if not tonumber(textbox.Text) then
                    value = self:updateSlider(slider, nil, nil, default or min, max, inc)
                    callback(value)
                elseif textbox.Text == "" or tonumber(textbox.Text) <= min then
                    value = self:updateSlider(slider, nil, nil, min, max, inc)
                    callback(value)
                elseif textbox.Text == "" or tonumber(textbox.Text) >= max then
                    value = self:updateSlider(slider, nil, nil, max, max, inc)
                    callback(value)
                end

                fill.Size = UDim2.new(math.clamp((textbox.Text - min) / (max - min), 0, 1), 0, 1, 0) 
            end)
            
            --[[textbox:GetPropertyChangedSignal("Text"):Connect(function()
                local text = textbox.Text
                
                if not allowed[text] and not tonumber(text) then
                    textbox.Text = text:sub(1, #text - 1)
                elseif not allowed[text] then	
                    value = self:updateSlider(slider, nil, tonumber(text) or value, min, max)
                    callback(value)
                end
            end)]]
            
            if search then
                config.Title, config.Default, config.Min, config.Max, config.Increment, config.Callback, config.Search, config.ToolTipText = title, default, min, max, inc, callback, search, ToolTipText
                table.insert(SearchModules, {class = "addSlider", variables = config})
            end
            return slider
        end

        function section:addDropdown(config)
            local config = config or {}
            local title, list, multi, callback, search, default, ToolTipText = config.Title or "Dropdown", config.List or {}, config.Multi or false, config.Callback or function()end, config.Search or false, config.Default, config.ToolTipText
            local dropdown = utility:Create("Frame", {
                Name = "Dropdown",
                Parent = self.container,
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 30),
                ClipsDescendants = true
            }, {
                utility:Create("UIListLayout", {
                    SortOrder = Enum.SortOrder.LayoutOrder,
                    Padding = UDim.new(0, 4)
                }),
                utility:Create("ImageLabel", {
                    Name = "Search",
                    BackgroundTransparency = 1,
                    BorderSizePixel = 0,
                    Size = UDim2.new(1, 0, 0, 30),
                    ZIndex = 2,
                    Image = "rbxassetid://5028857472",
                    ImageColor3 = themes.DarkContrast,
                    ImageTransparency = themes.Transparency,
                    ScaleType = Enum.ScaleType.Slice,
                    SliceCenter = Rect.new(2, 2, 298, 298)
                }, {
                    utility:Create("TextBox", {
                        Name = "TextBox",
                        AnchorPoint = Vector2.new(0, 0.5),
                        BackgroundTransparency = 1,
                        TextTruncate = Enum.TextTruncate.AtEnd,
                        Position = UDim2.new(0, 10, 0.5, 1),
                        Size = UDim2.new(1, -42, 1, 0),
                        ZIndex = 3,
                        Font = Enum.Font.Gotham,
                        Text = title,
                        TextColor3 = themes.TextColor,
                        TextSize = 12,
                        TextTransparency = 0.10000000149012,
                        TextXAlignment = Enum.TextXAlignment.Left
                    }),
                    utility:Create("ImageButton", {
                        Name = "Button",
                        BackgroundTransparency = 1,
                        BorderSizePixel = 0,
                        Position = UDim2.new(1, -28, 0.5, -9),
                        Size = UDim2.new(0, 18, 0, 18),
                        ZIndex = 3,
                        Image = "rbxassetid://5012539403",
                        ImageColor3 = themes.TextColor,
                        ImageTransparency = themes.Transparency,
                        SliceCenter = Rect.new(2, 2, 298, 298)
                    })
                }),
                utility:Create("ImageLabel", {
                    Name = "List",
                    BackgroundTransparency = 1,
                    BorderSizePixel = 0,
                    Size = UDim2.new(1, 0, 1, -34),
                    ZIndex = 2,
                    Image = "rbxassetid://5028857472",
                    ImageColor3 = themes.Background,
                    ImageTransparency = themes.Transparency,
                    ScaleType = Enum.ScaleType.Slice,
                    SliceCenter = Rect.new(2, 2, 298, 298)
                }, {
                    utility:Create("ScrollingFrame", {
                        Name = "Frame",
                        Active = true,
                        BackgroundTransparency = 1,
                        BorderSizePixel = 0,
                        Position = UDim2.new(0, 4, 0, 4),
                        Size = UDim2.new(1, -8, 1, -8),
                        CanvasPosition = Vector2.new(0, 28),
                        CanvasSize = UDim2.new(0, 0, 0, 120),
                        ZIndex = 2,
                        ScrollBarThickness = 3,
                        ScrollBarImageColor3 = themes.TextColor
                    }, {
                        utility:Create("UIListLayout", {
                            SortOrder = Enum.SortOrder.LayoutOrder,
                            Padding = UDim.new(0, 4)
                        })
                    })
                })
            })
            
            if ToolTipText then
                local container = utility:Create("ImageLabel", {
                Name = "ToolTip",
                Parent = self.page.library.container,
                BackgroundTransparency = 1,
                Size = UDim2.new(0, 0, 0, 30),
                Image = "rbxassetid://4641149554",
                ImageColor3 = themes.Background,
                ImageTransparency = themes.Transparency
                }, {
                    utility:Create("TextLabel", {
                        Name = "Text",
                        BackgroundTransparency = 1,
                        Visible = false,
                        Size = UDim2.new(1, 0, 0, 30),
                        ZIndex = 3,
                        Font = Enum.Font.Gotham,
                        Text = ToolTipText,
                        TextColor3 = themes.TextColor,
                        TextSize = 12,
                        TextTransparency = 0.10000000149012
                    })
                })

                local textSize = game:GetService("TextService"):GetTextSize(ToolTipText, 12, Enum.Font.Gotham, Vector2.new(math.huge, 16))

                dropdown.MouseEnter:Connect(function()
                    container.Position = UDim2.new(0, dropdown.AbsolutePosition.X + dropdown.AbsoluteSize.X + 30, 0, dropdown.AbsolutePosition.Y)
                    container:TweenSize(UDim2.new(0, textSize.X + 70, 0, 30), Enum.EasingDirection.In,	Enum.EasingStyle.Sine, .8, true, function()
                        if container.Size == UDim2.new(0, textSize.X + 70, 0, 30) then
                            container.Text.Visible = true
                        end
                    end)                
                end)
                dropdown.MouseLeave:Connect(function()
                    container:TweenSize(UDim2.new(0, 0, 0, 30), Enum.EasingDirection.In, Enum.EasingStyle.Sine, .5, true, function()
                        container.Text.Visible = false
                    end)
                    container.Text.Visible = false
                end)
            end
            
            table.insert(self.modules, dropdown)
            --self:Resize()
            
            local search = dropdown.Search
            local focused
            
            list = list or {}
            local multiList = {}
            
            search.Button.MouseButton1Click:Connect(function()
                if search.Button.Rotation == 0 then
                    self:updateDropdown(dropdown, nil, multi, default, list, callback, multiList)
                else
                    self:updateDropdown(dropdown, nil, multi, default, nil, callback, multiList)
                end
            end)
            
            search.TextBox.Focused:Connect(function()
                if search.Button.Rotation == 0 then
                    self:updateDropdown(dropdown, nil, multi, default, list, callback, multiList)
                end
                
                focused = true
            end)
            
            search.TextBox.FocusLost:Connect(function()
                focused = false
            end)
            
            search.TextBox:GetPropertyChangedSignal("Text"):Connect(function()
                if focused then
                    local list = utility:Sort(search.TextBox.Text, list)
                    list = #list ~= 0 and list 
                    
                    self:updateDropdown(dropdown, nil, multi, default, list, callback, multiList)
                end
            end)
            
            dropdown:GetPropertyChangedSignal("Size"):Connect(function()
                self:Resize()
            end)
            
            if search then
                config.Title, config.List, config.Multi, config.Callback, config.Search, config.Default, config.ToolTipText = title, list, multi, callback, search, default, ToolTipText
                table.insert(SearchModules, {class = "addDropdown", variables = config})
            end
            return dropdown
        end

        -- class functions

        function library:SelectPage(page, toggle)
            
            if toggle and self.focusedPage == page then -- already selected
                return
            end
            
            local button = page.button
            
            if toggle then
                -- page button
                pcall(function()
                    local function hasProperty(object, prop)
                        local t = object[prop]
                    end
                    for _, v in pairs(button:GetDescendants()) do
                        local success = pcall(function() hasProperty(v, "Font"); hasProperty(v, "TextTransparency") end)
                        if success then
                            v.TextTransparency = 0
                            v.Font = Enum.Font.GothamSemibold
                        end
                    end
                end)

                if button:FindFirstChild("Icon") then
                    button.Icon.ImageTransparency = 0
                end
                
                -- update selected page
                local focusedPage = self.focusedPage
                self.focusedPage = page
                
                if focusedPage then
                    self:SelectPage(focusedPage)
                end
                
                -- sections
                local existingSections = focusedPage and #focusedPage.sections or 0
                local sectionsRequired = #page.sections - existingSections
                
                pcall(function()
                    page:Resize()
                end)
                
                for i, section in pairs(page.sections) do
                    section.container.Parent.ImageTransparency = themes.Transparency
                end
                
                if sectionsRequired < 0 then -- "hides" some sections
                    for i = existingSections, #page.sections + 1, -1 do
                        local section = focusedPage.sections[i].container.Parent
                        
                        utility:Tween(section, {ImageTransparency = 1}, 0.1)
                    end
                end
                
                wait(0.1)
                page.container.Visible = true
                
                if focusedPage then
                    focusedPage.container.Visible = false
                end
                
                if sectionsRequired > 0 then -- "creates" more section
                    for i = existingSections + 1, #page.sections do
                        local section = page.sections[i].container.Parent
                        
                        section.ImageTransparency = 1
                        utility:Tween(section, {ImageTransparency = themes.Transparency}, 0.05)
                    end
                end
                
                wait(0.05)
                
                for i, section in pairs(page.sections) do
                    pcall(function()
                        utility:Tween(section.container.Title, {TextTransparency = 0}, 0.1)
                    end)
                    section:Resize(true)
                    
                    wait(0.05)
                end
                
                wait(0.05)
                pcall(function()
                    page:Resize(true)
                end)
            else
                -- page button
                pcall(function()
                    local function hasProperty(object, prop)
                        local t = object[prop]
                    end
                    for _, v in pairs(button:GetDescendants()) do
                        local success = pcall(function() hasProperty(v, "Font"); hasProperty(v, "TextTransparency") end)
                        if success then
                            v.TextTransparency = 0.65
                            v.Font = Enum.Font.Gotham
                        end
                    end
                end)
                
                if button:FindFirstChild("Icon") then
                    button.Icon.ImageTransparency = 0.65
                end
                
                -- sections
                for i, section in pairs(page.sections) do	
                    utility:Tween(section.container.Parent, {Size = UDim2.new(1, -10, 0, 0)}, 0.2)
                    pcall(function()
                        utility:Tween(section.container.Title, {TextTransparency = 1}, 0.1)
                    end)
                end
                
                wait(0.1)
                
                page.lastPosition = page.container.CanvasPosition.Y
                pcall(function()
                    page:Resize()
                end)
            end
        end

        function page:Resize(scroll)
            local padding = 10
            local size = 0
            
            for i, section in pairs(self.sections) do
                size = size + section.container.Parent.AbsoluteSize.Y + padding
            end
            
            self.container.CanvasSize = UDim2.new(0, 0, 0, size)
            self.container.ScrollBarImageTransparency = size > self.container.AbsoluteSize.Y
            
            if scroll then
                utility:Tween(self.container, {CanvasPosition = Vector2.new(0, self.lastPosition or 0)}, 0.2)
            end
        end

        function section:Resize(smooth)
        
            if self.page.library.focusedPage ~= self.page then
                return
            end
            
            local padding = 4
            local size = (4 * padding) + self.container.Title.AbsoluteSize.Y -- offset
            
            for i, module in pairs(self.modules) do
                size = size + module.AbsoluteSize.Y + padding
            end
            
            if smooth then
                utility:Tween(self.container.Parent, {Size = UDim2.new(1, -10, 0, size)}, 0.05)
            else
                self.container.Parent.Size = UDim2.new(1, -10, 0, size)
                self.page:Resize()
            end
        end

        function section:getModule(info)
        
            if table.find(self.modules, info) then
                return info
            end
            
            for i, module in pairs(self.modules) do
                if (module:FindFirstChild("Title") or module:FindFirstChild("TextBox", true)).Text == info then
                    return module
                end
            end
            
            error("No module found under "..tostring(info))
        end

        function section:clear()
            
            for i, module in pairs(self.modules) do
                module:Destroy()
            end
            table.clear(self.modules)
            self:Resize()
        end

        -- updates

        function section:updateButton(button, title)
            button = self:getModule(button)
            
            button.Title.Text = title
        end

        function section:updateToggle(toggle, title, value)
            toggle = self:getModule(toggle)
            
            local position = {
                In = UDim2.new(0, 2, 0.5, -6),
                Out = UDim2.new(0, 20, 0.5, -6)
            }
            
            local frame = toggle.Button.Frame
            value = value and "Out" or "In"
            
            if title then
                toggle.Title.Text = title
            end
            
            utility:Tween(frame, {
                Size = UDim2.new(1, -22, 1, -9),
                Position = position[value] + UDim2.new(0, 0, 0, 2.5)
            }, 0.2)
            
            wait(0.1)
            utility:Tween(frame, {
                Size = UDim2.new(1, -22, 1, -4),
                Position = position[value]
            }, 0.1)
        end

        function section:updateTextbox(textbox, title, value)
            textbox = self:getModule(textbox)
            
            if title then
                textbox.Title.Text = title
            end
            
            if value then
                textbox.Button.Textbox.Text = value
            end
            
        end

        function section:updateKeybind(keybind, title, key)
            keybind = self:getModule(keybind)
            
            local text = keybind.Button.Text
            local bind = self.binds[keybind]
            
            if title then
                keybind.Title.Text = title
            end
            
            if bind.connection then
                bind.connection = bind.connection:UnBind()
            end
                
            if key then
                self.binds[keybind].connection = utility:BindToKey(key, bind.callback)
                text.Text = key.Name
            else
                text.Text = "None"
            end
        end

        function section:updateColorPicker(colorpicker, title, color)
            colorpicker = self:getModule(colorpicker)
            
            local picker = self.colorpickers[colorpicker]
            local tab = picker.tab
            local callback = picker.callback
            
            if title then
                colorpicker.Title.Text = title
                tab.Title.Text = title
            end
            
            local color3
            local hue, sat, brightness
            
            if type(color) == "table" then -- roblox is literally retarded x2
                hue, sat, brightness = unpack(color)
                color3 = Color3.fromHSV(hue, sat, brightness)
            else
                color3 = color
                hue, sat, brightness = Color3.toHSV(color3)
            end
            
            utility:Tween(colorpicker.Button, {ImageColor3 = color3}, 0.5)
            utility:Tween(tab.Container.Color.Select, {Position = UDim2.new(hue, 0, 0, 0)}, 0.1)
            
            utility:Tween(tab.Container.Canvas, {ImageColor3 = Color3.fromHSV(hue, 1, 1)}, 0.5)
            utility:Tween(tab.Container.Canvas.Cursor, {Position = UDim2.new(sat, 0, 1 - brightness)}, 0.5)
            
            for i, container in pairs(tab.Container.Inputs:GetChildren()) do
                if container:IsA("ImageLabel") then
                    local value = math.clamp(color3[container.Name], 0, 1) * 255
                    
                    container.Textbox.Text = math.floor(value)
                    --callback(container.Name:lower(), value)
                end
            end
        end

        function section:updateSlider(slider, title, value, min, max, inc, lvalue)
            slider = self:getModule(slider)
            
            if title then
                slider.Title.Text = title
            end
            
            local bar = slider.Slider.Bar
            local percent;
            local Increment;
            local SizeRounded;
            local SliderValue;
            
            percent = math.clamp((mouse.X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
            Increment = inc and (max / ((max - min) / (inc * 4))) or (max >= 50 and max / ((max - min) / 4)) or (max >= 25 and max / ((max - min) / 2)) or (max / (max - min))
            SizeRounded = UDim2.new((math.round(percent * ((max / Increment) * 4)) / ((max / Increment) * 4)), 0, 1, 0)
            SliderValue = math.round((((SizeRounded.X.Scale * max) / max) * (max - min) + min) * 20) / 20
            

            if value then -- support negative ranges
                SizeRounded = UDim2.new(math.clamp((value - min) / (max - min), 0, 1), 0, 1, 0)
            end

            value = value or tonumber(string.format("%.2f", SliderValue))
        

            slider.TextBox.Text = value
            utility:Tween(bar.Fill, {Size = SizeRounded}, 0.1)
            
            if value ~= lvalue and slider.ImageTransparency == themes.Transparency then
                utility:Pop(slider, 10)
            end
            
            return value
        end

        function section:updateDropdown(dropdown, title, multi, def, list, callback, multiList)
            dropdown = self:getModule(dropdown)
            
            if title then
                dropdown.Search.TextBox.Text = title
            end
            
            local entries = 0
            
            utility:Pop(dropdown.Search, 10)
            
            for i, button in pairs(dropdown.List.Frame:GetChildren()) do
                if button:IsA("ImageButton") then
                    button:Destroy()
                end
            end
            
            for i, value in pairs(list or {}) do
                local button = utility:Create("ImageButton", {
                    Parent = dropdown.List.Frame,
                    BackgroundTransparency = 1,
                    BorderSizePixel = 0,
                    Size = UDim2.new(1, 0, 0, 30),
                    ZIndex = 2,
                    Image = "rbxassetid://5028857472",
                    ImageColor3 = themes.DarkContrast,
                    ImageTransparency = themes.Transparency,
                    ScaleType = Enum.ScaleType.Slice,
                    SliceCenter = Rect.new(2, 2, 298, 298)
                }, {
                    utility:Create("TextLabel", {
                        BackgroundTransparency = 1,
                        Position = UDim2.new(0, 10, 0, 0),
                        Size = UDim2.new(1, -10, 1, 0),
                        ZIndex = 3,
                        Font = Enum.Font.Gotham,
                        RichText = true,
                        Text = table.find(multiList, value) and "<b><u>" .. value .. "</u></b>" or value,
                        TextColor3 = themes.TextColor,
                        TextSize = 12,
                        TextXAlignment = "Left",
                        TextTransparency = 0.10000000149012
                    })
                })
                
                button.MouseButton1Click:Connect(function()
                    if callback then
                        callback(value, function(...)
                            self:updateDropdown(dropdown, ...)
                        end)
                    end
                    if multi then
                        if table.find(multiList, value) then
                            table.remove(multiList, table.find(multiList, value))
                            self:updateDropdown(dropdown, def .. " | " .. table.concat(multiList, ", ") or table.concat(multiList, ", "), multi, def, nil, callback)
                        else
                            table.insert(multiList, value)
                            self:updateDropdown(dropdown, def .. " | " .. table.concat(multiList, ", ") or table.concat(multiList, ", "), multi, def, nil, callback)
                        end
                    else
                        self:updateDropdown(dropdown, def and def .. " | " .. value or value, multi, def, nil, callback)
                    end
                end)
                
                entries = entries + 1
            end
            
            local frame = dropdown.List.Frame
            
            utility:Tween(dropdown, {Size = UDim2.new(1, 0, 0, (entries == 0 and 30) or math.clamp(entries, 0, 3) * 34 + 38)}, 0.3)
            utility:Tween(dropdown.Search.Button, {Rotation = list and 180 or 0}, 0.3)
            
            if entries > 3 then
            
                for i, button in pairs(dropdown.List.Frame:GetChildren()) do
                    if button:IsA("ImageButton") then
                        button.Size = UDim2.new(1, -6, 0, 30)
                    end
                end
                
                frame.CanvasSize = UDim2.new(0, 0, 0, (entries * 34) - 4)
                frame.ScrollBarImageTransparency = 0
            else
                frame.CanvasSize = UDim2.new(0, 0, 0, 0)
                frame.ScrollBarImageTransparency = 1
            end
        end
    end

    return library
