local mod = jezreelMod
local json = require("json")

local greenIsaac = Isaac.GetPlayerTypeByName("Green Isaac", false)

local function cloneTable(t)
    local tClone = {}
    for key, val in pairs(t) do
        if(type(val)=="table") then
            tClone[key] = cloneTable(val)
        else
            tClone[key]=val
        end
    end
    return tClone
end

local isDataLoaded = false
local defaultMarks = {
    ["Isaac"] = 0,
    ["BlueBaby"] = 0,
    ["Satan"] = 0,
    ["Lamb"] = 0,
    ["BossRush"] = 0,
    ["Hush"] = 0,
    ["MegaSatan"] = 0,
    ["Delirium"] = 0,
    ["Mother"] = 0,
    ["Beast"] = 0,
    ["UltraGreed"] = 0,
    ["UltraGreedier"] = 0,
}
mod.MARKS = {
    CHARACTERS = {
        ISAAC = {A=cloneTable(defaultMarks),B=cloneTable(defaultMarks),},
        CAIN = {A=cloneTable(defaultMarks),B=cloneTable(defaultMarks),},
        MAGGY = {A=cloneTable(defaultMarks),B=cloneTable(defaultMarks),},
    },
    CHALLENGES = {
        BIBLICALLY_ACCURATE = 0,
        PROLOGUE = 0,
    },
}
mod.UNLOCKS = {
    CHARACTERS = {
        ISAAC = {
            A={
                ["Isaac"] = {ID=mod.ENUMS.VEGETABLES.UNICORNRADISH, TYPE="VEGETABLE", ACHIEVEMENT={"unicornradish"}}, --Unlocks Unicornradish
                ["BlueBaby"] = {ID=mod.ENUMS.VEGETABLES.SWEET_POTATO, TYPE="VEGETABLE", ACHIEVEMENT={"sweet_potato"}}, --Unlocks Sweet Potato
                ["Satan"] = {ID=mod.ENUMS.VEGETABLES.REALLY_SPICY_PEPPER, TYPE="VEGETABLE", ACHIEVEMENT={"really_spicy_pepper"}}, --Unlocks Really Spicy Pepper
                ["Lamb"] = {ID=mod.ENUMS.VEGETABLES.RICIN_FLASK, TYPE="VEGETABLE", ACHIEVEMENT={"ricin_flask"}}, --Unlocks Ricin Flask
                ["BossRush"] = {ID=mod.ENUMS.VEGETABLES.BROCCOLI_MAN, TYPE="VEGETABLE", ACHIEVEMENT={"broccoli_man"}}, --Unlocks Broccoli Man
                ["Hush"] = {ID=mod.ENUMS.VEGETABLES.BLUE_BERRY, TYPE="VEGETABLE", ACHIEVEMENT={"blue_berry"}}, --Unlocks Blue Berry
                ["MegaSatan"] = {ID=mod.ENUMS.VEGETABLES.DRAGONFRUIT_BOMBS, TYPE="VEGETABLE", ACHIEVEMENT={"dragonfruit_bombs"}}, --Unlocks Dragonfruit Bombs
                ["Delirium"] = {ID=mod.ENUMS.ITEMS.G6, TYPE="COLLECTIBLE", ACHIEVEMENT={"the_g6"}}, --Unlocks G6
                ["Mother"] = {ID=mod.ENUMS.VEGETABLES.NATURAL_GIFT, TYPE="VEGETABLE", ACHIEVEMENT={"natural_gift"}}, --Unlocks Natural Gift
                ["Beast"] = {ID=mod.ENUMS.VEGETABLES.CHERRY_ON_TOP, TYPE="VEGETABLE", ACHIEVEMENT={"cherry_on_top"}}, --Unlocks Cherry on Top
                ["UltraGreed"] = {ID=mod.ENUMS.VEGETABLES.ECO_FRIENDLY_OPTIONS, TYPE="VEGETABLE", ACHIEVEMENT={"eco_friendly_options"}}, --Unlocks Eco-Firendly Options
                ["UltraGreedier"] = {ID=mod.ENUMS.VEGETABLES.LEMON_BATTERY, TYPE="VEGETABLE", ACHIEVEMENT={"lemon_battery"}}, --Unlocks Lemon Battery
            },
            B={
                ["Isaac"] = {ID=0, TYPE="COLLECTIBLE", ACHIEVEMENT={"test"}},
                ["BlueBaby"] = {ID=0, TYPE="COLLECTIBLE", ACHIEVEMENT={"test"}},
                ["Satan"] = {ID=0, TYPE="COLLECTIBLE", ACHIEVEMENT={"test"}},
                ["Lamb"] = {ID=0, TYPE="COLLECTIBLE", ACHIEVEMENT={"test"}},
                ["BossRush"] = {ID=0, TYPE="COLLECTIBLE", ACHIEVEMENT={"test"}},
                ["Hush"] = {ID=0, TYPE="COLLECTIBLE", ACHIEVEMENT={"test"}},
                ["MegaSatan"] = {ID=0, TYPE="COLLECTIBLE", ACHIEVEMENT={"test"}},
                ["Delirium"] = {ID=0, TYPE="COLLECTIBLE", ACHIEVEMENT={"test"}},
                ["Mother"] = {ID=0, TYPE="COLLECTIBLE", ACHIEVEMENT={"test"}},
                ["Beast"] = {ID=0, TYPE="COLLECTIBLE", ACHIEVEMENT={"test"}},
                ["UltraGreed"] = {ID=0, TYPE="COLLECTIBLE", ACHIEVEMENT={"test"}},
                ["UltraGreedier"] = {ID=0, TYPE="COLLECTIBLE", ACHIEVEMENT={"test"}},
            }
        },
        CAIN = {
            A={
                ["Isaac"] = {ID=mod.ENUMS.ITEMS.GREEN_STAKE, TYPE="COLLECTIBLE", ACHIEVEMENT={"green_stake"}},
                ["BlueBaby"] = {ID=0, TYPE="COLLECTIBLE", ACHIEVEMENT={"jade_pear"}},
                ["Satan"] = {ID=mod.ENUMS.ITEMS.SATANS_BET, TYPE="COLLECTIBLE", ACHIEVEMENT={"satans_bet"}},
                ["Lamb"] = {ID=0, TYPE="COLLECTIBLE", ACHIEVEMENT={"dice_stick"}},
                ["BossRush"] = {ID=mod.ENUMS.ITEMS.WHEEL_OF_FORTUNE, TYPE="COLLECTIBLE", ACHIEVEMENT={"wheel_of_fortune"}},
                ["Hush"] = {ID=mod.ENUMS.ITEMS.PONDERING_ORB, TYPE="COLLECTIBLE", ACHIEVEMENT={"pondering_orb"}},
                ["MegaSatan"] = {ID=0, TYPE="COLLECTIBLE", ACHIEVEMENT={"magnet_gummy"}},
                ["Delirium"] = {ID=mod.ENUMS.ITEMS.GOLDEN_EYE, TYPE="COLLECTIBLE", ACHIEVEMENT={"golden_eye"}},
                ["Mother"] = {ID=mod.ENUMS.ITEMS.LESSER_THAN_G, TYPE="COLLECTIBLE", ACHIEVEMENT={"lesser_than_g"}},
                ["Beast"] = {ID=mod.ENUMS.ITEMS.BROTHERLY_LOVE, TYPE="COLLECTIBLE", ACHIEVEMENT={"brotherly_love"}},
                ["UltraGreed"] = {ID=mod.ENUMS.ITEMS.DIRTY_MONEY, TYPE="COLLECTIBLE", ACHIEVEMENT={"dirty_money"}},
                ["UltraGreedier"] = {ID=0, TYPE="COLLECTIBLE", ACHIEVEMENT={"glasspenny_greencoin"}},
            },
            B={
                ["Isaac"] = {ID=0, TYPE="COLLECTIBLE", ACHIEVEMENT={"test"}},
                ["BlueBaby"] = {ID=0, TYPE="COLLECTIBLE", ACHIEVEMENT={"test"}},
                ["Satan"] = {ID=0, TYPE="COLLECTIBLE", ACHIEVEMENT={"test"}},
                ["Lamb"] = {ID=0, TYPE="COLLECTIBLE", ACHIEVEMENT={"test"}},
                ["BossRush"] = {ID=0, TYPE="COLLECTIBLE", ACHIEVEMENT={"test"}},
                ["Hush"] = {ID=0, TYPE="COLLECTIBLE", ACHIEVEMENT={"test"}},
                ["MegaSatan"] = {ID=0, TYPE="COLLECTIBLE", ACHIEVEMENT={"test"}},
                ["Delirium"] = {ID=0, TYPE="COLLECTIBLE", ACHIEVEMENT={"test"}},
                ["Mother"] = {ID=0, TYPE="COLLECTIBLE", ACHIEVEMENT={"test"}},
                ["Beast"] = {ID=0, TYPE="COLLECTIBLE", ACHIEVEMENT={"test"}},
                ["UltraGreed"] = {ID=0, TYPE="COLLECTIBLE", ACHIEVEMENT={"test"}},
                ["UltraGreedier"] = {ID=0, TYPE="COLLECTIBLE", ACHIEVEMENT={"test"}},
            }
        },
    },
    CHALLENGES = {
        BIBLICALLY_ACCURATE = {ID=mod.ENUMS.ITEMS.JEZREELS_CURSE, TYPE="COLLECTIBLE", ACHIEVEMENT={"jezreels_curse"}},
        PROLOGUE = {ID=mod.ENUMS.ITEMS.LIL_SILENCE, TYPE="COLLECTIBLE", ACHIEVEMENT={"lil_silence"}},
    },
}
mod.BASEVALUES = {
    canHotPotato = 0,
    spawnableBananas = -1,
    durianFear = 0,
    tangerineCooldown = 600,
    sackPickups = {[1]=1,[2]=0,[3]=0,[4]=0},
    lateActiveUses = {},
    greenStakeCounter = 0,
    currentBets = 0,
    exploredItemRoom = false,
}
mod.G6_VEGETABLES = {
    [mod.ENUMS.VEGETABLES.KEY_LIME] = true,
    [mod.ENUMS.VEGETABLES.BANANARANG] = true,
    [mod.ENUMS.VEGETABLES.SPIKY_DURIAN] = true,
    [mod.ENUMS.VEGETABLES.CURSED_GRAPES] = true,
    [mod.ENUMS.VEGETABLES.HEMOGUAVA] = true,
}

