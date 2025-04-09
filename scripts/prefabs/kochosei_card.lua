local function make(code, description, check_des_boolean, alter_description, fileanim)
	local name = (description or STRINGS.NAMES[string.upper(code)] or STRINGS.SKIN_NAMES[string.lower(code)] or "???")
	STRINGS.NAMES[string.upper(code)] = name
	STRINGS.RECIPE_DESC[string.upper(code)] = check_des_boolean or alter_description
	STRINGS.CHARACTERS.GENERIC.DESCRIBE[string.upper(code)] = alter_description
		or STRINGS.SKIN_DESCRIPTIONS[code]
		or (
			(description or STRINGS.NAMES[string.upper(code)] or STRINGS.SKIN_NAMES[string.lower(code)] or "???") .. "。"
		)

	return Prefab(code, function()
		local inst = CreateEntity()
		inst.entity:AddTransform()
		inst.entity:AddAnimState()
		inst.entity:AddNetwork()
		MakeInventoryPhysics(inst)
		MakeInventoryFloatable(inst)
		inst.entity:AddDynamicShadow()
		inst.DynamicShadow:SetSize(1, 0.6)
		inst.entity:AddLight()
		inst.Light:Enable(true)
		inst.Light:SetRadius(0.5)
		inst.Light:SetFalloff(0.7)
		inst.Light:SetIntensity(0.5)
		inst.Light:SetColour(238 / 255, 155 / 255, 143 / 255)

		inst.Transform:SetScale(1.5, 1.5, 1.5)
		inst.entity:SetPristine()
		if not TheWorld.ismastersim then
			return inst
		end

		inst:AddComponent("inspectable")
		inst:AddComponent("inventoryitem")
		inst.components.inventoryitem.atlasname = "images/inventoryimages/kochosei_card.xml"
		inst.components.inventoryitem.imagename = "kochosei_card"

		inst.AnimState:SetBank("kochosei_card")
		inst.AnimState:SetBuild("kochosei_card")
		inst.AnimState:PlayAnimation("kochosei_card", true)
		inst.components.inventoryitem.keepondeath = true

		inst:AddComponent("equippable")
		inst.components.equippable.equipslot = EQUIPSLOTS.MEDAL or EQUIPSLOTS.NECK or EQUIPSLOTS.BODY

		local function onbecamehuman(owner)
			--owner:DoTaskInTime(3, function()
			--    owner.AnimState:SetBuild(code)
			--    owner:DoTaskInTime(1.3, function()
			--        owner.AnimState:SetBuild(code)
			--    end)
			--end)
		end
		inst.components.equippable:SetOnEquip(function(inst, owner)
			local currentMaxHealth = owner.components.health.maxhealth
			local DeltaHealth = owner.components.health.maxhealth - owner.components.health.currenthealth
			if owner:HasTag("player") then
				if code == "kochosei_card_defend" then
					owner.components.health:SetMaxDamageTakenPerHit(currentMaxHealth / 10)
				end
				if code == "kochosei_card_attack" then
					-- Hắn dùng ExternalDamageMulti
					-- Mình dùng BaseDamage
					if owner.components.combat.damagemultiplier ~= nil then
						owner.components.combat.damagemultiplier = owner.components.combat.damagemultiplier * 2
						print("Khác nil")
					else
						owner.components.combat.damagemultiplier = 2
					end
				end
				if code == "kochosei_card_health" then
					owner.components.health:SetMaxHealth(currentMaxHealth + 500)
					owner.components.health:SetCurrentHealth(currentMaxHealth - DeltaHealth + 500)
					owner.components.health:DoDelta(0.01)
				end
				owner:ListenForEvent("ms_respawnedfromghost", onbecamehuman)
				--owner:DoTaskInTime(0, function()
				--    if owner:IsValid() and owner.sg and not owner.components.rider:IsRiding() then
				--        owner.components.locomotor:Stop()
				--owner.sg:GoToState("")
				--Tạm thời chưa dùng
				--    end
				--end)
				--owner:DoTaskInTime(1.5+FRAMES, function()
				--owner.AnimState:SetBuild(code)
				--Tạm thời chưa dùng
				--end)
			end
		end)
		inst.components.equippable:SetOnUnequip(function(inst, owner)
			local currentMaxHealth = owner.components.health.maxhealth
			local DeltaHealth = owner.components.health.maxhealth - owner.components.health.currenthealth
			if owner:HasTag("player") then
				if code == "kochosei_card_defend" then
					owner.components.health:SetMaxDamageTakenPerHit(nil)
				end
				if code == "kochosei_card_attack" then
					-- Hắn dùng ExternalDamageMulti
					-- Mình dùng BaseDamage
					if owner.components.combat.damagemultiplier ~= nil then
						owner.components.combat.damagemultiplier = owner.components.combat.damagemultiplier / 2
						-- Lúc Equip đã gán giá trị cho nó lên gấp đôi, vì vậy nên không cần else ở đây
					end
				end
				if code == "kochosei_card_health" then
					owner.components.health:SetMaxHealth(currentMaxHealth - 500)
					owner.components.health:DoDelta(DeltaHealth)
					-- Cố tình gỡ thì thấp hơn 500 máu thì cút
					--if (currentMaxHealth - DeltaHealth - 500) > 0 then
					--    owner.components.health:SetCurrentHealth(currentMaxHealth - DeltaHealth - 500)
					--    owner.components.health:DoDelta(-0.01)
					--else
					--    owner.components.health:SetCurrentHealth(1)
					--    owner.components.health:DoDelta(-0.01)
					--DoDelta để lấy hiệu ứng trên thanh máu
					--end
				end

				owner:RemoveEventCallback("ms_respawnedfromghost", onbecamehuman)
				-- owner:DoTaskInTime(0, function()
				--    if owner:IsValid() and owner.sg and not owner.components.rider:IsRiding() then
				--        owner.components.locomotor:Stop()
				--        owner.sg:GoToState("tz_cosplay")
				--    end
				--end)
				--owner:DoTaskInTime(1.5, function()
				--    local normal_skin = owner.prefab
				--    local skin_name = owner.components.skinner.skin_name
				-- if skin_name and skin_name ~= "" and owner.prefab ~= 'sora' then
				--    if skin_name ~= nil and skin_name ~= "" then
				--        local skin_prefab = Prefabs[skin_name] or nil
				--        if skin_prefab and skin_prefab.skins and skin_prefab.skins.normal_skin ~= nil then
				--            normal_skin = skin_prefab.skins.normal_skin
				--        end
				--    end
				--    owner.AnimState:SetBuild(normal_skin)
				--end)
			end
		end)
		return inst
	end, {
		Asset("ANIM", "anim/kochosei_card.zip"),
		Asset("ATLAS", "images/inventoryimages/kochosei_card.xml"),
	})
end

local blank = ""

-- Nếu được hãy làm hệ thống merge cho mấy tấm thẻ này.
-- Ý tưởng 1. Merge trong Kochosei_Altar
-- Ý tưởng 2. Merge bằng action của player
return make("kochosei_card_defend", "Thẻ Phòng Thủ", nil, "Giới hạn damage nhận vào còn 10% máu", nil),
	make("kochosei_card_attack", "Thẻ Tấn Công", nil, "Tăng sát thương lên gấp đôi", nil),
	make("kochosei_card_health", "Thẻ Trâu Bò", nil, "Tăng 500 máu tối đa", nil)
