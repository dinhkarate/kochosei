require("behaviours/faceentity")
require("behaviours/chaseandattack")
require("behaviours/follow")
require("behaviours/attackwall")
require("behaviours/leash")
require("behaviours/runaway")

local kochosei_enemy_brain = Class(Brain, function(self, inst)
    Brain._ctor(self, inst)
end)

------------------------------------------------------------------------
-- Constants
------------------------------------------------------------------------
local MIN_FOLLOW_DIST    = 0
local TARGET_FOLLOW_DIST = 4
local MAX_FOLLOW_DIST    = 8

local START_FACE_DIST    = 6
local KEEP_FACE_DIST     = 8

local KEEP_DANCING_DIST  = 2

local MAX_WORK_LEASH     = 25
local SEE_WORK_DIST      = 16

local WORK_COOLDOWN      = 1.5
local RESERVATION_TIME   = 8
local SAME_TARGET_GRACE  = 6

------------------------------------------------------------------------
-- Tag lists
------------------------------------------------------------------------
local TOWORK_CANT_TAGS = { "fire", "smolder", "event_trigger", "waxedplant", "INLIMBO", "NOCLICK", "carnivalgame_part" }

-- Dùng oneof_tags khi tìm stump: stump vẫn giữ tag "tree" sau khi chặt
local DIG_STUMP_TAGS = { "DIG_workable", "tree" }
local DIG_OTHER_TAGS = { "grave", "farm_debris" }

-- Các action có thể làm việc
local ANY_TOWORK_ACTIONS    = { ACTIONS.CHOP, ACTIONS.MINE, ACTIONS.DIG }
local ANY_TOWORK_MUSTONE_TAGS = { "CHOP_workable", "MINE_workable", "DIG_workable" }

------------------------------------------------------------------------
-- Helper: Leader
------------------------------------------------------------------------
local function GetLeader(inst)
    return inst.components.follower.leader
end

local function IsNearLeader(inst, dist)
    local leader = GetLeader(inst)
    return leader ~= nil and inst:IsNear(leader, dist)
end

local function GetLeaderPos(inst)
    local leader = GetLeader(inst)
    return leader ~= nil and leader:GetPosition() or nil
end

------------------------------------------------------------------------
-- Helper: Dance
------------------------------------------------------------------------
local function DanceParty(inst)
    inst:PushEvent("dance")
end

local function ShouldDanceParty(inst)
    local leader = GetLeader(inst)
    -- Chỉ dance khi leader đang dance, không combat và không làm việc
    return leader ~= nil
        and leader.sg:HasStateTag("dancing")
        and inst.components.combat.target == nil
        and inst.needtostop ~= 1
end

------------------------------------------------------------------------
-- Helper: Face
------------------------------------------------------------------------
local function GetFaceTargetFn(inst)
    local target = FindClosestPlayerToInst(inst, START_FACE_DIST, true)
    return target ~= nil and not target:HasTag("notarget") and target or nil
end

local function KeepFaceTargetFn(inst, target)
    return not target:HasTag("notarget") and inst:IsNear(target, KEEP_FACE_DIST)
end

------------------------------------------------------------------------
-- Helper: Reservation (giữ nguyên từ kochosei)
------------------------------------------------------------------------
local function IsTargetOccupied(inst, target)
    if target.work_reserved_by ~= nil and target.work_reserved_by ~= inst then
        if target.work_reserved_by:IsValid() and
           not (target.work_reserved_by.components.health and
                target.work_reserved_by.components.health:IsDead()) then
            return true
        end
    end
    return false
end

local function ReserveEnt(inst, ent)
    ent.work_reserved_by = inst
    if ent.unreserve_task then ent.unreserve_task:Cancel() end
    ent.unreserve_task = ent:DoTaskInTime(RESERVATION_TIME, function()
        ent.work_reserved_by = nil
    end)
end

------------------------------------------------------------------------
-- Helper: IgnoreThis (theo pattern shadowwaxwell)
------------------------------------------------------------------------
local function Unignore(inst, sometarget, ignorethese)
    ignorethese[sometarget] = nil
end

local function IgnoreThis(sometarget, ignorethese, leader, worker)
    if ignorethese[sometarget] ~= nil and ignorethese[sometarget].task ~= nil then
        ignorethese[sometarget].task:Cancel()
        ignorethese[sometarget].task = nil
    else
        ignorethese[sometarget] = { worker = worker }
    end
    ignorethese[sometarget].task = leader:DoTaskInTime(5, Unignore, sometarget, ignorethese)
