require("behaviours/faceentity")
require("behaviours/follow")
require("behaviours/leash")

local BrainCommon = require("brains/braincommon")

local kochosei_enemy_brain_b = Class(Brain, function(self, inst)
	Brain._ctor(self, inst)
end)

local MIN_FOLLOW_DIST    = 0
local TARGET_FOLLOW_DIST = 6
local MAX_FOLLOW_DIST    = 8

local START_FACE_DIST    = 6
local KEEP_FACE_DIST     = 8

local KEEP_DANCING_DIST  = 3

local PICKUP_SEARCH_DIST = TUNING.POLLY_ROGERS_RANGE

------------------------------------------------------------------------
-- Leader helpers
------------------------------------------------------------------------

local function GetLeader(inst)
	return inst.components.follower ~= nil
		and inst.components.follower.leader
		or nil
end

local function GetLeaderPos(inst)
	local leader = GetLeader(inst)
	return leader ~= nil and leader:GetPosition() or nil
end

------------------------------------------------------------------------
-- Face-target helpers
------------------------------------------------------------------------

local function GetFaceTargetFn(inst)
	local target = FindClosestPlayerToInst(inst, START_FACE_DIST, true)
	return target ~= nil and not target:HasTag("notarget") and target or nil
end

local function KeepFaceTargetFn(inst, target)
	return not target:HasTag("notarget") and inst:IsNear(target, KEEP_FACE_DIST)
end

------------------------------------------------------------------------
-- Dance helpers
------------------------------------------------------------------------

local function ShouldDanceParty(inst)
	local leader = GetLeader(inst)
	return leader ~= nil and leader.sg ~= nil and leader.sg:HasStateTag("dancing")
end

local function DanceParty(inst)
	inst:PushEvent("dance")
end

------------------------------------------------------------------------
-- Pick-up (tự nhặt vào container của bản thân)
--
-- Tìm item quanh leader như Woby dùng _playerlink làm source.
-- Không bọc WhileNode khoảng cách — DoAction giữ action đến khi xong.
------------------------------------------------------------------------

local function SelfPickUpFilter(inst, item, worker)
	if item:HasTag("outofreach") then
		return false
	end

	if not (item.components.inventoryitem ~= nil and item.components.inventoryitem.is_landed) then
		return false
	end

	if item.components.trap ~= nil then
		return false
	end

	-- Không nhặt item đang ở trên boat
	if item:GetCurrentPlatform() ~= nil then
		return false
	end

	return true
end

local function SelfPickUpAction(inst)
	local leader = GetLeader(inst)
	if leader == nil then
		return nil
	end

	if inst.components.container == nil or inst.components.container:IsFull() then
		return nil
	end

	local item = FindPickupableItem(
		leader,             -- source: tìm quanh leader
		PICKUP_SEARCH_DIST,
		false,              -- nearestfirst
		nil,                -- positionoverride
		nil,                -- ignorethese
		nil,                -- onlytheseprefabs
		false,              -- allowpickables
		inst,               -- worker
		SelfPickUpFilter,
		inst.components.container
	)

	if item == nil then
		return nil
	end

	return BufferedAction(inst, item, ACTIONS.WOBY_PICKUP)
end

------------------------------------------------------------------------
-- Brain
------------------------------------------------------------------------

function kochosei_enemy_brain_b:OnStart()
	local root = PriorityNode({

		-- 1. Panic / electric-fence
		BrainCommon.PanicTrigger(self.inst),
		BrainCommon.ElectricFencePanicTrigger(self.inst),

		-- 2. Dance khi leader đang dancing
		WhileNode(
			function() return ShouldDanceParty(self.inst) end,
			"Dance Party",
			PriorityNode({
				Leash(self.inst, GetLeaderPos, KEEP_DANCING_DIST, KEEP_DANCING_DIST),
				ActionNode(function() DanceParty(self.inst) end),
			}, 0.25)
		),

		-- 3. Pickup — condition trong SelfPickUpAction, không gate bằng khoảng cách
		DoAction(self.inst, SelfPickUpAction, "self pick up", true),

		-- 4. Follow
		Follow(self.inst, GetLeader, MIN_FOLLOW_DIST, TARGET_FOLLOW_DIST, MAX_FOLLOW_DIST),

		-- 5. Face player gần nhất khi idle
		WhileNode(
			function() return GetLeader(self.inst) ~= nil end,
			"Has Leader",
			FaceEntity(self.inst, GetFaceTargetFn, KeepFaceTargetFn)
		),

	}, 0.25)

	self.bt = BT(self.inst, root)
end

return kochosei_enemy_brain_b
