require "behaviours/wander"
require "behaviours/leash"
require "behaviours/chaseandattack"
require "behaviours/standandattack"

local KochoseiTornadoBrain = Class(Brain, function(self, inst)
    Brain._ctor(self, inst)
end)

local wanderTimes = 
{
    minwalktime = .25,
    randwalktime = .25,
    minwaittime = .25,
    randwaittime = .25,
}

function KochoseiTornadoBrain:OnStart()
    local root = 
    PriorityNode(
    {
        --Leash(self.inst, function() return self.inst.components.knownlocations:GetLocation("target") end, 3, 1, true),
		StandAndAttack(self.inst),
		Leash(self.inst, function() return self.inst.components.knownlocations:GetLocation("spawnpos") end, 3, 1, true),
        Wander(self.inst, function() return self.inst.components.knownlocations:GetLocation("spawnpos") end, 2, wanderTimes),
    }, .25)
    self.bt = BT(self.inst, root)
end

return KochoseiTornadoBrain