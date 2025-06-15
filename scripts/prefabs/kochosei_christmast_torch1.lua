local assets = {
	Asset("ANIM", "anim/kochosei_christmast_torch1.zip"),
	Asset("ANIM", "anim/swap_kochosei_christmast_torch1.zip"),
}

local function RemoveLight(inst, owner)
	if inst.firestest ~= nil then
		for i, fx in ipairs(inst.firestest) do
			fx:Remove()
		end
		inst.firestest = nil
	end
end
local function Addlight(inst, owner)
	if inst.firestest == nil then
		inst.firestest = {}

		for i, fx_prefab in
			ipairs(inst:GetSkinName() == nil and {
				"torchfire",
			} or SKIN_FX_PREFAB[inst:GetSkinName()] or {})
		do
			local fx = SpawnPrefab(fx_prefab)
			local fx2 = SpawnPrefab(fx_prefab)
			local fx3 = SpawnPrefab(fx_prefab)
			fx.entity:SetParent(owner.entity)
			fx.entity:AddFollower()
			fx.Follower:FollowSymbol(owner.GUID, "swap_object", -75, -235, 0) -- Cột nến 1
			fx:AttachLightTo(owner)

			fx2.entity:SetParent(owner.entity)
			fx2.entity:AddFollower()
			fx2.Follower:FollowSymbol(owner.GUID, "swap_object", 0, -290, 0) -- Cột nến 2
			fx:AttachLightTo(owner)

			fx3.entity:SetParent(owner.entity)
			fx3.entity:AddFollower()
			fx3.Follower:FollowSymbol(owner.GUID, "swap_object", 75, -235, 0) -- cột nến 3
			fx3:AttachLightTo(owner)

			table.insert(inst.firestest, fx)
			table.insert(inst.firestest, fx2)
			table.insert(inst.firestest, fx3)
		end
	end
end

local function OnEquip(inst, owner)
	owner.AnimState:OverrideSymbol("swap_object", "swap_kochosei_christmast_torch1", "swap_kochosei_christmast_torch1")
	owner.AnimState:Show("ARM_carry")
	owner.AnimState:Hide("ARM_normal")
	owner.SoundEmitter:PlaySound("dontstarve/wilson/lighter_on")
	RemoveLight(inst)
	Addlight(inst, owner)
end

local function OnUnequip(inst, owner)
	owner.AnimState:Hide("ARM_carry")
	owner.AnimState:Show("ARM_normal")
	RemoveLight(inst)
	inst.components.burnable:Extinguish()
	owner.SoundEmitter:PlaySound("dontstarve/wilson/lighter_off")
end
local function onattack(inst, attacker, target)
	if
		target ~= nil
		and target:IsValid()
		and target.components.burnable ~= nil
		and math.random() < TUNING.LIGHTER_ATTACK_IGNITE_PERCENT * target.components.burnable.flammability
	then
		target.components.burnable:Ignite(nil, attacker)
	end
end

local function oncook(inst, product, chef)
	if not chef:HasTag("expertchef") then
		-- burn
		if chef.components.health ~= nil then
			chef.components.health:DoFireDamage(5, inst, true)
			chef:PushEvent("burnt")
		end
	end
end
local function SpawnDeercmnlop(inst, target, pos)
	inst.components.spawnclonekochosei:Spawclone(inst, target, pos, "kochodeerclops")
end

local function Checklight(inst)
	RemoveLight(inst)
	if inst.firestest == nil then
		inst.firestest = {}
		for i, fx_prefab in
			ipairs(inst:GetSkinName() == nil and { "torchfire" } or SKIN_FX_PREFAB[inst:GetSkinName()] or {})
		do
			local fx = SpawnPrefab(fx_prefab)
			local fx2 = SpawnPrefab(fx_prefab)
			local fx3 = SpawnPrefab(fx_prefab)
			fx.entity:SetParent(inst.entity)
			fx.entity:AddFollower()
			fx.Follower:FollowSymbol(inst.GUID, "", -75, -195, 0) -- Cột nến 1
			fx:AttachLightTo(inst)

			fx2.entity:SetParent(inst.entity)
			fx2.entity:AddFollower()
			fx2.Follower:FollowSymbol(inst.GUID, "", 0, -245, 0) -- Cột nến 2
			fx2:AttachLightTo(inst)

			fx3.entity:SetParent(inst.entity)
			fx3.entity:AddFollower()
			fx3.Follower:FollowSymbol(inst.GUID, "", 75, -195, 0) -- cột nến 3
			fx3:AttachLightTo(inst)
			table.insert(inst.firestest, fx)
			table.insert(inst.firestest, fx2)
			table.insert(inst.firestest, fx3)
		end
	end
end
local function fn()
	local inst = CreateEntity()

	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddMiniMapEntity()
	inst.entity:AddNetwork()
	inst.entity:AddSoundEmitter()
	inst.entity:AddLight()

	MakeInventoryPhysics(inst)
	MakeHauntableLaunch(inst)

	inst.AnimState:SetBank("kochosei_christmast_torch1")
	inst.AnimState:SetBuild("kochosei_christmast_torch1")
	inst.AnimState:PlayAnimation("idle")

	inst:AddTag("kochosei_christmast_torch")
	inst.fxcolour = { 255 / 255, 255 / 255, 153 / 255 }
	if not TheWorld.ismastersim then
		return inst
	end
	inst.fxcolour = { 255 / 255, 255 / 255, 153 / 255 }
	inst.entity:SetPristine()

	inst:AddComponent("weapon")
	inst.components.weapon:SetDamage(TUNING.LIGHTER_DAMAGE)
	inst.components.weapon:SetOnAttack(onattack)

	inst:AddComponent("inspectable")
	inst:AddComponent("tradable")

	inst:AddComponent("equippable")
	inst.components.equippable:SetOnEquip(OnEquip)
	inst.components.equippable:SetOnUnequip(OnUnequip)

	inst:AddComponent("burnable")
	inst.components.burnable.canlight = false
	inst.components.burnable.fxprefab = nil

	inst:AddComponent("lighter")
	-----------------------------------
	inst:AddComponent("inventoryitem")
	inst.components.inventoryitem:SetOnDroppedFn(Checklight)
	inst.components.inventoryitem:SetOnPutInInventoryFn(RemoveLight)

	-----------------------------------
	inst:AddComponent("cooker")
	inst.components.cooker.oncookfn = oncook

	inst:AddComponent("spellcaster")
	inst.components.spellcaster.canpoint = false
	inst.components.spellcaster.canuseonpoint = true
	inst.components.spellcaster:SetSpellFn(SpawnDeercmnlop)

	inst:AddComponent("heater")
	inst.components.heater.heat = 30
	inst.components.heater.equippedheat = 30

	inst:AddComponent("spawnclonekochosei")

	MakeHauntableLaunch(inst)

	return inst
end

STRINGS.NAMES.KOCHOSEI_CHRISTMAST_TORCH1 = "Kochosei Christmast Torch"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.KOCHOSEI_CHRISTMAST_TORCH1 = "I want this!! :D"
STRINGS.RECIPE_DESC.KOCHOSEI_CHRISTMAST_TORCH1 = "ヾ(•ω•`)o"

return Prefab("kochosei_christmast_torch1", fn, assets, prefabs)
