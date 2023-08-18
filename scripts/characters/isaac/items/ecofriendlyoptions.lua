local mod = jezreelMod
local h = include("scripts/func")

local ecoFriendlyOptions = mod.ENUMS.VEGETABLES.ECO_FRIENDLY_OPTIONS

local funcs = {}

local function getNextFreeOptionsIndex()
    local maxOptionsIndex = 0
    for i, pickup in pairs(Isaac.FindInRadius(Game():GetRoom():GetCenterPos(), 600, EntityPartition.PICKUP)) do
        maxOptionsIndex = math.max(maxOptionsIndex, pickup:ToPickup().OptionsPickupIndex)
    end

    return maxOptionsIndex+1
end

---@param pickup EntityPickup
function funcs:postPickupInit(pickup)
    local room = Game():GetRoom()
    if(not (room:IsFirstVisit() and room:GetType()==RoomType.ROOM_TREASURE)) then return end
    if(not h:anyPlayerHas(ecoFriendlyOptions)) then return end
    if(mod:isGreenItem(pickup)) then return end

    local rng = Isaac.GetPlayer():GetCollectibleRNG(ecoFriendlyOptions)

    if(pickup.OptionsPickupIndex==0) then pickup.OptionsPickupIndex=getNextFreeOptionsIndex() end

    local spawnPos = pickup.Position+Vector(0,40)
    spawnPos = room:FindFreePickupSpawnPosition(spawnPos, 0)

    local newPickup = Isaac.Spawn(5,100,mod:getGreenItem(rng),spawnPos,Vector.Zero,pickup):ToPickup()
    newPickup.OptionsPickupIndex = pickup.OptionsPickupIndex
end
mod:AddCallback(ModCallbacks.MC_POST_PICKUP_INIT, funcs.postPickupInit, PickupVariant.PICKUP_COLLECTIBLE)

mod.ITEMS.ECOFRIENDLYOPTIONS = funcs