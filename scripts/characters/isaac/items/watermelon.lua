local mod = jezreelMod

local watermelon = mod.ENUMS.VEGETABLES.WATERMELON
local melonVariant = Isaac.GetEntityVariantByName("Bowling Melon")
local rankVariant = Isaac.GetEntityVariantByName("Bowling Ranking")

local MELON_CHANCE = 1

local funcs = {}

local function turnToMelon(tear)
    tear:ChangeVariant(melonVariant)
    tear.Height = -5
    tear.FallingSpeed = 0
    tear.FallingAcceleration = -0.1
    tear.TearFlags = TearFlags.TEAR_PUNCH | TearFlags.TEAR_NORMAL
    tear.GridCollisionClass = 5
    tear.Scale = 1
    tear.CollisionDamage = tear.CollisionDamage*0.5

    tear:GetData().cucumberTear = true
end

---@param tear EntityTear
function funcs:turnTearToMelong(tear)
    if(not (tear.SpawnerEntity and tear.SpawnerEntity:ToPlayer())) then return end
    if(tear.Variant==melonVariant) then return end
    if(tear.FrameCount~=1) then return end
    local player = tear.SpawnerEntity:ToPlayer()
    local melonNum = player:GetCollectibleNum(watermelon)
    if(melonNum<=0) then return end

    local data = tear:GetData()
    local rng = tear:GetDropRNG()

    if(rng:RandomFloat()>(1-MELON_CHANCE)^melonNum) then
        turnToMelon(tear)
    end
end
mod:AddPriorityCallback(ModCallbacks.MC_POST_TEAR_UPDATE, CallbackPriority.LATE, funcs.turnTearToMelong)

function funcs:preTearCollision(tear, collider, low)
    if(tear.Variant==melonVariant) then
        local angle = tear.Velocity:GetAngleDegrees()
        local player = tear.SpawnerEntity
        if(player) then player=player:ToPlayer() end
        if(not player) then player=Isaac.GetPlayer() end
        Isaac.Explode(tear.Position, player, tear.CollisionDamage*3)
        tear:GetData().didStrike = true

        tear:Remove()
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
                local puddle = Isaac.Spawn(1000, 32, 0, entity.Position, Vector.Zero, player):ToEffect()
                puddle.Color = Color(0.3,0.5,2,1,0.3,0.3,1.5)
                puddle.CollisionDamage = entity.CollisionDamage*4/3
                puddle.Timeout = 150
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