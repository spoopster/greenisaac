local mod = jezreelMod

local weirdGummy = mod.CONSUMABLES.WEIRD_GUMMY

local funcs = {}

---@param player EntityPlayer
function funcs:useCard(card, player, useFlags)
    player:UseActiveItem(CollectibleType.COLLECTIBLE_WAVY_CAP, UseFlag.USE_NOANIM, -1)
end
mod:AddCallback(ModCallbacks.MC_USE_CARD, funcs.useCard, weirdGummy)

local gCons = include("scripts/entities/pickups/genericGreenCons")

function funcs:postPickupInit(pickup)
    gCons:rerollLocked(pickup, weirdGummy, mod.MARKS.CHARACTERS.CAIN.A.MegaSatan)
    gCons:genericInit(pickup, weirdGummy)
end
mod:AddCallback(ModCallbacks.MC_POST_PICKUP_INIT, funcs.postPickupInit, 300)

function funcs:postPickupUpdate(pickup)
    gCons:genericUpdate(pickup, weirdGummy)
end
mod:AddCallback(ModCallbacks.MC_POST_PICKUP_UPDATE, funcs.postPickupUpdate, 300)

function funcs:prePickupCollision(pickup, collider, low)
    local coll = gCons:genericCollision(pickup, collider, weirdGummy)
    if(coll~=0) then return coll end
end
mod:AddCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, funcs.prePickupCollision, 300)

function funcs:postPickupRender(pickup, offset)
    gCons:rerenderOnCollect(pickup, offset, weirdGummy)
end
mod:AddCallback(ModCallbacks.MC_POST_PICKUP_RENDER, funcs.postPickupRender, 300)

function funcs:postPlayerUpdate(player)
    gCons:replaceLocked(player, weirdGummy, mod.MARKS.CHARACTERS.CAIN.A.MegaSatan)
end
mod:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, funcs.postPlayerUpdate)

mod.ENTITIES.PICKUPS.WEIRDGUMMY = funcs