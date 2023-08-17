local mod = jezreelMod

local cherryOnTop = mod.ENUMS.VEGETABLES.CHERRY_ON_TOP

local funcs = {}

local function roundUpVal(val, increment)
    local roundedVal = val

    roundedVal = math.ceil(val/increment)*increment

    return roundedVal
end

local function toTearsPerSecond(maxFireDelay)
    return 30 / (maxFireDelay + 1)
  end

local function toMaxFireDelay(tearsPerSecond)
    return (30 / tearsPerSecond) - 1
end

---@param player EntityPlayer
function funcs:evaluateCache(player, flag)
    local berryNum = player:GetCollectibleNum(cherryOnTop)
    if(berryNum<=0) then return end

    if(flag & CacheFlag.CACHE_SPEED == CacheFlag.CACHE_SPEED) then
        player.MoveSpeed = roundUpVal(player.MoveSpeed, 0.25)
    end
    if(flag & CacheFlag.CACHE_DAMAGE == CacheFlag.CACHE_DAMAGE) then
        player.Damage = roundUpVal(player.Damage, 1)
    end
    if(flag & CacheFlag.CACHE_FIREDELAY == CacheFlag.CACHE_FIREDELAY) then
        player.MaxFireDelay = toMaxFireDelay(roundUpVal(toTearsPerSecond(player.MaxFireDelay), 0.5))
    end
    if(flag & CacheFlag.CACHE_RANGE == CacheFlag.CACHE_RANGE) then
        player.TearRange = roundUpVal(player.TearRange, 40)
    end
    if(flag & CacheFlag.CACHE_SHOTSPEED == CacheFlag.CACHE_SHOTSPEED) then
        player.ShotSpeed = roundUpVal(player.ShotSpeed, 0.25)
    end
    if(flag & CacheFlag.CACHE_LUCK == CacheFlag.CACHE_LUCK) then
        player.Luck = roundUpVal(player.Luck, 1)
    end
end
mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, funcs.evaluateCache)

mod.ITEMS.CHERRYONTOP = funcs