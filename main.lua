-- MakoUI.lua
-- MakoUI Pro Blue v4 — polished reference-style Roblox UI library.
-- UI ONLY: no ESP / aimbot / gameplay implementation.
-- Upload the PNG files from /icons to Roblox, then put their rbxassetid values in Assets.

local MakoUI = {}
MakoUI.__index = MakoUI
MakoUI.Version = "6.0.0"

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local C = {
    BG = Color3.fromRGB(2, 3, 4),
    SIDEBAR = Color3.fromRGB(2, 3, 4),
    PANEL = Color3.fromRGB(3, 4, 5),
    BORDER = Color3.fromRGB(37, 40, 44),
    BORDER_DARK = Color3.fromRGB(18, 21, 24),
    TEXT = Color3.fromRGB(244, 246, 249),
    TEXT_DISABLED = Color3.fromRGB(126, 132, 141),
    ICON = Color3.fromRGB(220, 223, 228),
    OFF = Color3.fromRGB(25, 28, 32),
    ACCENT = Color3.fromRGB(0, 190, 255),
    ACCENT_BRIGHT = Color3.fromRGB(0, 225, 255),
}

local function New(class, props)
    local x = Instance.new(class)
    for k,v in pairs(props or {}) do
        if k ~= "Parent" then x[k] = v end
    end
    if props and props.Parent then x.Parent = props.Parent end
    return x
end

local function Corner(p, px)
    return New("UICorner", {CornerRadius=UDim.new(0,px or 3), Parent=p})
end

local function Stroke(p, color, thick, trans)
    return New("UIStroke", {
        Color=color or C.BORDER,
        Thickness=thick or 1,
        Transparency=trans or 0,
        ApplyStrokeMode=Enum.ApplyStrokeMode.Border,
        Parent=p
    })
end

local function Pad(p,l,r,t,b)
    return New("UIPadding", {
        PaddingLeft=UDim.new(0,l or 0), PaddingRight=UDim.new(0,r or l or 0),
        PaddingTop=UDim.new(0,t or 0), PaddingBottom=UDim.new(0,b or t or 0),
        Parent=p
    })
end

local function Tween(obj, props, time)
    TweenService:Create(
        obj,
        TweenInfo.new(time or .12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
        props
    ):Play()
end

local function Asset(v)
    if not v then return "" end
    v = tostring(v)
    if v:find("rbxassetid://",1,true) then return v end
    local id = v:match("%d+")
    return id and ("rbxassetid://"..id) or v
end

local function ParentGui()
    local ok, hui = pcall(function()
        if typeof(gethui) == "function" then return gethui() end
    end)
    if ok and hui then return hui end
    local plr = Players.LocalPlayer
    if plr then return plr:WaitForChild("PlayerGui") end
    return game:GetService("CoreGui")
end

local function Drag(handle, frame)
    local dragging, startMouse, startPos, dragInput = false, nil, nil, nil
    handle.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            startMouse = i.Position
            startPos = frame.Position
            i.Changed:Connect(function()
                if i.UserInputState == Enum.UserInputState.End then dragging=false end
            end)
        end
    end)
    handle.InputChanged:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch then
            dragInput=i
        end
    end)
    UIS.InputChanged:Connect(function(i)
        if dragging and i==dragInput then
            local d=i.Position-startMouse
            frame.Position=UDim2.new(startPos.X.Scale,startPos.X.Offset+d.X,startPos.Y.Scale,startPos.Y.Offset+d.Y)
        end
    end)
end

