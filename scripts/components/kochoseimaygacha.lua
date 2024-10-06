local Kochoseimaygacha = Class(function(self, inst)
    self.inst = inst
end)
-- Cơ bản nó để thêm action chứ không có ứng dụng gì khác
function Kochoseimaygacha:Gachatime(doer)
    if not self.inst.components.timer:TimerExists("maygacha") then
        self.inst.components.timer:StartTimer("maygacha", 5)
    end
	self.inst:PushEvent("banoidungnghiennua", {doer = doer})
end

return Kochoseimaygacha
