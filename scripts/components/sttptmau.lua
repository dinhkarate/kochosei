local Sttptmau = Class(function(self, inst)
	self.inst = inst
end)

function Sttptmau:Ondeath(inst)
	if inst:HasTag("dragonfly") then
		local lootdropper = inst.components.lootdropper
		lootdropper:AddChanceLoot("dragon_scales", 1)
		lootdropper:AddChanceLoot("dragon_scales", 0.5)
		lootdropper:AddChanceLoot("dragonflyfurnace_blueprint", 0.5)
		lootdropper:AddChanceLoot("chesspiece_dragonfly_sketch", 0.5)
		lootdropper:AddChanceLoot("chesspiece_dragonfly_sketch", 1)
		lootdropper:AddChanceLoot("lavae_egg", 1)

		lootdropper:AddChanceLoot("meat", 1)
		lootdropper:AddChanceLoot("meat", 1)
		lootdropper:AddChanceLoot("meat", 1)
		lootdropper:AddChanceLoot("meat", 0.5)
		lootdropper:AddChanceLoot("meat", 0.5)
		lootdropper:AddChanceLoot("meat", 0.5)
		lootdropper:AddChanceLoot("meat", 0.5)

		lootdropper:AddChanceLoot("goldnugget", 1)
		lootdropper:AddChanceLoot("goldnugget", 1)
		lootdropper:AddChanceLoot("goldnugget", 1)
		lootdropper:AddChanceLoot("goldnugget", 0.5)
		lootdropper:AddChanceLoot("goldnugget", 0.5)
		lootdropper:AddChanceLoot("goldnugget", 0.5)

		lootdropper:AddChanceLoot("bluegem", 1)
		lootdropper:AddChanceLoot("bluegem", 1)
		lootdropper:AddChanceLoot("bluegem", 0.5)

		lootdropper:AddChanceLoot("redgem", 1)
		lootdropper:AddChanceLoot("redgem", 1)
		lootdropper:AddChanceLoot("redgem", 0.5)

		lootdropper:AddChanceLoot("purplegem", 1)
		lootdropper:AddChanceLoot("purplegem", 0.5)

		lootdropper:AddChanceLoot("orangegem", 1)
		lootdropper:AddChanceLoot("orangegem", 0.5)

		lootdropper:AddChanceLoot("yellowgem", 1)
		lootdropper:AddChanceLoot("yellowgem", 0.5)

		lootdropper:AddChanceLoot("greengem", 1)
		lootdropper:AddChanceLoot("greengem", 0.5)
	end
end

function Sttptmau:SatthuongWP(target, phantrammau, mautoida, xuyengiap, hoatdongkhihp)
	if
		target
		and phantrammau
		and target.components.health
		and target.components.health.currenthealth > hoatdongkhihp
	then
		local damage
		local weapon = self.inst.components.combat:GetWeapon()
		if mautoida then
			damage = target.components.health.maxhealth * (phantrammau / 100)
		else
			damage = target.components.health.currenthealth * (phantrammau / 100)
		end
		if damage then
			target.components.health:DoDelta(
				xuyengiap and -damage or -damage,
				xuyengiap,
				nil,
				xuyengiap,
				nil,
				xuyengiap
			)
			if target.components.health:IsDead() then
				self:Ondeath(target)
				if weapon and weapon:HasTag("miohm") then
					weapon.levelmiohm = weapon.levelmiohm + TUNING.KOCHOSEI_PER_KILL
					weapon:applyupgrades()
				end
			end
		end
	end
end

function Sttptmau:Satthuong(target, phantrammau, mautoida, xuyengiap, hoatdongkhihp)
	if
		target
		and phantrammau
		and target.components.health
		and target.components.health.currenthealth > hoatdongkhihp
	then
		local damage
		if mautoida then
			damage = target.components.health.maxhealth * (phantrammau / 100)
		else
			damage = target.components.health.currenthealth * (phantrammau / 100)
		end
		if damage then
			target.components.health:DoDelta(
				xuyengiap and -damage or -damage,
				xuyengiap,
				nil,
				xuyengiap,
				nil,
				xuyengiap
			)
		end
	end
end

return Sttptmau