local function getSaveData(player)
    local data = player:GetData()

    local dataToReturn = {}

    for key, val in pairs(mod.BASEVALUES) do
        dataToReturn[key]=data[key] or mod.BASEVALUES[key]
    end

    return dataToReturn
end
local function saveProgress()
    local save = {}
    save.itemData = {}
    for _, player in ipairs(Isaac.FindByType(1,0)) do
        player=player:ToPlayer()
        local seed = ""..player:GetCollectibleRNG(273):GetSeed() --* GREEN ISAAC USES BOB's BRAIN RNG SEED JUST IN CASE !
        save.itemData[seed]={}
        for key, val in pairs(getSaveData(player)) do
            save.itemData[seed][key]=val
        end
    end
    save.unlockData = mod.MARKS

	mod:SaveData(json.encode(save))
end
function mod:saveCommands()
    saveProgress()
end
function mod:saveNewFloor()
    saveProgress()
end
mod:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, mod.saveNewFloor)
function mod:saveGameExit(save)
    saveProgress()
end
mod:AddCallback(ModCallbacks.MC_PRE_GAME_EXIT, mod.saveGameExit)

--#region ACHIEVEMENT_LOGIC
local function getScreenCenter()
    local game = Game()
	local room = game:GetRoom()

	local pos = room:WorldToScreenPosition(Vector(0,0)) - room:GetRenderScrollOffset() - game.ScreenShakeOffset
	local rx = pos.X + 60 * 26 / 40
	local ry = pos.Y + 140 * (26 / 40)

	return Vector(rx + 13*13, ry + 7*13)
