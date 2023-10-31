local mod = jezreelMod

local sfx = SFXManager()
local f = Font()
f:Load("font/luamini.fnt")

local greenStake = mod.ENUMS.ITEMS.GREEN_STAKE

local MAX_COUNTER_NUM = 10
local BATTERY_MAX_COUNTER_NUM = 15

local LOSE_MONEY_SFX = SoundEffect.SOUND_THUMBS_DOWN
local LOSE_MONEY_BIG_SFX = SoundEffect.SOUND_THUMBSDOWN_AMPLIFIED
local WIN_MONEY_SFX = SoundEffect.SOUND_THUMBSUP

sfx:Preload(LOSE_MONEY_SFX)
sfx:Preload(LOSE_MONEY_BIG_SFX)
sfx:Preload(WIN_MONEY_SFX)

local genericActiveReturn = {
    Discharge=true,
    Remove=false,
    ShowAnim=true,
}

local funcs = {}

local function getPlayerNum(player)
    for i=0,Game():GetNumPlayers()-1 do
        if(GetPtrHash(Isaac.GetPlayer(i))==GetPtrHash(player)) then
            return i
        end
    end
end

local function getOffsetForActive(player, item)
    local hasItem = false
    local offset = Vector.Zero
    local pNum = getPlayerNum(player)
    if(player:GetActiveItem(ActiveSlot.SLOT_POCKET)==item and player:GetCard(0)==0 and player:GetPill(0)==0) then
        if(pNum==0) then
            offset = Vector(-Options.HUDOffset*16+(Isaac.GetScreenWidth()-419), -Options.HUDOffset*6+(Isaac.GetScreenHeight()-259))
            hasItem = true
        end
    elseif(player:GetActiveItem(ActiveSlot.SLOT_PRIMARY)==item) then
        offset = Vector(Options.HUDOffset*20, Options.HUDOffset*12)
        if(pNum==1) then
            offset = offset+Vector(Isaac.GetScreenWidth()-419,0)
        elseif(pNum==2) then
            offset = offset+Vector(0, Isaac.GetScreenHeight()-259)
        elseif(pNum==3) then
            offset = offset+Vector(Isaac.GetScreenWidth()-419,Isaac.GetScreenHeight()-259)
        end
        hasItem = true
    end
    if hasItem then
        local renderPos = offset+Vector(26, 10)
        local renderOffset = Vector(0, 0)
        if(pNum==1) then
            renderOffset = Vector(256, 0)
        elseif(pNum==2) then
            renderOffset = Vector(12, 25)
        elseif(pNum==3) then
            renderOffset = Vector(256, 25)
        end
        renderPos = renderPos+renderOffset

        return renderPos
    end
    return nil
end

local function canUseStakes()
    local level = Game():GetLevel()
    local room = Game():GetRoom()
    return (level:GetCurrentRoomIndex()==level:GetStartingRoomIndex()) and room:IsFirstVisit()
end

function funcs:useItem(item, rng, player, flags, slot, vData)
    if(not canUseStakes()) then return genericActiveReturn end
    if(Game():GetLevel():IsAscent()) then return genericActiveReturn end

    if(flags & UseFlag.USE_CARBATTERY == UseFlag.USE_CARBATTERY) then return genericActiveReturn end

    local data = player:GetData()

    local counter = data.greenStakeCounter or 0
    counter = counter+1
    if(counter>((not player:HasCollectible(CollectibleType.COLLECTIBLE_CAR_BATTERY) and MAX_COUNTER_NUM) or BATTERY_MAX_COUNTER_NUM) ) then counter=0 end
    data.greenStakeCounter = counter

    data.stakeCounterColor = {Red=1,Green=1,Blue=0.25}

    return genericActiveReturn
end
mod:AddCallback(ModCallbacks.MC_USE_ITEM, funcs.useItem, greenStake)

---@param player Entity
function funcs:entityTakeDMG(player, _, flags)
    player = player:ToPlayer()
    local data = player:GetData()

    if(flags & DamageFlag.DAMAGE_NO_PENALTIES == DamageFlag.DAMAGE_NO_PENALTIES) then goto invalid end
    if(flags & DamageFlag.DAMAGE_IV_BAG == DamageFlag.DAMAGE_IV_BAG) then goto invalid end
    if(flags & DamageFlag.DAMAGE_FAKE == DamageFlag.DAMAGE_FAKE) then goto invalid end

    local amountLost = math.ceil(data.greenStakeCounter/2)
    data.greenStakeCounter = math.floor(data.greenStakeCounter/2)
    if(amountLost>0) then
        data.stakeCounterColor = {Red=1,Green=0.25,Blue=0.25}
        player:AddCoins(-amountLost*2)

        if(amountLost>=15) then sfx:Play(LOSE_MONEY_BIG_SFX, 1.5)
        else sfx:Play(LOSE_MONEY_SFX) end
    end

    ::invalid::
end
mod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, funcs.entityTakeDMG, EntityType.ENTITY_PLAYER)

function funcs:postNewLevel()
    for _, player in ipairs(Isaac.FindByType(1,0)) do
        player=player:ToPlayer()
        local data = player:GetData()

        if(data.greenStakeCounter>0) then
            for j=1, data.greenStakeCounter do
                local dPenny = Isaac.Spawn(5,20,4,Game():GetRoom():FindFreePickupSpawnPosition(player.Position,0,true,false),Vector.Zero,player)
                local penny = Isaac.Spawn(5,20,1,Game():GetRoom():FindFreePickupSpawnPosition(player.Position,0,true,false),Vector.Zero,player)
            end
            data.greenStakeCounter = 0
        end
    end
end
mod:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, funcs.postNewLevel)

function funcs:renderStakeCounter()
    for _, player in ipairs(Isaac.FindByType(1,0)) do
        player=player:ToPlayer()
        local renderPos = getOffsetForActive(player, greenStake)

        if(renderPos~=nil) then
            local data = player:GetData()
            renderPos = renderPos+Vector(5,8)

            local oldCol = data.stakeCounterColor or {Red=1, Green=1, Blue=1}

            local counter = data.greenStakeCounter or 0
            f:DrawString(tostring(counter),renderPos.X,renderPos.Y,KColor(oldCol.Red,oldCol.Green,oldCol.Blue,1),10,true)

            local newCol = {Red=1, Green=1, Blue=1}
            if(oldCol.Red<1) then newCol.Red = math.min(1,oldCol.Red*1.05) end
            if(oldCol.Green<1) then newCol.Green = math.min(1,oldCol.Green*1.05) end
            if(oldCol.Blue<1) then newCol.Blue = math.min(1,oldCol.Blue*1.05) end

            data.stakeCounterColor = newCol
        end
    end
end
mod:AddCallback(ModCallbacks.MC_POST_RENDER, funcs.renderStakeCounter)

mod.ITEMS.GREENSTAKE = funcs