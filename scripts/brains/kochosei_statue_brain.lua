require("behaviours/wander")
require("behaviours/faceentity")
require("behaviours/leash")

local MAX_WANDER_DIST = 4
local NO_REPEAT_COOLDOWN_TIME = 15

local KochoseiStatueBrain = Class(Brain, function(self, inst)
    Brain._ctor(self, inst)
end)

local FACE_DIST = TUNING.RESEARCH_MACHINE_DIST
local function GetFaceTargetFn(inst)
    return FindClosestPlayerToInst(inst, FACE_DIST, true)
end
local function KeepFaceTargetFn(inst, target)
    return inst:IsNear(target, FACE_DIST)
end

local function GetRoutePos(inst)
    if not inst.components.worldroutefollower:ShouldIterate() then
        return nil
    end

    return inst.components.worldroutefollower:GetRouteDestination()
end

function KochoseiStatueBrain:OnStart()
    local root = PriorityNode({
		IfNode(function() return  end, "No stock left",
            SequenceNode({
                ActionNode(function()
                    self.inst:DoChatter("WANDERINGTRADER_OUTOFSTOCK_PROXIMITY", math.random(#STRINGS.WANDERINGTRADER_OUTOFSTOCK_PROXIMITY), 15)
                end),
               -- FaceEntity(self.inst, GetFaceTargetFn, KeepFaceTargetFn, 2),
            })
        ),
     --   Wander(self.inst, function() return self.inst:GetPosition() end, MAX_WANDER_DIST),
    }, .25)
    self.bt = BT(self.inst, root)
end

return KochoseiStatueBrain
