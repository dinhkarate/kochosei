local assets = {
	Asset("ANIM", "anim/bienbao.zip"),
	Asset("ANIM", "anim/bienbao_dat.zip"),
}


local prefabs = {
	"propsignshatterfx",
}

local function OnUnequip(inst, owner)
	owner.AnimState:ClearOverrideSymbol("swap_object")
	owner.AnimState:Hide("ARM_carry")
	owner.AnimState:Show("ARM_normal")
end

local function OnEquip(inst, owner)
	owner.AnimState:OverrideSymbol("swap_object", "bienbao", "bienbao")
	owner.AnimState:Show("ARM_carry")
	owner.AnimState:Hide("ARM_normal")
end

local function OnSmashed(inst, pos)
	local owner = inst.components.inventoryitem:GetGrandOwner()
	if owner ~= nil and owner.components.minigame_participator ~= nil then
		local minigame = owner.components.minigame_participator:GetMinigame()
		if minigame ~= nil and minigame.components.minigame ~= nil then
			minigame.components.minigame:RecordExcitement()
		end
	end

	local fx = SpawnPrefab("propsignshatterfx")
	fx.Transform:SetPosition(pos:Get())
	fx.SoundEmitter:PlaySound("dontstarve/common/destroy_wood")
	inst:Remove()
end

local function BreakSign(inst)
	if not inst.broken then
		if not inst.components.inventoryitem:IsHeld() then
			inst.broken = true
			inst.persists = false
			inst:AddTag("NOCLICK")
			inst.components.inventoryitem.canbepickedup = false
			if inst.components.burnable:IsBurning() then
				inst.components.burnable:Extinguish()
				inst:AddTag("burnt")
				inst.AnimState:SetMultColour(0, 0, 0, 1)
			end
			inst.SoundEmitter:PlaySound("dontstarve/common/destroy_wood", nil, 0.6)
			inst.AnimState:PlayAnimation("idle")
			inst.AnimState:PushAnimation("idle", false)
			inst:DoTaskInTime(1, ErodeAway)
		else
			if inst.components.equippable:IsEquipped() then
				inst.components.inventoryitem.owner.components.inventory:Unequip(EQUIPSLOTS.HANDS, true)
			end
			OnSmashed(inst, inst:GetPosition())
		end
	end
end

local function OnDelayInteraction(inst)
	inst._knockbacktask = nil
	inst:RemoveTag("knockbackdelayinteraction")
end

local function OnDelayPlayerInteraction(inst)
	inst._playerknockbacktask = nil
	if not inst.broken then
		inst:RemoveTag("NOCLICK")
	end
end

local function OnKnockbackDropped(inst, data)
	if data ~= nil and (data.delayinteraction or 0) > 0 then
		if inst._knockbacktask ~= nil then
			inst._knockbacktask:Cancel()
		else
			inst:AddTag("knockbackdelayinteraction")
		end
		inst._knockbacktask = inst:DoTaskInTime(data.delayinteraction, OnDelayInteraction)
	elseif inst._knockbacktask ~= nil then
		inst._knockbacktask:Cancel()
		OnDelayInteraction(inst)
	end

	if data ~= nil and (data.delayplayerinteraction or 0) > 0 then
		if inst._playerknockbacktask ~= nil then
			inst._playerknockbacktask:Cancel()
		else
			inst:AddTag("NOCLICK")
		end
		inst._playerknockbacktask = inst:DoTaskInTime(data.delayplayerinteraction, OnDelayPlayerInteraction)
	elseif inst._playerknockbacktask ~= nil then
		inst._playerknockbacktask:Cancel()
		OnDelayPlayerInteraction(inst)
	end
end

local function fn()
	local inst = CreateEntity()

	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddSoundEmitter()
	inst.entity:AddNetwork()

	MakeInventoryPhysics(inst)

	inst.AnimState:SetBank("bienbao_dat")
	inst.AnimState:SetBuild("bienbao_dat")
	--   inst.AnimState:OverrideSymbol("burnt", "sign_home", "burnt")
	inst.AnimState:PlayAnimation("idle")

	inst:AddTag("propweapon")
	inst:AddTag("minigameitem")
	inst:AddTag("irreplaceable")
	inst:AddTag("nonpotatable")

	--weapon (from weapon component) added to pristine state for optimization
	inst:AddTag("weapon")

	inst:SetPrefabNameOverride("homesign")

	inst.entity:SetPristine()

	if not TheWorld.ismastersim then
		return inst
	end

	inst:AddComponent("inspectable")

	inst:AddComponent("inventoryitem")
	inst.components.inventoryitem.imagename = "propsign"

	inst:AddComponent("equippable")
	inst.components.equippable.equipslot = EQUIPSLOTS.HANDS
	inst.components.equippable:SetOnEquip(OnEquip)
	inst.components.equippable:SetOnUnequip(OnUnequip)

	inst:AddComponent("weapon")
	inst.components.weapon:SetRange(TUNING.PROP_WEAPON_RANGE)
	inst.components.weapon:SetDamage(1)

	MakeSmallBurnable(inst, 5, nil, true)
	MakeSmallPropagator(inst)

	inst:AddComponent("hauntable")
	inst.components.hauntable:SetHauntValue(TUNING.HAUNT_TINY)

	inst:ListenForEvent("propsmashed", OnSmashed)
	inst:ListenForEvent("knockbackdropped", OnKnockbackDropped)

	inst.nobrokentoolfx = true

	return inst
end

local function fxfn()
	local inst = CreateEntity()

	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddSoundEmitter()
	inst.entity:AddNetwork()

	inst.AnimState:SetBank("sign_elite")
	inst.AnimState:SetBuild("sign_elite")
	inst.AnimState:PlayAnimation("shatter")

	inst:AddTag("FX")
	inst:AddTag("NOCLICK")

	if not TheWorld.ismastersim then
		return inst
	end

	inst.persists = false
	inst:ListenForEvent("animover", inst.Remove)

	return inst
end

return Prefab("bienbao", fn, assets, prefabs)
