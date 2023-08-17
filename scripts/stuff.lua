local mod = jezreelMod

--#region ETERNITY_MODE_IN_ISAAC

local RANDOM_ROT = 90
local ADD_PROJ_NUM = 1

---@param proj EntityProjectile
local function postProjectileInit(_, proj)
    if(proj.FrameCount~=1) then return end

    if(proj:GetData().isDouble) then return end

    for i=1, ADD_PROJ_NUM do
        local rng = proj:GetDropRNG()
        local newProj = Isaac.Spawn(proj.Type, proj.Variant, proj.SubType, proj.Position, proj.Velocity:Rotated((rng:RandomFloat()-0.5)*RANDOM_ROT/2), proj.SpawnerEntity):ToProjectile()
        newProj.FallingAccel = proj.FallingAccel
        newProj.FallingSpeed = proj.FallingSpeed
        newProj.ProjectileFlags = proj.ProjectileFlags

        for key, val in pairs(proj:GetData()) do
            newProj:GetData()[key] = val
        end
        newProj:GetData().isDouble = true
    end
end
mod:AddCallback(ModCallbacks.MC_POST_PROJECTILE_UPDATE, postProjectileInit)

--#endregion


--#region AWESOME_RENDERING

local RENDER_NUM = 19
local ALPHA_MOD = 4/5

local function renderPlayer(player, pos)
    player:RenderShadowLayer(pos)
    player:RenderGlow(pos)
    player:RenderBody(pos)
    player:RenderHead(pos)
    player:RenderTop(pos)
end

---@param player EntityPlayer
local function postPlayerInit(_, player, offset)
    local data = player:GetData()

    if(not data.rendered) then data.rendered = 0 end

    local renderPos = Isaac.WorldToRenderPosition(player.Position)+offset
    local posOffset = Vector(2,1)

    local baseCol = player.Color

    local DIR_RENDERS = 8

    for j=1,DIR_RENDERS do
        for i=1, RENDER_NUM-1 do
            local oldColor = player.Color
            oldColor.A = oldColor.A * ALPHA_MOD^i
            player:SetColor(oldColor, 0, i, false, true)

            local newOffset = posOffset*i
            newOffset = newOffset:Rotated(j*360/DIR_RENDERS + i*10 + player.FrameCount*5)

            renderPlayer(player, renderPos+newOffset)

            player.Color = baseCol
        end
    end

    player.Color = baseCol
end
mod:AddCallback(ModCallbacks.MC_POST_PLAYER_RENDER, postPlayerInit)

--#endregion