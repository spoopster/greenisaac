local mod = jezreelMod

local testChar = Isaac.GetPlayerTypeByName("Green Test Char", false)

local greenCharCostume = Isaac.GetCostumeIdByPath("gfx/characters/green_char.anm2")
local flyingGreenCharCostume = Isaac.GetCostumeIdByPath("gfx/characters/green_ghost.anm2")

local funcs = {}

---@param player EntityPlayer
function funcs:onCache(player, flags)
    if(player:GetPlayerType()==testChar) then
        if(flags&CacheFlag.CACHE_FLYING==CacheFlag.CACHE_FLYING) then
            if(player:IsFlying()) then
                player:AddNullCostume(flyingGreenCharCostume)
                player:TryRemoveNullCostume(greenCharCostume)
            else
                player:AddNullCostume(greenCharCostume)
                player:TryRemoveNullCostume(flyingGreenCharCostume)
            end
        end
    end
end
mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, funcs.onCache)