local mod = jezreelMod
local h = include("scripts/func")

local jollyMint = mod.ENUMS.VEGETABLES.JOLLY_MINT
local iceVariant = Isaac.GetEntityVariantByName("Jolly Ice")

local funcs = {}

function funcs:postFireTear(tear)
    local player = tear.SpawnerEntity
    if(not (player and player:ToPlayer())) then return end
    player = player:ToPlayer()
    if(player:HasCollectible(jollyMint)) then
        if(tear:GetDropRNG():RandomFloat()>0.75) then
            tear:AddTearFlags(TearFlags.TEAR_SLOW)
        end
    end
end
mod:AddCallback(ModCallbacks.MC_POST_FIRE_TEAR, funcs.postFireTear)

function funcs:entityTakeDMG(entity,amount,flags,source,frames)
    return false
end
mod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, funcs.entityTakeDMG, iceVariant)

function funcs:spawnIce(entity, amount, flags, source, frames)
    local player = source.Entity
    if(not (player and ((player.SpawnerEntity and player.SpawnerEntity:ToPlayer()) or player:ToPlayer()))) then return nil end
    if(player:ToPlayer()) then player=player:ToPlayer()
    else player = player.SpawnerEntity:ToPlayer() end

    if(not (h:isValidEnemy(entity))) then return nil end

    if(entity.MaxHitPoints<1) then return nil end
    if(entity.HitPoints>amount) then return nil end
    if(entity.Type==EntityType.ENTITY_EFFECT and entity.Variant==iceVariant) then return nil end
    if(player:GetCollectibleNum(jollyMint)<=0) then return nil end

    local pos = entity.Position
    local room = Game():GetRoom()
    pos = room:GetGridPosition(room:GetGridIndex(pos))

    local iceBlock = Isaac.Spawn(EntityType.ENTITY_EFFECT, iceVariant, 0, pos, Vector.Zero, player):ToEffect()
    if(iceBlock:GetDropRNG():RandomInt(2)==0) then
        iceBlock:GetSprite():Play("Spawn2")
        iceBlock:GetSprite().PlaybackSpeed = (math.random(30) + 80)/50
    else
        iceBlock:GetSprite():Play("Spawn3")
        iceBlock:GetSprite().PlaybackSpeed = (math.random(30) + 80)/50
    end
    iceBlock:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
    iceBlock:AddEntityFlags(EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK | EntityFlag.FLAG_NO_KNOCKBACK | EntityFlag.FLAG_NO_STATUS_EFFECTS | EntityFlag.FLAG_NO_TARGET)
    iceBlock.Parent = player

end
mod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, funcs.spawnIce)

function funcs:postEffectUpdate(effect)
    if(not (effect.SpawnerEntity and effect.SpawnerEntity:ToPlayer())) then return end
    if(not (effect:GetSprite():IsFinished(effect:GetSprite():GetAnimation()))) then return end
    local player = effect.SpawnerEntity:ToPlayer()

    local sprite = effect:GetSprite()
    if(effect.State>0) then
        effect.State = effect.State-1
    end

    local bullets = Isaac.FindInRadius(effect.Position, effect.Size*effect.Scale, EntityPartition.BULLET)
    for _, bullet in ipairs(bullets) do bullet:Die() end

    local maxDist = effect.Size*effect.Scale*1.25
    if(effect.State<=0) then

        local stackBonus = (1.5^((player:GetCollectibleNum(jollyMint))-1))
        local enemies = Isaac.FindInRadius(effect.Position, maxDist*stackBonus, EntityPartition.ENEMY)
        for _, enemy in ipairs(enemies) do
            enemy:TakeDamage(player.Damage/3*stackBonus, 0, EntityRef(effect),10)
            effect.State = 15
        end
    end

    local enemiesInIce = Isaac.FindInRadius(effect.Position, maxDist, EntityPartition.ENEMY)
    for _, enemy in ipairs(enemiesInIce) do
        local dist = enemy.Position:Distance(effect.Position)
        if(dist<maxDist+enemy.Size) then
            local pos = effect.Position+(enemy.Position-effect.Position):Resized(maxDist+enemy.Size)
            enemy.Velocity = (pos-enemy.Position)*1
            enemy.Position = pos
        end
    end
end
mod:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, funcs.postEffectUpdate, iceVariant)

mod.ITEMS.JOLLYMINT = funcs