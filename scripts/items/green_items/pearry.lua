local mod = jezreelMod

local pearry = mod.ENUMS.VEGETABLES.PEARRY

local funcs = {}

function funcs:postCollectibleGet(player, item)
    for i=1,4 do
        local pickup = Isaac.Spawn(5,mod.PICKUPS.PEAR,0,Game():GetRoom():FindFreePickupSpawnPosition(player.Position+Vector(0,40),0,true),Vector.Zero,player)
    end
end
mod:AddCallback("GREEN_POST_COLLECTIBLE_GET", funcs.postCollectibleGet, pearry)

mod.ITEMS.PEARRY = funcs