end

------------------------------------------------------------------------
-- PickValidActionFrom (theo shadowwaxwell)
------------------------------------------------------------------------
local function PickValidActionFrom(target)
    if target.components.workable == nil then return nil end
    local desiredact = target.components.workable:GetWorkAction()
    for _, act in ipairs(ANY_TOWORK_ACTIONS) do
        if desiredact == act then return act end
    end
    return nil
end

------------------------------------------------------------------------
-- FilterAnyWorkableTargets (kết hợp: DIG_OTHER_TAGS + stump logic)
------------------------------------------------------------------------
local function FilterAnyWorkableTargets(targets, ignorethese, leader, worker, inst)
    for _, sometarget in ipairs(targets) do
        -- Bỏ qua nếu entity đang bị ignore bởi worker khác
        if ignorethese[sometarget] ~= nil and ignorethese[sometarget].worker ~= worker then
            -- skip

        -- Bỏ qua nếu đang bốc lửa
        elseif sometarget.components.burnable == nil or
               (not sometarget.components.burnable:IsBurning() and
                not sometarget.components.burnable:IsSmoldering()) then

            -- Kiểm tra reservation của kochosei
            if not IsTargetOccupied(inst, sometarget) and
               sometarget:IsNear(leader, MAX_WORK_LEASH) then

                if sometarget:HasTag("DIG_workable") then
                    -- Stump (tag "tree") hoặc DIG_OTHER_TAGS
                    local valid_dig = sometarget:HasTag("tree")
                    if not valid_dig then
                        for _, tag in ipairs(DIG_OTHER_TAGS) do
                            if sometarget:HasTag(tag) then
                                valid_dig = true
                                break
                            end
                        end
                    end
                    if valid_dig then
                        if sometarget.components.workable:GetWorkLeft() == 1 then
                            IgnoreThis(sometarget, ignorethese, leader, worker)
                        end
                        return sometarget
                    end
                else
                    -- CHOP_workable và MINE_workable không cần check tag phụ
                    if sometarget.components.workable:GetWorkLeft() == 1 then
                        IgnoreThis(sometarget, ignorethese, leader, worker)
                    end
                    return sometarget
                end
            end
        end
    end
    return nil
end

------------------------------------------------------------------------
-- FindAnyEntityToWorkActionsOn
-- Kết hợp logic tìm target của kochosei (cooldown, reservation, SAME_TARGET_GRACE)
-- với cấu trúc clean của shadowwaxwell
------------------------------------------------------------------------
local function FindAnyEntityToWorkActionsOn(inst, ignorethese)
    -- Nếu stategraph đang busy thì không làm gì
    if inst.sg ~= nil and inst.sg:HasStateTag("busy") then return nil end

    local leader = GetLeader(inst)
    if leader == nil then return nil end

    -- Kiểm tra cooldown
    if inst.work_cooldown_until ~= nil and GetTime() < inst.work_cooldown_until then
        return nil
    end

    -- Kiểm tra buffered action còn hợp lệ không
    local ba = inst:GetBufferedAction()
    if ba ~= nil and ba.target ~= nil and ba.target:IsValid() then
        local wk = ba.target.components.workable
        if wk ~= nil and wk:CanBeWorked() then
            -- Đang thực hiện action hợp lệ, không cần tìm mới
            return nil
        end
    end

    -- Thử giữ target hiện tại (SAME_TARGET_GRACE)
    local cur = inst.current_work_target
    if cur ~= nil and type(cur) == "table" and cur.IsValid ~= nil and cur:IsValid() then
        local wk = cur.components ~= nil and cur.components.workable or nil
        if wk ~= nil and wk:CanBeWorked() and
           inst.work_target_until ~= nil and GetTime() < inst.work_target_until and
           not IsTargetOccupied(inst, cur) and
           cur:IsNear(leader, MAX_WORK_LEASH) then
            local action = PickValidActionFrom(cur)
            if action ~= nil then
                ReserveEnt(inst, cur)
                return BufferedAction(inst, cur, action)
            end
        end
    end
    inst.current_work_target = nil

    -- Tìm target mới quanh bản thân
    local x, y, z = inst.Transform:GetWorldPosition()
    local candidates = TheSim:FindEntities(x, y, z, SEE_WORK_DIST, nil, TOWORK_CANT_TAGS, ANY_TOWORK_MUSTONE_TAGS)

    -- Sort theo khoảng cách gần nhất (giữ logic kochosei)
    table.sort(candidates, function(a, b)
        local ax, _, az = a.Transform:GetWorldPosition()
        local bx, _, bz = b.Transform:GetWorldPosition()
        return (ax-x)^2+(az-z)^2 < (bx-x)^2+(bz-z)^2
    end)

    local target = FilterAnyWorkableTargets(candidates, ignorethese, leader, inst, inst)

    -- Nếu không thấy quanh bản thân, thử tìm quanh leader
    if target == nil then
        local lx, ly, lz = leader.Transform:GetWorldPosition()
        local leader_candidates = TheSim:FindEntities(lx, ly, lz, SEE_WORK_DIST, nil, TOWORK_CANT_TAGS, ANY_TOWORK_MUSTONE_TAGS)
        table.sort(leader_candidates, function(a, b)
            local ax, _, az = a.Transform:GetWorldPosition()
            local bx, _, bz = b.Transform:GetWorldPosition()
            return (ax-lx)^2+(az-lz)^2 < (bx-lx)^2+(bz-lz)^2
        end)
        target = FilterAnyWorkableTargets(leader_candidates, ignorethese, leader, inst, inst)
    end

    if target ~= nil then
        local action = PickValidActionFrom(target)
        if action ~= nil then
            inst.current_work_target  = target
            inst.work_target_until    = GetTime() + SAME_TARGET_GRACE
            ReserveEnt(inst, target)
            return BufferedAction(inst, target, action)
        end
    end

    -- Không tìm được target → set cooldown
    inst.work_cooldown_until  = GetTime() + WORK_COOLDOWN
    inst.current_work_target  = nil
    return nil