end

local achievement_paper_queue={["HEAD"]=1,["TAIL"]=1}
local achievement_frame_count=0
local achievement_frame_state=0
local achievement_paper_in_sound=true
local achievement_paper_out_sound=true

function mod:RenderAchievements()
	if Game():IsPaused() or (ModConfigMenu and ModConfigMenu.IsVisible) then
		return
	end
	if achievement_paper_queue["TAIL"]<achievement_paper_queue["HEAD"] then
		local tmp_sprite=achievement_paper_queue[achievement_paper_queue["TAIL"]]
		if achievement_frame_count<8 then
			if achievement_paper_in_sound then
				SFXManager():Play(17,1.0)
				achievement_paper_in_sound=false
			end
			tmp_sprite:SetFrame("Appear",achievement_frame_count)
		elseif achievement_frame_count<32 then
			tmp_sprite:SetFrame("Idle",(achievement_frame_count-8)%8)
		else
			if achievement_paper_out_sound then
				SFXManager():Play(18,1.0)
				achievement_paper_out_sound=false
			end
			tmp_sprite:SetFrame("Disappear",achievement_frame_count-32)
		end
		tmp_sprite:Render(getScreenCenter(),Vector(0,0),Vector(0,0))
		achievement_frame_state=(achievement_frame_state+1)%2
		if achievement_frame_state==0 then
			achievement_frame_count=achievement_frame_count+1
			if achievement_frame_count==40 then
				achievement_paper_queue[achievement_paper_queue["TAIL"]]=nil
				achievement_paper_queue["TAIL"]=achievement_paper_queue["TAIL"]+1
				achievement_frame_count=0
				achievement_paper_in_sound=true
				achievement_paper_out_sound=true
			end
		end
	else
		achievement_paper_in_sound=true
		achievement_paper_out_sound=true
	end
end

