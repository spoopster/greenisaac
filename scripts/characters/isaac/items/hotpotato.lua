local mod = jezreelMod

local hotPotato = mod.ENUMS.VEGETABLES.HOT_POTATO
local funcs = {}

---@param player EntityPlayer
function funcs:postPlayerUpdate(player)
    local data = player:GetData()

    if(data.canHotPotato==nil) then
        data.canHotPotato=0
    end
    if(data.canHotPotato and data.canHotPotato>0) then
        data.canHotPotato=data.canHotPotato-1
    end
end
mod:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, funcs.postPlayerUpdate, 0)

---@param player EntityPlayer
---@param collider Entity
function funcs:prePlayerCollision(player, collider, _)
    if(collider:IsVulnerableEnemy() and not collider:HasEntityFlags(EntityFlag.FLAG_FRIENDLY)) then
        local data = player:GetData()
        if(player:HasCollectible(hotPotato) and data.canHotPotato==0) then
            local bomb = Isaac.Spawn(EntityType.ENTITY_BOMB, 0, 0, collider.Position, Vector.Zero, player):ToBomb()
            bomb.RadiusMultiplier = 1.5
            bomb.ExplosionDamage = 40
            bomb:SetExplosionCountdown(0)
            bomb.Visible = false

            local fire = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.RED_CANDLE_FLAME, 0, collider.Position, Vector.Zero, player):ToEffect()
            fire.CollisionDamage = 0.1

            data.canHotPotato=60
            player:RemoveCollectible(hotPotato)
        end
    end
end
mod:AddCallback(ModCallbacks.MC_PRE_PLAYER_COLLISION, funcs.prePlayerCollision, 0)

---@param player EntityPlayer
---@param flag CacheFlag
function funcs:evaluateCache(player, flag)
    if(player:HasCollectible(hotPotato)) then
        if(flag & CacheFlag.CACHE_DAMAGE == CacheFlag.CACHE_DAMAGE) then
            player.Damage = player.Damage*(1.2^player:GetCollectibleNum(hotPotato))
        end
        if(flag & CacheFlag.CACHE_SPEED == CacheFlag.CACHE_SPEED) then
            player.MoveSpeed = player.MoveSpeed+0.3*player:GetCollectibleNum(hotPotato)
        end
    end
end
mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, funcs.evaluateCache)

mod.ITEMS.HOTPOTATO = funcs