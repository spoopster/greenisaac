local mod = jezreelMod

local sfx = SFXManager()
local h = include("scripts/func")
local f = Font()
f:Load("font/luamini.fnt")

local betSprite = Sprite()
betSprite:Load("gfx/ui/bets/bets.anm2", true)
betSprite:Play("Bet", true)

local satansBet = mod.ENUMS.ITEMS.SATANS_BET

local BETS_ENUM = {
    LONGLIVETHEKING = {Flag=1<<0, Name="Long Live the King", Bet=1},
    LEAKYFOE ={Flag=1<<1, Name="Leaky Foe", Bet=0},
    KAMIKAZE = {Flag=1<<2, Name="Kamikaze!", Bet=1},
    UNTOUCHABLE = {Flag=1<<3, Name="Untouchable!", Bet=2},
    NOACTIVE = {Flag=1<<4, Name="No Active Items!", Bet=1},
    NOCONSUMABLE = {Flag=1<<5, Name="No Consumables!", Bet=1},
    NOTIMETOEXPLAIN = {Flag=1<<6, Name="Time Limit", Bet=1},
    HEMORRHAGE = {Flag=1<<7, Name="Hemorrhage", Bet=1},
    DROWSY = {Flag=1<<8, Name="Drowsy...", Bet=1},
    SUGARRUSH = {Flag=1<<9, Name="Sugar Rush!", Bet=0},
    CANTSTOPWONTSTOP = {Flag=1<<10, Name="Can't Stop Won't Stop", Bet=2},
}

local NUM_BETS = 0
for _, _ in pairs(BETS_ENUM) do NUM_BETS=NUM_BETS+1 end

local BET_CHANCES = 75

local LOSE_BET_SFX = SoundEffect.SOUND_THUMBS_DOWN
local WIN_BET_SFX = SoundEffect.SOUND_THUMBSUP

sfx:Preload(LOSE_BET_SFX)
sfx:Preload(WIN_BET_SFX)

local ROOM_TIME = 0

local TIMELIMIT_TIMER_MULT = 3
local MAX_TIMELIMIT_TIMER = 0

local HEMORRHAGE_PROJ_NUM = 8
local HEMORRHAGE_PROJ_SPEED = 8

local CANTSTOP_TIME_START = 3