mod:AddPriorityCallback(ModCallbacks.MC_POST_RENDER, CallbackPriority.LATE, mod.RenderAchievements)

---@param achname string
function mod:showAchievement(achname)
	local tmp_sprite=Sprite()
	local achstring=tostring(achname)
	tmp_sprite:Load("gfx/green_achievement.anm2",false)
	tmp_sprite:ReplaceSpritesheet(3,"gfx/achievements/"..achstring..".png")
	tmp_sprite:LoadGraphics()
	achievement_paper_queue[achievement_paper_queue["HEAD"]]=tmp_sprite
	achievement_paper_queue["HEAD"]=achievement_paper_queue["HEAD"]+1
end
--#endregion

local playerTypeToTable = {
    [Isaac.GetPlayerTypeByName("Green Isaac", false)] = "ISAAC",
    [Isaac.GetPlayerTypeByName("Green Isaac", true)] = "ISAAC_B",
    [Isaac.GetPlayerTypeByName("Green Cain", false)] = "CAIN",
    [Isaac.GetPlayerTypeByName("Green Cain", true)] = "CAIN_B",
    [Isaac.GetPlayerTypeByName("Green Maggie", false)] = "MAGGY",
    [Isaac.GetPlayerTypeByName("Green Maggie", true)] = "MAGGY_B",
}
---@param playerType number
local function getPlayerUnlockTable(playerType)
    local unlockKey = playerTypeToTable[playerType]
    if(not unlockKey) then return nil end

    if(string.sub(unlockKey, -2)=="_B") then unlockKey = string.sub(unlockKey, 0, -3) end
    return unlockKey
end
---@param playerType number
local function getUnlockSubTable(playerType)
    local unlockKey = playerTypeToTable[playerType]
    if(not unlockKey) then return nil end

    if(string.sub(unlockKey, -2)=="_B") then return "B" end
    return "A"
end

--#region UNLOCK_LOGIC
local lambDead = false
local blueBabyDead = false

function mod:beastUnlock(entity)
    if(not (Game():GetVictoryLap()==0 and entity.Variant==0)) then return end
	for i = 0, Game():GetNumPlayers()-1 do
        local unlock = "Beast"
        local playerTable = getPlayerUnlockTable(Isaac.GetPlayer(i):GetPlayerType())
        if(playerTable==nil) then goto invalid end
        local playerSubTable = getUnlockSubTable(Isaac.GetPlayer(i):GetPlayerType())
        if(mod.MARKS.CHARACTERS[playerTable][playerSubTable][unlock]==1) then goto invalid end
        mod.MARKS.CHARACTERS[playerTable][playerSubTable][unlock]=1

        local achTable = mod.UNLOCKS.CHARACTERS[playerTable][playerSubTable][unlock].ACHIEVEMENT
        for _, achievement in ipairs(achTable) do
            mod:showAchievement(achievement)
        end
        ::invalid::
	end
end
mod:AddCallback(ModCallbacks.MC_POST_ENTITY_KILL, mod.beastUnlock, EntityType.ENTITY_BEAST)

