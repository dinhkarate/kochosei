require("behaviours/chaseandattack")
require("behaviours/leash")
require("behaviours/wander")
require("behaviours/follow")
require("behaviours/doaction")
local kochodragonflybrain = Class(Brain, function(self, inst)
	Brain._ctor(self, inst)
end)

local MIN_FOLLOW_DIST = 0
local TARGET_FOLLOW_DIST = 20
local MAX_FOLLOW_DIST = 20
local function GetFaceTargetFn(inst)
	return inst.components.follower.leader
end

local function KeepFaceTargetFn(inst, target)
	return inst.components.follower.leader == target
end

local function GetLeader(inst)
	return inst.components.follower.leader
end
local function GetLeaderPos(inst)
	return inst.components.follower.leader:GetPosition()
end
function kochodragonflybrain:OnStart()
	local root = PriorityNode({
		ChaseAndAttack(self.inst),
		Follow(self.inst, GetLeader, MIN_FOLLOW_DIST, TARGET_FOLLOW_DIST, MAX_FOLLOW_DIST),

		Wander(self.inst, GetLeaderPos, MAX_FOLLOW_DIST),

		WhileNode(function()
			return GetLeader(self.inst) ~= nil
		end, "Has Leader", FaceEntity(self.inst, GetFaceTargetFn, KeepFaceTargetFn)),
	}, 0.25)
	self.bt = BT(self.inst, root)
end

return kochodragonflybrain
