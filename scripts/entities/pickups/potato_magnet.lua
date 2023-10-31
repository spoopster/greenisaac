local mod = jezreelMod

local greenCain = Isaac.GetPlayerTypeByName("Green Cain", false)
local potatoMagnet = mod.CONSUMABLES.POTATO_MAGNET
local slotVar = Isaac.GetEntityVariantByName("Green Slot")

local DOUBLE_BLACKLIST = {
    [PickupVariant.PICKUP_COLLECTIBLE]=true,
    [PickupVariant.PICKUP_BROKEN_SHOVEL]=true,
    [PickupVariant.PICKUP_TRINKET]=true,
    [PickupVariant.PICKUP_TROPHY]=true,
    [PickupVariant.PICKUP_BED]=true,
    [PickupVariant.PICKUP_MOMSCHEST]=true,
}
local MAGNET_CHESTS = {
    [PickupVariant.PICKUP_CHEST]=true,
    [PickupVariant.PICKUP_BOMBCHEST]=true,
    [PickupVariant.PICKUP_SPIKEDCHEST]=true,
    [PickupVariant.PICKUP_ETERNALCHEST]=true,
    [PickupVariant.PICKUP_MIMICCHEST]=true,
    [PickupVariant.PICKUP_OLDCHEST]=true,
    [PickupVariant.PICKUP_WOODENCHEST]=true,
    [PickupVariant.PICKUP_MEGACHEST]=true,
    [PickupVariant.PICKUP_HAUNTEDCHEST]=true,
    [PickupVariant.PICKUP_LOCKEDCHEST]=true,
    [PickupVariant.PICKUP_REDCHEST]=true,
}

local funcs = {}

function funcs:useCard(card, player, useFlags)
    if(player:GetPlayerType()==greenCain) then
        for _, machine in pairs(Isaac.FindByType(6, slotVar)) do
            local data = machine:GetData()
            data.magnetCharges = data.magnetCharges+2
        end
    else
        player:GetEffects():AddCollectibleEffect(CollectibleType.COLLECTIBLE_MAGNETO, true, 2)
        local chance = 1
        local rand = player:GetCardRNG(potatoMagnet):RandomFloat()
        for _, pickup in ipairs(Isaac.FindByType(5)) do
            pickup=pickup:ToPickup()
            --[[if(DOUBLE_BLACKLIST[pickup.Variant]~=true) then
                if(rand<chance) then
                    local spawnPos = pickup.Position+Vector(15,0):Rotated(pickup:GetDropRNG():RandomFloat()*360)
                    local newPickup = Isaac.Spawn(5,pickup.Variant,0,spawnPos,pickup.Velocity,pickup)
                    chance = chance/2
                end
            end]]
            if(MAGNET_CHESTS[pickup.Variant]==true) then
                if(pickup:GetDropRNG():RandomFloat()<0.5) then
                    pickup:TryOpenChest(nil)
                end
            end
        end
    end
end
mod:AddCallback(ModCallbacks.MC_USE_CARD, funcs.useCard, potatoMagnet)

local gCons = include("scripts/entities/pickups/generic_green_cons")

function funcs:postPickupInit(pickup)
    gCons:rerollLocked(pickup, potatoMagnet, mod.MARKS.CHARACTERS.CAIN.A.MegaSatan)
    gCons:genericInit(pickup, potatoMagnet)
end
mod:AddCallback(ModCallbacks.MC_POST_PICKUP_INIT, funcs.postPickupInit, 300)

function funcs:postPickupUpdate(pickup)
    gCons:genericUpdate(pickup, potatoMagnet)
end
mod:AddCallback(ModCallbacks.MC_POST_PICKUP_UPDATE, funcs.postPickupUpdate, 300)

function funcs:prePickupCollision(pickup, collider, low)
    local coll = gCons:genericCollision(pickup, collider, potatoMagnet)
    if(coll~=0) then return coll end
end
mod:AddCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, funcs.prePickupCollision, 300)

function funcs:postPickupRender(pickup, offset)
    gCons:rerenderOnCollect(pickup, offset, potatoMagnet)
end
mod:AddCallback(ModCallbacks.MC_POST_PICKUP_RENDER, funcs.postPickupRender, 300)

function funcs:postPlayerUpdate(player)
    gCons:replaceLocked(player, potatoMagnet, mod.MARKS.CHARACTERS.CAIN.A.MegaSatan)
end
mod:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, funcs.postPlayerUpdate)

mod.ENTITIES.PICKUPS.POTATOMAGNET = funcs