function mod:unlocks1(npc)
    if(Game():GetVictoryLap()~=0) then return end
	for i = 0, Game():GetNumPlayers() - 1 do
		local player = Isaac.GetPlayer(i)
		local stage = Game():GetLevel()

		if(Game():GetVictoryLap()==0) then
			if(stage:GetStage()==LevelStage.STAGE5) then --Isaac and Satan unlocks
				if(npc.Type==EntityType.ENTITY_ISAAC) then
                    local unlock = "Isaac"
                    local playerTable = getPlayerUnlockTable(Isaac.GetPlayer(i):GetPlayerType())
                    if(playerTable==nil) then goto invalid end
                    local playerSubTable = getUnlockSubTable(Isaac.GetPlayer(i):GetPlayerType())
                    if(mod.MARKS.CHARACTERS[playerTable][playerSubTable][unlock]==1) then goto invalid end
                    mod.MARKS.CHARACTERS[playerTable][playerSubTable][unlock]=1

                    local achTable = mod.UNLOCKS.CHARACTERS[playerTable][playerSubTable][unlock].ACHIEVEMENT
                    for _, achievement in ipairs(achTable) do
                        mod:showAchievement(achievement)
                    end
                    ::invalid::
				elseif(npc.Type==EntityType.ENTITY_SATAN) then
                    local unlock = "Satan"
                    local playerTable = getPlayerUnlockTable(Isaac.GetPlayer(i):GetPlayerType())
                    if(playerTable==nil) then goto invalid end
                    local playerSubTable = getUnlockSubTable(Isaac.GetPlayer(i):GetPlayerType())
                    if(mod.MARKS.CHARACTERS[playerTable][playerSubTable][unlock]==1) then goto invalid end
                    mod.MARKS.CHARACTERS[playerTable][playerSubTable][unlock]=1

                    local achTable = mod.UNLOCKS.CHARACTERS[playerTable][playerSubTable][unlock].ACHIEVEMENT
                    for _, achievement in ipairs(achTable) do
                        mod:showAchievement(achievement)
                    end
                    ::invalid::
				end
			elseif(stage:GetStage()==LevelStage.STAGE6) then --Blue Baby, the Lamb, and Mega Satan unlocks
				if(npc.Type==EntityType.ENTITY_ISAAC and npc.Variant==1) then
					blueBabyDead = true
				elseif(npc.Type==EntityType.ENTITY_THE_LAMB) then
					lambDead = true
				elseif(npc.Type==EntityType.ENTITY_MEGA_SATAN_2) then
                    local unlock = "MegaSatan"
                    local playerTable = getPlayerUnlockTable(Isaac.GetPlayer(i):GetPlayerType())
                    if(playerTable==nil) then goto invalid end
                    local playerSubTable = getUnlockSubTable(Isaac.GetPlayer(i):GetPlayerType())
                    if(mod.MARKS.CHARACTERS[playerTable][playerSubTable][unlock]==1) then goto invalid end
                    mod.MARKS.CHARACTERS[playerTable][playerSubTable][unlock]=1

                    local achTable = mod.UNLOCKS.CHARACTERS[playerTable][playerSubTable][unlock].ACHIEVEMENT
                    for _, achievement in ipairs(achTable) do
                        mod:showAchievement(achievement)
                    end
                    ::invalid::
				end
			elseif(stage:GetStage()==LevelStage.STAGE7 and npc.Type==EntityType.ENTITY_DELIRIUM) then --Delirium unlocks
                local unlock = "Delirium"
                local playerTable = getPlayerUnlockTable(Isaac.GetPlayer(i):GetPlayerType())
                if(playerTable==nil) then goto invalid end
                local playerSubTable = getUnlockSubTable(Isaac.GetPlayer(i):GetPlayerType())
                if(mod.MARKS.CHARACTERS[playerTable][playerSubTable][unlock]==1) then goto invalid end
                mod.MARKS.CHARACTERS[playerTable][playerSubTable][unlock]=1

                local achTable = mod.UNLOCKS.CHARACTERS[playerTable][playerSubTable][unlock].ACHIEVEMENT
                for _, achievement in ipairs(achTable) do
                    mod:showAchievement(achievement)
                end
                ::invalid::
			elseif((stage:GetStage()==LevelStage.STAGE4_1 or stage:GetStage()==LevelStage.STAGE4_2) and npc.Type==EntityType.ENTITY_MOTHER and npc.Variant==10) then --Mother unlocks
                local unlock = "Mother"
                local playerTable = getPlayerUnlockTable(Isaac.GetPlayer(i):GetPlayerType())
                if(playerTable==nil) then goto invalid end
                local playerSubTable = getUnlockSubTable(Isaac.GetPlayer(i):GetPlayerType())
                if(mod.MARKS.CHARACTERS[playerTable][playerSubTable][unlock]==1) then goto invalid end
                mod.MARKS.CHARACTERS[playerTable][playerSubTable][unlock]=1

                local achTable = mod.UNLOCKS.CHARACTERS[playerTable][playerSubTable][unlock].ACHIEVEMENT
                for _, achievement in ipairs(achTable) do
                    mod:showAchievement(achievement)
                end
                ::invalid::
            end
		end
	end
end
mod:AddCallback(ModCallbacks.MC_POST_NPC_DEATH, mod.unlocks1)

