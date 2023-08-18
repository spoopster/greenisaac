local mod = jezreelMod
local h = include("scripts/func")

local missiletoe = mod.ENUMS.VEGETABLES.MISSILETOE

local MISSILE_DAMAGE_LOWER = 20
local MISSILE_DAMAGE_UPPER = 100
local MISSILE_DAMAGE_FRACTION = 1/2

local MISSILE_TIMEOUT = 12*30
local MISSILE_STACK_SCALING = 0.9
local MISSILE_ONDEATH_CHANCE = 0.33

local ROCKET_DAMAGE_LOWER = 20
local ROCKET_DAMAGE_UPPER = 100
local ROCKET_DAMAGE_FRACTION = 1/4

local funcs = {}

local function spawnMissile(npc)
    local damage = npc.MaxHitPoints*(1-(1-ROCKET_DAMAGE_FRACTION)^(npc:GetData().hasMistletoe or 1))

    damage = math.max(damage, ROCKET_DAMAGE_LOWER)
    damage = math.min(damage, ROCKET_DAMAGE_UPPER)

    Isaac.Explode(npc.Position, Isaac.GetPlayer(), damage)
end

---@param npc EntityNPC
function funcs:postNpcInit(npc)
    if(not h:isValidEnemy(npc)) then return end

    local missileNum = h:allPlayersCollNum(missiletoe)
    if(missileNum<=0) then return end

    local data = npc:GetData()

    local damage = npc.MaxHitPoints*MISSILE_DAMAGE_FRACTION^(missileNum)
    damage = math.max(damage, MISSILE_DAMAGE_LOWER)
    damage = math.min(damage, MISSILE_DAMAGE_UPPER)

    data.hasMistletoe = missileNum
    data.mistletoeNeededDmg = damage
end
mod:AddCallback(ModCallbacks.MC_POST_NPC_INIT, funcs.postNpcInit)

---@param npc EntityNPC
function funcs:postNpcUpdate(npc)
    if(not h:isValidEnemy(npc)) then return end
    local missileScaling = npc:GetData().hasMistletoe
    if(not missileScaling) then return end

    local scale = MISSILE_STACK_SCALING^(missileScaling-1)

    if((npc.HitPoints<=npc.MaxHitPoints-npc:GetData().mistletoeNeededDmg)) then
        spawnMissile(npc)

        npc:GetData().hasMistletoe = nil
    end

    if(npc.FrameCount>=math.floor(MISSILE_TIMEOUT*scale)) then
        npc:GetData().hasMistletoe = nil
    end
end
mod:AddCallback(ModCallbacks.MC_NPC_UPDATE, funcs.postNpcUpdate)

---@param npc Entity
function funcs:postEntityRemove(npc)
    npc = npc:ToNPC()
    if(not npc) then return end
    if(npc.HitPoints>0) then return end
    if(h:isFriendly(npc)) then return end

    local data = npc:GetData()
    if(data.hasMistletoe and Isaac.GetPlayer():GetCollectibleRNG(missiletoe):RandomFloat()>1-data.hasMistletoe) then
        local chance = (1-MISSILE_ONDEATH_CHANCE)^(data.hasMistletoe)

        if(Isaac.GetPlayer():GetCollectibleRNG(missiletoe):RandomFloat()>chance) then
            spawnMissile(npc)
        end
    end
end
mod:AddCallback(ModCallbacks.MC_POST_ENTITY_REMOVE, funcs.postEntityRemove)
-- ^^^ SPAWNS MISSILES ON NPC DEATH

local f = Font()
f:Load("font/pftempestasevencondensed.fnt")

local mistleToeSprite = Sprite()
mistleToeSprite:Load("gfx/entities/effects/mistletoe/mistletoe.anm2", true)
mistleToeSprite:Play("Idle", true)

function funcs:postNpcRender(npc, offset)
    local missileScaling = npc:GetData().hasMistletoe
    if(not missileScaling) then return end

    local renderPos = Isaac.WorldToRenderPosition(npc.Position)+offset

    local neededDmg = npc:GetData().mistletoeNeededDmg
    local timeout = math.floor(MISSILE_TIMEOUT*(MISSILE_STACK_SCALING^(missileScaling-1)))

    local missingHealthRatio = (npc.HitPoints-npc.MaxHitPoints+neededDmg)/neededDmg

    local mistletoeHeight = 160
    mistletoeHeight = mistletoeHeight+30*missingHealthRatio
    local alpha = (timeout-npc.FrameCount)/timeout

    local newColor = Color(1,1,1,1)
    newColor:SetTint(1,3-missingHealthRatio*2,1,alpha)

    mistleToeSprite.Color = newColor

    mistleToeSprite.Rotation = math.sin(math.rad(npc.FrameCount*5))*2

    mistleToeSprite:Render(renderPos+Vector(0,-mistletoeHeight))
end
mod:AddCallback(ModCallbacks.MC_POST_NPC_RENDER, funcs.postNpcRender)

mod.ITEMS.MISSILETOE = funcs