end

------------------------------------------------------------------------
-- OnStart
------------------------------------------------------------------------
function kochosei_enemy_brain:OnStart()
    -- Chuẩn bị ignorethese (theo pattern shadowwaxwell worker)
    local leader = GetLeader(self.inst)
    local ignorethese = {}
    if leader ~= nil then
        ignorethese = leader._kochosei_brain_ignorethese or {}
        leader._kochosei_brain_ignorethese = ignorethese
    end

    local root = PriorityNode({
        -- 1. CHIẾN ĐẤU
        WhileNode(function() return self.inst.components.combat.target ~= nil end, "Attack",
            ChaseAndAttack(self.inst, 10)),

        -- 2. LÀM VIỆC (chỉ khi needtostop == 1 và còn gần leader)
        IfThenDoWhileNode(
            function()
                return self.inst.needtostop == 1 and IsNearLeader(self.inst, MAX_WORK_LEASH)
            end,
            function()
                return self.inst.needtostop == 1 and IsNearLeader(self.inst, MAX_WORK_LEASH)
            end,
            "Work Loop",
            WhileNode(
                function()
                    self.keepworking = false
                    return true
                end,
                "Keep Working",
                DoAction(self.inst, function()
                    local act = FindAnyEntityToWorkActionsOn(self.inst, ignorethese)
                    if act then
                        -- Giữ working nếu stategraph đang ở trạng thái pre-action
                        if self.inst.sg ~= nil and
                           self.inst.sg:HasStateTag("pre"..string.lower(act.action.id)) then
                            self.keepworking = true
                        else
                            return act
                        end
                    end
                end)
            )
        ),

        -- 3. FOLLOW
        Follow(self.inst, GetLeader, MIN_FOLLOW_DIST, TARGET_FOLLOW_DIST, MAX_FOLLOW_DIST),

        -- 4. DANCE (chỉ khi idle: không combat, không làm việc)
        WhileNode(function() return ShouldDanceParty(self.inst) end, "Dance Party",
            PriorityNode({
                Leash(self.inst, GetLeaderPos, KEEP_DANCING_DIST, KEEP_DANCING_DIST),
                ActionNode(function() DanceParty(self.inst) end),
            }, 0.25)),

        -- 5. FACE player
        FaceEntity(self.inst, GetFaceTargetFn, KeepFaceTargetFn),
    }, 0.25)

    self.bt = BT(self.inst, root)
end

return kochosei_enemy_brain