function mod:unlocks2()
	for i = 0, Game():GetNumPlayers() - 1 do
		local player = Isaac.GetPlayer(i)
		local room = Game():GetRoom()
		local stage = Game():GetLevel()
        if(Game():GetVictoryLap()==0) then
            if(stage:GetStage() == LevelStage.STAGE6 and room:GetType() == RoomType.ROOM_BOSS and room:IsClear()) then
                if blueBabyDead then
                    local unlock = "BlueBaby"
                    local playerTable = getPlayerUnlockTable(Isaac.GetPlayer(i):GetPlayerType())
                    if(playerTable==nil) then goto invalid end
                    local playerSubTable = getUnlockSubTable(Isaac.GetPlayer(i):GetPlayerType())
                    if(mod.MARKS.CHARACTERS[playerTable][playerSubTable][unlock]==1) then goto invalid end
                    mod.MARKS.CHARACTERS[playerTable][playerSubTable][unlock]=1

                    local achTable = mod.UNLOCKS.CHARACTERS[playerTable][playerSubTable][unlock].ACHIEVEMENT
                    for _, achievement in ipairs(achTable) do
                        mod:showAchievement(achievement)
                    end
                    blueBabyDead=false
                    ::invalid::
                elseif lambDead then
                    local unlock = "Lamb"
                    local playerTable = getPlayerUnlockTable(Isaac.GetPlayer(i):GetPlayerType())
                    if(playerTable==nil) then goto invalid end
                    local playerSubTable = getUnlockSubTable(Isaac.GetPlayer(i):GetPlayerType())
                    if(mod.MARKS.CHARACTERS[playerTable][playerSubTable][unlock]==1) then goto invalid end
                    mod.MARKS.CHARACTERS[playerTable][playerSubTable][unlock]=1

                    local achTable = mod.UNLOCKS.CHARACTERS[playerTable][playerSubTable][unlock].ACHIEVEMENT
                    for _, achievement in ipairs(achTable) do
                        mod:showAchievement(achievement)
                    end
                    lambDead=false
                    ::invalid::
                end
            end
            --Boss rush unlocks
            if(Game():GetStateFlag(GameStateFlag.STATE_BOSSRUSH_DONE)
            and(stage:GetStage()==LevelStage.STAGE3_1 or stage:GetStage()==LevelStage.STAGE3_2)) then
                local unlock = "BossRush"
                local playerTable = getPlayerUnlockTable(Isaac.GetPlayer(i):GetPlayerType())
                if(playerTable==nil) then goto invalid end
                local playerSubTable = getUnlockSubTable(Isaac.GetPlayer(i):GetPlayerType())
                if(mod.MARKS.CHARACTERS[playerTable][playerSubTable][unlock]==1) then goto invalid end
                mod.MARKS.CHARACTERS[playerTable][playerSubTable][unlock]=1

                local achTable = mod.UNLOCKS.CHARACTERS[playerTable][playerSubTable][unlock].ACHIEVEMENT
                for _, achievement in ipairs(achTable) do
                    mod:showAchievement(achievement)
                end
                ::invalid::
            end
            --Hush unlocks
            if(Game():GetStateFlag(GameStateFlag.STATE_BLUEWOMB_DONE)
            and stage:GetStage()==LevelStage.STAGE4_3) then
                local unlock = "Hush"
                local playerTable = getPlayerUnlockTable(Isaac.GetPlayer(i):GetPlayerType())
                if(playerTable==nil) then goto invalid end
                local playerSubTable = getUnlockSubTable(Isaac.GetPlayer(i):GetPlayerType())
                if(mod.MARKS.CHARACTERS[playerTable][playerSubTable][unlock]==1) then goto invalid end
                mod.MARKS.CHARACTERS[playerTable][playerSubTable][unlock]=1

                local achTable = mod.UNLOCKS.CHARACTERS[playerTable][playerSubTable][unlock].ACHIEVEMENT
                for _, achievement in ipairs(achTable) do
                    mod:showAchievement(achievement)
                end
                ::invalid::
            end
        end
        --Greed and greedier unlocks
        if(Game():IsGreedMode() and stage:GetStage()==LevelStage.STAGE7_GREED) then
            if(room:GetRoomShape()==RoomShape.ROOMSHAPE_1x2 and room:IsClear()) then
                if Game().Difficulty == Difficulty.DIFFICULTY_GREED then
                    local unlock = "UltraGreed"
                    local playerTable = getPlayerUnlockTable(Isaac.GetPlayer(i):GetPlayerType())
                    if(playerTable==nil) then goto invalid end
                    local playerSubTable = getUnlockSubTable(Isaac.GetPlayer(i):GetPlayerType())
                    if(mod.MARKS.CHARACTERS[playerTable][playerSubTable][unlock]==1) then goto invalid end
                    mod.MARKS.CHARACTERS[playerTable][playerSubTable][unlock]=1

                    local achTable = mod.UNLOCKS.CHARACTERS[playerTable][playerSubTable][unlock].ACHIEVEMENT
                    for _, achievement in ipairs(achTable) do
                        mod:showAchievement(achievement)
                    end
                    ::invalid::
                elseif Game().Difficulty == Difficulty.DIFFICULTY_GREEDIER then
                    local unlock = "UltraGreed"
                    local playerTable = getPlayerUnlockTable(Isaac.GetPlayer(i):GetPlayerType())
                    local achTable = {}
                    if(playerTable==nil) then goto invalid end
                    local playerSubTable = getUnlockSubTable(Isaac.GetPlayer(i):GetPlayerType())
                    if(mod.MARKS.CHARACTERS[playerTable][playerSubTable][unlock]==1) then goto greedInvalid end
                    mod.MARKS.CHARACTERS[playerTable][playerSubTable][unlock]=1

                    achTable = mod.UNLOCKS.CHARACTERS[playerTable][playerSubTable][unlock].ACHIEVEMENT
                    for _, achievement in ipairs(achTable) do
                        mod:showAchievement(achievement)
                    end
                    ::greedInvalid::

                    unlock="UltraGreedier"
                    if(mod.MARKS.CHARACTERS[playerTable][playerSubTable][unlock]==1) then goto invalid end
                    mod.MARKS.CHARACTERS[playerTable][playerSubTable][unlock]=1

                    achTable = mod.UNLOCKS.CHARACTERS[playerTable][playerSubTable][unlock].ACHIEVEMENT
                    for _, achievement in ipairs(achTable) do
                        mod:showAchievement(achievement)
                    end
                    ::invalid::
                end
            end
        end
    end
