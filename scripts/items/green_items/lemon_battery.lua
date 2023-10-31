local mod = jezreelMod

local lemonBattery = mod.ENUMS.VEGETABLES.LEMON_BATTERY

--max bonus is a damage multiplier added on top of the 1x damage mult
local DEFAULT_MAX_BONUS = 0.3
local MAX_BONUS = {
    [0]=0.1,
    [1]=0.1,
    [2]=0.2,
    [3]=0.3,
    [4]=0.4,
    [5]=0.4,
    [6]=0.5,
    [12]=0.5,
}

local funcs = {}

---@param player EntityPlayer
function funcs:postPlayerUpdate(player)

    local data = player:GetData()
    if(not (player:HasCollectible(lemonBattery))) then
        if(data.maxChargeBonus) then
            data.maxChargeBonus = 0

            player:AddCacheFlags(CacheFlag.CACHE_DAMAGE)
            player:EvaluateItems()
        end
        return
    end

    if(data.maxChargeBonus==nil) then data.maxChargeBonus=0 end

    local maxDamageBonus = 0

    for _, slot in pairs(ActiveSlot) do
        local damageBonus = 0

        local activeItem = player:GetActiveItem(slot)
        if(activeItem==0) then goto noItem end

        do
            local itemConf = Isaac.GetItemConfig():GetCollectible(activeItem)

            local currentCharge = player:GetActiveCharge(slot)
            local currentBatCharge = player:GetBatteryCharge(slot)
            local maxCharges = itemConf.MaxCharges
            local chargeMod = 1

            if(maxCharges==0 and activeItem~=1) then
                damageBonus = MAX_BONUS[0]

                goto zeroCharge
            end

            if(itemConf.ChargeType==1) then
                chargeMod=1/30
            elseif(itemConf.ChargeType==2) then
                chargeMod=4/maxCharges
            end

            currentCharge=currentCharge*chargeMod
            currentBatCharge=currentBatCharge*chargeMod
            maxCharges=maxCharges*chargeMod

            damageBonus = MAX_BONUS[maxCharges] or DEFAULT_MAX_BONUS

            damageBonus = damageBonus*(currentCharge+currentBatCharge/2)/maxCharges

            ::zeroCharge::

            maxDamageBonus = math.max(damageBonus, maxDamageBonus)

        end

        ::noItem::
    end

    maxDamageBonus = maxDamageBonus*(1.5^(player:GetCollectibleNum(lemonBattery)-1))

    if(maxDamageBonus~=data.maxChargeBonus) then
        data.maxChargeBonus = maxDamageBonus

        player:AddCacheFlags(CacheFlag.CACHE_DAMAGE)
        player:EvaluateItems()
    end
end
mod:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, funcs.postPlayerUpdate, 0)

function funcs:evaluateCache(player, flag)
    local lemonNum = player:GetCollectibleNum(lemonBattery)
    if(lemonNum>0) then
        if(flag & CacheFlag.CACHE_DAMAGE == CacheFlag.CACHE_DAMAGE) then
            local damageBonus = player:GetData().maxChargeBonus or 0
            player.Damage = player.Damage*(1+damageBonus)
        end
    end
end
mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, funcs.evaluateCache)

mod.ITEMS.LEMONBATTERY = funcs