local mod = jezreelMod
local sfx = SFXManager()

local tangerine = mod.ENUMS.VEGETABLES.OBNOXIOUS_TANGERINE
local tangerineVariant = Isaac.GetEntityVariantByName("Tangerine Dialogue")
local pearVariant = mod.PICKUPS.PEAR
sfx:Preload(262)

--90 characters max, add 5 spaces at the end
--15 characters per line ??
local tangerineMessages = {
  --[00]=   ""               ..""               ..""               ..""               ..""               ..""               .."     ",
    [1] =   "YOU MISSED A   ".."TINTED ROCK IN ".."THE LAST ROOM"  ..""               ..""               ..""               .."     ",
    [2] =   "I FUCKING HATE ".."THESE PEOPLE"   ..""               ..""               ..""               ..""               .."     ",
    [3] =   "HEY ISAAC HEY  ".."HEY HEY ISAAC"  ..""               ..""               ..""               ..""               .."     ",
    [4] =   "I USED TO HAVE ".."JOY IN MY SOUL" ..""               ..""               ..""               ..""               .."     ",
    [5] =   "ITS JUST A GAME".."IS SUCH A WEAK ".."MINDSET"        ..""               ..""               ..""               .."     ",
    [6] =   "IM GONNA FUCKIN".."KILL THEM ALL"  ..""               ..""               ..""               ..""               .."     ",
    [7] =   "ONE OF THESE   ".."ROCKS HAS A    ".."CRAWLSPACE"     ..""               ..""               ..""               .."     ",
    [8] =   "WHATS BROWN AND".."STICKY         ".."A BROWN STICK"  ..""               ..""               ..""               .."     ",
    [9] =   "WHY ARENT YOU  ".."RESPONDING  DO ".."YOU HATE ME    ".."WHAT IS WRONG  ".."WITH YOU"       ..""               .."     ",
    [10]=   "THE FUCK DID   ".."YOU SAY TO ME  ".."YOU LITTLE SHIT"..""               ..""               ..""               .."     ",
    [11]=   "ITS JUST A     ".."PRANK  BRO"     ..""               ..""               ..""               ..""               .."     ",
    [12]=   "SAY YOUR       ".."PRAYERS   ISAAC"..""               ..""               ..""               ..""               .."     ",
    [13]=   "YOURE TOO SLOW" ..""               ..""               ..""               ..""               ..""               .."     ",
    [14]=   "WHO ARE YOU I  ".."AM FROM ANCIENT".."GREECE"         ..""               ..""               ..""               .."     ",
    [15]=   "SKIP SCHOOL AND".."DO DRUGS KID"   ..""               ..""               ..""               ..""               .."     ",
    [16]=   "HOW MUCH WOOD  ".."WOULD A WOOD   ".."CHUCK CHUCK"    ..""               ..""               ..""               .."     ",
    [17]=   "JUST DONT GET  ".."HIT ITS THAT   ".."SIMPLE"         ..""               ..""               ..""               .."     ",
    [18]=   "YOU CAN HOLD   ".."R TO RESTART   ".."YOUR RUN"       ..""               ..""               ..""               .."     ",
    [19]=   "HEY    IM GLENN".."QUAGMIRE"       ..""               ..""               ..""               ..""               .."     ",
    [20]=   "HEY ISAAC      ".."HEY ISAAC      ".."HEY ISAAC      ".."HEY ISAAC      ".."HEY ISAAC      ".."MOMS FOOT"      .."     ",
    [21]=   "REMOVED FOR    ".."VULGARITY      ".."               ".."JUST KIDDING   ".."FUCK YOU LOL"   ..""               .."     ",
    [22]=   "YO             ".."CAN YOU STOP   ".."YELLING KILL   ".."EVERYONE"       ..""               ..""               .."     ",
    [23]=   "UPDATE COMING  ".."AUGUST 2022    ".."LOL"            ..""               ..""               ..""               .."     ",
    [24]=   "THIS WEIRDO    ".."MUST BE STOPPED"..""               ..""               ..""               ..""               .."     ",
    [25]=   "CAN YOU GET ME ".."A BIG MAC"      ..""               ..""               ..""               ..""               .."     ",
    [26]=   "SHES PRETTY YEA".."BUT MY TYPE IS ".."MEN"            ..""               ..""               ..""               .."     ",
    [27]=   "OH NO          ".."MY SUPER GAMING".."HOUSE"          ..""               ..""               ..""               .."     ",
    [28]=   "ARE YOU READY  ".."FOR MONSTROS   ".."ADVENTURE"      ..""               ..""               ..""               .."     ",
    [29]=   "TARNISHED GREEN".."ISAAC COMING   ".."SOON"           ..""               ..""               ..""               .."     ",
    [30]=   "YOU ARE SO     ".."FUCKING STUPID" ..""               ..""               ..""               ..""               .."     ",
    [31]=   "NO"             ..""               ..""               ..""               ..""               ..""               .."     ",
    -- RED BABY QUOTES
    [32]=   "I WILL SKIN    ".."YOU ALIVE"      ..""               ..""               ..""               ..""               .."     ",
    [33]=   "WHERE DO ALL   ".."OF THESE BABY  ".."SKINS COME FROM"..""               ..""               ..""               .."     ",
    [34]=   "BRB GOTTA PISS ".."               ".."               ".."               ".."               ".."IM BACK"        .."     ",
    [35]=   "YOUR SKELETON  ".."IS MADE OF     ".."SOYLENT"        ..""               ..""               ..""               .."     ",
    [36]=   "RED BABY BOSS  ".."IS REAL"        ..""               ..""               ..""               ..""               .."     ",
    -- FELIX QUOTES
    [37]=   "BIG BOULDER    ".."DOWN THE LANE"  ..""               ..""               ..""               ..""               .."     ",
    [38]=   "RANGE IS       ".."USELESS"        ..""               ..""               ..""               ..""               .."     ",
    [39]=   "I EAT ROCKS"    ..""               ..""               ..""               ..""               ..""               .."     ",

    [40]=   "THIS MOD IS    ".."SPYWARE        ".."I HAVE YOUR    ".."ADDRESS"        ..""               ..""               .."     ",
    [41]=   "THIS IS AN     ".."IP LOGGER"      ..""               ..""               ..""               ..""               .."     ",
    [42]=   "I AM MINING    ".."BITCOINS ON    ".."YOUR MACHINE"   ..""               ..""               ..""               .."     ",
    [43]=   "THIS RUN SUCKS ".."JUST RESTART"   ..""               ..""               ..""               ..""               .."     ",

    -- WARP QUOTES
    [44]=   "HAVE A HEART   ".."MORON"          ..""               ..""               ..""               ..""               .."     ",
    [45]=   "YOURE ALL WARP ".."NO HEART"       ..""               ..""               ..""               ..""               .."     ",
    [46]=   "GREEN PLUS BEAN"..""               ..""               ..""               ..""               ..""               .."     ",

    [47]=   "MY DAD WORKS AT".."FIEND FOLIO HE ".."WILL BEAT YOUR ".."ASS"            ..""               ..""               .."     ",
    [48]=   "I WANNA GO TO  ".."BED            ".."SNOOOORE MIMIMI".."SNOOOORE MIMIMI"..""               ..""               .."     ",
    [49]=   "HOOLY YOUTUBER ".."LUCK ISAAC     ".."MIND OPENING UP".."YOUR CONSOLE"   ..""               ..""               .."     ",
    [50]=   "MOD DOESNT WORK".."PLS FIX"        ..""               ..""               ..""               ..""               .."     ",
}