end
mod:AddCallback(ModCallbacks.MC_POST_UPDATE, mod.unlocks2)

--#endregion

function mod:dataSaveInit(player)
    local data = player:GetData()

    if(Game():GetFrameCount()==0) then
        for key, val in pairs(mod.BASEVALUES) do
            if(type(val)=="table") then
                data[key]=cloneTable(val)
            else
                data[key]=val
            end
        end
    else
        if(mod:HasData()) then
            local save = json.decode(mod:LoadData())
            local iData = save.itemData[""..player:GetCollectibleRNG(273):GetSeed()]
            if(iData) then
                for key, val in pairs(iData) do
                    data[key]=val
                end
            end
        end
    end
end
mod:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT, mod.dataSaveInit, 0)

function mod:postGameStartedLoadData(isCont)
    if(mod:HasData()) then
        local save = json.decode(mod:LoadData())
        if(save.unlockData~=nil) then
            mod.MARKS = save.unlockData
        end
    end
    isDataLoaded = true
end
mod:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, mod.postGameStartedLoadData)

--#region LOCKED_ITEM_LOGIC
local itemPool = Game():GetItemPool()
local itemConfig = Isaac.GetItemConfig()

--#region COLLECTIBLE_LOGIC
function mod:rerollLockedCollectiblePickup(pickup)
    if not isDataLoaded then return end

    for character, unlockTable in pairs(mod.UNLOCKS.CHARACTERS) do
        for side, subUnlockTable in pairs(unlockTable) do
            for mark, unlock in pairs(subUnlockTable) do
                if(mod.MARKS.CHARACTERS[character][side][mark]==1) then goto unlocked end
                if(not ((unlock.TYPE=="COLLECTIBLE" or unlock.TYPE=="VEGETABLE") and unlock.ID>0 and pickup.SubType==unlock.ID)) then goto invalidItem end

                pickup:Morph(pickup.Type, pickup.Variant, 0, true, true)

                ::unlocked:: ::invalidItem::
            end
        end
    end
end
mod:AddCallback(ModCallbacks.MC_POST_PICKUP_INIT, mod.rerollLockedCollectiblePickup, PickupVariant.PICKUP_COLLECTIBLE)

local function getActiveSlotForItem(player, collectibleType)
    for _, activeSlot in pairs(ActiveSlot) do
        if player:GetActiveItem(activeSlot) == collectibleType then
            return activeSlot
        end
    end

    return nil
end

local maxTries = 100
local function getItemConfigOfSameType(collectibleType)
    local itemType = itemConfig:GetCollectible(collectibleType).Type

    local tries = 0
    while tries < maxTries do
        local chosenCollectible = itemPool:GetCollectible(ItemPoolType.POOL_TREASURE, false, Random(), CollectibleType.COLLECTIBLE_BREAKFAST)
        local collectibleConfig = itemConfig:GetCollectible(chosenCollectible)

        if collectibleConfig.Type == itemType then
            return collectibleConfig
        else
            tries = tries + 1
        end
    end

    return itemConfig:GetCollectible(CollectibleType.COLLECTIBLE_BREAKFAST)
end

local function replaceCollectible(player, collectibleType)
    for _ = 1, player:GetCollectibleNum(collectibleType) do
        local activeSlot = getActiveSlotForItem(player, collectibleType)
        player:RemoveCollectible(collectibleType)

        local collectibleConfig = getItemConfigOfSameType(collectibleType)
        player:AddCollectible(collectibleConfig.ID, collectibleConfig.MaxCharges, true, activeSlot)
    end
end

