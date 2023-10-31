local mod = jezreelMod
local h = include("scripts/func")

local sweetPotato = mod.ENUMS.VEGETABLES.SWEET_POTATO

local statBonuses = {
    Damage = {
        Red = 0.05,
        Soul = 0.15,
        Black = 0.1, -- added on top of soul heart damage
        Rotten = 0.15,
        Eternal = 0.3,
    },
    Tears = {
        Bone = 0.15,
        Golden = 0.2,
        Eternal = 0.3,
    },
    Range = {
        Red = 1/2,
        Eternal = 2,
    },
    Speed = {
        Red = 0.1,
        Eternal = 0.2,
    },
    Shotspeed = {
        Rotten = -0.2,
        Eternal = 0.2,
    },
}

local cacheFlagsToAdd = {
    Damage = CacheFlag.CACHE_DAMAGE,
    Tears = CacheFlag.CACHE_FIREDELAY,
    Range = CacheFlag.CACHE_RANGE,
    Speed = CacheFlag.CACHE_SPEED,
    Shotspeed = CacheFlag.CACHE_SHOTSPEED,
}

local funcs = {}

---@param player EntityPlayer
function funcs:postPlayerUpdate(player)

    local data = player:GetData()
    if(not (player:HasCollectible(sweetPotato))) then
        if(data.sweetPotatoBonuses) then
            data.sweetPotatoBonuses = {Damage=0,Tears=0,Range=0,Speed=0,Shotspeed=0}

            player:AddCacheFlags(CacheFlag.CACHE_DAMAGE)
            player:EvaluateItems()
        end
        return
    end

    if(data.sweetPotatoBonuses==nil) then data.sweetPotatoBonuses={Damage=0,Tears=0,Range=0,Speed=0,Shotspeed=0} end

    local bonuses = {
        Damage=0,
        Tears=0,
        Range=0,
        Speed=0,
        Shotspeed=0,
    }

    local hearts = h:getHearts(player)

    for stat, table in pairs(statBonuses) do
        for heart, bonus in pairs(table) do
            bonuses[stat] = bonuses[stat] + hearts[heart]*bonus
        end
    end

    local stackBonus = 1.5^(player:GetCollectibleNum(sweetPotato)-1)

    for stat, val in pairs(bonuses) do bonuses[stat] = val*stackBonus end

    local shouldEvaluateStats = false
    local cacheFlags = 0

    for stat, val in pairs(bonuses) do
        if(data.sweetPotatoBonuses[stat]~=val) then
            shouldEvaluateStats=true
            cacheFlags = cacheFlags | cacheFlagsToAdd[stat]
        end
    end

    if(shouldEvaluateStats) then
        for stat, val in pairs(bonuses) do
            data.sweetPotatoBonuses[stat] = val
        end

        player:AddCacheFlags(cacheFlags)
        player:EvaluateItems()
    end
end
mod:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, funcs.postPlayerUpdate, 0)

---@param player EntityPlayer
function funcs:evaluateCache(player, flag)
    local potatoNum = player:GetCollectibleNum(sweetPotato)
    if(potatoNum<=0) then return end

    local stats = player:GetData().sweetPotatoBonuses
    if(stats==nil) then return end
    if(flag & CacheFlag.CACHE_DAMAGE == CacheFlag.CACHE_DAMAGE) then
        local statBonus = stats.Damage or 0
        player.Damage = player.Damage*(1+statBonus)
    end
    if(flag & CacheFlag.CACHE_FIREDELAY == CacheFlag.CACHE_FIREDELAY) then
        local statBonus = stats.Tears or 0
        player.MaxFireDelay = player.MaxFireDelay/(1+statBonus)
    end
    if(flag & CacheFlag.CACHE_RANGE == CacheFlag.CACHE_RANGE) then
        local statBonus = stats.Range or 0
        player.TearRange = player.TearRange+statBonus*40
    end
    if(flag & CacheFlag.CACHE_SPEED == CacheFlag.CACHE_SPEED) then
        local statBonus = stats.Speed or 0
        player.MoveSpeed = player.MoveSpeed+statBonus
    end
    if(flag & CacheFlag.CACHE_SHOTSPEED == CacheFlag.CACHE_SHOTSPEED) then
        local statBonus = stats.Shotspeed or 0
        player.ShotSpeed = player.ShotSpeed+statBonus
    end
end
mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, funcs.evaluateCache)

mod.ITEMS.SWEETPOTATO = funcs