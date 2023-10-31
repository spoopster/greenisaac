local mod = jezreelMod
local sfx = SFXManager()

local shatterSound = 53
sfx:Preload(shatterSound)

local glassPenny = mod.CONSUMABLES.GLASS_PENNY

local funcs = {}

function funcs:useCard(card, player, useFlags)
    player:UseActiveItem(CollectibleType.COLLECTIBLE_CROOKED_PENNY, 1, -1, 0)
    sfx:Play(shatterSound, 2.5)
end
mod:AddCallback(ModCallbacks.MC_USE_CARD, funcs.useCard, glassPenny)

local gCons = include("scripts/entities/pickups/generic_green_cons")

function funcs:postPickupInit(pickup)
    gCons:rerollLocked(pickup, glassPenny, mod.MARKS.CHARACTERS.CAIN.A.UltraGreedier)
    gCons:genericInit(pickup, glassPenny)
end
mod:AddCallback(ModCallbacks.MC_POST_PICKUP_INIT, funcs.postPickupInit, 300)

function funcs:postPickupUpdate(pickup)
    gCons:genericUpdate(pickup, glassPenny)
end
mod:AddCallback(ModCallbacks.MC_POST_PICKUP_UPDATE, funcs.postPickupUpdate, 300)

function funcs:prePickupCollision(pickup, collider, low)
    local coll = gCons:genericCollision(pickup, collider, glassPenny)
    if(coll~=0) then return coll end
end
mod:AddCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, funcs.prePickupCollision, 300)

function funcs:postPickupRender(pickup, offset)
    gCons:rerenderOnCollect(pickup, offset, glassPenny)
end
mod:AddCallback(ModCallbacks.MC_POST_PICKUP_RENDER, funcs.postPickupRender, 300)

function funcs:postPlayerUpdate(player)
    gCons:replaceLocked(player, glassPenny, mod.MARKS.CHARACTERS.CAIN.A.UltraGreedier)
end
mod:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, funcs.postPlayerUpdate)

mod.ENTITIES.PICKUPS.GLASSPENNY = funcs