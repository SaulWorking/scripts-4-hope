local Players = game:GetService("Players")
local player = Players.LocalPlayer

local function playSound(ID: string)
    local character = player.Character

    if character:FindFirstChild("Sahur") then
        return
    end
        local TUNGTUNGTUNG = Instance.new("Sound",character)
        TUNGTUNGTUNG.SoundId = ID
        TUNGTUNGTUNG.Name = "Sahur"

        TUNGTUNGTUNG:Play()
        
        print("sound played")
end


local function changeLighting() 
    local Lighting = game:GetService("Lighting")
    local fog =500_000


    Lighting:ClearAllChildren()

    Lighting.FogStart = Lighting.FogEnd
    Lighting.FogColor = Color3.fromRGB(fog,fog,fog)
    
    playSound("rbxassetid://92226310389946")
end

local function forceFirstPerson()
    local char  = player.character
    player.CameraMode = Enum.CameraMode.Classic


end

local function changePlayerSounds()

    local char = player.Character or player.CharacterAdded:Wait()
    local hrp = char:WaitForChild("HumanoidRootPart")
    local running = hrp:FindFirstChild("Running")
    local jumping = hrp:FindFirstChild("Jumping")
    local died = hrp:FindFirstChild("Died")

    if running then
        running.SoundId = "rbxassetid://122993282366150"
    end

   
    if jumping then
        jumping.SoundId = "rbxassetid://132163823091536"
    end

    if died then
        died.SoundId = "rbxassetid://84062856983699"
    end

end



changeLighting()
forceFirstPerson()
changePlayerSounds()


