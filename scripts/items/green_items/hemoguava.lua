local mod = jezreelMod
local h = include("scripts/func")

local greenD6 = mod.ENUMS.ITEMS.G6
local hemoguava = mod.ENUMS.VEGETABLES.HEMOGUAVA

local BLOOD_CREEP_COOL = 4 --frames
local BLOOD_TEAR_NUM = 12
local BLOOD_TEAR_COOL = 25

local funcs = {}

function funcs:useItem(_, rng, player, _, _, _)
    local data = player:GetData()

    if(player:HasCollectible(hemoguava)) then data.usedGuava = player:GetCollectibleNum(hemoguava) end
end
mod:AddCallback(ModCallbacks.MC_USE_ITEM, funcs.useItem, greenD6)

---@param player EntityPlayer
function funcs:postPlayerUpdate(player)
    if(not player:GetData().usedGuava) then return end

    local data = player:GetData()
    local guavaNum = player:GetData().usedGuava or 1

    if(data.spawnedHemoCreep==nil) then
        if(player.FrameCount%BLOOD_CREEP_COOL==0) then
            local blood = Isaac.Spawn(1000, EffectVariant.PLAYER_CREEP_RED, 0, player.Position, Vector.Zero, player):ToEffect()
            blood.CollisionDamage = 1*guavaNum
            blood.Scale = 0.5
            blood.Timeout = 10
            blood:Update()
        end

        if(player.FrameCount%BLOOD_TEAR_COOL==0) then
            local rng = player:GetCollectibleRNG(hemoguava)

            player:AddCollectible(CollectibleType.COLLECTIBLE_BLOOD_OF_THE_MARTYR)
            for i=1, math.floor(BLOOD_TEAR_NUM*guavaNum) do
                local tear = player:FireTear(player.Position, Vector.FromAngle(rng:RandomFloat()*360)*rng:RandomFloat()*(15*player.ShotSpeed))
                tear.TearFlags = TearFlags.TEAR_NORMAL

                tear.FallingAcceleration = 2
                tear.FallingSpeed = -10
                tear.Scale = tear.Scale*(0.33+rng:RandomFloat()*0.66)
                tear.CollisionDamage = player.Damage*0.5
                tear.Color = Color(1,1,1)
            end
            player:RemoveCollectible(CollectibleType.COLLECTIBLE_BLOOD_OF_THE_MARTYR)
        end

        data.spawnedHemoCreep=true
    else
        data.spawnedHemoCreep=nil
    end
end
mod:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, funcs.postPlayerUpdate, 0)

function funcs:postNewRoom()
    for _, player in ipairs(Isaac.FindByType(1,0)) do
        player:GetData().usedGuava = nil
    end
end
mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, funcs.postNewRoom)

-- CURSED GRAPES SYNERGY --
local GRAPE_GUAVA_CHANCE = 2/3
local GRAPE_GUAVA_MOD = 1/2

local cursedGrapes = mod.ENUMS.VEGETABLES.CURSED_GRAPES
function funcs:postNewRoomGrapes()
    if(h:isRoomClear()) then return end
    for _, player in ipairs(Isaac.FindByType(1,0)) do
        player=player:ToPlayer()
        local data = player:GetData()
        local rng = player:GetCollectibleRNG(cursedGrapes)

        local chance = (1-GRAPE_GUAVA_CHANCE)^(player:GetCollectibleNum(cursedGrapes))

        if(rng:RandomFloat()>chance and player:HasCollectible(cursedGrapes) and player:HasCollectible(hemoguava)) then
            data.usedGuava = GRAPE_GUAVA_CHANCE * player:GetCollectibleNum(hemoguava)
        end
    end
end
mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, funcs.postNewRoomGrapes)

mod.ITEMS.HEMOGUAVA = funcs