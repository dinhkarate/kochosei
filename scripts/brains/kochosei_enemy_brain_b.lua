require("behaviours/faceentity")
require("behaviours/follow")

local kochosei_enemy_brain_b = Class(Brain, function(self, inst)
	Brain._ctor(self, inst)
end)

local MIN_FOLLOW_DIST = 0
local TARGET_FOLLOW_DIST = 6
local MAX_FOLLOW_DIST = 8

local START_FACE_DIST = 6
local KEEP_FACE_DIST = 8

local KEEP_WORKING_DIST = 14

local KEEP_DANCING_DIST = 3

local DIG_TAGS = { "stump", "grave", "farm_debris", "snowpile" }
local CHOP_TAGS = { "evergreens", "deciduoustree" }

local function GetLeader(inst)
	return inst.components.follower.leader
end

local function GetLeaderPos(inst)
	return inst.components.follower.leader:GetPosition()
end

local function GetFaceTargetFn(inst)
	local target = FindClosestPlayerToInst(inst, START_FACE_DIST, true)
	return target ~= nil and not target:HasTag("notarget") and target or nil
end

local function IsNearLeader(inst, dist)
	local leader = GetLeader(inst)
	return leader ~= nil and inst:IsNear(leader, dist)
end

local function KeepFaceTargetFn(inst, target)
	return not target:HasTag("notarget") and inst:IsNear(target, KEEP_FACE_DIST)
end

local function DanceParty(inst)
	inst:PushEvent("dance")
end

local function ShouldDanceParty(inst)
	local leader = GetLeader(inst)
	return leader ~= nil and leader.sg:HasStateTag("dancing")
end

local function PickUpAction(inst)

	if inst.components.container:IsFull() or inst.needtostop == 0 then
		return nil
	end

	local leader = inst.components.follower and inst.components.follower.leader or nil
	if leader == nil or leader.components.trader == nil then -- Trader component is needed for ACTIONS.GIVEALLTOPLAYER
		return nil
	end

	if not leader:HasTag("player") then -- Stop Polly Rogers from trying to help non-players due to trader mechanics.
		return nil
	end

	local item = FindPickupableItem(leader, TUNING.POLLY_ROGERS_RANGE, true)
	if item == nil then
		return nil
	end

	return BufferedAction(inst, item, ACTIONS.PICKUP)
end

function kochosei_enemy_brain_b:OnStart()
	local root = PriorityNode({
		WhileNode(
			function()
				return ShouldDanceParty(self.inst)
			end,
			"Dance Party",
			PriorityNode({
				Leash(self.inst, GetLeaderPos, KEEP_DANCING_DIST, KEEP_DANCING_DIST),
				ActionNode(function()
					DanceParty(self.inst)
				end),
			}, 0.25)
		),

		WhileNode(
			function()
				return IsNearLeader(self.inst, KEEP_WORKING_DIST)
					or Follow(self.inst, GetLeader, MIN_FOLLOW_DIST, TARGET_FOLLOW_DIST, MAX_FOLLOW_DIST)
			end,
			"Leader In Range",
			PriorityNode({
			DoAction(self.inst, PickUpAction, "pick up", true),
			}, 0.25)
		),
       -- WhileNode( function() return closetoleader(self.inst) end, "Stayclose", BrainCommon.NodeAssistLeaderPickUps(self, pickupparams)),
		Follow(self.inst, GetLeader, MIN_FOLLOW_DIST, TARGET_FOLLOW_DIST, MAX_FOLLOW_DIST),

		WhileNode(function()
			return GetLeader(self.inst) ~= nil
		end, "Has Leader", FaceEntity(self.inst, GetFaceTargetFn, KeepFaceTargetFn)),
	}, 0.25)

	self.bt = BT(self.inst, root)
end

return kochosei_enemy_brain_b
