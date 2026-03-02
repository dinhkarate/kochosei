local KochoseiTeleport = Class(function(self, inst)
	self.inst = inst
end)
-- Cơ bản nó để thêm action chứ không có ứng dụng gì khác
function KochoseiTeleport:Gachatime(doer)
	self.inst:PushEvent("kochoseiteleport", { doer = doer })
end

return KochoseiTeleport
