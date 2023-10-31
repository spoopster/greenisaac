local mod = jezreelMod

local floweringJade = mod.CONSUMABLES.FLOWERING_JADE

local funcs = {}

function funcs:useCard(card, player, useFlags)
    player:UseActiveItem(mod.ENUMS.ITEMS.G6, 1, -1, 0)
end
mod:AddCallback(ModCallbacks.MC_USE_CARD, funcs.useCard, floweringJade)

local gCons = include("scripts/entities/pickups/generic_green_cons")

function funcs:postPickupInit(pickup)
    gCons:rerollLocked(pickup, floweringJade, mod.MARKS.CHARACTERS.CAIN.A.BlueBaby)
    gCons:genericInit(pickup, floweringJade)
end
mod:AddCallback(ModCallbacks.MC_POST_PICKUP_INIT, funcs.postPickupInit, 300)

function funcs:postPickupUpdate(pickup)
    gCons:genericUpdate(pickup, floweringJade)
end
mod:AddCallback(ModCallbacks.MC_POST_PICKUP_UPDATE, funcs.postPickupUpdate, 300)

function funcs:prePickupCollision(pickup, collider, low)
    local coll = gCons:genericCollision(pickup, collider, floweringJade)
    if(coll~=0) then return coll end
end
mod:AddCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, funcs.prePickupCollision, 300)

function funcs:postPickupRender(pickup, offset)
    gCons:rerenderOnCollect(pickup, offset, floweringJade)
end
mod:AddCallback(ModCallbacks.MC_POST_PICKUP_RENDER, funcs.postPickupRender, 300)

function funcs:postPlayerUpdate(player)
    gCons:replaceLocked(player, floweringJade, mod.MARKS.CHARACTERS.CAIN.A.BlueBaby)
end
mod:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, funcs.postPlayerUpdate)

mod.ENTITIES.PICKUPS.FLOWERINGJADE = funcs