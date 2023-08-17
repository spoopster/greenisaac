local mod = jezreelMod

local watermelon = mod.ENUMS.VEGETABLES.WATERMELON
local melonVariant = Isaac.GetEntityVariantByName("Bowling Melon")
local rankVariant = Isaac.GetEntityVariantByName("Bowling Ranking")

local funcs = {}

local function turnToMelon(tear)
    tear:ChangeVariant(melonVariant)
    tear.Height = -5
    tear.FallingSpeed = 0
    tear.FallingAcceleration = -0.1
    tear.TearFlags = TearFlags.TEAR_PUNCH | TearFlags.TEAR_NORMAL
    tear.GridCollisionClass = 5
    tear.Scale = 1
    tear.CollisionDamage = tear.CollisionDamage*3
end

function funcs:postFireTear(tear)
    local player = tear.SpawnerEntity
    if(not (player and player:ToPlayer())) then return end
    player = player:ToPlayer()
    if(player:HasCollectible(watermelon)) then
        local power = player:GetCollectibleNum(watermelon)*math.max(1, (player.Luck+3)/3)
        if(tear:GetDropRNG():RandomFloat()>(19/20)^power) then
            turnToMelon(tear)
        end
    end
end
mod:AddCallback(ModCallbacks.MC_POST_FIRE_TEAR, funcs.postFireTear)

function funcs:preTearCollision(tear, collider, low)
    if(tear.Variant==melonVariant) then
        local angle = tear.Velocity:GetAngleDegrees()
        local player = tear.SpawnerEntity
        if(player) then player=player:ToPlayer() end
        if(not player) then player=Isaac.GetPlayer() end
        Isaac.Explode(tear.Position, player, 20)
        tear:GetData().didStrike = true
    end
end
mod:AddCallback(ModCallbacks.MC_PRE_TEAR_COLLISION, funcs.preTearCollision)

function funcs:postTearUpdate(tear)
    --if(tear.Variant~=melonVariant) then return end
    local player = tear.SpawnerEntity
    local data = tear:GetData()

    tear.SpriteRotation = tear.Velocity:GetAngleDegrees()
    local sprite = tear:GetSprite()
    if(sprite:GetAnimation()~="Roll") then
        sprite:Load("gfx/entities/tears/melon/bowling_melon.anm2", true)
        sprite:Play("Roll", true)
    end
end
mod:AddCallback(ModCallbacks.MC_POST_TEAR_UPDATE, funcs.postTearUpdate, melonVariant)

function funcs:postEffectUpdate(effect)
    local sprite = effect:GetSprite()
    if(sprite:GetAnimation()=="Strike" and sprite:GetFrame()<27) then
        effect.SpriteRotation = sprite:GetFrame()*(1080/26)
    end
    if(sprite:IsFinished(sprite:GetAnimation())) then
        effect:Remove()
    end
end
mod:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, funcs.postEffectUpdate, rankVariant)

function funcs:postEntityRemove(entity)
    if(entity.Type==2) then
        entity = entity:ToTear()
        local player = entity.SpawnerEntity
        if(player and player:ToPlayer()) then
            player = player:ToPlayer()
            if(entity.Variant==melonVariant) then
                local puddle = Isaac.Spawn(1000, 32, 0, entity.Position, Vector.Zero, player)
                puddle.Color = Color(0.3,0.5,2,1,0.3,0.3,1.5)
                puddle.CollisionDamage = 4
                local rank = Isaac.Spawn(1000, rankVariant, 0, entity.Position, Vector.Zero, entity)
                rank.SpriteOffset = Vector(0, -30)
                if(entity:GetData().didStrike==true) then
                    rank:GetSprite():Play("Strike", true)
                else
                    rank:GetSprite():Play("Miss", true)
                end
            end
        end
    end
end
mod:AddCallback(ModCallbacks.MC_POST_ENTITY_REMOVE, funcs.postEntityRemove)

mod.ITEMS.WATERMELON = funcs