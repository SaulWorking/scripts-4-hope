-- LocalScript inside StarterGui
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local Animator = Humanoid:WaitForChild("Animator")

--------------------------------------------------------------------------------
-- Emote data
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Emote data
--------------------------------------------------------------------------------
local EMOTES = {
    {
        name = "terra nova blue shirt kid",
        animIdR15 = "rbxassetid://110057724172905",
        animIdR6 = "rbxassetid://YOUR_R6_ANIMATION_ID",
        soundId = "rbxassetid://82746224492420",
        loopStart = 30,
    },
    {
        name = "mitchell rome",
        animIdR15 = "rbxassetid://100156926241491", -- tick tock
        animIdR6 = "rbxassetid://126157973857632", -- bhop
        soundId = "rbxassetid://103637998030679",
        loopStart = 13,
    },
    {
        name = "cry for me",
        animIdR15 = "rbxassetid://129306314449009",
        animIdR6 = "rbxassetid://YOUR_R6_ANIMATION_ID",
        soundId = "rbxassetid://125230341990848",
    },
    {
        name = "chase brasil",
        animIdR15 = "rbxassetid://126397455439159",
        animIdR6 = "rbxassetid://YOUR_R6_ANIMATION_ID",
        soundId = "rbxassetid://104427243518756",
    },
    {
        name = "Gentle Weather Theme",
        animIdR15 = "rbxassetid://78371783111118",
        animIdR6 = "rbxassetid://YOUR_R6_ANIMATION_ID",
        soundId = "rbxassetid://75245799036926",
    },
    {
        name = "looping rooms",
        animIdR15 = "rbxassetid://112623357691520",
        animIdR6 = "rbxassetid://YOUR_R6_ANIMATION_ID",
        soundId = "rbxassetid://118142475408810",
    },
    {
        name = "Flower man",
        animIdR15 = "rbxassetid://87732260846484",
        animIdR6 = "rbxassetid://YOUR_R6_ANIMATION_ID",
        soundId = "rbxassetid://78976295013927",
    },
    {
        name = "Daniel Inferno",
        animIdR15 = "rbxassetid://88143768235497",
        animIdR6 = "rbxassetid://YOUR_R6_ANIMATION_ID",
        soundId = "rbxassetid://73329981655112",
    },

    {
        name = "Jax Jaris",
        animIdR15 = "rbxassetid://88143768235497",
        animIdR6 = "rbxassetid://74104037699653",
        soundId = "rbxassetid://75245799036926",
    },
    {
        name = "Bird brain",
        animIdR15 = "rbxassetid://88143768235497",
        animIdR6 = "rbxassetid://88143768235497",
        soundId = "rbxassetid://101921312074464",
    },
    {
        name = "daniel night theme",
        animIdR15 = "rbxassetid://88143768235497",
        animIdR6 = "rbxassetid://88143768235497",
        soundId = "rbxassetid://82747303393157",
           loopStart = 5
    },
    {
        name = "bubble pop daniel ",
        animIdR15 = "rbxassetid://88143768235497",
        animIdR6 = "rbxassetid://88143768235497",
        soundId = "rbxassetid://136375054415890",
    },


}

local activeEmote, activeTrack, activeSound = nil, nil, nil
local buttons = {} -- name -> button, for visual toggling

local emoteSettings = {}
local updateSliderDisplays -- forward declaration, assigned later
local speedSlider, pitchSlider

local function getSettings(name)
    if not emoteSettings[name] then
        emoteSettings[name] = {speed = 1, pitch = 1}
    end
    return emoteSettings[name]
end


local function setButtonState(name, isActive)
    local btn = buttons[name]
    if not btn then return end
    btn.BackgroundColor3 = isActive and Color3.fromRGB(90, 140, 240) or Color3.fromRGB(45, 45, 55)
end

local function stopEmote()
    if activeTrack then
        activeTrack:Stop()
        activeTrack:Destroy()
        activeTrack = nil
    end
    if activeSound then
        activeSound:Stop()
        activeSound:Destroy()
        activeSound = nil
    end
    if activeEmote then
        setButtonState(activeEmote, false)
    end
    activeEmote = nil
end


--thanks to infinite yield on line 10002 to 10010 for their animation player 
local function anim2track(asset_id) 
    local objs = game:GetObjects(asset_id) 
        for i = 1, #objs do
        if objs[i]:IsA("Animation") then 
            return objs[i].AnimationId 
            end 
        end 
        return asset_id 
end

-- Extracts the raw SoundId if the asset is an object container
local function sound2track(asset_id)
    -- Ensure asset_id has the correct prefix
    asset_id = tostring(asset_id)
    if not asset_id:find("rbxassetid://", 1, true) then
        asset_id = "rbxassetid://" .. asset_id
    end

    local success, objs = pcall(function()
        return game:GetObjects(asset_id)
    end)

    if success and objs then
        for i = 1, #objs do
            if objs[i]:IsA("Sound") then
                return objs[i].SoundId
            elseif objs[i]:IsA("AudioPlayer") then -- Support for newer Roblox Audio API
                return objs[i].AssetId
            end
        end
    end

    return asset_id
