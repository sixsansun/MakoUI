--[[
    MakoUI.lua
    Dark Roblox UI library inspired by the supplied reference.
    Accent: cyan / electric blue.
    Pure UI library: no aimbot/ESP/gameplay logic is included.

    GitHub usage example:
    local MakoUI = loadstring(game:HttpGet("YOUR_RAW_GITHUB_URL"))()
    local Window = MakoUI:CreateWindow({
        Title = "Mako",
        Logo = "rbxassetid://1234567890"
    })
]]

local MakoUI = {}
MakoUI.__index = MakoUI

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local Theme = {
    Background = Color3.fromRGB(3, 4, 6),
    Sidebar = Color3.fromRGB(4, 5, 7),
    Surface = Color3.fromRGB(5, 6, 8),
    Surface2 = Color3.fromRGB(8, 10, 13),
    Stroke = Color3.fromRGB(34, 38, 44),
    StrokeSoft = Color3.fromRGB(22, 26, 31),
    Text = Color3.fromRGB(225, 229, 235),
    Muted = Color3.fromRGB(83, 89, 98),
    Accent = Color3.fromRGB(0, 190, 255),
    AccentBright = Color3.fromRGB(0, 225, 255),
    ToggleOff = Color3.fromRGB(24, 27, 32),
}

local function new(className, props)
    local obj = Instance.new(className)
    for k, v in pairs(props or {}) do
        if k ~= "Parent" then
            obj[k] = v
        end
    end
    if props and props.Parent then
        obj.Parent = props.Parent
    end
    return obj
end

local function corner(parent, radius)
    return new("UICorner", {
        CornerRadius = UDim.new(0, radius or 4),
        Parent = parent
    })
end

local function stroke(parent, color, thickness, transparency)
    return new("UIStroke", {
        Color = color or Theme.Stroke,
        Thickness = thickness or 1,
        Transparency = transparency or 0,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
        Parent = parent
    })
end

local function padding(parent, l, r, t, b)
    return new("UIPadding", {
        PaddingLeft = UDim.new(0, l or 0),
        PaddingRight = UDim.new(0, r or l or 0),
        PaddingTop = UDim.new(0, t or 0),
        PaddingBottom = UDim.new(0, b or t or 0),
        Parent = parent
    })
end

local function label(parent, text, size, color, font, xalign)
    return new("TextLabel", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, size or 16),
        Text = text or "",
        TextColor3 = color or Theme.Text,
        TextSize = size or 13,
        Font = font or Enum.Font.GothamSemibold,
        TextXAlignment = xalign or Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Center,
        Parent = parent
    })
end

local function tween(obj, duration, props)
    TweenService:Create(
        obj,
        TweenInfo.new(duration or 0.16, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
        props
    ):Play()
end

local function normalizeAsset(asset)
    if asset == nil then return "" end
    asset = tostring(asset)
    if asset == "" then return "" end
    if asset:find("rbxassetid://", 1, true) then
        return asset
    end
    local id = asset:match("%d+")
    return id and ("rbxassetid://" .. id) or asset
end

local function getDefaultParent()
    local ok, result = pcall(function()
        if typeof(gethui) == "function" then
            return gethui()
        end
    end)
    if ok and result then
        return result
    end

    local player = Players.LocalPlayer
    if player then
        return player:WaitForChild("PlayerGui")
    end

    return game:GetService("CoreGui")
end

local function makeDraggable(handle, target)
    local dragging = false
    local dragStart
    local startPos
    local activeInput

    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = target.Position
            activeInput = input

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    handle.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch then
            activeInput = input
        end
    end)

    UIS.InputChanged:Connect(function(input)
        if dragging and input == activeInput then
            local delta = input.Position - dragStart
            target.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end)
end

local function autoCanvas(scroller, layout, extra)
    local function update()
        scroller.CanvasSize = UDim2.fromOffset(0, layout.AbsoluteContentSize.Y + (extra or 0))
    end
    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(update)
    update()
end

