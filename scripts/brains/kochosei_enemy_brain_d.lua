require("behaviours/chaseandattack")
require("behaviours/leash")
require("behaviours/wander")

local function GetHomePos(inst)
	return inst.components.knownlocations:GetLocation("spawnpoint")
end

local kochosei_enemy_brain_d = Class(Brain, function(self, inst)
	Brain._ctor(self, inst)
end)

function kochosei_enemy_brain_d:OnStart()
	local root = PriorityNode({

		Leash(self.inst, GetHomePos, 30, 5),
		ChaseAndAttack(self.inst, 12, 21),
		Wander(self.inst),
	}, 0.25)

	self.bt = BT(self.inst, root)
end

function kochosei_enemy_brain_d:OnInitializationComplete()
	self.inst.components.knownlocations:RememberLocation("spawnpoint", self.inst:GetPosition())
end

return kochosei_enemy_brain_d
