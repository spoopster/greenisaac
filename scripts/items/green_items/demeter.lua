local mod = jezreelMod
local h = include("scripts/func")

local demeter = mod.ENUMS.VEGETABLES.DEMETER
local blockbumVar = Isaac.GetEntityVariantByName("Blockbum")
local pearVariant = mod.PICKUPS.PEAR

local DEMETER_PICKUP_NUM = 4
local DEMETER_BLOCKBUM_NUM = 2
local DEMETER_PEAR_CHANCE = 0.5

local DEMETER_VALID_HEARTS = {
    [1]=HeartSubType.HEART_FULL,
    [2]=HeartSubType.HEART_HALF,
    [3]=HeartSubType.HEART_SOUL,
    [4]=HeartSubType.HEART_HALF_SOUL,
    [5]=HeartSubType.HEART_DOUBLEPACK,
    [6]=HeartSubType.HEART_GOLDEN,
    --[7]=HeartSubType.HEART_BONE,
    --[8]=HeartSubType.HEART_ROTTEN,
    --[9]=HeartSubType.HEART_BLACK,
    --[10]=HeartSubType.HEART_ETERNAL,
}

local funcs = {}

function funcs:postNewRoom()
    local room = Game():GetRoom()
    if(not (room:IsFirstVisit() and room:GetType()==RoomType.ROOM_TREASURE)) then return end
    local allDemeterNum = h:allPlayersCollNum(demeter)
    if(allDemeterNum<=0) then return end

    for i=0, Game():GetNumPlayers()-1 do
        local player = Isaac.GetPlayer(i)
        local demeterNum = player:GetCollectibleNum(demeter)
        if(demeterNum>0) then
            local rng = player:GetCollectibleRNG(demeter)

            for j=1, DEMETER_PICKUP_NUM*demeterNum do
                local spawnPos = room:FindFreePickupSpawnPosition(room:GetCenterPos(),0)
                local pickup = nil
                if(rng:RandomFloat()>(1-DEMETER_PEAR_CHANCE)^demeterNum) then
                    pickup = Isaac.Spawn(5,pearVariant,0,spawnPos,Vector.Zero,nil)
                else
                    --VANILLA WEIGHTS
                    --pickup = Isaac.Spawn(5,10,0,spawnPos,Vector.Zero,nil)

                    --RANDOM HEARTS
                    pickup = Isaac.Spawn(5,10,DEMETER_VALID_HEARTS[rng:RandomInt(#DEMETER_VALID_HEARTS)+1],spawnPos,Vector.Zero,nil)
                end
            end
            local blockBumNum = DEMETER_BLOCKBUM_NUM+(demeterNum-1)
            for j=1, blockBumNum do
                local spawnPos = room:FindFreePickupSpawnPosition(room:GetCenterPos()+Vector.FromAngle(j*360/blockBumNum)*40,0,true)
                local subtype = rng:RandomInt(6)+1
                local blockbum = Isaac.Spawn(3, blockbumVar, subtype, spawnPos, Vector.Zero, player)
            end

            player:GetData().exploredItemRoom = true
            player:AddCacheFlags(CacheFlag.CACHE_DAMAGE)
            player:EvaluateItems()

            player:AnimateHappy()
        end
    end
end
mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, funcs.postNewRoom)

function funcs:postNewLevel()
    for i=0, Game():GetNumPlayers()-1 do
        Isaac.GetPlayer(i):GetData().exploredItemRoom = false
    end
end
mod:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, funcs.postNewLevel)

function funcs:evaluateCache(player, flag)
    local demeterNum = player:GetCollectibleNum(demeter)
    if(demeterNum>0 and player:GetData().exploredItemRoom==true) then
        if(flag & CacheFlag.CACHE_DAMAGE == CacheFlag.CACHE_DAMAGE) then
            player.Damage = player.Damage*1.5^demeterNum
        end
    end
end
mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, funcs.evaluateCache)

mod.ITEMS.DEMETER = funcs