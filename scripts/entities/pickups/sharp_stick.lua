local mod = jezreelMod

local sharpStick = mod.CONSUMABLES.SHARP_STICK
local blockbumVar = Isaac.GetEntityVariantByName("Blockbum")

local funcs = {}

function funcs:useCard(card, player, useFlags)
    player:UseActiveItem(CollectibleType.COLLECTIBLE_DULL_RAZOR, false)
    local rng = player:GetDropRNG()
    local subtype = rng:RandomInt(6)+1
    local blockbum = Isaac.Spawn(3, blockbumVar, subtype, player.Position, Vector.Zero, player)
end
mod:AddCallback(ModCallbacks.MC_USE_CARD, funcs.useCard, sharpStick)

local gCons = include("scripts/entities/pickups/generic_green_cons")

function funcs:postPickupInit(pickup)
    gCons:rerollLocked(pickup, sharpStick, mod.MARKS.CHARACTERS.CAIN.A.Lamb)
    gCons:genericInit(pickup, sharpStick)
end
mod:AddCallback(ModCallbacks.MC_POST_PICKUP_INIT, funcs.postPickupInit, 300)

function funcs:postPickupUpdate(pickup)
    gCons:genericUpdate(pickup, sharpStick)
end
mod:AddCallback(ModCallbacks.MC_POST_PICKUP_UPDATE, funcs.postPickupUpdate, 300)

function funcs:prePickupCollision(pickup, collider, low)
    local coll = gCons:genericCollision(pickup, collider, sharpStick)
    if(coll~=0) then return coll end
end
mod:AddCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, funcs.prePickupCollision, 300)

function funcs:postPickupRender(pickup, offset)
    gCons:rerenderOnCollect(pickup, offset, sharpStick)
end
mod:AddCallback(ModCallbacks.MC_POST_PICKUP_RENDER, funcs.postPickupRender, 300)

function funcs:postPlayerUpdate(player)
    gCons:replaceLocked(player, sharpStick, mod.MARKS.CHARACTERS.CAIN.A.Lamb)
end
mod:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, funcs.postPlayerUpdate)

mod.ENTITIES.PICKUPS.SHARPSTICK = funcs