local mod = jezreelMod
local h = include("scripts/func")

local starFruit = mod.ENUMS.VEGETABLES.STARFRUIT
local starTearVar = Isaac.GetEntityVariantByName("Starfruit Star")

local STARTEAR_SPEED = 5
local STYPE_TO_DEBUFF = {
    [1]=function(tear, entity) entity:AddPoison(EntityRef(tear), 103, tear.CollisionDamage/3) end,
    [2]=function(tear, entity) entity:AddCharmed(EntityRef(tear), 180) end,
    [3]=function(tear, entity) entity:AddSlowing(EntityRef(tear), 180, 0.5, Color(0.5,0.5,0.5,1)) end,
    [4]=function(tear, entity) entity:AddFear(EntityRef(tear), 120) end,
    [5]=function(tear, entity) entity:AddBurn(EntityRef(tear), 103, tear.CollisionDamage/3) end,
    [6]=function(tear, entity) entity:AddFreeze(EntityRef(tear), 120) end,
    [7]=function(tear, entity) entity:AddConfusion(EntityRef(tear), 180, false) end,
}
local STAR_DEBUFF_CHANCE = 0.25

local funcs = {}

---@param tear EntityTear
local function starTearInit(tear)
    local rng = tear:GetDropRNG()
    local starNum = Isaac.GetPlayer():GetCollectibleNum(starFruit)
    if(tear.SpawnerEntity and tear.SpawnerEntity:ToPlayer()) then
        starNum = tear.SpawnerEntity:ToPlayer():GetCollectibleNum(starFruit)
    end

    local tearEffect = 8
    if(tear.SubType==0 or tear.SubType>=9) then
        if(rng:RandomFloat()>(1-0.25)^starNum) then
            tearEffect = rng:RandomInt(7)+1
        end
        tear.SubType = tearEffect
    end
    tearEffect = tear.SubType

    tear:GetSprite():Load("gfx/entities/tears/starfruit/star.anm2", true)
    tear:GetSprite():Play("Eff"..tearEffect, true)
    tear.Scale = 1

    tear:ClearTearFlags(tear.TearFlags)
    tear:AddTearFlags(TearFlags.TEAR_PIERCING | TearFlags.TEAR_SPECTRAL)
    tear.FallingAcceleration = -0.1
    tear.FallingSpeed = 0
    tear.Height = -30
    tear.Color = Color.Default
end

---@param player EntityPlayer
local function spawnStarTear(position, player)
    local rng = player:GetCollectibleRNG(starFruit)
    local tear = player:FireTear(position, Vector.FromAngle(rng:RandomFloat()*360)*STARTEAR_SPEED,false,true,false,player,0.2)
    tear:ChangeVariant(starTearVar)

    starTearInit(tear)
end

---@param source EntityRef
function funcs:entityTakeDMG(entity, amount, flags, source)
    if(not (entity:IsVulnerableEnemy() and not entity:HasEntityFlags(EntityFlag.FLAG_FRIENDLY))) then return nil end
    if(amount<=0) then return nil end

    local s = source.Entity
    if(not (s)) then return nil end
    if(not (s.Type==EntityType.ENTITY_PLAYER or (s.SpawnerEntity and s.SpawnerEntity.Type==EntityType.ENTITY_PLAYER))) then return nil end
    if((s.Type==EntityType.ENTITY_TEAR and s.Variant==starTearVar)) then return nil end

    local player = ((s.Type==EntityType.ENTITY_PLAYER and s) or s.SpawnerEntity):ToPlayer()
    for i=1, h:allPlayersCollNum(starFruit) do
        spawnStarTear(entity.Position, player)
    end
end
mod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, funcs.entityTakeDMG)

function funcs:starTearDMG(entity, amount, flags, source)
    if(not (entity:IsVulnerableEnemy() and not entity:HasEntityFlags(EntityFlag.FLAG_FRIENDLY))) then return nil end
    if(amount<=0) then return nil end

    local s = source.Entity
    if(not (s)) then return nil end
    if(not (s.Type==EntityType.ENTITY_TEAR and s.Variant==starTearVar)) then return nil end

    if(STYPE_TO_DEBUFF[s.SubType]) then
        STYPE_TO_DEBUFF[s.SubType](s:ToTear(), entity)
    end
end
mod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, funcs.starTearDMG)

---@param tear EntityTear
function funcs:postTearInit(tear)
    starTearInit(tear)
end
mod:AddCallback(ModCallbacks.MC_POST_TEAR_INIT, funcs.postTearInit, starTearVar)

function funcs:postTearUpdate(tear)
    local data = tear:GetData()

    tear.SpriteRotation = (data.sRotation or 0)+tear.Velocity:Length()
    data.sRotation = tear.SpriteRotation

    tear.Velocity = tear.Velocity*0.9

    if(tear.FrameCount==150) then
        tear:Remove()
    end
end
mod:AddCallback(ModCallbacks.MC_POST_TEAR_UPDATE, funcs.postTearUpdate, starTearVar)

function funcs:postTearRemove(tear)
    if(tear.Variant~=starTearVar) then return end
    tear=tear:ToTear()

    local impact = Isaac.Spawn(1000,97,0,tear.Position,Vector.Zero,nil)
    impact:Update()

    impact.SpriteOffset = Vector(0,-17)
    impact.SpriteScale = Vector(1,1)
end
mod:AddCallback(ModCallbacks.MC_POST_ENTITY_REMOVE, funcs.postTearRemove, EntityType.ENTITY_TEAR)

mod.ITEMS.STARFRUIT = funcs