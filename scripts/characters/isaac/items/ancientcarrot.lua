local mod = jezreelMod
local h = include("scripts/func")

local ancientCarrot = mod.ENUMS.VEGETABLES.ANCIENT_CARROT

local funcs = {}

function funcs:evaluateCache(player, flag)
    if(player:HasCollectible(ancientCarrot)) then
        if(flag & CacheFlag.CACHE_DAMAGE == CacheFlag.CACHE_DAMAGE) then
            player.Damage = player.Damage*(1.2^(player:GetCollectibleNum(ancientCarrot)))
        end
        if(flag & CacheFlag.CACHE_FIREDELAY == CacheFlag.CACHE_FIREDELAY) then
            player.MaxFireDelay = player.MaxFireDelay*(0.9^(player:GetCollectibleNum(ancientCarrot)))
        end
        if(flag & CacheFlag.CACHE_LUCK == CacheFlag.CACHE_LUCK) then
            player.Luck = player.Luck+1*player:GetCollectibleNum(ancientCarrot)
        end
        if(flag & CacheFlag.CACHE_RANGE == CacheFlag.CACHE_RANGE) then
            player.TearRange = player.TearRange+4*40*player:GetCollectibleNum(ancientCarrot)
        end
        if(flag & CacheFlag.CACHE_SHOTSPEED == CacheFlag.CACHE_SHOTSPEED) then
            player.ShotSpeed = player.ShotSpeed+0.3*player:GetCollectibleNum(ancientCarrot)
        end
        if(flag & CacheFlag.CACHE_SPEED == CacheFlag.CACHE_SPEED) then
            player.MoveSpeed = player.MoveSpeed+0.2*player:GetCollectibleNum(ancientCarrot)
        end
    end
end
mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, funcs.evaluateCache)

function funcs:GetShaderParams(shaderName)
    if(shaderName=="AncientCarrotShader") then
        local anyHasCarrot = h:allPlayersCollNum(ancientCarrot)
        local params = {
            ShouldGreen = math.min(anyHasCarrot,10),
        }

        return params
    end
end
mod:AddCallback(ModCallbacks.MC_GET_SHADER_PARAMS, funcs.GetShaderParams)

mod.ITEMS.ANCIENTCARROT = funcs