end

local function playEmote(data)
    if activeEmote == data.name then
        stopEmote()
        return
    end

    stopEmote()

    local settings = getSettings(data.name)
    local humanoid = Character:WaitForChild("Humanoid")

    ----------------------------------------------------------------
    -- Choose animation based on rig
    ----------------------------------------------------------------
    local animId

    if humanoid.RigType == Enum.HumanoidRigType.R6 then
        animId = data.animIdR6
    else
        animId = data.animIdR15
    end

    -- Make sure an animation exists for this rig
    if not animId or animId == "" or animId:find("YOUR_R6_ANIMATION_ID", 1, true) then
        warn("No animation configured for " .. data.name .. " on " .. humanoid.RigType.Name)
        return
    end

    ----------------------------------------------------------------
    -- Reproduce the original animation ID
    ----------------------------------------------------------------
    animId = anim2track(animId)

    local animation = Instance.new("Animation")
    animation.AnimationId = animId

    ----------------------------------------------------------------
    -- Get Animator
    ----------------------------------------------------------------
    local animator = humanoid:FindFirstChildOfClass("Animator")

    if not animator then
        animator = Instance.new("Animator")
        animator.Parent = humanoid
    end

    ----------------------------------------------------------------
    -- Load and play animation
    ----------------------------------------------------------------
    local track = animator:LoadAnimation(animation)
    animation:Destroy()

    track.Priority = Enum.AnimationPriority.Movement
    track.Looped = true
    track:Play()
    track:AdjustSpeed(settings.speed)

    ----------------------------------------------------------------
    -- Sound
    ----------------------------------------------------------------
    local rawSoundId = sound2track(data.soundId)

    local sound = Instance.new("Sound")
    sound.SoundId = rawSoundId
    sound.Looped = true
    sound.PlaybackSpeed = settings.speed
    sound.Parent = Character:WaitForChild("HumanoidRootPart")

    local pitchEffect = Instance.new("PitchShiftSoundEffect")
    pitchEffect.Octave = settings.pitch
    pitchEffect.Parent = sound

    sound:Play()

    ----------------------------------------------------------------
    -- Custom sound loop point
    ----------------------------------------------------------------
    if data.loopStart then
        local function seek()
            if sound.Parent then
                sound.TimePosition = data.loopStart
            end
        end

        if sound.IsLoaded then
            seek()
        else
            task.spawn(function()
                sound.Loaded:Wait()

                if sound.Parent then
                    seek()
                end
            end)
        end

        local loopConn
        loopConn = sound.DidLoop:Connect(seek)

        sound.AncestryChanged:Connect(function(_, parent)
            if not parent and loopConn then
                loopConn:Disconnect()
                loopConn = nil
            end
        end)
    end

    ----------------------------------------------------------------
    -- Save active state
    ----------------------------------------------------------------
    activeTrack = track
    activeSound = sound
    activeEmote = data.name

    setButtonState(data.name, true)

    if updateSliderDisplays then
        updateSliderDisplays(settings.speed, settings.pitch)
    end
end



--------------------------------------------------------------------------------
-- UI
--------------------------------------------------------------------------------
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "EmoteMenu"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = PlayerGui

local Panel = Instance.new("Frame")
Panel.Name = "Panel"
Panel.Size = UDim2.new(0, 220, 0, 300)
Panel.Position = UDim2.new(0, 20, 0.5, 0)
Panel.AnchorPoint = Vector2.new(0, 0.5)
Panel.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
Panel.Parent = ScreenGui

local PanelCorner = Instance.new("UICorner")
PanelCorner.CornerRadius = UDim.new(0, 12)
PanelCorner.Parent = Panel

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 36)
Title.BackgroundTransparency = 1
Title.Text = "Emotes"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 18
Title.Parent = Panel

local ScrollingFrame = Instance.new("ScrollingFrame")
ScrollingFrame.Name = "EmotesList"
ScrollingFrame.Position = UDim2.new(0, 0, 0, 36)
ScrollingFrame.Size = UDim2.new(1, 0, 1, -36)
ScrollingFrame.BackgroundTransparency = 1
ScrollingFrame.ScrollBarThickness = 4
ScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
ScrollingFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
ScrollingFrame.Parent = Panel

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Padding = UDim.new(0, 8)
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Parent = ScrollingFrame

local UIPadding = Instance.new("UIPadding")
UIPadding.PaddingTop = UDim.new(0, 8)
UIPadding.PaddingLeft = UDim.new(0, 8)
UIPadding.PaddingRight = UDim.new(0, 8)
UIPadding.PaddingBottom = UDim.new(0, 8)
UIPadding.Parent = ScrollingFrame

