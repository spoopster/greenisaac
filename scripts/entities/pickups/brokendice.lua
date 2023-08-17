local mod = jezreelMod

local brokenDice = mod.CONSUMABLES.BROKEN_DICE

local funcs = {}

function funcs:useCard(card, player, useFlags)
    for _, entity in ipairs(Isaac.FindByType(5,100)) do
        if(entity.SubType~=0 and entity:ToPickup().Price==0) then
            local rng = entity:GetDropRNG()
            for i=1, 4+rng:RandomInt(3) do
                local var = Isaac.GetEntityVariantByName("The Pear")
                if(rng:RandomFloat()<0.5) then var = Isaac.GetEntityVariantByName("Greencoin") end

                local pickup = Isaac.Spawn(5,var,0,entity.Position, Vector(5,0):Rotated(rng:RandomFloat()*360), player)
            end
            local puff = Isaac.Spawn(1000,15,0,entity.Position,Vector.Zero,nil)
            entity:Remove()
        end
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