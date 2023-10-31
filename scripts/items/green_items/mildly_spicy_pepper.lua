local mod = jezreelMod
local sfx = SFXManager()

local spicyPepper = mod.ENUMS.VEGETABLES.MILDLY_SPICY_PEPPER
local spicyFlameVariant = Isaac.GetEntityVariantByName("Spicy Fire")
local funcs = {}

---@param tear EntityTear
---@param position Vector
---@param velocity Vector
---@param scale number
local function spawnFlame(tear, position, velocity, scale)
    if(not (tear.SpawnerEntity and tear.SpawnerEntity:ToPlayer())) then return end
    local player = tear.SpawnerEntity:ToPlayer()
    local fire = Isaac.Spawn(1000, spicyFlameVariant, 0, position, velocity, player):ToEffect()
    fire.CollisionDamage = player.Damage*(1-(1/2)^player:GetCollectibleNum(spicyPepper))
    fire.Scale = scale
    sfx:Play(700, 0.4)

    fire:Update()

    return fire
end
function mod:synergyFlame(tear, position, velocity, scale)
    spawnFlame(tear, position, velocity, scale)
end

---@param tear EntityTear
function funcs:postTearUpdate(tear)
    if(not (tear.SpawnerEntity and tear.SpawnerEntity:ToPlayer())) then return end
    local player = tear.SpawnerEntity:ToPlayer()

    local data = tear:GetData()
    local rng = tear:GetDropRNG()
    if(player:HasCollectible(spicyPepper)) then
        if(tear.FrameCount==0) then tear:AddTearFlags(TearFlags.TEAR_PIERCING) end
        if(rng:RandomInt(30)==0 and data.shouldSpice~=false) then
            spawnFlame(tear, tear.Position, Vector.Zero, 1)
        end
    end
end
mod:AddCallback(ModCallbacks.MC_POST_TEAR_UPDATE, funcs.postTearUpdate)

---@param effect EntityEffect
function funcs:postEffectUpdate(effect)
    local sprite = effect:GetSprite()
    local data = effect:GetData()
    sprite.Scale = Vector(1,1)*effect.Scale
    if(effect.Position:Distance(Game():GetRoom():GetClampedPosition(effect.Position,5))>2) then
        effect.Velocity = effect.Velocity*-0.4
        effect.Position = Game():GetRoom():GetClampedPosition(effect.Position,5)
    end
    if(effect.GridCollisionClass~=5) then
        effect.GridCollisionClass=5
    end
    effect.Velocity = effect.Velocity*0.95

    local maxFramecount = 60
    if(data.isEnemyFire) then maxFramecount = data.isEnemyFire or 60 end
    if(effect.FrameCount==maxFramecount and sprite:GetAnimation()~="Disappear") then
        sprite:Play("Disappear", true)
    end

    if(sprite:IsFinished("Disappear")) then
        effect:Remove()
    end
    if(sprite:GetAnimation()~="Disappear") then
        local enemies = Isaac.FindInRadius(effect.Position, 12*effect.Scale, EntityPartition.ENEMY)
        if(data.isEnemyFire) then enemies = Isaac.FindInRadius(effect.Position, 12*effect.Scale, EntityPartition.PLAYER) end
        for _, enemy in ipairs(enemies) do
            if(((not enemy:ToPlayer()) and enemy:IsVulnerableEnemy()) or (enemy:ToPlayer())) then
                local collDamage = effect.CollisionDamage
                if(enemy:ToPlayer()) then collDamage = 1 end
                enemy:TakeDamage(collDamage, 0, EntityRef(effect), 0)
            end
        end
        if(#enemies>=1) then
            sprite:Play("Disappear", true)
        end
    end
end
mod:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, funcs.postEffectUpdate, spicyFlameVariant)

function funcs:postEntityRemove(entity)
    if(entity.Type~=2) then return end
    if(not (entity.SpawnerEntity and entity.SpawnerEntity:ToPlayer())) then return end

    local player = entity.SpawnerEntity:ToPlayer()
    local pepperNum = player:GetCollectibleNum(spicyPepper)
    if(pepperNum<=0) then return end

    local rng = player:GetCollectibleRNG(spicyPepper)

    entity = entity:ToTear()
    for i=1, pepperNum do
        spawnFlame(entity, entity.Position, Vector.FromAngle(rng:RandomFloat()*360), 0.5)
    end
end
mod:AddCallback(ModCallbacks.MC_POST_ENTITY_REMOVE, funcs.postEntityRemove)

mod.ITEMS.MILDLYSPICYPEPPER = funcs