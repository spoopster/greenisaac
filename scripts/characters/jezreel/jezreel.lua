local mod = jezreelMod

local greenThumbId = mod.ENUMS.ITEMS.GREEN_THUMB

local jezreelId = Isaac.GetPlayerTypeByName("Jezreel", false)

local greenCharCostume = Isaac.GetCostumeIdByPath("gfx/characters/green_char.anm2")
local flyingGreenCharCostume = Isaac.GetCostumeIdByPath("gfx/characters/green_ghost.anm2")

local funcs = {}

---@param player EntityPlayer
function funcs:onCache(player, flags)
    if(player:GetPlayerType()==jezreelId) then
        if(flags&CacheFlag.CACHE_SPEED==CacheFlag.CACHE_SPEED) then
            player.MoveSpeed = player.MoveSpeed+0.2
        end
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

function funcs:postPlayerInit(player)
    if(player:GetPlayerType()==jezreelId) then
        if(player:GetActiveItem(2)~=greenThumbId and player:GetActiveItem(3)~=greenThumbId) then
            player:SetPocketActiveItem(greenThumbId, ActiveSlot.SLOT_POCKET, true)
        end
    end
end
mod:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT, funcs.postPlayerInit, 0)

function funcs:postPlayerUpdate(player)
    if(player:GetPlayerType()==jezreelId) then
        player:ClearCostumes()
    end
end
mod:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, funcs.postPlayerUpdate, 0)

mod.CHARACTERS.JEZREEL = funcs