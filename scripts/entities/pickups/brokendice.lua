local mod = jezreelMod

local brokenDice = mod.CONSUMABLES.BROKEN_DICE

local funcs = {}

local pickupToGreenNum = {
    [PickupVariant.PICKUP_HEART]={
        [HeartSubType.HEART_FULL]=1,
        [HeartSubType.HEART_HALF]=1,
        [HeartSubType.HEART_SOUL]=2,
        [HeartSubType.HEART_ETERNAL]=5,
        [HeartSubType.HEART_DOUBLEPACK]=2,
        [HeartSubType.HEART_BLACK]=3,
        [HeartSubType.HEART_GOLDEN]=5,
        [HeartSubType.HEART_HALF_SOUL]=1,
        [HeartSubType.HEART_SCARED]=2,
        [HeartSubType.HEART_BLENDED]=2,
        [HeartSubType.HEART_BONE]=3,
        [HeartSubType.HEART_ROTTEN]=3,
    },
    [PickupVariant.PICKUP_COIN]={
        [CoinSubType.COIN_PENNY]=1,
        [CoinSubType.COIN_NICKEL]=2,
        [CoinSubType.COIN_DIME]=5,
        [CoinSubType.COIN_DOUBLEPACK]=2,
        [CoinSubType.COIN_LUCKYPENNY]=2,
        [CoinSubType.COIN_STICKYNICKEL]=1,
        [CoinSubType.COIN_GOLDEN]=5,
    },
    [PickupVariant.PICKUP_KEY]={
        [KeySubType.KEY_NORMAL]=1,
        [KeySubType.KEY_DOUBLEPACK]=2,
        [KeySubType.KEY_GOLDEN]=5,
        [KeySubType.KEY_CHARGED]=2,
    },
    [PickupVariant.PICKUP_BOMB]={
        [BombSubType.BOMB_NORMAL]=1,
        [BombSubType.BOMB_DOUBLEPACK]=2,
        [BombSubType.BOMB_GOLDEN]=5,
        [BombSubType.BOMB_GIGA]=5,
    },
    [PickupVariant.PICKUP_CHEST]=8,
    [PickupVariant.PICKUP_BOMBCHEST]=8,
    [PickupVariant.PICKUP_SPIKEDCHEST]=10,
    [PickupVariant.PICKUP_ETERNALCHEST]=12,
    [PickupVariant.PICKUP_MIMICCHEST]=10,
    [PickupVariant.PICKUP_OLDCHEST]=10,
    [PickupVariant.PICKUP_MEGACHEST]=16,
    [PickupVariant.PICKUP_HAUNTEDCHEST]=10,
    [PickupVariant.PICKUP_LOCKEDCHEST]=10,
    [PickupVariant.PICKUP_GRAB_BAG]=3,
    [PickupVariant.PICKUP_PILL]=3,
    [PickupVariant.PICKUP_LIL_BATTERY]=5,
    [PickupVariant.PICKUP_COLLECTIBLE]=12,
    [PickupVariant.PICKUP_TAROTCARD]=3,
    [PickupVariant.PICKUP_TRINKET]=6,
    [PickupVariant.PICKUP_REDCHEST]=8,
}

function funcs:useCard(card, player, useFlags)
    local function getVel(rng) return Vector(3,0):Rotated(rng:RandomFloat()*360) end

    local function greenPickup(entity)
        local rng = entity:GetDropRNG()

        local greenNum = 0
        if(type(pickupToGreenNum[entity.Variant])=="number") then greenNum=pickupToGreenNum[entity.Variant]
        elseif(type(pickupToGreenNum[entity.Variant])=="table" and type(pickupToGreenNum[entity.Variant][entity.SubType])=="number") then
            greenNum=pickupToGreenNum[entity.Variant][entity.SubType]
        end

        if(greenNum~=0) then
            for i=1, greenNum do

                local vel = Vector.Zero
                if(greenNum>1) then vel = getVel(rng) end
                if(rng:RandomFloat()<0.5) then
                    local pickup = Isaac.Spawn(5,mod.PICKUPS.PEAR,0, entity.Position, vel, player)
                else
                    local pickup = Isaac.Spawn(5,20,mod.PICKUPS.GREENCOIN, entity.Position, vel, player)
                end
            end
            local puff = Isaac.Spawn(1000,15,0,entity.Position,Vector.Zero,nil)
            entity:Remove()
        end
    end

    for _, entity in ipairs(Isaac.FindByType(5)) do
        if(entity:ToPickup().Price~=0) then goto invalidPickup end

        do
            greenPickup(entity)
        end

        ::invalidPickup::
    end
end
mod:AddCallback(ModCallbacks.MC_USE_CARD, funcs.useCard, brokenDice)

local gCons = include("scripts/entities/pickups/genericGreenCons")

function funcs:postPickupInit(pickup)
    gCons:rerollLocked(pickup, brokenDice, mod.MARKS.CHARACTERS.CAIN.A.Lamb)
    gCons:genericInit(pickup, brokenDice)
end
mod:AddCallback(ModCallbacks.MC_POST_PICKUP_INIT, funcs.postPickupInit, 300)

function funcs:postPickupUpdate(pickup)
    gCons:genericUpdate(pickup, brokenDice)
end
mod:AddCallback(ModCallbacks.MC_POST_PICKUP_UPDATE, funcs.postPickupUpdate, 300)

function funcs:prePickupCollision(pickup, collider, low)
    local coll = gCons:genericCollision(pickup, collider, brokenDice)
    if(coll~=0) then return coll end
end
mod:AddCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, funcs.prePickupCollision, 300)

function funcs:postPickupRender(pickup, offset)
    gCons:rerenderOnCollect(pickup, offset, brokenDice)
end
mod:AddCallback(ModCallbacks.MC_POST_PICKUP_RENDER, funcs.postPickupRender, 300)

function funcs:postPlayerUpdate(player)
    gCons:replaceLocked(player, brokenDice, mod.MARKS.CHARACTERS.CAIN.A.Lamb)
end
mod:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, funcs.postPlayerUpdate)

mod.ENTITIES.PICKUPS.BROKENDICE = funcs