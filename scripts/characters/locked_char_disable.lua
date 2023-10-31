--KILL THE TAINTED CHARS
local taintedChars = {
    [Isaac.GetPlayerTypeByName("Green Isaac", true)]=true,
    [Isaac.GetPlayerTypeByName("Green Cain", true)]=true,
}

jezreelMod:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT, function(_, player)
	if taintedChars[player:GetPlayerType()] then
		SFXManager():Play(SoundEffect.SOUND_BOSS2INTRO_ERRORBUZZ)
		Game():Fadeout(1, 2)
	end
end)