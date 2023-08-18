local mod = jezreelMod
local h = include("scripts/func")
local sfx = SFXManager()

local scallion = mod.ENUMS.VEGETABLES.SCALLION
local scallionVar = Isaac.GetEntityVariantByName("Scallion Head")

local SCALLION_TEARS_NUM = 30
local SCALLION_TEARS_SPEED = 15
local SCALLION_HORSE_SFX = Isaac.GetSoundIdByName("ScallionNeigh")
sfx:Preload(SCALLION_HORSE_SFX)

local funcs = {}

---@param player EntityPlayer
function funcs:useItem(_, rng, player, _, _, _)
    local room = Game():GetRoom()
    local vertClamps = {Top=room:GetTopLeftPos().Y, Bottom=room:GetBottomRightPos().Y}
    local horiClamps = {Left=room:GetTopLeftPos().X-124, Right=room:GetBottomRightPos().X+124}

    local isLeft = true
    if(player.Position.X>room:GetCenterPos().X) then isLeft=false end

    local tearVel = Vector.FromAngle((isLeft and 0) or 180)*SCALLION_TEARS_SPEED

    local tearsNum = SCALLION_TEARS_NUM
    for i=1, tearsNum do
        local vel = tearVel*(rng:RandomFloat()*0.5+1)

        local randPos = Vector((isLeft and horiClamps.Left) or horiClamps.Right, vertClamps.Top)
        randPos = randPos+Vector(rng:RandomFloat()*24*((isLeft and 1) or -1), (i/tearsNum)*(vertClamps.Bottom-vertClamps.Top))
        local tear = player:FireTear(randPos, vel, true, true, false, player)
        tear:ChangeVariant(scallionVar)

        tear.Velocity = vel
    end

    sfx:Play(SCALLION_HORSE_SFX)

    return {
        Discharge=true,
        Remove=false,
        ShowAnim=true,
    }
end
mod:AddCallback(ModCallbacks.MC_USE_ITEM, funcs.useItem, scallion)

function funcs:postTearUpdate(tear)
    local room = Game():GetRoom()

    if(room:IsPositionInRoom(tear.Position,0)) then
        if(tear.FrameCount%5==0) then
            local tear2 = Isaac.Spawn(EntityType.ENTITY_TEAR, 0, 0, tear.Position,Vector.Zero,tear):ToTear()
            tear2.CollisionDamage = 7

            tear2.Color = Color(0.3,0.6,0.2,1,0,0,0)
        end
    else
        local horiClamps = {Left=room:GetTopLeftPos().X-174, Right=room:GetBottomRightPos().X+174}

        if((h:sign(tear.Velocity.X)>=0 and tear.Position.X>horiClamps.Right) or tear.Position.X<horiClamps.Left) then
            tear:Remove()
        end
    end

    if(tear.FrameCount~=1) then return end
    tear.FallingSpeed = 0
    tear.FallingAcceleration = -0.1
    tear.Height = -25
    tear.TearFlags = TearFlags.TEAR_PIERCING | TearFlags.TEAR_SPECTRAL
    tear.CollisionDamage = 7
    tear.Color = Color(1,1,1)

    if(h:sign(tear.Velocity.X)<0) then tear:GetSprite().FlipX=true end

    tear:GetSprite():Play("Idle", true)
end
mod:AddCallback(ModCallbacks.MC_POST_TEAR_UPDATE, funcs.postTearUpdate, scallionVar)

---@param player EntityPlayer
function funcs:evaluateCache(player, flag)
    if(not player:HasCollectible(scallion)) then return end

    if(flag & CacheFlag.CACHE_SPEED == CacheFlag.CACHE_SPEED) then
        player.MoveSpeed = math.max(player.MoveSpeed, 1.25)
    end
    if(flag & CacheFlag.CACHE_FLYING == CacheFlag.CACHE_FLYING) then
        player.CanFly = true
    end
end
mod:AddPriorityCallback(ModCallbacks.MC_EVALUATE_CACHE, CallbackPriority.IMPORTANT, funcs.evaluateCache)

mod.ITEMS.SCALLION = funcs