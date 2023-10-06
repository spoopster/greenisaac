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