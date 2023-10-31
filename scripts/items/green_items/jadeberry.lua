local mod = jezreelMod

local jadeberry = mod.ENUMS.VEGETABLES.JADEBERRY

local funcs = {}

function funcs:postCollectibleGet(player, item)
    for i=1,9 do
        local pickup = Isaac.Spawn(5,20,mod.PICKUPS.GREENCOIN,Game():GetRoom():FindFreePickupSpawnPosition(player.Position+Vector(0,40),0,true),Vector.Zero,player)
    end
end
mod:AddCallback("GREEN_POST_COLLECTIBLE_GET", funcs.postCollectibleGet, jadeberry)

mod.ITEMS.JADEBERRY = funcs