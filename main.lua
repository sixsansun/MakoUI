-- MakoUI.lua
-- Reference-style Roblox UI library.
-- UI ONLY: no ESP / aimbot / gameplay implementation.
-- Upload the PNG files from /icons to Roblox, then put their rbxassetid values in Assets.

local MakoUI = {}
MakoUI.__index = MakoUI

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local C = {
    BG = Color3.fromRGB(2, 3, 4),
    SIDEBAR = Color3.fromRGB(2, 3, 4),
    PANEL = Color3.fromRGB(3, 4, 5),
    BORDER = Color3.fromRGB(37, 40, 44),
    BORDER_DARK = Color3.fromRGB(18, 21, 24),
    TEXT = Color3.fromRGB(231, 233, 236),
    TEXT_DISABLED = Color3.fromRGB(69, 72, 77),
    ICON = Color3.fromRGB(207, 210, 215),
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
        Position=UDim2.fromOffset(23,16),
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
        Position=UDim2.fromOffset(23,67),
        Size=UDim2.new(1,-39,1,-82),
        BackgroundTransparency=1,
        ClipsDescendants=true,
        Parent=content
    })

    local api={
        Gui=gui, Main=main, Logo=logo, Accent=accent, Bright=bright,
        Assets=assets, Tabs={}, NavItems={}, ActiveTab=nil
    }

    function api:SetLogo(id) self.Logo.Image=Asset(id) end
    function api:SetVisible(v) self.Gui.Enabled=v end
    function api:Toggle() self.Gui.Enabled=not self.Gui.Enabled end
    function api:Destroy() self.Gui:Destroy() end

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
            Size=UDim2.fromOffset(42,42), BackgroundTransparency=1,
            Text="", AutoButtonColor=false, Parent=holder
        })
        local img=New("ImageLabel",{
            AnchorPoint=Vector2.new(.5,.5), Position=UDim2.fromScale(.5,.5),
            Size=UDim2.fromOffset(22,22), BackgroundTransparency=1,
            Image=Asset(imageId), ImageColor3=C.ICON,
            ScaleType=Enum.ScaleType.Fit, Parent=b
        })
        b.MouseEnter:Connect(function() Tween(img,{ImageColor3=bright},.1) end)
        b.MouseLeave:Connect(function()
            if active.BackgroundTransparency==1 then Tween(img,{ImageColor3=C.ICON},.1) end
        end)
        b.MouseButton1Click:Connect(function()
            if callback then callback(index) end
        end)
        local item={Button=b,Icon=img,Line=active}
        function item:SetActive(v)
            Tween(active,{BackgroundTransparency=v and 0 or 1},.1)
            Tween(img,{ImageColor3=v and bright or C.ICON},.1)
        end
        table.insert(self.NavItems,item)
        return item
    end

    function api:AddDefaultSidebar(callback)
        local keys={"Code","Folder","Controls","Document","Cubes","Settings"}
        for _,key in ipairs(keys) do
            self:AddNavIcon(self.Assets[key],function()
                for _,it in ipairs(self.NavItems) do it:SetActive(false) end
                local clicked=self.NavItems[_]
                if clicked then clicked:SetActive(true) end
                if callback then callback(key) end
            end)
        end
        if self.NavItems[5] then self.NavItems[5]:SetActive(true) end
    end

    function api:AddTab(name)
        local count=#self.Tabs+1
        local b=New("TextButton",{
            Size=UDim2.new(1/count,0,1,0),
            BackgroundTransparency=1,
            Text=name, TextColor3=C.TEXT,
            TextSize=12, Font=Enum.Font.GothamSemibold,
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
            ScrollBarThickness=2,
            ScrollBarImageColor3=accent,
            CanvasSize=UDim2.fromOffset(0,0),
            Visible=false,
            Parent=pages
        })

        local left=New("Frame",{
            Size=UDim2.new(.5,-9,0,0), AutomaticSize=Enum.AutomaticSize.Y,
            BackgroundTransparency=1, Parent=page
        })
        local right=New("Frame",{
            Position=UDim2.new(.5,9,0,0),
            Size=UDim2.new(.5,-9,0,0), AutomaticSize=Enum.AutomaticSize.Y,
            BackgroundTransparency=1, Parent=page
        })
        local ll=New("UIListLayout",{Padding=UDim.new(0,12),SortOrder=Enum.SortOrder.LayoutOrder,Parent=left})
        local rl=New("UIListLayout",{Padding=UDim.new(0,12),SortOrder=Enum.SortOrder.LayoutOrder,Parent=right})

        local function canvas()
            page.CanvasSize=UDim2.fromOffset(0,math.max(ll.AbsoluteContentSize.Y,rl.AbsoluteContentSize.Y)+8)
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
            Tween(self.Button,{TextColor3=self.Window.Bright},.1)
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
                    Position=UDim2.fromOffset(11,9),
                    Size=UDim2.fromOffset(16,16),
                    BackgroundTransparency=1,
                    Image=Asset(headerIcon),
                    ImageColor3=accent,
                    ScaleType=Enum.ScaleType.Fit,
                    Parent=head
                })
            end
            local titleX=headerIcon and 38 or 12
            local titleLabel=New("TextLabel",{
                Position=UDim2.fromOffset(titleX,0),
                Size=UDim2.new(1,-titleX-10,1,0),
                BackgroundTransparency=1,
                Text=title,
                TextColor3=C.TEXT,
                TextSize=12,
                Font=Enum.Font.GothamBold,
                TextXAlignment=Enum.TextXAlignment.Left,
                Parent=head
            })
            if questionMark then
                titleLabel.Text=title.."  (?)"
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
            New("UIListLayout",{Padding=UDim.new(0,2),SortOrder=Enum.SortOrder.LayoutOrder,Parent=body})

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
                    TextSize=12,Font=Enum.Font.GothamSemibold,
                    TextXAlignment=Enum.TextXAlignment.Left,Parent=row
                })
                local track=New("Frame",{
                    AnchorPoint=Vector2.new(1,.5),Position=UDim2.new(1,0,.5,0),
                    Size=UDim2.fromOffset(25,13),
                    BackgroundColor3=state and accent or C.OFF,
                    BorderSizePixel=0,Parent=row
                })
                Corner(track,8)
                local dot=New("Frame",{
                    AnchorPoint=Vector2.new(.5,.5),
                    Position=state and UDim2.new(1,-6.5,.5,0) or UDim2.new(0,6.5,.5,0),
                    Size=UDim2.fromOffset(9,9),
                    BackgroundColor3=state and Color3.new(1,1,1) or Color3.fromRGB(79,84,91),
                    BorderSizePixel=0,Parent=track
                })
                Corner(dot,9)
                local ctl={}
                function ctl:Set(v,silent)
                    if disabled then return end
                    state=v==true
                    Tween(track,{BackgroundColor3=state and accent or C.OFF},.11)
                    Tween(dot,{
                        Position=state and UDim2.new(1,-6.5,.5,0) or UDim2.new(0,6.5,.5,0),
                        BackgroundColor3=state and Color3.new(1,1,1) or Color3.fromRGB(79,84,91)
                    },.11)
                    if callback and not silent then callback(state) end
                end
                function ctl:Get() return state end
                row.MouseButton1Click:Connect(function() if not disabled then ctl:Set(not state) end end)
                return ctl
            end

            function s:AddSlider(text,min,max,default,callback,suffix)
                min,max=min or 0,max or 100
                local value=math.clamp(default or min,min,max)
                suffix=suffix or ""
                local row=New("Frame",{Size=UDim2.new(1,0,0,31),BackgroundTransparency=1,Parent=body})
                New("TextLabel",{
                    Size=UDim2.new(0,95,1,0),BackgroundTransparency=1,
                    Text=text,TextColor3=C.TEXT,TextSize=12,Font=Enum.Font.GothamSemibold,
                    TextXAlignment=Enum.TextXAlignment.Left,Parent=row
                })
                local val=New("TextLabel",{
                    Position=UDim2.fromOffset(105,0),Size=UDim2.fromOffset(58,31),
                    BackgroundTransparency=1,Text=tostring(value)..suffix,
                    TextColor3=C.TEXT,TextSize=12,Font=Enum.Font.GothamMedium,
                    TextXAlignment=Enum.TextXAlignment.Right,Parent=row
                })
                local track=New("Frame",{
                    Position=UDim2.new(0,173,.5,-2),Size=UDim2.new(1,-173,0,4),
                    BackgroundColor3=Color3.fromRGB(30,32,35),BorderSizePixel=0,Parent=row
                })
                Corner(track,4)
                local alpha=(value-min)/(max-min)
                local fill=New("Frame",{Size=UDim2.new(alpha,0,1,0),BackgroundColor3=accent,BorderSizePixel=0,Parent=track})
                Corner(fill,4)
                local knob=New("Frame",{
                    AnchorPoint=Vector2.new(.5,.5),Position=UDim2.new(alpha,0,.5,0),
                    Size=UDim2.fromOffset(10,10),BackgroundColor3=Color3.new(1,1,1),
                    BorderSizePixel=0,Parent=track
                })
                Corner(knob,10)
                local dragging=false
                local ctl={}
                local function applyX(x,fire)
                    local a=math.clamp((x-track.AbsolutePosition.X)/track.AbsoluteSize.X,0,1)
                    value=min+(max-min)*a
                    if math.floor(min)==min and math.floor(max)==max then value=math.floor(value+.5) end
                    a=(value-min)/(max-min)
                    fill.Size=UDim2.new(a,0,1,0); knob.Position=UDim2.new(a,0,.5,0)
                    val.Text=tostring(value)..suffix
                    if callback and fire then callback(value) end
                end
                function ctl:Set(v,silent)
                    value=math.clamp(v,min,max)
                    local a=(value-min)/(max-min)
                    fill.Size=UDim2.new(a,0,1,0);knob.Position=UDim2.new(a,0,.5,0)
                    val.Text=tostring(value)..suffix
                    if callback and not silent then callback(value) end
                end
                function ctl:Get() return value end
                track.InputBegan:Connect(function(i)
                    if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
                        dragging=true;applyX(i.Position.X,true)
                    end
                end)
                UIS.InputChanged:Connect(function(i)
                    if dragging and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then
                        applyX(i.Position.X,true)
                    end
                end)
                UIS.InputEnded:Connect(function(i)
                    if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then dragging=false end
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
                    Text=text,TextColor3=C.TEXT,TextSize=12,Font=Enum.Font.GothamSemibold,
                    TextXAlignment=Enum.TextXAlignment.Left,Parent=row
                })
                local sw=New("Frame",{
                    AnchorPoint=Vector2.new(1,.5),Position=UDim2.new(1,0,.5,0),
                    Size=UDim2.fromOffset(18,18),BackgroundColor3=color,BorderSizePixel=0,Parent=row
                })
                Corner(sw,1)
                -- 2x2 highlight blocks, like the reference color squares.
                New("Frame",{Size=UDim2.new(.5,0,.5,0),BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=.84,BorderSizePixel=0,Parent=sw})
                local ctl={}
                function ctl:Set(v,silent) color=v;sw.BackgroundColor3=v;if callback and not silent then callback(v) end end
                function ctl:Get() return color end
                row.MouseButton1Click:Connect(function() if callback then callback(color) end end)
                return ctl
            end

            function s:AddButton(text,callback)
                local b=New("TextButton",{
                    Size=UDim2.new(1,0,0,28),BackgroundColor3=Color3.fromRGB(7,9,11),
                    BorderSizePixel=0,Text=text,TextColor3=C.TEXT,TextSize=12,
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

    local key=o.ToggleKey or Enum.KeyCode.RightShift
    UIS.InputBegan:Connect(function(i,processed)
        if not processed and i.KeyCode==key then gui.Enabled=not gui.Enabled end
    end)

    return api
end

return MakoUI
