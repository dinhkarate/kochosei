local assets = {
	Asset("ANIM", "anim/kochosei_lantern.zip"),
	Asset("ANIM", "anim/swap_kochosei_lantern.zip"),
}

local function onremovelight(light)
	light._lantern._light = nil
end

local function fuelupdate(inst)
	if inst._light ~= nil then
		local fuelpercent = inst.components.fueled:GetPercent()
		inst._light.Light:SetIntensity(Lerp(0.4, 0.6, fuelpercent))
		inst._light.Light:SetRadius(Lerp(3, 5, fuelpercent))
		inst._light.Light:SetFalloff(0.9)
	end
end

local function turnon(inst)
	if not inst.components.fueled:IsEmpty() then
		if not inst.components.machine.ison then
			if inst.components.fueled then
				inst.components.fueled:StartConsuming()
			end

			local owner = inst.components.inventoryitem.owner

			if inst._light == nil then
				inst._light = SpawnPrefab("kochoseilanternlight")
				inst._light._lantern = inst
				inst:ListenForEvent("onremove", onremovelight, inst._light)
				fuelupdate(inst)
			end
			inst._light.entity:SetParent((owner or inst).entity)
			inst.AnimState:PlayAnimation("idle_on")

			if inst.components.equippable:IsEquipped() then
				inst.components.inventoryitem.owner.AnimState:OverrideSymbol(
					"swap_object",
					"swap_kochosei_lantern",
					"swap_lantern_on"
				)
				--                inst.components.inventoryitem.owner.AnimState:Show("lantern_overlay")
			end
			inst.components.machine.ison = true

			inst.SoundEmitter:PlaySound("dontstarve/wilson/lantern_on")
			inst.SoundEmitter:PlaySound("dontstarve/wilson/lantern_LP", "loop")

			-- inst.components.inventoryitem:ChangeImageName("kochosei_lantern")
		end
	end
end

local function turnoff(inst)
	if inst.components.fueled then
		inst.components.fueled:StopConsuming()
	end
	if inst._light ~= nil then
		inst._light:Remove()
	end

	inst.AnimState:PlayAnimation("idle_off")

	if inst.components.equippable:IsEquipped() then
		inst.components.inventoryitem.owner.AnimState:OverrideSymbol(
			"swap_object",
			"swap_kochosei_lantern",
			"swap_lantern_off"
		)
		--        inst.components.inventoryitem.owner.AnimState:Hide("lantern_overlay")
	end

	inst.components.machine.ison = false

	inst.SoundEmitter:KillSound("loop")
	inst.SoundEmitter:PlaySound("dontstarve/wilson/lantern_off")
end

local function OnLoad(inst, data)
	if inst.components.machine and inst.components.machine.ison then
		inst.AnimState:PlayAnimation("idle_on")
		turnon(inst)
	else
		inst.AnimState:PlayAnimation("idle_off")
		turnoff(inst)
	end
end

local function ondropped(inst)
	turnoff(inst)
	turnon(inst)
end

local function onpickup(inst)
	turnon(inst)
end

local function onputininventory(inst)
	turnoff(inst)
end

local function OnRemove(inst)
	if inst._light ~= nil then
		inst._light:Remove()
	end
	if inst._soundtask ~= nil then
		inst._soundtask:Cancel()
	end
end

local function onequip(inst, owner)
	owner.AnimState:Show("ARM_carry")
	owner.AnimState:Hide("ARM_normal")
	--    owner.AnimState:OverrideSymbol("lantern_overlay", "swap_kochosei_lantern", "lantern_overlay")

	if inst.components.fueled:IsEmpty() then
		owner.AnimState:OverrideSymbol("swap_object", "swap_kochosei_lantern", "swap_lantern_off")
	--		owner.AnimState:Hide("LANTERN_OVERLAY")
	else
		owner.AnimState:OverrideSymbol("swap_object", "swap_kochosei_lantern", "swap_lantern_on")
		--		owner.AnimState:Show("LANTERN_OVERLAY")
	end
	turnon(inst, owner)
end

local function onunequip(inst, owner)
	owner.AnimState:Hide("ARM_carry")
	owner.AnimState:Show("ARM_normal")
	--    owner.AnimState:ClearOverrideSymbol("lantern_overlay")
	--	owner.AnimState:Hide("LANTERN_OVERLAY")
end

local function nofuel(inst)
	local owner = inst.components.inventoryitem and inst.components.inventoryitem.owner
	if owner then
		owner:PushEvent("torchranout", { torch = inst })
	end

	turnoff(inst)
end

local function takefuel(inst)
	if inst.components.equippable and inst.components.equippable:IsEquipped() then
		turnon(inst)
	end
end

local function lanternlightfn()
	local inst = CreateEntity()

	inst.entity:AddTransform()
	inst.entity:AddLight()
	inst.entity:AddSoundEmitter()
	inst.entity:AddNetwork()

	inst:AddTag("FX")

	inst.Light:SetColour(180 / 255, 195 / 255, 150 / 255)

	inst.entity:SetPristine()

	if not TheWorld.ismastersim then
		return inst
	end

	inst.persists = false

	return inst
end

local function fn()
	local inst = CreateEntity()

	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddSoundEmitter()
	inst.entity:AddNetwork()

	MakeInventoryPhysics(inst)

	inst.AnimState:SetBank("lantern")
	inst.AnimState:SetBuild("kochosei_lantern")
	inst.AnimState:PlayAnimation("idle_off")
	MakeInventoryFloatable(inst, "small", 0.1, 1.12)

	-- anim:SetBank("lantern")
	-- anim:SetBuild("lantern")
	-- anim:PlayAnimation("idle_off")

	inst:AddTag("light")
	inst:AddTag("kochosei_lantern")
	inst:AddComponent("inspectable")

	if not TheWorld.ismastersim then
		return inst
	end

	inst:AddComponent("inventoryitem")
	--  inst.components.inventoryitem.imagename = "kochosei_lantern"
	--	inst.components.inventoryitem.atlasname = "images/inventoryimages/kochosei_inv.xml"
	inst.components.inventoryitem:SetOnDroppedFn(ondropped)
	inst.components.inventoryitem:SetOnPutInInventoryFn(onputininventory)

	inst:AddComponent("equippable")
	inst:AddComponent("fueled")

	inst:AddComponent("machine")
	inst.components.machine.turnonfn = turnon
	inst.components.machine.turnofffn = turnoff
	inst.components.machine.cooldowntime = 0
	inst.components.machine.caninteractfn = function()
		return not inst.components.fueled:IsEmpty()
	end

	inst.components.fueled.fueltype = "BURNABLE"
	inst.components.fueled:InitializeFuelLevel(TUNING.LANTERN_LIGHTTIME * 2)
	inst.components.fueled:SetDepletedFn(nofuel)
	inst.components.fueled:SetUpdateFn(fuelupdate)
	inst.components.fueled.ontakefuelfn = takefuel
	inst.components.fueled.accepting = true

	inst._light = nil

	fuelupdate(inst)

	inst.OnRemoveEntity = OnRemove

	inst.components.equippable:SetOnEquip(onequip)
	inst.components.equippable:SetOnUnequip(onunequip)

	inst.OnLoad = OnLoad

	return inst
end

STRINGS.NAMES.KOCHOSEI_LANTERN = "Kochosei Lantern"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.KOCHOSEI_LANTERN = "Fancy"
STRINGS.RECIPE_DESC.KOCHOSEI_LANTERN = "Wandering Wandering like a some witch"

return Prefab("kochosei_lantern", fn, assets), Prefab("kochoseilanternlight", lanternlightfn)
