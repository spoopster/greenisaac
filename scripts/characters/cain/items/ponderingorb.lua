local mod = jezreelMod

local ponderingOrb = mod.ENUMS.ITEMS.PONDERING_ORB
local ponderingOrbDummy = mod.ENUMS.ITEMS.PONDERING_ORB_DUMMY

local ORB_SPECIFIC = {
    [CollectibleType.COLLECTIBLE_DECAP_ATTACK]=0,
    [CollectibleType.COLLECTIBLE_BOBS_ROTTEN_HEAD]=0,
    [CollectibleType.COLLECTIBLE_ISAACS_TEARS]=0,
}

local funcs = {}

local function getEffectiveItemNum(player)
    return player:GetCollectibleNum(ponderingOrb)+player:GetCollectibleNum(ponderingOrbDummy)
end

function funcs:postPlayerUpdate(player)
    local data = player:GetData()
    local orbNum = getEffectiveItemNum(player)
    if(orbNum>0) then
        if(data.canFireSack==true) then
            local tps = 30/(player.MaxFireDelay + 1)
            tps = math.floor(30/tps)
            local frameCount = player.FrameCount
            if(data.usingSack and frameCount%tps==0) then
                local maxTears = 4+orbNum-1
                for i=0,maxTears-1 do
                    local angle = i*(360/maxTears)+((frameCount/tps)%4*(90/maxTears))
                    local tear = player:FireTear(player.Position, Vector(10*player.ShotSpeed,0):Rotated(angle))
                    tear.CollisionDamage = tear.CollisionDamage*0.4
                end
            end
            data.canFireSack=nil
        else
            data.canFireSack=true
        end
    end
    if(data.lateActiveUses~=nil and type(data.lateActiveUses)=="table" and #(data.lateActiveUses)>0) then
        for _, itemDat in ipairs(data.lateActiveUses) do -- why do you torture me like this nicalis
            if(itemDat.Slot~=-1) then
                local activeCharge = player:GetActiveCharge(itemDat.Slot)
                local extraCharge = player:GetBatteryCharge(itemDat.Slot)
                if((activeCharge==0 and itemDat.IsOvercharged==false) or (activeCharge==Isaac.GetItemConfig():GetCollectible(itemDat.Item).MaxCharges and extraCharge==0 and itemDat.IsOvercharged==true)) then
                    local maxTears = 3+orbNum-1
                    local maxCharges = itemDat.Charges
                    for i=0, maxCharges*maxTears-1 do
                        local angle = i*360/(maxCharges*maxTears)
                        local tear = player:FireTear(player.Position, Vector(10*player.ShotSpeed,0):Rotated(angle))
                        tear.CollisionDamage = tear.CollisionDamage*2
                    end
                end
            end
            if(itemDat.Slot==-1) then
                local maxTears = 3+orbNum-1
                local maxCharges = itemDat.Charges
                for i=0, maxCharges*maxTears-1 do
                    local angle = i*360/(maxCharges*maxTears)
                    local tear = player:FireTear(player.Position, Vector(10*player.ShotSpeed,0):Rotated(angle))
                    tear.CollisionDamage = tear.CollisionDamage*2
                end
            end
        end
        data.lateActiveUses = {}
    end
end
mod:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, funcs.postPlayerUpdate, 0)

function funcs:useItem(item, rng, player, flags, slot, data)
    if(getEffectiveItemNum(player)>0) then
        local config = Isaac.GetItemConfig():GetCollectible(item)
        local maxCharges=0
        if(config.ChargeType==1) then maxCharges=2
        elseif(config.ChargeType==0) then maxCharges=config.MaxCharges end

        local pData = player:GetData()
        pData.lateActiveUses[#(pData.lateActiveUses)+1]={ -- why
            IsOvercharged = (player:GetBatteryCharge(slot)>0),
            Charges=maxCharges,
            Slot=slot,
            Item=item,
        }
    end
end
mod:AddCallback(ModCallbacks.MC_USE_ITEM, funcs.useItem)

mod.ITEMS.PONDERINGORB = funcs