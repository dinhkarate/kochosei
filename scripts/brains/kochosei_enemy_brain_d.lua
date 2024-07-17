require("behaviours/chaseandattack")
require("behaviours/wander")

local MAX_CHASE_DIST = 30

local function GetWanderHome(inst)
    -- If we have a target, we want to pick randomly and fall through to GetWanderDir
    if inst.components.combat.target ~= nil then
        return nil
    else
        return inst.components.knownlocations:GetLocation("home")
    end
end


local kochosei_enemy_brain_d = Class(Brain, function(self, inst)
	Brain._ctor(self, inst)
end)

function kochosei_enemy_brain_d:OnStart()
	local root = PriorityNode({
		ChaseAndAttack(self.inst),
        Wander(self.inst, GetWanderHome, MAX_CHASE_DIST),
	}, 0.25)

	self.bt = BT(self.inst, root)
end

return kochosei_enemy_brain_d
