local Kochoseienemy = Class(function(self, inst)
    self.inst = inst
end)
local brain2 = require("brains/kochosei_enemy_brain_d")
local brain = require("brains/kochosei_enemy_brain")
function Kochoseienemy:Setbrain(inst)
       self.inst:SetBrain(brain2)
end

function Kochoseienemy:Setbackbrain(inst)
       self.inst:SetBrain(brain)
end

function Kochoseienemy:Setlocation(inst)
       self.inst.components.knownlocations:RememberLocation("home", self.inst:GetPosition(), false)

end
return Kochoseienemy
