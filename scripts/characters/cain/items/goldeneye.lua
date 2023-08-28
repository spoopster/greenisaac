local mod = jezreelMod
local helper = include("scripts/func")

local goldenEye = mod.ENUMS.ITEMS.GOLDEN_EYE
local goldenEyeEffect = Isaac.GetEntityVariantByName("Golden Eye")

--* This is a percentage
local FAKE_GOLD_PICKUP_MOD = 7.5

--* ConvChance is shown as a percentage
local GOLD_CONV_TABLE = {
    [PickupVariant.PICKUP_HEART] = {
        InvalidSubtypes = {[HeartSubType.HEART_GOLDEN]=true,},
        ConvSubtypes = {
            {Chance=0.63, Subtype=HeartSubType.HEART_GOLDEN},
            {Chance=FAKE_GOLD_PICKUP_MOD, Subtype=-1},
        },
    },
    [PickupVariant.PICKUP_COIN] = {
        InvalidSubtypes = {[CoinSubType.COIN_GOLDEN]=true,},
        ConvSubtypes = {
            {Chance=0.5, Subtype=CoinSubType.COIN_GOLDEN},
            {Chance=FAKE_GOLD_PICKUP_MOD, Subtype=-1},
        },
    },
    [PickupVariant.PICKUP_KEY] = {
        InvalidSubtypes = {[KeySubType.KEY_GOLDEN]=true,},
        ConvSubtypes = {
            {Chance=1.97, Subtype=KeySubType.KEY_GOLDEN},
            {Chance=FAKE_GOLD_PICKUP_MOD, Subtype=-1},
        },
    },
    [PickupVariant.PICKUP_BOMB] = {
        InvalidSubtypes = {[BombSubType.BOMB_GOLDEN]=true,[BombSubType.BOMB_GOLDENTROLL]=true,[BombSubType.BOMB_GIGA]=true,},
        ConvSubtypes = {
            {Chance=0.89, Subtype=BombSubType.BOMB_GOLDEN},
            {Chance=0.12, Subtype=BombSubType.BOMB_GOLDENTROLL},
            {Chance=FAKE_GOLD_PICKUP_MOD, Subtype=-1},
        },
    },
    [PickupVariant.PICKUP_LIL_BATTERY] = {
        InvalidSubtypes = {[BatterySubType.BATTERY_GOLDEN]=true,},
        ConvSubtypes = {
            {Chance=0.83, Subtype=BatterySubType.BATTERY_GOLDEN},
            {Chance=FAKE_GOLD_PICKUP_MOD, Subtype=-1},
        },
    },
    [PickupVariant.PICKUP_PILL] = {
        InvalidSubtypes = {[PillColor.PILL_GOLD]=true,[PillColor.PILL_GOLD+PillColor.PILL_GIANT_FLAG]=true,},
        ConvSubtypes = {
            {Chance=0.70, Subtype=PillColor.PILL_GOLD},
            {Chance=0.01, Subtype=PillColor.PILL_GOLD+PillColor.PILL_GIANT_FLAG},
            {Chance=FAKE_GOLD_PICKUP_MOD, Subtype=-1},
        },
    },
}

local funcs = {}

---@param s Sprite
---@param animation string
local function getLastFrame(s, animation)
    local sprite = Sprite()
    sprite:Load(s:GetFilename(), true)

    local anim = sprite:GetAnimation()
    local oldFrame = sprite:GetFrame()
    sprite:SetAnimation(animation, true)
    sprite:SetLastFrame()
    local lastFrame = sprite:GetFrame()
    sprite:SetFrame(anim, oldFrame)

    return lastFrame or 0
end

function funcs:postPickupInit(pickup)
    local goldEyeNum = helper:allPlayersCollNum(goldenEye)
    if(goldEyeNum<1) then return end

    local goldTable = GOLD_CONV_TABLE[pickup.Variant]
    if(type(goldTable)~="table") then return end

    local didConvert = false

    if(goldTable.InvalidSubtypes[pickup.SubType]~=true) then
        local convRng = RNG()
        convRng:SetSeed(pickup.InitSeed, 35)
        local convFloat = convRng:RandomFloat()*100
        local currentChance = 0

        for _, table in ipairs(goldTable.ConvSubtypes) do
            local sub = table.Subtype
            local mult = goldEyeNum
            if(sub==-1) then mult=1.5^goldEyeNum end
            currentChance=currentChance+table.Chance*mult
            if(convFloat<=currentChance) then
                if(sub==-1) then
                    didConvert=nil
                    break
                end
                pickup:Morph(pickup.Type,pickup.Variant,sub)
                didConvert=true
                break
            end
        end
    end

    if(didConvert==true) then
        local dink = Isaac.Spawn(1000,EffectVariant.CRACKED_ORB_POOF,0,pickup.Position,Vector.Zero,pickup):ToEffect()
        if(pickup:GetSprite()=="Appear") then
            dink.SpriteOffset = Vector(0,-3)
        else
            dink.SpriteOffset = Vector(0,25)
        end
        dink.Color=Color(1,1,1,1,1,1,0)
        dink.SpriteScale = Vector(1.5,1.5)
        SFXManager():Play(435, 0.75)
    elseif(didConvert==nil) then
        pickup:GetData().isFalseGold = 0
    end
