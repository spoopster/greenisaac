local mod = jezreelMod

local grass = mod.ENUMS.VEGETABLES.GRASS_CLIPPINGS

local funcs = {}

function funcs:postPlayerUpdate(player)
    local data = player:GetData()

    if(data.grassBoy==false) then
        player.MoveSpeed = math.min(player.MoveSpeed+player:GetCollectibleNum(grass)*0.1, 3)
        data.grassBoy = nil
    end
end
mod:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, funcs.postPlayerUpdate, 0)

function funcs:evaluateCache(player, flag)
    if(player:HasCollectible(grass)) then
        if(flag & CacheFlag.CACHE_SPEED == CacheFlag.CACHE_SPEED) then
            player:GetData().grassBoy = false
        end
    end
end
mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, funcs.evaluateCache)

mod.ITEMS.GRASS = funcs