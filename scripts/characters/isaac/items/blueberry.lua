local mod = jezreelMod
local sfx = SFXManager()

local blueBerry = mod.ENUMS.VEGETABLES.BLUE_BERRY
local blueVar = Isaac.GetEntityVariantByName("Blue Berry")

local IDLE_LENGTH = 13
local BERRY_SPEED = 5

local BERRY_DEATHSFX1 = 28
local BERRY_DEATHSFX2 = 2
local BERRY_PRIZESFX = 268

local BERRY_COINCHANCE = 1/3

sfx:Preload(BERRY_DEATHSFX1)
sfx:Preload(BERRY_DEATHSFX2)
sfx:Preload(BERRY_PRIZESFX)

local funcs = {}

local function getBerryTargetPos(berry)
    local pos = Vector.Zero
    local failsafe = 0
    while(Game():GetRoom():CheckLine(pos, berry.Position, 0)==false and failsafe<100) do
        failsafe=failsafe+1

        pos = Game():GetRoom():GetRandomPosition(berry.Size)
    end

    return pos
end

local function spawnBerryPrize(berry)
    local rng = berry.Player:GetCollectibleRNG(blueBerry)

    local vel = Vector.FromAngle(rng:RandomFloat()*360)

    if(rng:RandomFloat()<BERRY_COINCHANCE) then
        Isaac.Spawn(5,20,0,berry.Position,vel,berry)
    else
        Isaac.Spawn(5,10,0,berry.Position,vel,berry)
    end
end

---@param familiar EntityFamiliar
function funcs:familiarInit(familiar)
    local sprite = familiar:GetSprite()
    local data = familiar:GetData()
    sprite:Play("Idle", true)

    familiar.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
    familiar.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_GROUND

    data.canBeSaved = true
    data.targetPos = getBerryTargetPos(familiar)

    familiar.Velocity = Vector.Zero
    familiar.EntityCollisionClass = EntityCollisionClass.ENTCOLL_PLAYERONLY
end
mod:AddCallback(ModCallbacks.MC_FAMILIAR_INIT, funcs.familiarInit, blueVar)

---@param familiar EntityFamiliar
function funcs:familiarUpdate(familiar)
    local data = familiar:GetData()
    local sprite = familiar:GetSprite()

    if(sprite:IsFinished("Wait")) then sprite:Play("Death", true) end
    if(sprite:IsFinished("Death")) then sprite:Play("DeadIdle", true) end
    if(sprite:IsFinished("Payout")) then familiar:Remove() end

    if(sprite:IsEventTriggered("Dead")) then
        data.canBeSaved = false

        sfx:Play(BERRY_DEATHSFX1)
        sfx:Play(BERRY_DEATHSFX2)
    end
    if(sprite:IsEventTriggered("Prize")) then
        spawnBerryPrize(familiar)

        sfx:Play(BERRY_PRIZESFX)
    end

    if(sprite:GetAnimation()=="Idle") then
        if(data.targetPos) then
            local dist = (data.targetPos-familiar.Position)
            if(sprite:IsEventTriggered("Hop")) then
                local vel = Vector(dist.X,dist.Y)
                if(vel:Length()>BERRY_SPEED) then
                    vel:Resize(BERRY_SPEED)
                else
                    data.targetPos=nil
                end

                familiar.Velocity = vel
            end
            if(sprite:IsEventTriggered("StopHop")) then
                familiar.Velocity = Vector.Zero
            end

            if(dist:Length()<=BERRY_SPEED) then
                data.targetPos=nil
            end
        else
            if(sprite:GetFrame()==IDLE_LENGTH-1) then
                sprite:Play("Wait", true)
            end
        end
    else
        familiar.Velocity = Vector.Zero
    end
end
mod:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, funcs.familiarUpdate, blueVar)

function funcs:familiarCollision(familiar, collider, low)
    local data = familiar:GetData()
    if((collider.Type==1 and GetPtrHash(collider)==GetPtrHash(familiar.Player))) then
        if(data.canBeSaved==true and familiar:GetSprite():GetAnimation()=="Death") then
            familiar:GetSprite():Play("Payout", true)
        end
    end
end
mod:AddCallback(ModCallbacks.MC_PRE_FAMILIAR_COLLISION, funcs.familiarCollision, blueVar)

function funcs:postNewRoom()
    local room = Game():GetRoom()

    for _, berry in ipairs(Isaac.FindByType(3,blueVar)) do
        berry:Remove()
    end

    if(room:IsClear()) then return end

    for _, player in ipairs(Isaac.FindByType(1,0)) do
        player=player:ToPlayer()
        for i=1, player:GetCollectibleNum(blueBerry) do
            local berry = Isaac.Spawn(3,blueVar,0,player.Position,Vector.Zero,player):ToFamiliar()
            berry:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
        end
    end
end
mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, funcs.postNewRoom)

mod.ITEMS.BLUEBERRY = funcs