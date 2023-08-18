local mod = jezreelMod

local pizzaBerry = mod.ENUMS.VEGETABLES.PIZZABERRY
local funcs = {}

---@param player EntityPlayer
---@param flag CacheFlag
function funcs:evaluateCache(player, flag)
    if(player:HasCollectible(pizzaBerry)) then
        if(flag & CacheFlag.CACHE_DAMAGE == CacheFlag.CACHE_DAMAGE) then
            player.Damage = player.Damage*(1.1^player:GetCollectibleNum(pizzaBerry))
        end
    end
end
mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, funcs.evaluateCache)

mod.ITEMS.PIZZABERRY = funcs