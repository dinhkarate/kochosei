require("behaviours/chaseandattack")
require("behaviours/wander")
require("behaviours/doaction")
require("behaviours/follow")
local BrainCommon = require("brains/braincommon")
local MIN_FOLLOW_DIST = 0
local TARGET_FOLLOW_DIST = 20
local MAX_FOLLOW_DIST = 20
local wander_times =
{
    minwalktime = 1,
    minwaittime = 1,
}

local DIG_TAGS = { "DIG_workable", "tree" }
local DIG_CANT_TAGS = { "carnivalgame_part", "event_trigger", "waxedplant" }

local function GetLeader(inst)
	return inst.components.follower.leader or nil
end

local function GetLeaderPos(inst)
    local leader = inst.components.follower.leader or nil
    if leader and
	leader:IsValid() then
        return Vector3(leader.Transform:GetWorldPosition() )
    end
end
local function dig_stump_starter(inst,finddist)
    local target = FindEntity(inst, finddist, nil, DIG_TAGS, DIG_CANT_TAGS)
    return inst.stump_target or target or nil
end

local function dig_stump_keepgoing(inst, leaderdist, finddist)
    return inst.stump_target ~= nil
        or (inst.components.follower.leader ~= nil and
            inst:IsNear(inst.components.follower.leader, leaderdist))
end

local function dig_stump_finder(inst, leaderdist, finddist)
    local target = FindEntity(inst, finddist, nil, DIG_TAGS, DIG_CANT_TAGS)
    if target == nil and inst.components.follower.leader ~= nil then
        target = FindEntity(inst.components.follower.leader, finddist, nil, DIG_TAGS, DIG_CANT_TAGS)
    end
    if target ~= nil then
        if inst.stump_target ~= nil then
            target = inst.stump_target
            inst.stump_target = nil
        end

        return BufferedAction(inst, target, ACTIONS.DIG)
    end
end
local KochoBeargerBrain = Class(Brain, function(self, inst)
	Brain._ctor(self, inst)
end)


function KochoBeargerBrain:OnStart()
	local NODES = PriorityNode(
		{
			ChaseAndAttack(self.inst, 10),
			BrainCommon.NodeAssistLeaderDoAction(self, {
				action = "CHOP", -- Required.
				chatterstring = "MERM_TALK_HELP_CHOP_WOOD",
			}),
	
			BrainCommon.NodeAssistLeaderDoAction(self, {
				action = "MINE", -- Required.
				chatterstring = "MERM_TALK_HELP_MINE_ROCK",
			}),
			
			BrainCommon.NodeAssistLeaderDoAction(self, {
				action = "CHOP", -- Required.
				chatterstring = "MERM_TALK_HELP_CHOP_WOOD",
				starter = dig_stump_starter,
                keepgoing = dig_stump_keepgoing,
                finder = dig_stump_finder,
			}),
			Follow(self.inst, function() return self.inst.components.follower.leader end,
				MIN_FOLLOW_DIST, TUNING.ABIGAIL_DEFENSIVE_MED_FOLLOW, MAX_FOLLOW_DIST, true),
			Wander(self.inst, GetLeaderPos, MAX_FOLLOW_DIST)
			}, .25)

    local root = PriorityNode({
        WhileNode(function() return not self.inst.sg:HasStateTag("jumping") end, "pause for jump", NODES)
    }, .25)

    self.bt = BT(self.inst, root)
end

return KochoBeargerBrain
