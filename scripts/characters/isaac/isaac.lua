local mod = jezreelMod

local greenD6 = mod.ENUMS.ITEMS.G6
local greenBreakfast = mod.ENUMS.ITEMS.GREEN_BREAKFAST

local greenIsaac = Isaac.GetPlayerTypeByName("Green Isaac", false)

local greenCharCostume = Isaac.GetCostumeIdByPath("gfx/characters/green_char.anm2")
local flyingGreenCharCostume = Isaac.GetCostumeIdByPath("gfx/characters/green_ghost.anm2")

local funcs = {}

---@param player EntityPlayer
function funcs:onCache(player, flags)
    if(player:GetPlayerType()==greenIsaac) then
        if(flags&CacheFlag.CACHE_FLYING==CacheFlag.CACHE_FLYING) then
            if(player.CanFly) then
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

---@param player EntityPlayer
function funcs:postPlayerInit(player)
    if(player:GetPlayerType()==greenIsaac) then
        if(player:GetActiveItem(2)~=greenD6 and player:GetActiveItem(3)~=greenD6) then
            player:SetPocketActiveItem(greenD6, ActiveSlot.SLOT_POCKET, true)
        end
        if(not player:HasCollectible(greenBreakfast)) then
            player:AddCollectible(greenBreakfast, 0, true)
        end
    end
end
mod:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT, funcs.postPlayerInit, 0)

---@param tear EntityTear
function funcs:postIsaacFireTear(tear)
    local player = tear.SpawnerEntity:ToPlayer()
    if(not (player)) then return end
    if(player:GetPlayerType()==greenIsaac) then
        tear.Color = Color(0.3,0.6,0.2,1,0,0,0)
    end
end
mod:AddCallback(ModCallbacks.MC_POST_FIRE_TEAR, funcs.postIsaacFireTear)

mod.CHARACTERS.ISAAC = funcs