for i, data in ipairs(EMOTES) do
    local Button = Instance.new("TextButton")
    Button.Name = data.name
    Button.Size = UDim2.new(1, 0, 0, 44)
    Button.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
    Button.Text = data.name
    Button.TextColor3 = Color3.fromRGB(255, 255, 255)
    Button.Font = Enum.Font.Gotham
    Button.TextSize = 16
    Button.AutoButtonColor = false
    Button.LayoutOrder = i
    Button.Parent = ScrollingFrame

    local BtnCorner = Instance.new("UICorner")
    BtnCorner.CornerRadius = UDim.new(0, 8)
    BtnCorner.Parent = Button

    buttons[data.name] = Button

    Button.MouseButton1Click:Connect(function()
        playEmote(data)
    end)
end













local speedSlider, pitchSlider -- forward declarations for updateSliderDisplays

local function createSlider(labelText, minVal, maxVal, defaultVal, yPos, onChange)
    local Container = Instance.new("Frame")
    Container.Size = UDim2.new(1, -16, 0, 44)
    Container.Position = UDim2.new(0, 8, 0, yPos)
    Container.BackgroundTransparency = 1
    Container.Parent = Panel

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, 0, 0, 16)
    Label.BackgroundTransparency = 1
    Label.Text = labelText .. ": " .. string.format("%.2f", defaultVal)
    Label.TextColor3 = Color3.fromRGB(255, 255, 255)
    Label.Font = Enum.Font.Gotham
    Label.TextSize = 12
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Container

    local Track = Instance.new("Frame")
    Track.Size = UDim2.new(1, 0, 0, 6)
    Track.Position = UDim2.new(0, 0, 0, 24)
    Track.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
    Track.Parent = Container

    local TrackCorner = Instance.new("UICorner")
    TrackCorner.CornerRadius = UDim.new(1, 0)
    TrackCorner.Parent = Track

    local fraction = (defaultVal - minVal) / (maxVal - minVal)
    local Fill = Instance.new("Frame")
    Fill.Size = UDim2.new(fraction, 0, 1, 0)
    Fill.BackgroundColor3 = Color3.fromRGB(90, 140, 240)
    Fill.Parent = Track

    local FillCorner = Instance.new("UICorner")
    FillCorner.CornerRadius = UDim.new(1, 0)
    FillCorner.Parent = Fill

    local Knob = Instance.new("Frame")
    Knob.Size = UDim2.new(0, 14, 0, 14)
    Knob.Position = UDim2.new(fraction, -7, 0.5, -7)
    Knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Knob.Parent = Track

    local KnobCorner = Instance.new("UICorner")
    KnobCorner.CornerRadius = UDim.new(1, 0)
    KnobCorner.Parent = Knob

    local dragging = false
    local UserInputService = game:GetService("UserInputService")

    local function setVisual(value)
        local relX = math.clamp((value - minVal) / (maxVal - minVal), 0, 1)
        Fill.Size = UDim2.new(relX, 0, 1, 0)
        Knob.Position = UDim2.new(relX, -7, 0.5, -7)
        Label.Text = labelText .. ": " .. string.format("%.2f", value)
    end

    local function updateFromInput(input)
        local relX = math.clamp((input.Position.X - Track.AbsolutePosition.X) / Track.AbsoluteSize.X, 0, 1)
        local value = minVal + (maxVal - minVal) * relX
        setVisual(value)
        onChange(value)
    end

    Track.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            updateFromInput(input)
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            updateFromInput(input)
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)

    return {setVisual = setVisual}
end

speedSlider = createSlider("Speed", 0.5, 2, 1, 320, function(value)
    if activeEmote then
        getSettings(activeEmote).speed = value
    end
    if activeTrack then
        activeTrack:AdjustSpeed(value)
    end
    if activeSound then
        activeSound.PlaybackSpeed = value
    end
end)

pitchSlider = createSlider("Pitch", 0.10, 2, 1, 368, function(value)
    if activeEmote then
        getSettings(activeEmote).pitch = value
    end
    if activeSound then
        local pitchEffect = activeSound:FindFirstChildOfClass("PitchShiftSoundEffect")
        if pitchEffect then
            pitchEffect.Octave = value
        end
    end
end)

function updateSliderDisplays(speed, pitch)
    speedSlider.setVisual(speed)
    pitchSlider.setVisual(pitch)
end









--------------------------------------------------------------------------------
-- Make Panel draggable (drag from the title bar)
--------------------------------------------------------------------------------
local UserInputService = game:GetService("UserInputService")

local dragging = false
local dragInput
local dragStart
local startPos

local function updateDrag(input)
    local delta = input.Position - dragStart
    Panel.Position = UDim2.new(
        startPos.X.Scale, startPos.X.Offset + delta.X,
        startPos.Y.Scale, startPos.Y.Offset + delta.Y
    )
end

Title.Active = true
Title.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = Panel.Position

        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

Title.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        updateDrag(input)
    end
end)