function MakoUI:CreateWindow(o)
    o=o or {}
    local accent=o.Accent or C.ACCENT
    local bright=o.AccentBright or C.ACCENT_BRIGHT
    local assets=o.Assets or {}

    local gui=New("ScreenGui",{
        Name=o.Name or "MakoUI",
        ResetOnSpawn=false,
        IgnoreGuiInset=true,
        ZIndexBehavior=Enum.ZIndexBehavior.Sibling,
        Parent=o.Parent or ParentGui()
    })

    local main=New("Frame",{
        Name="Main",
        AnchorPoint=Vector2.new(.5,.5),
        Position=o.Position or UDim2.fromScale(.5,.5),
        Size=o.Size or UDim2.fromOffset(708,520),
        BackgroundColor3=C.BG,
        BorderSizePixel=0,
        ClipsDescendants=true,
        Parent=gui
    })
    -- The reference is nearly square-edged: only 2px rounding.
    Corner(main,2)
    Stroke(main,Color3.fromRGB(8,18,24),1)

    -- No wallpaper / no background image.
    local sidebar=New("Frame",{
        Size=UDim2.new(0,82,1,0),
        BackgroundColor3=C.SIDEBAR,
        BorderSizePixel=0,
        Parent=main
    })
    New("Frame",{
        AnchorPoint=Vector2.new(1,0), Position=UDim2.new(1,0,0,0),
        Size=UDim2.new(0,1,1,0), BackgroundColor3=C.BORDER_DARK,
        BorderSizePixel=0, Parent=sidebar
    })

    -- Logo: intentionally NO square/card around it.
    local logo=New("ImageLabel",{
        Name="Logo",
        Position=UDim2.fromOffset(18,15),
        Size=UDim2.fromOffset(48,48),
        BackgroundTransparency=1,
        Image=Asset(o.Logo),
        ScaleType=Enum.ScaleType.Fit,
        Parent=sidebar
    })
    New("Frame",{
        Position=UDim2.fromOffset(18,77), Size=UDim2.fromOffset(48,1),
        BackgroundColor3=C.BORDER, BorderSizePixel=0, Parent=sidebar
    })

    local nav=New("Frame",{
        Position=UDim2.fromOffset(0,91),
        Size=UDim2.new(1,0,1,-99),
        BackgroundTransparency=1,
        Parent=sidebar
    })

    local content=New("Frame",{
        Position=UDim2.fromOffset(82,0),
        Size=UDim2.new(1,-82,1,0),
        BackgroundTransparency=1,
        Parent=main
    })

    local tabsBar=New("Frame",{
        Position=UDim2.fromOffset(18,15),
        Size=UDim2.fromOffset(411,31),
        BackgroundColor3=C.PANEL,
        BorderSizePixel=0,
        Parent=content
    })
    Corner(tabsBar,4)
    Stroke(tabsBar,C.BORDER,1)

    local tabsHolder=New("Frame",{
        Size=UDim2.fromScale(1,1), BackgroundTransparency=1, Parent=tabsBar
    })
    New("UIListLayout",{
        FillDirection=Enum.FillDirection.Horizontal,
        SortOrder=Enum.SortOrder.LayoutOrder,
        Parent=tabsHolder
    })

    local pages=New("Frame",{
        Position=UDim2.fromOffset(18,83),
        Size=UDim2.new(1,-34,1,-101),
        BackgroundTransparency=1,
        ClipsDescendants=true,
        Parent=content
    })

    local key=o.ToggleKey or Enum.KeyCode.RightShift

    local api={
        Gui=gui, Main=main, Logo=logo, Accent=accent, Bright=bright,
        Assets=assets, Tabs={}, NavItems={}, ActiveTab=nil,
        Content=content, TabsBar=tabsBar, Pages=pages,
        SidebarPages={}, ToggleKey=key
    }

    function api:SetLogo(id) self.Logo.Image=Asset(id) end
    function api:SetVisible(v) self.Gui.Enabled=v end
    function api:Toggle() self.Gui.Enabled=not self.Gui.Enabled end
    function api:Destroy() self.Gui:Destroy() end

    function api:SetToggleKey(newKey)
        if typeof(newKey)=="EnumItem" and newKey.EnumType==Enum.KeyCode then
            key=newKey
            self.ToggleKey=newKey
            return true
        end
        return false
    end

    function api:GetToggleKey()
        return key
    end

    function api:AddSidebarPage(name)
        name=tostring(name or "Page")

        if self.SidebarPages[name] then
            return self.SidebarPages[name]
        end

        local page=New("Frame",{
            Name=name.."SidebarPage",
            Position=UDim2.fromOffset(18,15),
            Size=UDim2.new(1,-34,1,-30),
            BackgroundTransparency=1,
            BorderSizePixel=0,
            Visible=false,
            Parent=content
        })

        self.SidebarPages[name]=page
        return page
    end

    function api:ShowSidebarPage(name)
        tabsBar.Visible=false
        pages.Visible=false

        for pageName,page in pairs(self.SidebarPages) do
            page.Visible=(pageName==name)
        end
    end

    function api:ShowControls()
        for _,page in pairs(self.SidebarPages) do
            page.Visible=false
        end

        tabsBar.Visible=true
        pages.Visible=true

        if self.ActiveTab then
            self.ActiveTab.Page.Visible=true
        elseif self.Tabs[1] then
            self.Tabs[1]:Select()
        end
    end

    function api:AddNavIcon(imageId, callback)
        local index=#self.NavItems+1
        local holder=New("Frame",{
            Position=UDim2.fromOffset(0,(index-1)*56),
            Size=UDim2.new(1,0,0,50),
            BackgroundTransparency=1,
            Parent=nav
        })
        local active=New("Frame",{
            Position=UDim2.new(0,0,.5,-14),
            Size=UDim2.fromOffset(3,28),
            BackgroundColor3=accent,
            BackgroundTransparency=1,
            BorderSizePixel=0,
            Parent=holder
        })
        local b=New("TextButton",{
            AnchorPoint=Vector2.new(.5,.5), Position=UDim2.fromScale(.5,.5),
            Size=UDim2.fromOffset(46,46), BackgroundTransparency=1,
            Text="", AutoButtonColor=false, Parent=holder
        })
        local iconGlow=New("ImageLabel",{
            AnchorPoint=Vector2.new(.5,.5), Position=UDim2.fromScale(.5,.5),
            Size=UDim2.fromOffset(33,33), BackgroundTransparency=1,
            Image=Asset(imageId), ImageColor3=accent, ImageTransparency=1,
            ScaleType=Enum.ScaleType.Fit, ZIndex=1, Parent=b
        })
        local img=New("ImageLabel",{
            AnchorPoint=Vector2.new(.5,.5), Position=UDim2.fromScale(.5,.5),
            Size=UDim2.fromOffset(27,27), BackgroundTransparency=1,
            Image=Asset(imageId), ImageColor3=C.ICON,
            ScaleType=Enum.ScaleType.Fit, ZIndex=2, Parent=b
        })
        b.MouseEnter:Connect(function() Tween(img,{ImageColor3=bright},.1) end)
        b.MouseLeave:Connect(function()
            if active.BackgroundTransparency==1 then Tween(img,{ImageColor3=C.ICON},.1) end
        end)
        b.MouseButton1Click:Connect(function()
            if callback then callback(index) end
        end)
        local item={Button=b,Icon=img,Glow=iconGlow,Line=active}
        function item:SetActive(v)
            Tween(active,{BackgroundTransparency=v and 0 or 1},.1)
            Tween(img,{ImageColor3=v and bright or C.ICON},.1)
            Tween(iconGlow,{ImageTransparency=v and .72 or 1},.1)
        end
        table.insert(self.NavItems,item)
        return item
    end

    function api:AddDefaultSidebar(callback)
        local keys={"Code","Folder","Controls","Document","Settings"}

        for index,keyName in ipairs(keys) do
            self:AddNavIcon(self.Assets[keyName],function()
                for _,it in ipairs(self.NavItems) do
                    it:SetActive(false)
                end

                local clicked=self.NavItems[index]
                if clicked then
                    clicked:SetActive(true)
                end

                if callback then
                    callback(keyName)
                end
            end)
        end

        -- Controls par défaut.
        if self.NavItems[3] then
            self.NavItems[3]:SetActive(true)
        end

        if callback then
            task.defer(callback,"Controls")
        end
    end

    function api:AddTab(name)
        local count=#self.Tabs+1
        local b=New("TextButton",{
            Size=UDim2.new(1/count,0,1,0),
            BackgroundTransparency=1,
            Text=name, TextColor3=C.TEXT,
            TextSize=13, Font=Enum.Font.GothamSemibold,
            AutoButtonColor=false, Parent=tabsHolder
        })
        for _,x in ipairs(tabsHolder:GetChildren()) do
            if x:IsA("TextButton") then x.Size=UDim2.new(1/count,0,1,0) end
        end
        if count>1 then
            New("Frame",{
                Position=UDim2.fromOffset(0,0), Size=UDim2.fromOffset(1,31),
                BackgroundColor3=C.BORDER, BorderSizePixel=0, Parent=b
            })
        end

        local page=New("ScrollingFrame",{
            Name=name,
            Size=UDim2.fromScale(1,1),
            BackgroundTransparency=1,
            BorderSizePixel=0,
            ScrollBarThickness=0,
            ScrollBarImageColor3=accent,
            CanvasSize=UDim2.fromOffset(0,0),
            Visible=false,
            Parent=pages
        })

        local left=New("Frame",{
            Position=UDim2.fromOffset(2,2),
            Size=UDim2.new(.5,-11,0,0), AutomaticSize=Enum.AutomaticSize.Y,
            BackgroundTransparency=1, Parent=page
        })
        local right=New("Frame",{
            Position=UDim2.new(.5,9,0,2),
            Size=UDim2.new(.5,-11,0,0), AutomaticSize=Enum.AutomaticSize.Y,
            BackgroundTransparency=1, Parent=page
        })
        local ll=New("UIListLayout",{Padding=UDim.new(0,12),SortOrder=Enum.SortOrder.LayoutOrder,Parent=left})
        local rl=New("UIListLayout",{Padding=UDim.new(0,12),SortOrder=Enum.SortOrder.LayoutOrder,Parent=right})

        local function canvas()
            page.CanvasSize=UDim2.fromOffset(0,math.max(ll.AbsoluteContentSize.Y,rl.AbsoluteContentSize.Y)+6)
        end
        ll:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(canvas)
        rl:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(canvas)

        local tab={Window=self,Button=b,Page=page,Left=left,Right=right}

        function tab:Select()
            for _,t in ipairs(self.Window.Tabs) do
                t.Page.Visible=false
                Tween(t.Button,{TextColor3=C.TEXT},.1)
            end
            self.Page.Visible=true
            -- Reference top tabs do not need a glowing underline.
            Tween(self.Button,{TextColor3=C.TEXT},.1)
            self.Window.ActiveTab=self
        end

        function tab:AddSection(title, side, headerIcon, questionMark)
            local parent=(side=="Right" or side==2) and right or left
            local sec=New("Frame",{
                Size=UDim2.new(1,0,0,34),
                AutomaticSize=Enum.AutomaticSize.Y,
                BackgroundColor3=C.PANEL,
                BorderSizePixel=0,
                Parent=parent
            })
            Corner(sec,3); Stroke(sec,C.BORDER,1)

            local head=New("Frame",{
                Size=UDim2.new(1,0,0,33),
                BackgroundTransparency=1,
                Parent=sec
            })
            if headerIcon then
                New("ImageLabel",{
                    Position=UDim2.fromOffset(9,7),
                    Size=UDim2.fromOffset(20,20),
                    BackgroundTransparency=1,
                    Image=Asset(headerIcon),
                    ImageColor3=bright,
                    ImageTransparency=.74,
                    ScaleType=Enum.ScaleType.Fit,
                    ZIndex=1,
                    Parent=head
                })
                New("ImageLabel",{
                    Position=UDim2.fromOffset(11,9),
                    Size=UDim2.fromOffset(16,16),
                    BackgroundTransparency=1,
                    Image=Asset(headerIcon),
                    ImageColor3=accent,
                    ScaleType=Enum.ScaleType.Fit,
                    ZIndex=2,
                    Parent=head
                })
            end
            local titleX=headerIcon and 38 or 12
            local titleWrap=New("Frame",{
                Position=UDim2.fromOffset(titleX,0),
                Size=UDim2.new(1,-titleX-10,1,0),
                BackgroundTransparency=1,
                Parent=head
            })
            local titleLabel=New("TextLabel",{
                Size=UDim2.fromOffset(0,33),
                AutomaticSize=Enum.AutomaticSize.X,
                BackgroundTransparency=1,
                Text=title,
                TextColor3=C.TEXT,
                TextSize=13,
                Font=Enum.Font.GothamBold,
                TextXAlignment=Enum.TextXAlignment.Left,
                LayoutOrder=1,
                Parent=titleWrap
            })
            if questionMark then
                New("TextLabel",{
                    Position=UDim2.new(0,0,0,0),
                    Size=UDim2.fromOffset(0,33),
                    AutomaticSize=Enum.AutomaticSize.X,
                    BackgroundTransparency=1,
                    Text="(?)",
                    TextColor3=accent,
                    TextSize=13,
                    Font=Enum.Font.GothamBold,
                    TextXAlignment=Enum.TextXAlignment.Left,
                    LayoutOrder=2,
                    Parent=titleWrap
                })
                New("UIListLayout",{
                    FillDirection=Enum.FillDirection.Horizontal,
                    VerticalAlignment=Enum.VerticalAlignment.Center,
                    Padding=UDim.new(0,5),
                    SortOrder=Enum.SortOrder.LayoutOrder,
                    Parent=titleWrap
                })
            end
            New("Frame",{
                Position=UDim2.fromOffset(0,33),Size=UDim2.new(1,0,0,1),
                BackgroundColor3=C.BORDER,BorderSizePixel=0,Parent=sec
            })

            local body=New("Frame",{
                Position=UDim2.fromOffset(0,34),
                Size=UDim2.new(1,0,0,0),
                AutomaticSize=Enum.AutomaticSize.Y,
                BackgroundTransparency=1,
                Parent=sec
            })
            Pad(body,12,12,7,9)
            New("UIListLayout",{Padding=UDim.new(0,1),SortOrder=Enum.SortOrder.LayoutOrder,Parent=body})

            local s={Frame=sec,Body=body,Window=self.Window}

            function s:AddToggle(text,default,callback,disabled)
                local state=default==true
                local row=New("TextButton",{
                    Size=UDim2.new(1,0,0,25),BackgroundTransparency=1,
                    Text="",AutoButtonColor=false,Parent=body
                })
                New("TextLabel",{
                    Size=UDim2.new(1,-42,1,0),BackgroundTransparency=1,
                    Text=text,TextColor3=disabled and C.TEXT_DISABLED or C.TEXT,
                    TextSize=13,Font=Enum.Font.GothamSemibold,
                    TextXAlignment=Enum.TextXAlignment.Left,Parent=row
                })

                -- Soft two-layer bloom, matching the checked red switches in the
                -- reference but recolored to the Mako cyan accent.
                local glowOuter=New("Frame",{
                    AnchorPoint=Vector2.new(1,.5),Position=UDim2.new(1,4,.5,0),
                    Size=UDim2.fromOffset(33,21),BackgroundColor3=accent,
                    BackgroundTransparency=state and .90 or 1,BorderSizePixel=0,
                    ZIndex=1,Parent=row
                })
                Corner(glowOuter,11)
                local glowInner=New("Frame",{
                    AnchorPoint=Vector2.new(1,.5),Position=UDim2.new(1,2,.5,0),
                    Size=UDim2.fromOffset(29,17),BackgroundColor3=bright,
                    BackgroundTransparency=state and .82 or 1,BorderSizePixel=0,
                    ZIndex=1,Parent=row
                })
                Corner(glowInner,9)

                local track=New("Frame",{
                    AnchorPoint=Vector2.new(1,.5),Position=UDim2.new(1,0,.5,0),
                    Size=UDim2.fromOffset(25,13),
                    BackgroundColor3=C.OFF,BorderSizePixel=0,ZIndex=2,Parent=row
                })
                Corner(track,8)
                Stroke(track,Color3.fromRGB(7,9,11),1,.28)

                local activeFill=New("Frame",{
                    Size=UDim2.fromScale(1,1),BackgroundColor3=accent,
                    BackgroundTransparency=state and 0 or 1,
                    BorderSizePixel=0,ZIndex=2,Parent=track
                })
                Corner(activeFill,8)
                New("UIGradient",{
                    Color=ColorSequence.new({
                        ColorSequenceKeypoint.new(0,accent:Lerp(Color3.new(0,0,0),.58)),
                        ColorSequenceKeypoint.new(.58,accent),
                        ColorSequenceKeypoint.new(1,bright)
                    }),
                    Rotation=0,
                    Parent=activeFill
                })
                local activeShine=New("Frame",{
                    Position=UDim2.fromOffset(3,2),Size=UDim2.new(1,-6,0,1),
                    BackgroundColor3=Color3.new(1,1,1),
                    BackgroundTransparency=state and .72 or 1,
                    BorderSizePixel=0,ZIndex=3,Parent=track
                })
                Corner(activeShine,1)

                local dotGlow=New("Frame",{
                    AnchorPoint=Vector2.new(.5,.5),
                    Position=state and UDim2.new(1,-6.5,.5,0) or UDim2.new(0,6.5,.5,0),
                    Size=UDim2.fromOffset(13,13),BackgroundColor3=Color3.new(1,1,1),
                    BackgroundTransparency=state and .80 or 1,BorderSizePixel=0,
                    ZIndex=3,Parent=track
                })
                Corner(dotGlow,13)
                local dot=New("Frame",{
                    AnchorPoint=Vector2.new(.5,.5),
                    Position=state and UDim2.new(1,-6.5,.5,0) or UDim2.new(0,6.5,.5,0),
                    Size=UDim2.fromOffset(9,9),
                    BackgroundColor3=state and Color3.new(1,1,1) or Color3.fromRGB(74,79,86),
                    BorderSizePixel=0,ZIndex=4,Parent=track
                })
                Corner(dot,9)

                local ctl={}
                local function render(instant)
                    local t=instant and 0 or .12
                    Tween(activeFill,{BackgroundTransparency=state and 0 or 1},t)
                    Tween(activeShine,{BackgroundTransparency=state and .72 or 1},t)
                    Tween(glowOuter,{BackgroundTransparency=state and .90 or 1},t)
                    Tween(glowInner,{BackgroundTransparency=state and .82 or 1},t)
                    local pos=state and UDim2.new(1,-6.5,.5,0) or UDim2.new(0,6.5,.5,0)
                    Tween(dotGlow,{Position=pos,BackgroundTransparency=state and .80 or 1},t)
                    Tween(dot,{Position=pos,BackgroundColor3=state and Color3.new(1,1,1) or Color3.fromRGB(74,79,86)},t)
                end
                function ctl:Set(v,silent)
                    if disabled then return end
                    state=v==true
                    render(false)
                    if callback and not silent then callback(state) end
                end
                function ctl:Get() return state end
                row.MouseButton1Click:Connect(function() if not disabled then ctl:Set(not state) end end)
                return ctl
            end

            function s:AddSlider(text,min,max,default,callback,suffix)
                min,max=min or 0,max or 100
                local range=math.max(max-min,0.000001)
                local value=math.clamp(default or min,min,max)
                suffix=suffix or ""

                local row=New("Frame",{
                    Size=UDim2.new(1,0,0,34),
                    BackgroundTransparency=1,
                    Parent=body
                })

                New("TextLabel",{
                    Size=UDim2.new(0,94,1,0),
                    BackgroundTransparency=1,
                    Text=text,
                    TextColor3=C.TEXT,
                    TextSize=13,
                    Font=Enum.Font.GothamSemibold,
                    TextXAlignment=Enum.TextXAlignment.Left,
                    Parent=row
                })

                -- Outer capsule. The numeric value lives INSIDE this slider.
                local track=New("Frame",{
                    Position=UDim2.new(0,101,.5,-9),
                    Size=UDim2.new(1,-101,0,18),
                    BackgroundColor3=Color3.fromRGB(10,13,17),
                    BorderSizePixel=0,
                    ClipsDescendants=false,
                    Parent=row
                })
                Corner(track,9)
                Stroke(track,Color3.fromRGB(39,45,51),1,0)

                -- Subtle blue edge on the capsule, like the polished reference.
                local trackAccent=New("Frame",{
                    Position=UDim2.fromOffset(1,1),
                    Size=UDim2.new(1,-2,0,1),
                    BackgroundColor3=accent,
                    BackgroundTransparency=.72,
                    BorderSizePixel=0,
                    ZIndex=2,
                    Parent=track
                })
                Corner(trackAccent,1)

                -- Reserve the right side for "2000.0" so the knob never sits on the text.
                local valueZoneWidth=62
                local fillZone=New("Frame",{
                    Position=UDim2.fromOffset(7,0),
                    Size=UDim2.new(1,-(valueZoneWidth+14),1,0),
                    BackgroundTransparency=1,
                    ClipsDescendants=false,
                    ZIndex=2,
                    Parent=track
                })

                local rail=New("Frame",{
                    AnchorPoint=Vector2.new(0,.5),
                    Position=UDim2.new(0,0,.5,0),
                    Size=UDim2.new(1,0,0,5),
                    BackgroundColor3=Color3.fromRGB(28,32,37),
                    BorderSizePixel=0,
                    ZIndex=2,
                    Parent=fillZone
                })
                Corner(rail,4)

                local alpha=(value-min)/range

                local fillGlow=New("Frame",{
                    AnchorPoint=Vector2.new(0,.5),
                    Position=UDim2.new(0,0,.5,0),
                    Size=UDim2.new(alpha,0,0,11),
                    BackgroundColor3=accent,
                    BackgroundTransparency=.84,
                    BorderSizePixel=0,
                    ZIndex=1,
                    Parent=fillZone
                })
                Corner(fillGlow,6)

                local fill=New("Frame",{
                    AnchorPoint=Vector2.new(0,.5),
                    Position=UDim2.new(0,0,.5,0),
                    Size=UDim2.new(alpha,0,0,5),
                    BackgroundColor3=accent,
                    BorderSizePixel=0,
                    ZIndex=3,
                    Parent=fillZone
                })
                Corner(fill,4)
                New("UIGradient",{
                    Color=ColorSequence.new({
                        ColorSequenceKeypoint.new(0,accent:Lerp(Color3.new(0,0,0),.64)),
                        ColorSequenceKeypoint.new(.58,accent),
                        ColorSequenceKeypoint.new(1,bright)
                    }),
                    Rotation=0,
                    Parent=fill
                })

                local knobGlow=New("Frame",{
                    AnchorPoint=Vector2.new(.5,.5),
                    Position=UDim2.new(alpha,0,.5,0),
                    Size=UDim2.fromOffset(16,16),
                    BackgroundColor3=Color3.new(1,1,1),
                    BackgroundTransparency=.84,
                    BorderSizePixel=0,
                    ZIndex=4,
                    Parent=fillZone
                })
                Corner(knobGlow,16)

                local knob=New("Frame",{
                    AnchorPoint=Vector2.new(.5,.5),
                    Position=UDim2.new(alpha,0,.5,0),
                    Size=UDim2.fromOffset(10,10),
                    BackgroundColor3=Color3.new(1,1,1),
                    BorderSizePixel=0,
                    ZIndex=5,
                    Parent=fillZone
                })
                Corner(knob,10)
                Stroke(knob,Color3.fromRGB(220,225,230),1,.35)

                local val=New("TextLabel",{
                    AnchorPoint=Vector2.new(1,.5),
                    Position=UDim2.new(1,-7,.5,0),
                    Size=UDim2.fromOffset(valueZoneWidth-5,16),
                    BackgroundTransparency=1,
                    Text=tostring(value)..suffix,
                    TextColor3=C.TEXT,
                    TextSize=12,
                    Font=Enum.Font.GothamSemibold,
                    TextXAlignment=Enum.TextXAlignment.Right,
                    ZIndex=6,
                    Parent=track
                })

                local dragging=false
                local ctl={}

                local function setVisual(a)
                    fill.Size=UDim2.new(a,0,0,5)
                    fillGlow.Size=UDim2.new(a,0,0,11)
                    knob.Position=UDim2.new(a,0,.5,0)
                    knobGlow.Position=UDim2.new(a,0,.5,0)
                end

                local function applyX(x,fire)
                    local a=math.clamp(
                        (x-fillZone.AbsolutePosition.X)/math.max(fillZone.AbsoluteSize.X,1),
                        0,1
                    )
                    value=min+(max-min)*a
                    if math.floor(min)==min and math.floor(max)==max then
                        value=math.floor(value+.5)
                    end
                    a=(value-min)/range
                    setVisual(a)
                    val.Text=tostring(value)..suffix
                    if callback and fire then callback(value) end
                end

                function ctl:Set(v,silent)
                    value=math.clamp(v,min,max)
                    local a=(value-min)/range
                    setVisual(a)
                    val.Text=tostring(value)..suffix
                    if callback and not silent then callback(value) end
                end

                function ctl:Get()
                    return value
                end

                track.InputBegan:Connect(function(i)
                    if i.UserInputType==Enum.UserInputType.MouseButton1
                    or i.UserInputType==Enum.UserInputType.Touch then
                        dragging=true
                        applyX(i.Position.X,true)
                    end
                end)

                UIS.InputChanged:Connect(function(i)
                    if dragging and (
                        i.UserInputType==Enum.UserInputType.MouseMovement
                        or i.UserInputType==Enum.UserInputType.Touch
                    ) then
                        applyX(i.Position.X,true)
                    end
                end)

                UIS.InputEnded:Connect(function(i)
                    if i.UserInputType==Enum.UserInputType.MouseButton1
                    or i.UserInputType==Enum.UserInputType.Touch then
                        dragging=false
                    end
                end)

                return ctl
            end

            function s:AddColor(text,color,callback)
                color=color or accent
                local row=New("TextButton",{
                    Size=UDim2.new(1,0,0,31),BackgroundTransparency=1,
                    Text="",AutoButtonColor=false,Parent=body
                })
                New("TextLabel",{
                    Size=UDim2.new(1,-35,1,0),BackgroundTransparency=1,
                    Text=text,TextColor3=C.TEXT,TextSize=13,Font=Enum.Font.GothamSemibold,
                    TextXAlignment=Enum.TextXAlignment.Left,Parent=row
                })
                local sw=New("Frame",{
                    AnchorPoint=Vector2.new(1,.5),Position=UDim2.new(1,0,.5,0),
                    Size=UDim2.fromOffset(18,18),BackgroundColor3=color,BorderSizePixel=0,Parent=row
                })
                Corner(sw,1)
                -- Four subtle quadrants like the color swatches in the reference.
                New("Frame",{Position=UDim2.fromScale(0,0),Size=UDim2.fromScale(.5,.5),BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=.86,BorderSizePixel=0,Parent=sw})
                New("Frame",{Position=UDim2.fromScale(.5,0),Size=UDim2.fromScale(.5,.5),BackgroundColor3=Color3.new(0,0,0),BackgroundTransparency=.82,BorderSizePixel=0,Parent=sw})
                New("Frame",{Position=UDim2.fromScale(0,.5),Size=UDim2.fromScale(.5,.5),BackgroundColor3=Color3.new(0,0,0),BackgroundTransparency=.70,BorderSizePixel=0,Parent=sw})
                New("Frame",{Position=UDim2.fromScale(.5,.5),Size=UDim2.fromScale(.5,.5),BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=.94,BorderSizePixel=0,Parent=sw})
                local ctl={}
                function ctl:Set(v,silent) color=v;sw.BackgroundColor3=v;if callback and not silent then callback(v) end end
                function ctl:Get() return color end
                row.MouseButton1Click:Connect(function() if callback then callback(color) end end)
                return ctl
            end

            function s:AddButton(text,callback)
                local b=New("TextButton",{
                    Size=UDim2.new(1,0,0,28),BackgroundColor3=Color3.fromRGB(7,9,11),
                    BorderSizePixel=0,Text=text,TextColor3=C.TEXT,TextSize=13,
                    Font=Enum.Font.GothamSemibold,AutoButtonColor=false,Parent=body
                })
                Corner(b,2);Stroke(b,C.BORDER,1)
                b.MouseEnter:Connect(function() Tween(b,{BackgroundColor3=Color3.fromRGB(10,14,17)},.1) end)
                b.MouseLeave:Connect(function() Tween(b,{BackgroundColor3=Color3.fromRGB(7,9,11)},.1) end)
                b.MouseButton1Click:Connect(function() if callback then callback() end end)
                return b
            end

            return s
        end

        b.MouseButton1Click:Connect(function() tab:Select() end)
        table.insert(self.Tabs,tab)
        if #self.Tabs==1 then tab:Select() end
        return tab
    end

    Drag(sidebar,main)

    UIS.InputBegan:Connect(function(i,processed)
        if not processed and i.KeyCode==key then
            gui.Enabled=not gui.Enabled
        end
    end)


    -- =========================================================
    -- Notifications
    -- Top-right, black/cyan, slides in from the right.
    -- Usage:
    -- Window:Notify("Title", "Message", 4)
    -- =========================================================

    local notificationHolder=New("Frame",{
        Name="Notifications",
        AnchorPoint=Vector2.new(1,0),
        Position=UDim2.new(1,-18,0,18),
        Size=UDim2.fromOffset(330,0),
        AutomaticSize=Enum.AutomaticSize.Y,
        BackgroundTransparency=1,
        ZIndex=100,
        Parent=gui
    })

    New("UIListLayout",{
        Padding=UDim.new(0,8),
        SortOrder=Enum.SortOrder.LayoutOrder,
        VerticalAlignment=Enum.VerticalAlignment.Top,
        Parent=notificationHolder
    })

    local notificationIndex=0

    function api:Notify(title,message,duration)
        notificationIndex+=1
        title=tostring(title or "Mako")
        message=tostring(message or "")
        duration=tonumber(duration) or 4
        duration=math.max(duration,.5)

        -- The slot stays in the list while the actual card slides inside it.
        local slot=New("Frame",{
            Name="NotificationSlot",
            Size=UDim2.fromOffset(330,72),
            BackgroundTransparency=1,
            LayoutOrder=notificationIndex,
            ZIndex=100,
            Parent=notificationHolder
        })

        local card=New("Frame",{
            Name="Notification",
            Position=UDim2.fromOffset(365,0),
            Size=UDim2.fromScale(1,1),
            BackgroundColor3=Color3.fromRGB(3,5,7),
            BackgroundTransparency=.02,
            BorderSizePixel=0,
            ClipsDescendants=true,
            ZIndex=101,
            Parent=slot
        })
        Corner(card,4)
        Stroke(card,Color3.fromRGB(29,38,44),1,0)

        -- Cyan left edge.
        local accentLine=New("Frame",{
            Position=UDim2.fromOffset(0,0),
            Size=UDim2.fromOffset(3,72),
            BackgroundColor3=accent,
            BorderSizePixel=0,
            ZIndex=104,
            Parent=card
        })
        New("UIGradient",{
            Color=ColorSequence.new({
                ColorSequenceKeypoint.new(0,bright),
                ColorSequenceKeypoint.new(1,accent)
            }),
            Rotation=90,
            Parent=accentLine
        })

        -- Very restrained cyan bloom behind the accent edge.
        local accentGlow=New("Frame",{
            Position=UDim2.fromOffset(3,5),
            Size=UDim2.fromOffset(7,62),
            BackgroundColor3=accent,
            BackgroundTransparency=.86,
            BorderSizePixel=0,
            ZIndex=102,
            Parent=card
        })
        Corner(accentGlow,4)

        local titleLabel=New("TextLabel",{
            Position=UDim2.fromOffset(16,9),
            Size=UDim2.new(1,-28,0,20),
            BackgroundTransparency=1,
            Text=title,
            TextColor3=C.TEXT,
            TextSize=13,
            Font=Enum.Font.GothamBold,
            TextXAlignment=Enum.TextXAlignment.Left,
            TextYAlignment=Enum.TextYAlignment.Center,
            TextTruncate=Enum.TextTruncate.AtEnd,
            ZIndex=104,
            Parent=card
        })

        local messageLabel=New("TextLabel",{
            Position=UDim2.fromOffset(16,31),
            Size=UDim2.new(1,-28,0,25),
            BackgroundTransparency=1,
            Text=message,
            TextColor3=Color3.fromRGB(198,205,214),
            TextSize=11,
            Font=Enum.Font.GothamMedium,
            TextWrapped=true,
            TextXAlignment=Enum.TextXAlignment.Left,
            TextYAlignment=Enum.TextYAlignment.Top,
            TextTruncate=Enum.TextTruncate.AtEnd,
            ZIndex=104,
            Parent=card
        })

        -- Bottom lifetime bar.
        local progressBG=New("Frame",{
            AnchorPoint=Vector2.new(0,1),
            Position=UDim2.new(0,0,1,0),
            Size=UDim2.new(1,0,0,2),
            BackgroundColor3=Color3.fromRGB(16,21,25),
            BorderSizePixel=0,
            ZIndex=103,
            Parent=card
        })

        local progress=New("Frame",{
            Size=UDim2.fromScale(1,1),
            BackgroundColor3=accent,
            BorderSizePixel=0,
            ZIndex=104,
            Parent=progressBG
        })
        New("UIGradient",{
            Color=ColorSequence.new({
                ColorSequenceKeypoint.new(0,accent:Lerp(Color3.new(0,0,0),.45)),
                ColorSequenceKeypoint.new(1,bright)
            }),
            Parent=progress
        })

        -- Entry: right -> left.
        TweenService:Create(
            card,
            TweenInfo.new(.32,Enum.EasingStyle.Quart,Enum.EasingDirection.Out),
            {Position=UDim2.fromOffset(0,0)}
        ):Play()

        -- Lifetime bar.
        task.delay(.32,function()
            if progress and progress.Parent then
                TweenService:Create(
                    progress,
                    TweenInfo.new(duration,Enum.EasingStyle.Linear,Enum.EasingDirection.Out),
                    {Size=UDim2.new(0,0,1,0)}
                ):Play()
            end
        end)

        -- Exit: left -> right, then remove slot.
        task.delay(duration+.32,function()
            if not card or not card.Parent then return end

            local exitTween=TweenService:Create(
                card,
                TweenInfo.new(.28,Enum.EasingStyle.Quart,Enum.EasingDirection.In),
                {Position=UDim2.fromOffset(365,0)}
            )
            exitTween:Play()
            exitTween.Completed:Connect(function()
                if slot and slot.Parent then
                    slot:Destroy()
                end
            end)
        end)

        return card
    end

    return api
end

return MakoUI
