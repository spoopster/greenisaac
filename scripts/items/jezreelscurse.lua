local mod = jezreelMod
local h = include("scripts/func")

local jezreelsCurse = mod.ENUMS.ITEMS.JEZREELS_CURSE
local budVar = Isaac.GetEntityVariantByName("Flower Bud")

local BUD_SPEED = 12
local BUD_ORBIT_SPEED = 4
local BUD_ORBIT_CONST = 200
local BUD_ORBIT_DIST = 40

local funcs = {}

function mod:addFlowerBuds(player, num, position)
    for i=1, num do
        local bud = Isaac.Spawn(3,budVar,0,position,Vector.Zero,player):ToFamiliar()
        bud.Player = player
    end
end

local function getBuds(player)
    local buds = {}
    for i, ent in ipairs(Isaac.FindByType(3,budVar)) do
        if(GetPtrHash(ent:ToFamiliar().Player)==GetPtrHash(player)) then
            buds[#buds+1] = ent
        end
    end

    return buds
end

local function getBudsInOrbit(player)
    local buds = getBuds(player)
    local orbBuds = {}

    for i, ent in ipairs(buds) do
        if(ent.Position:Distance(player.Position)<=BUD_ORBIT_DIST+30) then
            orbBuds[#orbBuds+1] = ent
        end
    end

    return orbBuds
end

function funcs:postUpdate()
    for _, player in ipairs(Isaac.FindByType(1,0)) do
        player=player:ToPlayer()
        local orbBuds = getBudsInOrbit(player)
        local isOffsetChanged = false
        for j, ent in ipairs(orbBuds) do
            local oldOffset = ent:GetData().budAngleOffset
            ent:GetData().budAngleOffset = j*360/(#orbBuds)
            if(oldOffset~=ent:GetData().budAngleOffset) then
                isOffsetChanged=true
            end
        end
        if(isOffsetChanged) then
            for j, ent in ipairs(orbBuds) do
                ent:GetData().budCurrAngle=0
            end
        end
    end
end
mod:AddCallback(ModCallbacks.MC_POST_UPDATE, funcs.postUpdate)

---@param bud EntityFamiliar
function funcs:postBudInit(bud)
    local sprite = bud:GetSprite()
    sprite:Play("Idle", true)
    sprite.Offset = Vector(0, -16)

    bud:ClearEntityFlags(EntityFlag.FLAG_APPEAR)

    --bud.Position = bud.Player.Position
    bud.Target = nil
    bud:GetData().budAngleOffset = 0
end
mod:AddCallback(ModCallbacks.MC_FAMILIAR_INIT, funcs.postBudInit, budVar)

---@param bud EntityFamiliar
function funcs:postBudUpdate(bud)
    if(bud:GetSprite():IsFinished("Death")) then bud:Remove() end

    if(bud:GetSprite():GetAnimation()=="Idle") then
        local data = bud:GetData()
        bud.SpriteRotation = bud.SpriteRotation+10
        data.budAngleOffset = data.budAngleOffset or 0
        data.budCurrAngle = (data.budCurrAngle or 0)+1

        if(bud.Target==nil) then
            bud:PickEnemyTarget(240)
            local dist = bud.Position:Distance(bud.Player.Position)
            if(dist<5) then dist=5 end
            local dir = Vector.FromAngle((bud.Player.Position-bud.Position):GetAngleDegrees())
            if(dist>BUD_ORBIT_DIST+30) then
                bud.Velocity = h:lerp(bud.Velocity, dir*BUD_SPEED, 0.05)
            else
                local orbitPos = Vector.FromAngle(data.budAngleOffset+data.budCurrAngle*BUD_ORBIT_SPEED)*BUD_ORBIT_DIST+bud.Player.Position
                local f = 0.1
                local speed = BUD_ORBIT_SPEED
                if(orbitPos:Distance(bud.Position)>3) then
                    f=0.3
                end
                bud.Velocity = h:lerp(bud.Velocity, (orbitPos-bud.Position):Normalized()*speed, f)
            end
        else
            bud.SpriteRotation = bud.SpriteRotation+10
            bud.Velocity = h:lerp(bud.Velocity, (bud.Target.Position-bud.Position):Normalized()*BUD_SPEED, 0.1)
        end
    else
        bud.Velocity = bud.Velocity*0.6
    end
end
mod:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, funcs.postBudUpdate, budVar)

---@param bud EntityFamiliar
---@param collider Entity
function funcs:preBudCollision(bud, collider, low)
    if(bud:GetSprite():GetAnimation()=="Idle") then
        if(collider:IsEnemy() and collider:IsVulnerableEnemy() and collider:IsActiveEnemy() and not (h:isFriendly(collider) or collider:HasEntityFlags(EntityFlag.FLAG_NO_TARGET))) then
            collider:TakeDamage(bud.Player.Damage*3, 0, EntityRef(bud.Player), 0)
            bud:GetSprite():Play("Death", true)
        end
    end
end
mod:AddCallback(ModCallbacks.MC_PRE_FAMILIAR_COLLISION, funcs.preBudCollision, budVar)

---@param npc Entity
function funcs:postNpcRemove(npc)
    npc = npc:ToNPC()
    if(not npc) then return end
    if(npc.HitPoints>0) then return end

    for _, player in ipairs(Isaac.FindByType(1,0)) do
        player=player:ToPlayer()
        mod:addFlowerBuds(player, player:GetCollectibleNum(jezreelsCurse), player.Position)
    end
end
mod:AddCallback(ModCallbacks.MC_POST_ENTITY_REMOVE, funcs.postNpcRemove)

---@param bud Entity
function funcs:postBudRemove(bud)
    bud = bud:ToFamiliar()
    if(not bud) then return end
    if(bud.HitPoints>0) then return end
end
mod:AddCallback(ModCallbacks.MC_POST_ENTITY_REMOVE, funcs.postBudRemove)


function funcs:postFamiliarInit(familiar)
    if(h:anyPlayerHas(jezreelsCurse)) then
        mod:addFlowerBuds(familiar.Player, 1, familiar.Position)
        familiar:Remove()
    end
end
mod:AddCallback(ModCallbacks.MC_FAMILIAR_INIT, funcs.postFamiliarInit, FamiliarVariant.BLUE_FLY)

mod.ITEMS.JEZREELSCURSE = funcs