end
mod:AddCallback(ModCallbacks.MC_POST_PICKUP_INIT, funcs.postPickupInit)

function funcs:prePickupCollision(pickup, collider, low)
    if(pickup:GetData().isFalseGold and collider.Type==1) then
        local rng = pickup:GetDropRNG()
        for i=0,1 do
            local pickup2 = Isaac.Spawn(pickup.Type,pickup.Variant,pickup.SubType,pickup.Position,Vector.FromAngle(rng:RandomFloat()*360)*2, pickup):ToPickup()
        end
        pickup:Remove()
        return true
    end
end
--mod:AddCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, funcs.prePickupCollision)

---data.isFalseGold is also used as storage for the pickup's animation frame
---@param pickup EntityPickup
function funcs:postPickupRender(pickup, offset)
    if(not pickup:GetData().isFalseGold) then
        if(mod.getMenuData().greediestMode==2) then
            if(GOLD_CONV_TABLE[pickup.Variant] and GOLD_CONV_TABLE[pickup.Variant].InvalidSubtypes[pickup.SubType]~=true) then
                pickup:GetData().isFalseGold=0
            else
                return
            end
        else
            return
        end
    end

    local goldSprite = Sprite()
    local renderPos = Isaac.WorldToRenderPosition(pickup.Position)+offset--+Game():GetRoom():GetRenderScrollOffset()

    local goldAnim = "gfx/005.017_goldheart.anm2"
    if(pickup.Variant==20) then goldAnim = "gfx/005.027_golden penny.anm2"
    elseif(pickup.Variant==30) then goldAnim = "gfx/005.032_golden key.anm2"
    elseif(pickup.Variant==40) then goldAnim = "gfx/005.043_golden bomb.anm2"
    elseif(pickup.Variant==70) then
        if(pickup.SubType<2049) then goldAnim="gfx/005.084_pill gold-gold.anm2"
        else goldAnim="gfx/005.084_horse pill gold-gold.anm2" end
    elseif(pickup.Variant==90) then goldAnim="gfx/005.090_golden battery.anm2" end
    goldSprite:Load(goldAnim, true)

    local frame = pickup:GetData().isFalseGold or 0
    goldSprite:SetAnimation(pickup:GetSprite():GetAnimation(), true)
    if(goldSprite:GetAnimation()=="") then goldSprite:SetAnimation("Idle", true) end
    if(frame>getLastFrame(goldSprite, goldSprite:GetAnimation())) then frame=0 end
    if(not Game():IsPaused()) then pickup:GetData().isFalseGold=frame+0.5 end -- +0.5 because otherwise it play twice as fast lol
    goldSprite:SetFrame(goldSprite:GetAnimation(), math.floor(frame))

    local dist = pickup.Position:Distance(helper:closestPlayer(pickup.Position).Position)
    local spriteA =math.max(0, math.min(1, (dist-pickup.Size-60)/40))

    local col = pickup:GetSprite().Color

    goldSprite.Color = Color(col.R,col.G,col.B,spriteA,col.RO,col.GO,col.BO)

    goldSprite:Render(renderPos)

    pickup.Color = Color(col.R,col.G,col.B,1-spriteA,col.RO,col.GO,col.BO) -- color is inversely visible to the gold sprite's color

end
mod:AddCallback(ModCallbacks.MC_POST_PICKUP_RENDER, funcs.postPickupRender)

function funcs:postEffectUpdate(effect)
    if(effect.FrameCount==0) then effect:GetSprite():Play("Idle", true) end
    if(effect:GetSprite():IsFinished("Idle")) then effect:Remove() end
end
mod:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, funcs.postEffectUpdate, goldenEyeEffect)

--[[function funcs:spawnFakeGold(cmd, args)
    if(cmd=="gspawn") then
        local commaPos = string.find(args, ",")
        local var = tonumber(string.sub(args, 1, commaPos-1)) or 0

        args = string.sub(args, commaPos+1)
        commaPos = string.find(args, ",")
        local subtype = tonumber(string.sub(args, 1, commaPos-1)) or 0

        args = string.sub(args, commaPos+1)
        local gridpos = tonumber(args) or 1

        local pickup = Isaac.Spawn(5,var,subtype,Game():GetRoom():GetGridPosition(gridpos),Vector.Zero,nil)
    end
end
mod:AddCallback(ModCallbacks.MC_EXECUTE_CMD, funcs.spawnFakeGold)]]

mod.ITEMS.GOLDENEYE = funcs