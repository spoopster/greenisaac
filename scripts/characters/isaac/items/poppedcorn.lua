local mod = jezreelMod
local sfx = SFXManager()

local poppedCorn = mod.ENUMS.VEGETABLES.POPPED_CORN
local melonVariant = Isaac.GetEntityVariantByName("Bowling Melon")

local funcs = {}

local function popTear(tear, player, frameCheck)
    local rng = tear:GetDropRNG()
    local iMax = 3+(player:GetCollectibleNum(poppedCorn)-1)*1
    local spawnPos = tear.Position
    local gridCol = Game():GetRoom():GetGridCollisionAtPos(spawnPos)
    if(GetPtrHash(tear.SpawnerEntity)~=GetPtrHash(player)) then return end
    if(tear.Variant==melonVariant) then return end
    if(tear:GetData().poppedTear~=false) then return end
    if(frameCheck==true and tear.FrameCount<20) then return end
    if(tear.TearFlags & TearFlags.TEAR_QUADSPLIT == TearFlags.TEAR_QUADSPLIT) then
        if(frameCheck==true)then
            tear:Die()
            sfx:Play(237, 1.5, 2, false, 0.9, 0)
        end
        return
    end
    if(tear.TearFlags & TearFlags.TEAR_ABSORB == TearFlags.TEAR_ABSORB or tear.Variant==TearVariant.HUNGRY) then
        tear:GetData().poppedTear = false
        return
    end
    if(tear.TearFlags & TearFlags.TEAR_LUDOVICO == TearFlags.TEAR_LUDOVICO) then return end
    if(tear.TearFlags & TearFlags.TEAR_BURSTSPLIT == TearFlags.TEAR_BURSTSPLIT) then return end
    if(gridCol==2 or gridCol==3) then
        spawnPos = spawnPos-tear.Velocity*2
    end
    tear:GetData().poppedTear=true
    for i=1, iMax do
        if(player:HasCollectible(mod.ENUMS.VEGETABLES.MILDLY_SPICY_PEPPER) and i%3==0) then
            mod:synergyFlame(tear, spawnPos, Vector(2+rng:RandomFloat()*2,0):Rotated(rng:RandomFloat()*60-30+i*360/iMax), 0.75)
        end
        local vel=Vector(3,0):Rotated(rng:RandomFloat()*360)*(rng:RandomFloat()+0.2)
        if(Game():GetRoom():GetBackdropType()==57) then
            vel.Y = math.abs(vel.Y)*-1
            vel.X = vel.X*1.5
        end
        local poppedTear = Isaac.Spawn(2, tear.Variant, tear.SubType, spawnPos, vel, player):ToTear()
        poppedTear.TearFlags = tear.TearFlags & (~TearFlags.TEAR_SPLIT)
        poppedTear.CollisionDamage = tear.CollisionDamage
        poppedTear.FallingSpeed = -15
        poppedTear.FallingAcceleration = 1
        if(tear.TearFlags & TearFlags.TEAR_ORBIT == TearFlags.TEAR_ORBIT) then
            poppedTear.FallingSpeed = tear.FallingSpeed
            poppedTear.FallingAcceleration = tear.FallingAcceleration
            poppedTear.Height = tear.Height
            poppedTear.Velocity = poppedTear.Velocity*((tear.Velocity:Length())/(poppedTear.Velocity:Length())+rng:RandomFloat()*2-1)
        end
        poppedTear.Scale = tear.Scale*0.8
        poppedTear.Color = tear.Color
        poppedTear:GetData().poppedTear = true
        poppedTear:GetData().cucumberTear = true
        poppedTear:GetData().shouldSpice = false
    end
    tear:Die()
    sfx:Play(237, 1.5, 2, false, 0.9, 0)
end

function funcs:postTearUpdate(tear)
    local player = tear.SpawnerEntity
    if(player and player:ToPlayer()) then
        player = player:ToPlayer()
        local rng = tear:GetDropRNG()
        if(player:HasCollectible(poppedCorn)) then
            popTear(tear, player, true)
        end
    end
end
mod:AddCallback(ModCallbacks.MC_POST_TEAR_UPDATE, funcs.postTearUpdate)

function funcs:postTearInit(tear)
    local data = tear:GetData()
    if(data.poppedTear==nil) then
        data.poppedTear = false
    end
end
mod:AddCallback(ModCallbacks.MC_POST_TEAR_INIT, funcs.postTearInit)

function funcs:postEntityRemove(entity)
    entity = entity:ToTear()
    if(not entity) then return end
    if(not (entity.SpawnerEntity and entity.SpawnerEntity:ToPlayer())) then return end
    local player = entity.SpawnerEntity:ToPlayer()
    if(player:HasCollectible(poppedCorn) and entity:GetData().poppedTear~=true) then
        popTear(entity, player, false)
    end
end
mod:AddCallback(ModCallbacks.MC_POST_ENTITY_REMOVE, funcs.postEntityRemove)

mod.ITEMS.POPPEDCORN = funcs