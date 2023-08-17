local mod = jezreelMod

local funcs = {}

---@param spawner Entity? Default: nil — The firejet's spawner entity
---@param damage number? Default: 3.5 — How much damage the firejet should do
---@param position Vector? Default: Room:GetCenterPos() — Where the firejet should spawn
---@param amount number? Default: 0 — How many firejets should be spawned in a line, starting from the one being currently spawned
---@param distance number? Default: 40 — Distance between 2 firejets in a line
---@param delay number? Default: 5 — Delay (in frames) between 2 firejets in a line being spawned
---@param angle number? Default: 0 — Angle between 2 firejets in a line
---@param angleVar number? Default: 0 — Random angle variance added on top of the base angle from the interval (-angleVar/2, angleVar/2)
---@param color Color? Default: Color(1,1,1,1,0,0,0) — Color of the firejet
---@return EntityEffect
function funcs:spawnFireJet(spawner, damage, position, amount, distance, delay, angle, angleVar, color)
    local fireJet = Isaac.Spawn(1000,EffectVariant.FIRE_JET,0,(position or Game():GetRoom():GetCenterPos()),Vector.Zero,(spawner or nil)):ToEffect()
    fireJet.CollisionDamage = (damage or 3.5)
    fireJet.Timeout = (delay or 5)

    local data = fireJet:GetData()

    data.fjSpawnDelay = fireJet.Timeout
    data.fjSpawnsLeft = (amount or 1)-1
    data.fjSpawnsDist = (distance or 40)
    data.fjSpawnAngle = (angle or 0)
    data.fjAngleVar = (angleVar or 0)

    if(color) then fireJet.Color = color end

    if(fireJet.Timeout==0) then
        fireJet:Update()
    end

    return fireJet
end

---@param effect EntityEffect
local function updateJet(_, effect)
    local data = effect:GetData()
    if(not data.fjSpawnsLeft) then return end
    if(data.fjSpawnsLeft<1) then return end
    if(effect.Timeout~=0) then return end
    local rng = effect:GetDropRNG()

    local angle = data.fjSpawnAngle+data.fjAngleVar*(rng:RandomFloat()-0.5)
    local spawnPos = effect.Position + Vector.FromAngle(angle)*data.fjSpawnsDist

    if(not Game():GetRoom():IsPositionInRoom(spawnPos,0)) then return end

    local jet = funcs:spawnFireJet(effect.SpawnerEntity, effect.CollisionDamage, spawnPos, data.fjSpawnsLeft, data.fjSpawnsDist, data.fjSpawnDelay, angle, data.fjAngleVar, effect.Color)
    jet.Scale = effect.Scale
    effect.Timeout = -1
end
mod:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, updateJet, EffectVariant.FIRE_JET)

local function jetDamage(_, tookDmg, _, _, source)
    local effect = source.Entity
    if(not (effect)) then return nil end
    if(not (effect:ToEffect())) then return nil end

    effect = effect:ToEffect()
    if(not (effect:GetData().fjSpawnsLeft)) then return nil end

    if(GetPtrHash(effect.SpawnerEntity)==GetPtrHash(tookDmg)) then return false end

    if(effect:GetData().fjIsPlayerFriendly) then
        if(tookDmg.Type==EntityType.ENTITY_PLAYER) then return false end
    end
end
mod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, jetDamage)

return funcs