local function getRandomBet(rng, invalidBets)
    local betsArray = {}
    local i=1
    for _, val in pairs(BETS_ENUM) do
        betsArray[i]=val.Flag
        i=i+1
    end

    local chosenBet = betsArray[rng:RandomInt(#betsArray)+1]
    while(invalidBets & chosenBet == chosenBet) do chosenBet = betsArray[rng:RandomInt(#betsArray)+1] end

    return chosenBet
end

local function failBet(betFlag, loseMoney)
    local bet = BETS_ENUM[betFlag]
    if(loseMoney) then
        Isaac.GetPlayer():AddCoins(-bet.Bet)
        sfx:Play(LOSE_BET_SFX)

        for i=1, bet.Bet do
            local coin = Isaac.Spawn(5,20,1,Isaac.GetPlayer().Position,Vector(5,0):Rotated(Isaac.GetPlayer():GetCollectibleRNG(satansBet):RandomFloat()*360),nil):ToPickup()
            coin.Wait=9999
            coin.Timeout=30
        end
    end
    for _, player in ipairs(Isaac.FindByType(1,0)) do
        player=player:ToPlayer()
        local data = player:GetData()
        data.currentBets = data.currentBets & (~(bet.Flag))
    end
end

local function getVulnerableEntities()
    local vulnerableEntities = {}
    for _, entity in ipairs(Isaac:GetRoomEntities()) do
        if(entity:IsVulnerableEnemy()) then vulnerableEntities[#vulnerableEntities+1] = entity end
    end

    return vulnerableEntities
end

local function getRandomEnemy(rng)
    local vulnerableEntities = getVulnerableEntities()

    if(#vulnerableEntities>0) then
        return vulnerableEntities[rng:RandomInt(#vulnerableEntities)+1]
    else
        return nil
    end
end

local function doesBossExist()
    for _, entity in ipairs(Isaac:GetRoomEntities()) do
        if(entity:IsBoss()) then return true end
    end
    return false
end

local function anyPlayerHasConsumable()
    for _, player in ipairs(Isaac.FindByType(1,0)) do
        player=player:ToPlayer()
        for j=0,3 do
            if(player:GetCard(j)~=0 or player:GetPill(j)~=0) then return true end
        end
    end
    return false
end

local function anyPlayerHasActive()
    for _, player in ipairs(Isaac.FindByType(1,0)) do
        player=player:ToPlayer()
        for j=0,3 do
            if(player:GetActiveItem(j)~=0) then return true end
        end
    end
    return false
end

local function renderEnemyBetEffect(spritePath, pos)
    betSprite:ReplaceSpritesheet(0, spritePath)
    betSprite:LoadGraphics()
    betSprite:Render(pos)
end

local funcs = {}

function funcs:chooseBets()
    for _, player in ipairs(Isaac.FindByType(1,0)) do
        player=player:ToPlayer()
        player:GetData().currentBets = 0
    end

    ROOM_TIME = 0
    MAX_TIMELIMIT_TIMER = 0

    if(Game():GetRoom():IsClear()) then return end

    local betsNum = h:allPlayersCollNum(satansBet)
    if(betsNum<1) then return end
    local rng = RNG()
    rng:SetSeed(Isaac.GetPlayer().InitSeed+Game():GetLevel():GetCurrentRoomIndex(), 35)

    local invalidBets = 0
    if(not anyPlayerHasConsumable()) then invalidBets=invalidBets+BETS_ENUM.NOCONSUMABLE.Flag end
    if(not anyPlayerHasActive()) then invalidBets=invalidBets+BETS_ENUM.NOACTIVE.Flag end

    local bets = 0
    for i=1, math.min(betsNum, NUM_BETS) do
        if(i==1 and doesBossExist()) then
            bets = bets+BETS_ENUM.UNTOUCHABLE.Flag
        else
            if(rng:RandomFloat()*100<BET_CHANCES) then
                bets = bets+getRandomBet(rng, bets+invalidBets)
            end
        end
    end

    for _, player in ipairs(Isaac.FindByType(1,0)) do
        player=player:ToPlayer()
        player:GetData().currentBets = bets
    end
end
mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, funcs.chooseBets)

function funcs:useItem(_,_,player,flags,slot)
    local bets = player:GetData().currentBets
    if(not bets or bets==0) then goto NOBETS end

    if(bets & BETS_ENUM.NOACTIVE.Flag == 0) then goto NOACTIVE_INVALID end
    if(flags & UseFlag.USE_OWNED == UseFlag.OWNED or slot~=-1) then
        failBet("NOACTIVE", true)
    end
    ::NOACTIVE_INVALID::

    ::NOBETS::
end
mod:AddPriorityCallback(ModCallbacks.MC_USE_ITEM, CallbackPriority.EARLY, funcs.useItem)

function funcs:useConsumable(_,player,flags)
    local bets = player:GetData().currentBets
    if(not bets or bets==0) then goto NOBETS end

    if(bets & BETS_ENUM.NOCONSUMABLE.Flag == 0) then goto NOCONSUMABLE_INVALID end
    if(flags & UseFlag.USE_MIMIC == 0 and flags & UseFlag.USE_NOHUD == 0) then
        failBet("NOCONSUMABLE", true)
    end
    ::NOCONSUMABLE_INVALID::

    ::NOBETS::
end
mod:AddCallback(ModCallbacks.MC_USE_PILL, funcs.useConsumable)
mod:AddCallback(ModCallbacks.MC_USE_CARD, funcs.useConsumable)

function funcs:playerTakeDmg(player)
    player = player:ToPlayer()

    local bets = player:GetData().currentBets
    if(not bets or bets==0) then goto NOBETS end

    if(bets & BETS_ENUM.UNTOUCHABLE.Flag == 0) then goto UNTOUCHABLE_INVALID end
    failBet("UNTOUCHABLE", true)
    ::UNTOUCHABLE_INVALID::

    ::NOBETS::
end
mod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, funcs.playerTakeDmg, EntityType.ENTITY_PLAYER)

function funcs:postUpdate()
    local bets = Isaac.GetPlayer():GetData().currentBets
    if(not bets or bets==0) then return end

    ROOM_TIME = ROOM_TIME+1

    if(bets & BETS_ENUM.NOTIMETOEXPLAIN.Flag == 0) then goto TIMELIMIT_INVALID end
    if(not Game():GetRoom():IsClear()) then
        if(ROOM_TIME>=MAX_TIMELIMIT_TIMER*30) then
            failBet("NOTIMETOEXPLAIN", true)
            MAX_TIMELIMIT_TIMER = 0
        end
    end
    ::TIMELIMIT_INVALID::
end
mod:AddCallback(ModCallbacks.MC_POST_UPDATE, funcs.postUpdate)

function funcs:postNewRoom()
    local bets = Isaac.GetPlayer():GetData().currentBets
    if(not bets or bets==0) then return end

    if(bets & BETS_ENUM.NOTIMETOEXPLAIN.Flag == BETS_ENUM.NOTIMETOEXPLAIN.Flag) then
        MAX_TIMELIMIT_TIMER = TIMELIMIT_TIMER_MULT*#getVulnerableEntities()
        if(MAX_TIMELIMIT_TIMER==0) then failBet("NOTIMETOEXPLAIN", false) end
        if(doesBossExist()) then
            failBet("NOTIMETOEXPLAIN", false)
            MAX_TIMELIMIT_TIMER=0
        end
    end

    local rng = Isaac.GetPlayer():GetCollectibleRNG(satansBet)

    if(bets & BETS_ENUM.LONGLIVETHEKING.Flag == BETS_ENUM.LONGLIVETHEKING.Flag) then
        local enemy = getRandomEnemy(rng)
        if(enemy) then enemy:GetData().BET_KING=true
        else failBet("LONGLIVETHEKING", false) end
    end
    if(bets & BETS_ENUM.LEAKYFOE.Flag == BETS_ENUM.LEAKYFOE.Flag) then
        local enemy = getRandomEnemy(rng)
        if(enemy) then enemy:GetData().BET_CREEP=true
        else failBet("LEAKYFOE", false) end
    end

end
mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, funcs.postNewRoom)

function funcs:postNpcUpdate(npc)
    local bets = Isaac.GetPlayer():GetData().currentBets
    if(not bets or bets==0) then return end

    local rng = Isaac.GetPlayer():GetCollectibleRNG(satansBet)
    local data = npc:GetData()

    if(data.BET_CREEP) then
        if(npc.FrameCount%5==0) then
            local creep = Isaac.Spawn(1000,EffectVariant.CREEP_RED,0,npc.Position,Vector.Zero,npc)
        end
    end

end
mod:AddCallback(ModCallbacks.MC_NPC_UPDATE, funcs.postNpcUpdate)

function funcs:postPlayerUpdate(player)
    local bets = Isaac.GetPlayer():GetData().currentBets
    if(not bets or bets==0) then return end

    if(bets & BETS_ENUM.DROWSY.Flag == BETS_ENUM.DROWSY.Flag) then
        player.Velocity = player.Velocity*0.95
    end
    if(bets & BETS_ENUM.SUGARRUSH.Flag == BETS_ENUM.SUGARRUSH.Flag) then
        player.Velocity = player.Velocity*1.05
    end

    if(bets & BETS_ENUM.CANTSTOPWONTSTOP.Flag == BETS_ENUM.CANTSTOPWONTSTOP.Flag) then
        if(ROOM_TIME>CANTSTOP_TIME_START*30) then
            if(player.Velocity:Length()<0.1) then failBet("CANTSTOPWONTSTOP", true) end
        end
    end
end
mod:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, funcs.postPlayerUpdate)

function funcs:postNpcRender(npc, offset)
    local data = npc:GetData()
    local effectNum = 0

    if(data.BET_KING) then effectNum=effectNum+1 end
    if(data.BET_CREEP) then effectNum=effectNum+1 end

    local renderPos = Isaac.WorldToRenderPosition(npc.Position)+offset+Vector(-effectNum*8+1,0)

    if(data.BET_KING) then
        renderEnemyBetEffect("gfx/ui/bets/LONGLIVETHEKING_EFFECT.png", renderPos)
        renderPos = renderPos+Vector(16,0)
    end
    if(data.BET_CREEP) then
        renderEnemyBetEffect("gfx/ui/bets/LEAKYFOE_EFFECT.png", renderPos)
        renderPos = renderPos+Vector(16,0)
    end
end
mod:AddCallback(ModCallbacks.MC_POST_NPC_RENDER, funcs.postNpcRender)

---@param npc Entity
function funcs:postEntityRemove(npc)
    npc = npc:ToNPC()
    if(not npc) then return end
    if(npc.HitPoints>0) then return end

    local bets = Isaac.GetPlayer():GetData().currentBets
    if(bets==0) then return end

    local data = npc:GetData()

    if(data.BET_KING and #getVulnerableEntities()~=0) then
        failBet("LONGLIVETHEKING", true)
    end
    if(bets & BETS_ENUM.KAMIKAZE.Flag == BETS_ENUM.KAMIKAZE.Flag) then
        Isaac.Explode(npc.Position,npc,1)
    end
    if(bets & BETS_ENUM.HEMORRHAGE.Flag == BETS_ENUM.HEMORRHAGE.Flag) then
        for i=1,HEMORRHAGE_PROJ_NUM do
            npc:FireProjectiles(npc.Position,Vector.FromAngle(i*360/HEMORRHAGE_PROJ_NUM)*HEMORRHAGE_PROJ_SPEED,0,ProjectileParams())
        end
    end
end
mod:AddCallback(ModCallbacks.MC_POST_ENTITY_REMOVE, funcs.postEntityRemove)


function funcs:postRender() --* RENDER THE BETS
    local bets = Isaac.GetPlayer():GetData().currentBets
    if(not bets or bets==0) then return end
    if(not Game():GetHUD():IsVisible()) then return end

    local offset = Vector(Options.HUDOffset*20, Options.HUDOffset*12)

    local x = offset.X; local y = offset.Y+200
    for flag, val in pairs(BETS_ENUM) do
        if(bets & val.Flag == val.Flag) then
            betSprite:ReplaceSpritesheet(0, "gfx/ui/bets/"..flag..".png")
            betSprite:LoadGraphics()
            betSprite:Render(Vector(x,y))

            local s = val.Name
            if(flag=="NOTIMETOEXPLAIN") then s=s.." "..math.floor((MAX_TIMELIMIT_TIMER-ROOM_TIME/30)*10)/10 end
            f:DrawString(s, x+18, y, KColor(1,1,1,1))
            y = y+16
            if(y+16>Isaac.GetScreenHeight()-48) then
                x=offset.X+115; y=offset.Y+200
            end
        end
    end
end
mod:AddCallback(ModCallbacks.MC_POST_RENDER, funcs.postRender)

function funcs:preSpawnCleanAward(rng, pos)
    local bets = Isaac.GetPlayer():GetData().currentBets
    if(not bets) then return nil end

    local betTotal = 0

    for _, val in pairs(BETS_ENUM) do
        if(bets & val.Flag == val.Flag) then
            Isaac.GetPlayer():AddCoins(val.Bet)
            betTotal = betTotal+val.Bet
        end
    end
    if(betTotal>0) then sfx:Play(WIN_BET_SFX) end

    for _, player in ipairs(Isaac.FindByType(1,0)) do
        player=player:ToPlayer()
        player:GetData().currentBets=0
    end
end
mod:AddCallback(ModCallbacks.MC_PRE_SPAWN_CLEAN_AWARD, funcs.preSpawnCleanAward)

mod.ITEMS.SATANSBET = funcs