function mod:replaceLockedCollectibles(player)
    if not isDataLoaded then return end

    for character, unlockTable in pairs(mod.UNLOCKS.CHARACTERS) do
        for side, subUnlockTable in pairs(unlockTable) do
            for mark, unlock in pairs(subUnlockTable) do
                if(mod.MARKS.CHARACTERS[character][side][mark]==1) then goto unlocked end
                if(not (unlock.TYPE=="COLLECTIBLE" or unlock.TYPE=="VEGETABLE")) then goto invalidItem end
                if(unlock.ID<=0) then goto invalidItem end
                if(player:GetPlayerType()==Isaac.GetPlayerTypeByName("Green Isaac", false) and unlock.ID==mod.ENUMS.ITEMS.G6) then goto invalidItem end

                if(player:HasCollectible(unlock.ID)) then
                    replaceCollectible(player, unlock.ID)
                    print("Replaced locked item!")
                end

                ::unlocked:: ::invalidItem::
            end
        end
    end
end
mod:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, mod.replaceLockedCollectibles, 0)
--#endregion

--#region TRINKET_LOGIC
function mod:rerollLockedTrinketPickup(pickup)
    if not isDataLoaded then return end

    for character, unlockTable in pairs(mod.UNLOCKS.CHARACTERS) do
        for side, subUnlockTable in pairs(unlockTable) do
            for mark, unlock in pairs(subUnlockTable) do
                if(mod.MARKS.CHARACTERS[character][side][mark]==1) then goto unlocked end
                if(not (unlock.TYPE=="TRINKET" and unlock.ID>0 and pickup.SubType==unlock.ID)) then goto invalidItem end

                pickup:Morph(pickup.Type, pickup.Variant, 0, true, true)

                ::unlocked:: ::invalidItem::
            end
        end
    end
end
mod:AddCallback(ModCallbacks.MC_POST_PICKUP_INIT, mod.rerollLockedTrinketPickup, PickupVariant.PICKUP_TRINKET)

local function replaceTrinket(player, trinketType)
    if not player:TryRemoveTrinket(trinketType) then return end
    player:AddTrinket(itemPool:GetTrinket(false))
end

function mod:replaceLockedTrinkets(player)
    if not isDataLoaded then return end

    for character, unlockTable in pairs(mod.UNLOCKS.CHARACTERS) do
        for side, subUnlockTable in pairs(unlockTable) do
            for mark, unlock in pairs(subUnlockTable) do
                if(mod.MARKS.CHARACTERS[character][side][mark]==1) then goto unlocked end
                if(not (unlock.TYPE=="TRINKET" and unlock.ID>0 and player:HasTrinket(unlock.ID))) then goto invalidItem end

                replaceTrinket(player, unlock.ID)

                ::unlocked:: ::invalidItem::
            end
        end
    end
end
mod:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, mod.replaceLockedTrinkets, 0)
--#endregion
--#endregion

local f = Font()
f:Load("font/pftempestasevencondensed.fnt")

function mod:postRender()
    local marks = mod.MARKS.CHARACTERS.ISAAC.A
    local yPos = 200
    Isaac.RenderScaledText("Isaac: " .. marks.Isaac, 25, yPos, 0.75, 0.75, 1,1,1,1)
    Isaac.RenderScaledText("Blue Baby: " .. marks.BlueBaby, 25, yPos+10, 0.75, 0.75, 1,1,1,1)
    Isaac.RenderScaledText("Satan: " .. marks.Satan, 25, yPos+20, 0.75, 0.75, 1,1,1,1)
    Isaac.RenderScaledText("The Lamb: " .. marks.Lamb, 25, yPos+30, 0.75, 0.75, 1,1,1,1)
    Isaac.RenderScaledText("Boss Rush: " .. marks.BossRush, 25, yPos+40, 0.75, 0.75, 1,1,1,1)
    Isaac.RenderScaledText("Hush: " .. marks.Hush, 25, yPos+50, 0.75, 0.75, 1,1,1,1)
    Isaac.RenderScaledText("Mega Satan: " .. marks.MegaSatan, 25, yPos+60, 0.75, 0.75, 1,1,1,1)
    Isaac.RenderScaledText("Delirium: " .. marks.Delirium, 25, yPos+70, 0.75, 0.75, 1,1,1,1)
    Isaac.RenderScaledText("Mother: " .. marks.Mother, 25, yPos+80, 0.75, 0.75, 1,1,1,1)
    Isaac.RenderScaledText("Beast: " .. marks.Beast, 25, yPos+90, 0.75, 0.75, 1,1,1,1)
    Isaac.RenderScaledText("Ultra Greed: " .. marks.UltraGreed, 25, yPos+100, 0.75, 0.75, 1,1,1,1)
    Isaac.RenderScaledText("Ultra Greedier: " .. marks.UltraGreedier, 25, yPos+110, 0.75, 0.75, 1,1,1,1)
end
--mod:AddCallback(ModCallbacks.MC_POST_RENDER, mod.postRender)