local funcs = {}

function funcs:spawnTangerine(spawner)
    local tang = Isaac.Spawn(1000, tangerineVariant, 0, Vector.Zero, Vector.Zero, spawner):ToEffect()
    local tRng = tang:GetDropRNG()
    local room = Game():GetRoom()
    local roomSize = Vector(room:GetGridWidth(), room:GetGridHeight())
    local spawnPos = Vector(roomSize.X*tRng:RandomFloat()*40, roomSize.Y*tRng:RandomFloat()*40)
    local shape = room:GetRoomShape()
    if((shape==9 and spawnPos.X<roomSize.X*20) or (shape==10 and spawnPos.X>roomSize.X*20)) then
        spawnPos.Y = roomSize.Y*20+tRng:RandomFloat()*roomSize.Y*20
    elseif((shape==11 and spawnPos.X<roomSize.X*20) or (shape==12 and spawnPos.X>roomSize.X*20)) then
        spawnPos.Y = tRng:RandomFloat()*roomSize.Y*20
    end
    spawnPos = spawnPos+room:GetTopLeftPos()
    tang.Position = spawnPos
    tang.RenderZOffset = 9999
    local sprite = tang:GetSprite()
    sprite:Play("Spawn", true)
    local tData = tang:GetData()
    tData.renderCount = 0
    tData.lettersRendered = 0
    tData.letters = {}
    tData.message = tangerineMessages[tRng:RandomInt(#tangerineMessages)+1]
    tData.SFXvolume = 1
    return tang
end

---@param player EntityPlayer
function funcs:postPlayerUpdate(player)
    local data = player:GetData()

    local hasTangerine = player:HasCollectible(tangerine)
    if(hasTangerine or mod:getMenuData().constantAnnoyance==2) then
        if(data.tangerineCooldown==nil) then
            data.tangerineCooldown=0
        end
        if(data.tangerineCooldown==0) then
            local cooldown = 300
            if(hasTangerine and mod:getMenuData().constantAnnoyance==2) then cooldown=120 end

            local tang = funcs:spawnTangerine(player)
            data.tangerineCooldown=math.floor(cooldown*(1+player:GetCollectibleRNG(tangerine):RandomFloat()*0.5))
        end

        if(data.tangerineCooldown>0) then
            data.tangerineCooldown=data.tangerineCooldown-1
        end
    end
end
mod:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, funcs.postPlayerUpdate, 0)

---@param player EntityPlayer
function funcs:useItem(_, _, player, _, _, _)
    local tang = funcs:spawnTangerine(player)

    local pear = Isaac.Spawn(5,pearVariant,0,player.Position+Vector(0,30),Vector.Zero,player)
    pear:GetSprite():ReplaceSpritesheet(0, "gfx/entities/pickups/pear/annoying_pear.png")
    pear:GetSprite():ReplaceSpritesheet(1, "gfx/entities/pickups/pear/annoying_pear.png")
    pear:GetSprite():LoadGraphics()

    return {
        Discharge=true,
        Remove=false,
        ShowAnim=true,
    }
end
mod:AddCallback(ModCallbacks.MC_USE_ITEM, funcs.useItem, tangerine)

---@param effect EntityEffect
function funcs:postEffectUpdate(effect)
    if(effect.SubType==0) then
        local sprite = effect:GetSprite()
        local data = effect:GetData()
        if(sprite:IsFinished("Spawn")) then
            sprite:Play("Idle", true)
        end
        if(sprite:IsPlaying("Despawn")) then
            for i=1, data.lettersRendered do
                data.letters[i]:Remove()
            end
            data.lettersRendered=0
        end
        if(sprite:IsFinished("Despawn")) then
            effect:Remove()
        end
    end
end
mod:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, funcs.postEffectUpdate, tangerineVariant)

