require("behaviours/chaseandattack")
require("behaviours/wander")
require("behaviours/doaction")
require("behaviours/follow")
local BrainCommon = require("brains/braincommon")

local MIN_FOLLOW_DIST = 0
local MAX_FOLLOW_DIST = 20
local WANDER_DIST = 30

local DIG_TAGS      = { "DIG_workable", "tree" }
local DIG_CANT_TAGS = { "carnivalgame_part", "event_trigger", "waxedplant" }

local function GetLeader(inst)
    return inst.components.follower and inst.components.follower:GetLeader()
end

local function GetLeaderPos(inst)
    local leader = GetLeader(inst)
    if leader and leader:IsValid() then
        return Vector3(leader.Transform:GetWorldPosition())
    end
end

--------------------------------------------------------------------------
-- DIG stump (copy y hệt merm, chỉ chạy khi leader đang dig/chop)

local function dig_stump_starter(inst, finddist)
    local target = FindEntity(inst, finddist, nil, DIG_TAGS, DIG_CANT_TAGS)
    return inst.stump_target or target or nil
end

local function dig_stump_keepgoing(inst, leaderdist, finddist)
    if inst.stump_target then
        return true
    end
    local leader = GetLeader(inst)
    return leader ~= nil and inst:IsNear(leader, leaderdist)
end

local function dig_stump_finder(inst, leaderdist, finddist)
    local target = FindEntity(inst, finddist, nil, DIG_TAGS, DIG_CANT_TAGS)
    if target == nil then
        local leader = GetLeader(inst)
        if leader then
            target = FindEntity(leader, finddist, nil, DIG_TAGS, DIG_CANT_TAGS)
        end
    end
    if target ~= nil then
        if inst.stump_target ~= nil then
            target = inst.stump_target
            inst.stump_target = nil
        end
        return BufferedAction(inst, target, ACTIONS.DIG)
    end
end

--------------------------------------------------------------------------

local KochoBeargerBrain = Class(Brain, function(self, inst)
    Brain._ctor(self, inst)
end)

function KochoBeargerBrain:OnStart()
    local NODES = PriorityNode(
        {
            -- 1. Tấn công
            ChaseAndAttack(self.inst, 10),

            -- 2. CHOP: dùng default starter (chỉ chop khi leader đang chopping)
            BrainCommon.NodeAssistLeaderDoAction(self, {
                action        = "CHOP",
                chatterstring = "MERM_TALK_HELP_CHOP_WOOD",
            }),

            -- 3. DIG stump: chỉ dig khi leader đang dig
            BrainCommon.NodeAssistLeaderDoAction(self, {
                action        = "CHOP",  -- action field chỉ để lookup defaults, finder trả DIG action
                chatterstring = "MERM_TALK_HELP_CHOP_WOOD",
                starter       = dig_stump_starter,
                keepgoing     = dig_stump_keepgoing,
                finder        = dig_stump_finder,
            }),

            -- 4. MINE
            BrainCommon.NodeAssistLeaderDoAction(self, {
                action        = "MINE",
                chatterstring = "MERM_TALK_HELP_MINE_ROCK",
            }),

            -- 5. Follow leader
            Follow(self.inst, function() return GetLeader(self.inst) end,
                MIN_FOLLOW_DIST, TUNING.ABIGAIL_DEFENSIVE_MED_FOLLOW, MAX_FOLLOW_DIST, true),

            -- 6. Wander quanh leader
            Wander(self.inst, GetLeaderPos, WANDER_DIST),
        }, .25)

    local root = PriorityNode({
        WhileNode(function() return not self.inst.sg:HasStateTag("jumping") end, "pause for jump", NODES)
    }, .25)

    self.bt = BT(self.inst, root)
end

return KochoBeargerBrain
