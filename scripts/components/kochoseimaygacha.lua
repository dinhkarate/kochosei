local Kochoseimaygacha = Class(function(self, inst)
    self.inst = inst
end)
-- Cơ bản nó để thêm action chứ không có ứng dụng gì khác
function Kochoseimaygacha:Gachatime(inst)
	if not self.inst.components.timer:TimerExists("maygacha") then
		self.inst.components.timer:StartTimer("maygacha", 5)
	end
	self.inst:PushEvent("banoidungnghiennua")
end
return Kochoseimaygacha