function MakoUI:CreateWindow(options)
    options = options or {}

    local accent = options.Accent or Theme.Accent
    local accentBright = options.AccentBright or Theme.AccentBright
    local guiName = options.Name or "MakoUI"
    local size = options.Size or UDim2.fromOffset(708, 520)

    local old
    pcall(function()
        old = getDefaultParent():FindFirstChild(guiName)
    end)
    if old then old:Destroy() end

    local screen = new("ScreenGui", {
        Name = guiName,
        ResetOnSpawn = false,
        IgnoreGuiInset = true,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        Parent = options.Parent or getDefaultParent()
    })

    local root = new("Frame", {
        Name = "Window",
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.5, 0.5),
        Size = size,
        BackgroundColor3 = Theme.Background,
        BorderSizePixel = 0,
        ClipsDescendants = true,
        Parent = screen
    })
    corner(root, 3)
    stroke(root, Color3.fromRGB(15, 20, 26), 1)

    -- very subtle cyan top glow
    local topGlow = new("Frame", {
        Name = "TopGlow",
        Size = UDim2.new(1, 0, 0, 1),
        BackgroundColor3 = accent,
        BackgroundTransparency = 0.35,
        BorderSizePixel = 0,
        ZIndex = 5,
        Parent = root
    })
    new("UIGradient", {
        Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 1),
            NumberSequenceKeypoint.new(0.5, 0.05),
            NumberSequenceKeypoint.new(1, 1),
        }),
        Parent = topGlow
    })

    local sidebar = new("Frame", {
        Name = "Sidebar",
        Size = UDim2.new(0, 82, 1, 0),
        BackgroundColor3 = Theme.Sidebar,
        BorderSizePixel = 0,
        Parent = root
    })
    new("Frame", {
        AnchorPoint = Vector2.new(1, 0),
        Position = UDim2.new(1, 0, 0, 0),
        Size = UDim2.new(0, 1, 1, 0),
        BackgroundColor3 = Theme.StrokeSoft,
        BorderSizePixel = 0,
        Parent = sidebar
    })

    local logoHolder = new("Frame", {
        Name = "LogoHolder",
        Position = UDim2.fromOffset(16, 15),
        Size = UDim2.fromOffset(50, 50),
        BackgroundColor3 = Color3.fromRGB(8, 10, 13),
        BorderSizePixel = 0,
        Parent = sidebar
    })
    corner(logoHolder, 5)
    stroke(logoHolder, Theme.Stroke, 1)

    local logo = new("ImageLabel", {
        Name = "Logo",
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(4, 4),
        Size = UDim2.new(1, -8, 1, -8),
        Image = normalizeAsset(options.Logo),
        ScaleType = Enum.ScaleType.Fit,
        Parent = logoHolder
    })

    local separator = new("Frame", {
        Position = UDim2.fromOffset(17, 78),
        Size = UDim2.fromOffset(48, 1),
        BackgroundColor3 = Theme.Stroke,
        BorderSizePixel = 0,
        Parent = sidebar
    })

    local sideButtons = new("Frame", {
        Name = "SideButtons",
        Position = UDim2.fromOffset(0, 92),
        Size = UDim2.new(1, 0, 1, -100),
        BackgroundTransparency = 1,
        Parent = sidebar
    })

    local content = new("Frame", {
        Name = "Content",
        Position = UDim2.fromOffset(82, 0),
        Size = UDim2.new(1, -82, 1, 0),
        BackgroundTransparency = 1,
        Parent = root
    })

    local topbar = new("Frame", {
        Name = "TopBar",
        Position = UDim2.fromOffset(20, 15),
        Size = UDim2.new(1, -40, 0, 31),
        BackgroundColor3 = Color3.fromRGB(4, 5, 7),
        BorderSizePixel = 0,
        Parent = content
    })
    corner(topbar, 4)
    stroke(topbar, Theme.Stroke, 1)

    local tabButtons = new("Frame", {
        Name = "TabButtons",
        Size = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1,
        Parent = topbar
    })
    local tabLayout = new("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal,
        HorizontalAlignment = Enum.HorizontalAlignment.Left,
        VerticalAlignment = Enum.VerticalAlignment.Center,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = tabButtons
    })

    local pages = new("Frame", {
        Name = "Pages",
        Position = UDim2.fromOffset(20, 66),
        Size = UDim2.new(1, -40, 1, -81),
        BackgroundTransparency = 1,
        ClipsDescendants = true,
        Parent = content
    })

    local window = {
        ScreenGui = screen,
        Root = root,
        Logo = logo,
        Accent = accent,
        AccentBright = accentBright,
        Tabs = {},
        ActiveTab = nil,
        _sideIndex = 0
    }

    function window:SetLogo(asset)
        self.Logo.Image = normalizeAsset(asset)
    end

    function window:SetVisible(state)
        self.ScreenGui.Enabled = state
    end

    function window:Toggle()
        self.ScreenGui.Enabled = not self.ScreenGui.Enabled
    end

    function window:Destroy()
        self.ScreenGui:Destroy()
    end

    function window:AddSidebarButton(icon, callback, tooltip)
        self._sideIndex += 1
        local y = (self._sideIndex - 1) * 56

        local holder = new("Frame", {
            Position = UDim2.fromOffset(0, y),
            Size = UDim2.new(1, 0, 0, 50),
            BackgroundTransparency = 1,
            Parent = sideButtons
        })

        local activeLine = new("Frame", {
            Size = UDim2.fromOffset(3, 26),
            Position = UDim2.new(0, 0, 0.5, -13),
            BackgroundColor3 = accent,
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Parent = holder
        })
        corner(activeLine, 2)

        local button = new("TextButton", {
            Position = UDim2.new(0.5, -20, 0.5, -20),
            Size = UDim2.fromOffset(40, 40),
            BackgroundTransparency = 1,
            Text = "",
            AutoButtonColor = false,
            Parent = holder
        })

        local image = new("ImageLabel", {
            AnchorPoint = Vector2.new(0.5, 0.5),
            Position = UDim2.fromScale(0.5, 0.5),
            Size = UDim2.fromOffset(22, 22),
            BackgroundTransparency = 1,
            Image = normalizeAsset(icon),
            ImageColor3 = Color3.fromRGB(190, 196, 205),
            ScaleType = Enum.ScaleType.Fit,
            Parent = button
        })

        button.MouseEnter:Connect(function()
            tween(image, 0.14, {ImageColor3 = accentBright})
        end)
        button.MouseLeave:Connect(function()
            tween(image, 0.14, {ImageColor3 = Color3.fromRGB(190, 196, 205)})
        end)
        button.MouseButton1Click:Connect(function()
            if callback then callback() end
        end)

        return {
            Button = button,
            Image = image,
            Indicator = activeLine,
            SetActive = function(_, state)
                tween(activeLine, 0.14, {BackgroundTransparency = state and 0 or 1})
                tween(image, 0.14, {ImageColor3 = state and accentBright or Color3.fromRGB(190,196,205)})
            end
        }
    end

    function window:AddTab(name)
        local count = #self.Tabs + 1
        local button = new("TextButton", {
            Name = name .. "Button",
            Size = UDim2.new(1 / count, 0, 1, 0),
            BackgroundTransparency = 1,
            Text = name,
            TextColor3 = Theme.Text,
            TextSize = 12,
            Font = Enum.Font.GothamSemibold,
            AutoButtonColor = false,
            Parent = tabButtons
        })

        -- Rebalance all buttons whenever a tab is added.
        for _, child in ipairs(tabButtons:GetChildren()) do
            if child:IsA("TextButton") then
                child.Size = UDim2.new(1 / count, 0, 1, 0)
            end
        end

        if count > 1 then
            new("Frame", {
                Position = UDim2.new(0, 0, 0, 0),
                Size = UDim2.fromOffset(1, 31),
                BackgroundColor3 = Theme.Stroke,
                BorderSizePixel = 0,
                Parent = button
            })
        end

        local underline = new("Frame", {
            AnchorPoint = Vector2.new(0.5, 1),
            Position = UDim2.new(0.5, 0, 1, 0),
            Size = UDim2.new(0.4, 0, 0, 1),
            BackgroundColor3 = accent,
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Parent = button
        })

        local page = new("ScrollingFrame", {
            Name = name .. "Page",
            Size = UDim2.fromScale(1, 1),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            ScrollBarThickness = 2,
            ScrollBarImageColor3 = accent,
            CanvasSize = UDim2.fromOffset(0, 0),
            Visible = false,
            Parent = pages
        })
        padding(page, 0, 4, 0, 4)

        local columns = new("Frame", {
            Name = "Columns",
            Size = UDim2.new(1, -4, 0, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
            BackgroundTransparency = 1,
            Parent = page
        })

        local left = new("Frame", {
            Name = "Left",
            Size = UDim2.new(0.5, -8, 0, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
            BackgroundTransparency = 1,
            Parent = columns
        })
        local right = new("Frame", {
            Name = "Right",
            Position = UDim2.new(0.5, 8, 0, 0),
            Size = UDim2.new(0.5, -8, 0, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
            BackgroundTransparency = 1,
            Parent = columns
        })

        local leftLayout = new("UIListLayout", {
            Padding = UDim.new(0, 12),
            SortOrder = Enum.SortOrder.LayoutOrder,
            Parent = left
        })
        local rightLayout = new("UIListLayout", {
            Padding = UDim.new(0, 12),
            SortOrder = Enum.SortOrder.LayoutOrder,
            Parent = right
        })

        local function updateCanvas()
            local h = math.max(leftLayout.AbsoluteContentSize.Y, rightLayout.AbsoluteContentSize.Y)
            columns.Size = UDim2.new(1, -4, 0, h)
            page.CanvasSize = UDim2.fromOffset(0, h + 8)
        end
        leftLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateCanvas)
        rightLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateCanvas)

        local tab = {
            Name = name,
            Button = button,
            Underline = underline,
            Page = page,
            Left = left,
            Right = right,
            Window = self
        }

        function tab:Select()
            for _, other in ipairs(self.Window.Tabs) do
                other.Page.Visible = false
                tween(other.Underline, 0.12, {BackgroundTransparency = 1})
                tween(other.Button, 0.12, {TextColor3 = Theme.Text})
            end
            self.Page.Visible = true
            tween(self.Underline, 0.12, {BackgroundTransparency = 0})
            tween(self.Button, 0.12, {TextColor3 = self.Window.AccentBright})
            self.Window.ActiveTab = self
        end

        local function resolveColumn(side)
            if side == "Right" or side == 2 then return right end
            return left
        end

        function tab:AddSection(title, side, icon)
            local parent = resolveColumn(side)
            local section = new("Frame", {
                Name = title,
                Size = UDim2.new(1, 0, 0, 34),
                AutomaticSize = Enum.AutomaticSize.Y,
                BackgroundColor3 = Color3.fromRGB(4, 5, 7),
                BorderSizePixel = 0,
                Parent = parent
            })
            corner(section, 4)
            stroke(section, Theme.Stroke, 1)

            local header = new("Frame", {
                Size = UDim2.new(1, 0, 0, 33),
                BackgroundTransparency = 1,
                Parent = section
            })

            if icon and tostring(icon) ~= "" then
                new("ImageLabel", {
                    Position = UDim2.fromOffset(12, 9),
                    Size = UDim2.fromOffset(15, 15),
                    BackgroundTransparency = 1,
                    Image = normalizeAsset(icon),
                    ImageColor3 = accent,
                    ScaleType = Enum.ScaleType.Fit,
                    Parent = header
                })
            else
                local dot = new("Frame", {
                    Position = UDim2.fromOffset(13, 13),
                    Size = UDim2.fromOffset(7, 7),
                    BackgroundColor3 = accent,
                    BorderSizePixel = 0,
                    Rotation = 45,
                    Parent = header
                })
                corner(dot, 1)
            end

            local titleLabel = new("TextLabel", {
                Position = UDim2.fromOffset(34, 0),
                Size = UDim2.new(1, -42, 1, 0),
                BackgroundTransparency = 1,
                Text = title,
                TextColor3 = Theme.Text,
                TextSize = 12,
                Font = Enum.Font.GothamBold,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = header
            })

            new("Frame", {
                Position = UDim2.new(0, 0, 0, 33),
                Size = UDim2.new(1, 0, 0, 1),
                BackgroundColor3 = Theme.Stroke,
                BorderSizePixel = 0,
                Parent = section
            })

            local body = new("Frame", {
                Position = UDim2.fromOffset(0, 34),
                Size = UDim2.new(1, 0, 0, 0),
                AutomaticSize = Enum.AutomaticSize.Y,
                BackgroundTransparency = 1,
                Parent = section
            })
            padding(body, 12, 12, 7, 8)

            local layout = new("UIListLayout", {
                Padding = UDim.new(0, 3),
                SortOrder = Enum.SortOrder.LayoutOrder,
                Parent = body
            })

            local sectionApi = {
                Frame = section,
                Body = body,
                Window = self.Window
            }

            function sectionApi:AddLabel(textValue, muted)
                local row = new("TextLabel", {
                    Size = UDim2.new(1, 0, 0, 23),
                    BackgroundTransparency = 1,
                    Text = textValue,
                    TextColor3 = muted and Theme.Muted or Theme.Text,
                    TextSize = 12,
                    Font = Enum.Font.GothamSemibold,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = body
                })
                return row
            end

            function sectionApi:AddButton(textValue, callback)
                local btn = new("TextButton", {
                    Size = UDim2.new(1, 0, 0, 28),
                    BackgroundColor3 = Theme.Surface2,
                    BorderSizePixel = 0,
                    Text = textValue,
                    TextColor3 = Theme.Text,
                    TextSize = 12,
                    Font = Enum.Font.GothamSemibold,
                    AutoButtonColor = false,
                    Parent = body
                })
                corner(btn, 4)
                stroke(btn, Theme.Stroke, 1)
                btn.MouseEnter:Connect(function()
                    tween(btn, 0.12, {BackgroundColor3 = Color3.fromRGB(12, 16, 20)})
                end)
                btn.MouseLeave:Connect(function()
                    tween(btn, 0.12, {BackgroundColor3 = Theme.Surface2})
                end)
                btn.MouseButton1Click:Connect(function()
                    if callback then callback() end
                end)
                return btn
            end

            function sectionApi:AddToggle(textValue, default, callback, disabled)
                local state = default == true
                local row = new("TextButton", {
                    Size = UDim2.new(1, 0, 0, 24),
                    BackgroundTransparency = 1,
                    Text = "",
                    AutoButtonColor = false,
                    Parent = body
                })

                local textLabel = new("TextLabel", {
                    Size = UDim2.new(1, -48, 1, 0),
                    BackgroundTransparency = 1,
                    Text = textValue,
                    TextColor3 = disabled and Theme.Muted or Theme.Text,
                    TextSize = 12,
                    Font = Enum.Font.GothamSemibold,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = row
                })

                local track = new("Frame", {
                    AnchorPoint = Vector2.new(1, 0.5),
                    Position = UDim2.new(1, 0, 0.5, 0),
                    Size = UDim2.fromOffset(25, 13),
                    BackgroundColor3 = state and accent or Theme.ToggleOff,
                    BorderSizePixel = 0,
                    Parent = row
                })
                corner(track, 8)

                local knob = new("Frame", {
                    AnchorPoint = Vector2.new(0.5, 0.5),
                    Position = state and UDim2.new(1, -6.5, 0.5, 0) or UDim2.new(0, 6.5, 0.5, 0),
                    Size = UDim2.fromOffset(9, 9),
                    BackgroundColor3 = Color3.fromRGB(238, 244, 248),
                    BorderSizePixel = 0,
                    Parent = track
                })
                corner(knob, 9)

                local api = {}

                local function render(instant)
                    local duration = instant and 0 or 0.14
                    tween(track, duration, {BackgroundColor3 = state and accent or Theme.ToggleOff})
                    tween(knob, duration, {
                        Position = state and UDim2.new(1, -6.5, 0.5, 0) or UDim2.new(0, 6.5, 0.5, 0)
                    })
                end

                function api:Set(value, silent)
                    if disabled then return end
                    state = value == true
                    render(false)
                    if callback and not silent then callback(state) end
                end

                function api:Get()
                    return state
                end

                row.MouseButton1Click:Connect(function()
                    if disabled then return end
                    api:Set(not state)
                end)

                return api
            end

            function sectionApi:AddSlider(textValue, min, max, default, callback, suffix)
                min = min or 0
                max = max or 100
                local value = math.clamp(default or min, min, max)
                suffix = suffix or ""

                local row = new("Frame", {
                    Size = UDim2.new(1, 0, 0, 45),
                    BackgroundTransparency = 1,
                    Parent = body
                })

                local nameLabel = new("TextLabel", {
                    Size = UDim2.new(0.55, 0, 0, 23),
                    BackgroundTransparency = 1,
                    Text = textValue,
                    TextColor3 = Theme.Text,
                    TextSize = 12,
                    Font = Enum.Font.GothamSemibold,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = row
                })

                local valueLabel = new("TextLabel", {
                    AnchorPoint = Vector2.new(1, 0),
                    Position = UDim2.new(1, 0, 0, 0),
                    Size = UDim2.new(0.45, 0, 0, 23),
                    BackgroundTransparency = 1,
                    Text = tostring(value) .. suffix,
                    TextColor3 = Theme.Text,
                    TextSize = 12,
                    Font = Enum.Font.GothamMedium,
                    TextXAlignment = Enum.TextXAlignment.Right,
                    Parent = row
                })

                local track = new("Frame", {
                    Position = UDim2.fromOffset(0, 30),
                    Size = UDim2.new(1, 0, 0, 4),
                    BackgroundColor3 = Theme.ToggleOff,
                    BorderSizePixel = 0,
                    Parent = row
                })
                corner(track, 4)

                local fill = new("Frame", {
                    Size = UDim2.new((value - min) / (max - min), 0, 1, 0),
                    BackgroundColor3 = accent,
                    BorderSizePixel = 0,
                    Parent = track
                })
                corner(fill, 4)

                local knob = new("Frame", {
                    AnchorPoint = Vector2.new(0.5, 0.5),
                    Position = UDim2.new((value - min) / (max - min), 0, 0.5, 0),
                    Size = UDim2.fromOffset(10, 10),
                    BackgroundColor3 = Color3.fromRGB(235, 242, 247),
                    BorderSizePixel = 0,
                    Parent = track
                })
                corner(knob, 10)

                local dragging = false
                local api = {}

                local function setFromX(x, fire)
                    local alpha = math.clamp((x - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
                    value = min + (max - min) * alpha
                    if math.floor(min) == min and math.floor(max) == max then
                        value = math.floor(value + 0.5)
                    end
                    local actualAlpha = (value - min) / (max - min)
                    fill.Size = UDim2.new(actualAlpha, 0, 1, 0)
                    knob.Position = UDim2.new(actualAlpha, 0, 0.5, 0)
                    valueLabel.Text = tostring(value) .. suffix
                    if callback and fire then callback(value) end
                end

                function api:Set(v, silent)
                    value = math.clamp(v, min, max)
                    local a = (value - min) / (max - min)
                    fill.Size = UDim2.new(a, 0, 1, 0)
                    knob.Position = UDim2.new(a, 0, 0.5, 0)
                    valueLabel.Text = tostring(value) .. suffix
                    if callback and not silent then callback(value) end
                end

                function api:Get()
                    return value
                end

                track.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1
                    or input.UserInputType == Enum.UserInputType.Touch then
                        dragging = true
                        setFromX(input.Position.X, true)
                    end
                end)

                UIS.InputChanged:Connect(function(input)
                    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
                    or input.UserInputType == Enum.UserInputType.Touch) then
                        setFromX(input.Position.X, true)
                    end
                end)

                UIS.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1
                    or input.UserInputType == Enum.UserInputType.Touch then
                        dragging = false
                    end
                end)

                return api
            end

            function sectionApi:AddColor(textValue, default, callback)
                local color = default or accent
                local row = new("TextButton", {
                    Size = UDim2.new(1, 0, 0, 28),
                    BackgroundTransparency = 1,
                    Text = "",
                    AutoButtonColor = false,
                    Parent = body
                })

                new("TextLabel", {
                    Size = UDim2.new(1, -35, 1, 0),
                    BackgroundTransparency = 1,
                    Text = textValue,
                    TextColor3 = Theme.Text,
                    TextSize = 12,
                    Font = Enum.Font.GothamSemibold,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = row
                })

                local swatch = new("Frame", {
                    AnchorPoint = Vector2.new(1, 0.5),
                    Position = UDim2.new(1, 0, 0.5, 0),
                    Size = UDim2.fromOffset(18, 18),
                    BackgroundColor3 = color,
                    BorderSizePixel = 0,
                    Parent = row
                })
                corner(swatch, 2)
                stroke(swatch, Color3.fromRGB(0,0,0), 1, 0.4)

                local api = {}
                function api:Set(c, silent)
                    color = c
                    swatch.BackgroundColor3 = c
                    if callback and not silent then callback(c) end
                end
                function api:Get()
                    return color
                end

                row.MouseButton1Click:Connect(function()
                    if callback then callback(color) end
                end)

                return api
            end

            function sectionApi:AddDropdown(textValue, values, default, callback)
                values = values or {}
                local current = default or values[1] or "None"
                local open = false

                local holder = new("Frame", {
                    Size = UDim2.new(1, 0, 0, 50),
                    BackgroundTransparency = 1,
                    ClipsDescendants = true,
                    Parent = body
                })

                new("TextLabel", {
                    Size = UDim2.new(1, 0, 0, 20),
                    BackgroundTransparency = 1,
                    Text = textValue,
                    TextColor3 = Theme.Text,
                    TextSize = 12,
                    Font = Enum.Font.GothamSemibold,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = holder
                })

                local selectButton = new("TextButton", {
                    Position = UDim2.fromOffset(0, 22),
                    Size = UDim2.new(1, 0, 0, 27),
                    BackgroundColor3 = Theme.Surface2,
                    BorderSizePixel = 0,
                    Text = "  " .. tostring(current),
                    TextColor3 = Theme.Text,
                    TextSize = 11,
                    Font = Enum.Font.GothamMedium,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    AutoButtonColor = false,
                    Parent = holder
                })
                corner(selectButton, 3)
                stroke(selectButton, Theme.Stroke, 1)

                local list = new("Frame", {
                    Position = UDim2.fromOffset(0, 53),
                    Size = UDim2.new(1, 0, 0, #values * 25),
                    BackgroundColor3 = Theme.Surface2,
                    BorderSizePixel = 0,
                    Parent = holder
                })
                corner(list, 3)
                stroke(list, Theme.Stroke, 1)

                new("UIListLayout", {
                    SortOrder = Enum.SortOrder.LayoutOrder,
                    Parent = list
                })

                local api = {}

                local function setOpen(v)
                    open = v
                    holder.Size = UDim2.new(1, 0, 0, open and (56 + #values * 25) or 50)
                end

                function api:Set(v, silent)
                    current = v
                    selectButton.Text = "  " .. tostring(v)
                    setOpen(false)
                    if callback and not silent then callback(v) end
                end

                function api:Get()
                    return current
                end

                selectButton.MouseButton1Click:Connect(function()
                    setOpen(not open)
                end)

                for _, option in ipairs(values) do
                    local opt = new("TextButton", {
                        Size = UDim2.new(1, 0, 0, 25),
                        BackgroundTransparency = 1,
                        Text = "  " .. tostring(option),
                        TextColor3 = Theme.Text,
                        TextSize = 11,
                        Font = Enum.Font.GothamMedium,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        AutoButtonColor = false,
                        Parent = list
                    })
                    opt.MouseEnter:Connect(function()
                        opt.BackgroundTransparency = 0
                        opt.BackgroundColor3 = Color3.fromRGB(12, 16, 20)
                    end)
                    opt.MouseLeave:Connect(function()
                        opt.BackgroundTransparency = 1
                    end)
                    opt.MouseButton1Click:Connect(function()
                        api:Set(option)
                    end)
                end

                return api
            end

            return sectionApi
        end

        button.MouseButton1Click:Connect(function()
            tab:Select()
        end)

        table.insert(self.Tabs, tab)
        if #self.Tabs == 1 then
            tab:Select()
        end

        return tab
    end

    -- Drag from unused top area/sidebar. This keeps controls clickable.
    makeDraggable(sidebar, root)

    -- Optional keybind to hide/show.
    local toggleKey = options.ToggleKey or Enum.KeyCode.RightShift
    UIS.InputBegan:Connect(function(input, processed)
        if not processed and input.KeyCode == toggleKey then
            screen.Enabled = not screen.Enabled
        end
    end)

    return window
end

return MakoUI
