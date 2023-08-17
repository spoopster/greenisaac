local mod = jezreelMod

local fcukBerry = mod.ENUMS.VEGETABLES.FCUKBERRY

local funcs = {}

function funcs:postCollectibleGet(player, item)
    local portal = Isaac.Spawn(1000,EffectVariant.PORTAL_TELEPORT,3,player.Position+Vector(0,50),Vector.Zero,player)

    local color = portal.Color
    color:SetColorize(1,1,1,1)

    color:SetTint(1.5,1.5,1.5,1)

    portal.Color = color
end
mod:AddCallback("GREEN_POST_COLLECTIBLE_GET", funcs.postCollectibleGet, fcukBerry)

mod.ITEMS.PEARRY = funcs