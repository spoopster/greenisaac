local mod = jezreelMod
local sfx = SFXManager()

local urielsHand = mod.ENUMS.VEGETABLES.URIELS_HAND

local LASER_PISS_NUM = 6
local LASER_ANGLE_OFFSET = 30
local PISS_RAND_ANGLE = 40
local PISS_DISTANCE = Vector(15,0)

local DOGMA_LASER = SoundEffect.SOUND_DOGMA_LIGHT_RAY_FIRE
sfx:Preload(DOGMA_LASER)

local funcs = {}

---@param player EntityPlayer
function funcs:useItem(_, rng, player, flags, _, _)
    local angleOffset = 0
    if(flags & UseFlag.USE_CARBATTERY ~= 0) then angleOffset = 360/(LASER_PISS_NUM*2) end

    for i=1, LASER_PISS_NUM do
        local angle = i*360/LASER_PISS_NUM+90+LASER_ANGLE_OFFSET+angleOffset
        local laser = EntityLaser.ShootAngle(2, player.Position, angle, 30, Vector.Zero, player)
        laser.Color = Color(0,0,0,1,0.75,0.75,0.25)
        laser.CollisionDamage = 12

        local distToAdd = PISS_DISTANCE:Rotated(angle)
        local pos = player.Position+distToAdd
        while(Game():GetRoom():IsPositionInRoom(pos, 0)) do
            local piss = Isaac.Spawn(1000, EffectVariant.PLAYER_CREEP_RED, 0, pos, Vector.Zero, player):ToEffect()
            piss.Color = Color(0,0,0,1,1,1,0.33)
            piss.Scale = 0.5
            piss.CollisionDamage = 6
            piss.Timeout = 10

            piss:Update()

            pos = pos+distToAdd:Rotated((rng:RandomFloat()-0.5)*PISS_RAND_ANGLE)
        end
    end

    sfx:Play(DOGMA_LASER)
    local lightBeam = Isaac.Spawn(1000, EffectVariant.CRACK_THE_SKY, 0, player.Position+Vector(0,1), Vector.Zero, player)
    for i=1, 5 do lightBeam:Update() end

    return {
        Discharge=true,
        Remove=false,
        ShowAnim=true,
    }
end
mod:AddCallback(ModCallbacks.MC_USE_ITEM, funcs.useItem, urielsHand)

mod.ITEMS.URIELSHAND = funcs