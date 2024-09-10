require "behaviours/wander"
require "behaviours/runaway"
require "behaviours/doaction"

local MAX_IDLE_WANDER_DIST = 30

local MAX_CHASE_TIME = 10
local GIVE_UP_DIST = 20
local MAX_CHARGE_DIST = 60

local DO_ACTIONS_DISTANCE = 30

local FOOD_TAGS = {"edible"}
local NO_TAGS = {"FX", "NOCLICK", "DECOR", "INLIMBO", "kittenchow"}

local KochoseiDukeBrain = Class(Brain, function(self, inst)
    Brain._ctor(self, inst)
end)

local wandertimes =
{
    minwalktime = 6,
    randwalktime =  6,
    minwaittime = 5,
    randwaittime = 5,
}

--[[
    intended behaviour cases:

    -defend children from baddies
        -aggressive if player is near home
    -feed children
        -drop food near them
    -hunt prey near player
        -after doing something near the player, return home
--]]

local function FeedChildrenAction(inst)
    --If you are holding some food and your children are nearby
    --Go over to them and drop the food.

    if GetTime() < inst.NextFeedTime or inst.components.combat.target ~= nil then
        return
    end

    local kittenHerd = inst:FindSharkHome()

    if kittenHerd and inst:GetPosition():Dist(kittenHerd:GetPosition()) < 40 then --children are nearby
        inst.NextFeedTime = GetTime() + 30
        return BufferedAction(inst, kittenHerd, ACTIONS.TIGERSHARK_FEED)
    end
end

local function EatFoodAction(inst)
    local target = nil

    local pt = inst:GetPosition()
    local ents = TheSim:FindEntities(pt.x, pt.y, pt.z, DO_ACTIONS_DISTANCE, FOOD_TAGS, NO_TAGS)

    for _, ent in pairs(ents) do
        if inst.components.eater:CanEat(ent) then
            target = ent
            break
        end
    end

    if target then
        return BufferedAction(inst, target, ACTIONS.EAT)--(PICK UP ACTION)
    end
end

local function GetWanderPoint(inst)
    if inst.components.knownlocations and inst.components.knownlocations:GetLocation("point_of_interest") then
        return inst.components.knownlocations:GetLocation("point_of_interest")
    end

    if inst:FindSharkHome() and inst:GetPosition():Dist(inst:FindSharkHome():GetPosition()) < 40 then
        return inst:FindSharkHome():GetPosition()
    end

    return inst:GetPosition()
end

local function FindWaterAction(inst)
    if inst:HasTag("aquatic") then
        --Don't do anything.
        return nil
    end
    local wateroffset = FindWaterOffset(inst:GetPosition(), math.random() * 2 * math.pi, 30, 36)
    if wateroffset then
        return BufferedAction(inst, nil, ACTIONS.WALKTO, nil, inst:GetPosition() + wateroffset)
    end
end

function KochoseiDukeBrain:OnStart()
    local root = PriorityNode(
    {
        ---- Combat Actions ----
        WhileNode(function() return self.inst.CanRun and self.inst.components.combat.target and
            (distsq(self.inst:GetPosition(), self.inst.components.combat.target:GetPosition()) > 10*10 or self.inst.sg:HasStateTag("running")) end,
                "Charge Behaviours", ChaseAndRam(self.inst, MAX_CHASE_TIME, GIVE_UP_DIST, MAX_CHARGE_DIST)),
        ChaseAndAttack(self.inst),
        ----

        --Run home
       --[[ WhileNode(function() return self.inst.components.health:GetPercent() <= 0.1 end, "Low Health",
            PriorityNode({
                DoAction(self.inst, FindWaterAction, "Go To Water"), --Get into water
                Leash(self.inst, function() return self.inst:FindSharkHome() and self.inst:FindSharkHome():GetPosition() end, 81, 80, true),
            }, 0.25)),--]]

        --DoAction(self.inst, FeedChildrenAction, "Feed Action"),

        DoAction(self.inst, EatFoodAction, "Eat Action"),

        WhileNode(function() return not self.inst.CanFly end, "Wander Behaviours", --Wander around
            Wander(self.inst)),

    }, .25)
    self.bt = BT(self.inst, root)
end

return KochoseiDukeBrain