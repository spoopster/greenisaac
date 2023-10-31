local greenCharCostume = Isaac.GetCostumeIdByPath("gfx/characters/green_char.anm2")
local flyingGreenCharCostume = Isaac.GetCostumeIdByPath("gfx/characters/green_ghost.anm2")

---@param player EntityPlayer
local function onCache(_, player, flags)
    if(flags&CacheFlag.CACHE_FLYING==CacheFlag.CACHE_FLYING) then
        player:TryRemoveNullCostume(greenCharCostume)
        player:TryRemoveNullCostume(flyingGreenCharCostume)
    end
end
jezreelMod:AddPriorityCallback(ModCallbacks.MC_EVALUATE_CACHE, CallbackPriority.EARLY, onCache)