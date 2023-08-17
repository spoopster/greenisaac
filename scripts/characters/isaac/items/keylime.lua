local mod = jezreelMod

local greenD6 = mod.ENUMS.ITEMS.G6
local keyLime = mod.ENUMS.VEGETABLES.KEY_LIME

local funcs = {}

function funcs:useItem(_, _, player, _, _, _)
    local items = Isaac.FindByType(5,100)
    local data = player:GetData()

    local numKeys = #items+player:GetCollectibleNum(keyLime)-1
    if(#items>0 and player:HasCollectible(keyLime)) then
        for i=1, numKeys do
            local key = Isaac.Spawn(5, 30, 0, player.Position+Vector(0, 40):Rotated(i*360/numKeys), Vector.Zero, player)
        end
    end
end
mod:AddCallback(ModCallbacks.MC_USE_ITEM, funcs.useItem, greenD6)

mod.ITEMS.KEYLIME = funcs