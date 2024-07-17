local assets = {
	Asset("ANIM", "anim/kochosei_purplemagic.zip"),
	Asset("ANIM", "anim/swap_kochosei_purplemagic.zip"),
}

local function onremovefire(fire)
	fire.miohm.fire = nil
end

local function TurnOn(inst, owner)
	if inst.fire == nil then
		inst.fire = SpawnPrefab("miohammer_light")
		inst.fire.miohm = inst
		inst:ListenForEvent("onremove", onremovefire, inst.fire)
	end
	inst.fire.entity:SetParent(owner.entity)
end

local function TurnOff(inst, owner)
	if inst.fire ~= nil then
		inst.fire:Remove()
	end
end

local function HealFunc3(inst, target, pos)
	inst.SoundEmitter:PlaySound("dontstarve/common/together/moonbase/beam_stop_fail")

	local caster = inst.components.inventoryitem.owner
	local check = caster.components.sanity.current
	if not caster then
		caster = target or caster
	end
	if not caster:HasTag("kochosei") then
		caster.components.talker:Say("Maybe Kochosei knows how to use this")
		return
	end

	if caster.components.petleash ~= nil and caster.components.petleash:IsFull() then
		caster.components.talker:Say("Toooooooooo many clone")
		return
	end

	if check <= TUNING.KOCHOSEI_SLAVE_COST then
		caster.components.talker:Say("Not enough sanity")
	else
		caster.components.petleash:SpawnPetAt(pos.x, 0, pos.z, "kochosei_enemy")
		if caster ~= nil then
			if caster.components.staffsanity then
				caster.components.staffsanity:DoCastingDelta(-TUNING.KOCHOSEI_SLAVE_COST)
			elseif caster.components.sanity ~= nil then
				caster.components.sanity:DoDelta(-TUNING.KOCHOSEI_SLAVE_COST)
			end
		end
	end
end

local function OnEquip(inst, owner)
	owner.AnimState:OverrideSymbol("swap_object", "swap_kochosei_purplemagic", "swap_kochosei_purplemagic")
	owner.AnimState:Show("ARM_carry")
	owner.AnimState:Hide("ARM_normal")
	if inst.magicfx ~= nil then
		inst.magicfx:Remove()
		inst.magicfx = nil
	end
	inst.magicfx = SpawnPrefab("cane_victorian_fx")
	if inst.magicfx then
		inst.magicfx.entity:AddFollower()
		inst.magicfx.entity:SetParent(owner.entity)
		inst.magicfx.Follower:FollowSymbol(owner.GUID, "swap_object", 0, -60, 0)
	end
	TurnOn(inst, owner)
end

local function OnUnequip(inst, owner)
	owner.AnimState:Hide("ARM_carry")
	owner.AnimState:Show("ARM_normal")
	if inst.magicfx ~= nil then
		inst.magicfx:Remove()
		inst.magicfx = nil
	end
	TurnOff(inst, owner)
end
local function onUse(inst, owner)
	owner = inst.components.inventoryitem.owner or owner
	local pets = owner.components.petleash:GetPets()

	for _, pet in pairs(pets) do
		if pet.needtostop == 0 then
			pet.needtostop = 1
		elseif pet.needtostop == 1 then
			pet.needtostop = 0
		end
	end

	owner.components.talker:Say("Đã đổi trạng thái clone")

	return false -- Ngăn không cho item biến mất sau khi sử dụng
end

local function fn()
	local inst = CreateEntity()

	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddNetwork()
	inst.entity:AddSoundEmitter()

	MakeInventoryPhysics(inst)
	MakeHauntableLaunch(inst)
	inst.AnimState:SetBank("kochosei_purplemagic")
	-- This is the name of your compiled*.zip file.
	inst.AnimState:SetBuild("kochosei_purplemagic")
	-- This is the animation name while item is on the ground.
	inst.AnimState:PlayAnimation("idle")
	MakeInventoryFloatable(inst, "small", 0.1, 1.12)

	inst:AddTag("sharp")

	-- Glow in the Dark!
	inst.entity:AddLight()
	inst.Light:Enable(true) -- originally was false.
	inst.Light:SetRadius(1)
	inst.Light:SetFalloff(0.5)
	inst.Light:SetIntensity(0.8)
	inst.Light:SetColour(200 / 255, 100 / 255, 200 / 255)

	if not TheWorld.ismastersim then
		return inst
	end

	inst.entity:SetPristine()

	inst.fxcolour = { 178 / 255, 102 / 255, 255 / 255 }
	inst:AddComponent("spellcaster")
	inst.components.spellcaster.canpoint = false
	inst.components.spellcaster.canuseonpoint = true
	inst.components.spellcaster:SetSpellFn(HealFunc3)
	if type(TUNING.PURPLEMAGIC_DURABILITY) == "number" then
		inst:AddComponent("finiteuses")
		inst.components.finiteuses:SetMaxUses(TUNING.PURPLEMAGIC_DURABILITY)
		inst.components.finiteuses:SetUses(TUNING.PURPLEMAGIC_DURABILITY)
		inst.components.finiteuses:SetOnFinished(inst.Remove)
	end
	inst:AddComponent("weapon")
	inst.components.weapon:SetDamage(TUNING.PURPLEMAGIC_DAMAGE)
	inst.components.weapon:SetRange(12)

	inst.components.weapon:SetProjectile("kochosei_magicbubble")

	inst:AddComponent("inspectable")

	inst:AddComponent("tradable")

	inst:AddComponent("talker")

	inst:AddComponent("equippable")
	inst.components.equippable:SetOnEquip(OnEquip)
	inst.components.equippable:SetOnUnequip(OnUnequip)
	inst.components.equippable.walkspeedmult = 1.25
	inst.components.equippable.dapperness = 0.033

	inst:AddComponent("inventoryitem")

	inst:AddComponent("useableitem") -- Đổi trạngt thái clone
	inst.components.useableitem:SetOnUseFn(onUse)

	return inst
end

STRINGS.NAMES.KOCHOSEI_PURPLEMAGIC = "Kochosei Purplemagic"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.KOCHOSEI_PURPLEMAGIC = "Holyyy!! :D"
STRINGS.RECIPE_DESC.KOCHOSEI_PURPLEMAGIC = "Spawn Kochosei clone"

return Prefab("common/inventory/kochosei_purplemagic", fn, assets, prefabs)
