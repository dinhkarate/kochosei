local assets = {
	Asset("ANIM", "anim/kochosei_christmast_torch1.zip"),
	Asset("ANIM", "anim/swap_kochosei_christmast_torch1.zip"),
}
local function onequiptomodel(inst, owner, from_ground)
	if inst.fires ~= nil then
		for i, fx in ipairs(inst.fires) do
			fx:Remove()
		end
		inst.fires = nil
	end

	inst.components.burnable:Extinguish()
end

local function onpocket(inst, owner)
	if inst.fires ~= nil then
		for i, fx in ipairs(inst.fires) do
			fx:Remove()
		end
		inst.fires = nil
	end
	inst.components.burnable:Extinguish()
end

local function OnEquip(inst, owner)
	owner.AnimState:OverrideSymbol("swap_object", "swap_kochosei_christmast_torch1", "swap_kochosei_christmast_torch1")
	owner.AnimState:Show("ARM_carry")
	owner.AnimState:Hide("ARM_normal")
	owner.SoundEmitter:PlaySound("dontstarve/wilson/lighter_on")
	if inst.fires == nil then
		inst.fires = {}

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

			table.insert(inst.fires, fx)
			table.insert(inst.fires, fx2)
			table.insert(inst.fires, fx3)
		end
	end
end

local function OnUnequip(inst, owner)
	owner.AnimState:Hide("ARM_carry")
	owner.AnimState:Show("ARM_normal")
	if inst.fires ~= nil then
		for i, fx in ipairs(inst.fires) do
			fx:Remove()
		end
		inst.fires = nil
	end
	owner.SoundEmitter:PlaySound("dontstarve/wilson/lighter_off")
	inst.components.burnable:Extinguish()
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
		caster.components.petleash:SpawnPetAt(pos.x, 0, pos.z, "kochodeerclops")
		if caster ~= nil then
			if caster.components.staffsanity then
				caster.components.staffsanity:DoCastingDelta(-TUNING.KOCHOSEI_SLAVE_COST)
			elseif caster.components.sanity ~= nil then
				caster.components.sanity:DoDelta(-TUNING.KOCHOSEI_SLAVE_COST)
			end
		end
	end
end

local MIOHM_CANT_TAGS = {
	"DECOR",
	"FX",
	"INLIMBO",
	"NOCLICK",
	"playerghost",
}

local function SetTemperatureToOwner(owner)
	if owner and owner.components.temperature then
		local current = owner.components.temperature:GetCurrent()
		if current and current <= 3 then
			owner.components.temperature:SetTemperature(3)
		end
	end
end

local function checklight(inst)
	local x, y, z = inst.Transform:GetWorldPosition()

	-- Kiểm tra và thiết lập nhiệt độ cho người chơi trong phạm vi 4
	local playersheal = TheSim:FindEntities(x, y, z, 5, { "player" }, MIOHM_CANT_TAGS)
	for i, v in ipairs(playersheal) do
		local owner2 = inst.components.inventoryitem.owner
		if owner2 == nil then
			SetTemperatureToOwner(v)
		end
	end

	if inst.components.equippable:IsEquipped() then
		local owner = inst.components.inventoryitem.owner
		if owner and owner:HasTag("player") then
			SetTemperatureToOwner(owner)
		end
	end

	if inst:HasTag("INLIMBO") then
		if inst.firestest ~= nil then
			for i, fx in ipairs(inst.firestest) do
				fx:Remove()
			end
			inst.firestest = nil
		end
	else
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
	inst.components.equippable:SetOnPocket(onpocket)
	inst.components.equippable:SetOnEquip(OnEquip)
	inst.components.equippable:SetOnUnequip(OnUnequip)
	inst.components.equippable:SetOnEquipToModel(onequiptomodel)

	inst:AddComponent("burnable")
	inst.components.burnable.canlight = false
	inst.components.burnable.fxprefab = nil

	inst:AddComponent("lighter")
	-----------------------------------
	inst:AddComponent("inventoryitem")

	-----------------------------------
	inst:AddComponent("cooker")
	inst.components.cooker.oncookfn = oncook

	inst:AddComponent("spellcaster")
	inst.components.spellcaster.canpoint = false
	inst.components.spellcaster.canuseonpoint = true
	inst.components.spellcaster:SetSpellFn(HealFunc3)

	MakeHauntableLaunch(inst)

	inst:DoPeriodicTask(0.5, checklight)
	return inst
end

STRINGS.NAMES.KOCHOSEI_CHRISTMAST_TORCH1 = "Kochosei Christmast Torch"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.KOCHOSEI_CHRISTMAST_TORCH1 = "I want this!! :D"
STRINGS.RECIPE_DESC.KOCHOSEI_CHRISTMAST_TORCH1 = "ヾ(•ω•`)o"

return Prefab("kochosei_christmast_torch1", fn, assets, prefabs)