function funcs:postEffectRemove(effect)
    if(effect.Variant==tangerineVariant and effect.SubType==0) then
        local data = effect:GetData()
        if(data.lettersRendered) then
            for i=1, data.lettersRendered do
                data.letters[i]:Remove()
            end
            data.lettersRendered=0
        end
    end
end
mod:AddCallback(ModCallbacks.MC_POST_ENTITY_REMOVE, funcs.postEffectRemove, EntityType.ENTITY_EFFECT)

---@param effect EntityEffect
function funcs:postEffectRender(effect, offset)
    if(not Game():IsPaused()) then
        local data = effect:GetData()
        local sprite = effect:GetSprite()
        if(sprite:IsPlaying("Idle") and effect.SubType==0) then
            if(data.renderCount and (data.renderCount)%8==1) then
                data.lettersRendered = data.lettersRendered+1
                local letter = Isaac.Spawn(1000, tangerineVariant, 0, effect.Position, Vector.Zero, effect)
                letter.RenderZOffset = 10000
                local displayLetter = string.byte(data.message, data.lettersRendered, data.lettersRendered)-65
                local lSprite = letter:GetSprite()
                lSprite:Play("Text", true)
                lSprite:Stop()
                letter.SpriteOffset = Vector(((data.lettersRendered-1)%15-1)*6,math.floor((data.lettersRendered-1)/15)*7)
                if(displayLetter<0) then
                    letter.Color = Color(1,1,1,0,0,0,0)
                else
                    local sfxVol = data.SFXvolume
                    if(data.SFXvolume==nil) then sfxVol=1 end
                    if(sfxVol>0) then
                        sfx:Play(262,sfxVol,2,false,1.4+effect:GetDropRNG():RandomFloat()*0.8)
                    end
                    lSprite:SetFrame(displayLetter)
                end

                data.letters[data.lettersRendered] = letter
            elseif(data.renderCount==nil) then
                sprite:Play("Despawn", true)
                data.renderCount = 0
            end
            if(data.lettersRendered>=string.len(data.message)) then
                sprite:Play("Despawn", true)
            end
            data.renderCount = data.renderCount+1
        end
    end
end
mod:AddCallback(ModCallbacks.MC_POST_EFFECT_RENDER, funcs.postEffectRender, tangerineVariant)

mod.ITEMS.OBNOXIOUSTANGERINE = funcs