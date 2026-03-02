local assets = {
	Asset("ANIM", "anim/demonlord.zip"),
	Asset("ANIM", "anim/swap_demonlord.zip"),
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

local function Spawnclone(inst, target, pos, prefabclone)
	inst.components.spawnclonekochosei:Spawclone(inst, target, pos, "dinhcutenhathematroi")
end

local MIN_RANGE = .5      -- khoảng cách tối thiểu so với player
local MAX_RANGE = 1.5      -- khoảng cách tối đa
local MAX_PLANTS = 18

local PLANTFX_TAGS =
{
    "shadowtrail",
}

local function PlantTick(inst)
    if not inst.entity:IsVisible() then
        return
    end

    local x, y, z = inst.Transform:GetWorldPosition()

    -- Giới hạn số FX quanh player
    if #TheSim:FindEntities(x, y, z, MAX_RANGE, PLANTFX_TAGS) >= MAX_PLANTS then
        return
    end

    local pt = Vector3(0, 0, 0)

    local offset = FindValidPositionByFan(
        math.random() * 2 * PI,
        MIN_RANGE + math.random() * (MAX_RANGE - MIN_RANGE),
        6, -- số lần thử
        function(offset)
            pt.x = x + offset.x
            pt.z = z + offset.z

            -- Chỉ check trùng FX, KHÔNG check địa hình
            return #TheSim:FindEntities(pt.x, 0, pt.z, 0.5, PLANTFX_TAGS) < 3
        end
    )

    if offset ~= nil then
        local plant = SpawnPrefab("cane_ancient_fx")
        if plant ~= nil then
            plant.Transform:SetPosition(
                x + offset.x,
                0,
                z + offset.z
            )
        end
    end
end

local function OnEquip(inst, owner)
	owner.AnimState:OverrideSymbol("swap_object", "swap_demonlord", "swap_demonlord")
	owner.AnimState:Show("ARM_carry")
	owner.AnimState:Hide("ARM_normal")
	if owner.demonlord == nil then 
		owner.demonlord = owner:DoPeriodicTask(0.15, PlantTick)
	end
	TurnOn(inst, owner)
end

local function OnUnequip(inst, owner)
	owner.AnimState:Hide("ARM_carry")
	owner.AnimState:Show("ARM_normal")
	TurnOff(inst, owner)
	if owner.demonlord ~= nil then
		owner.demonlord:Cancel()
		owner.demonlord = nil
	end
end

local function fn()
	local inst = CreateEntity()

	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddNetwork()
	inst.entity:AddSoundEmitter()

	MakeInventoryPhysics(inst)
	MakeHauntableLaunch(inst)
	inst.AnimState:SetBank("demonlord")
	-- This is the name of your compiled*.zip file.
	inst.AnimState:SetBuild("demonlord")
	-- This is the animation name while item is on the ground.
	inst.AnimState:PlayAnimation("idle")

	inst:AddTag("sharp")
	MakeInventoryFloatable(inst, "small", 0.1, 1.12)
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

	inst.fxcolour = { 255 / 255, 128 / 255, 0 / 255 }
	inst:AddComponent("spellcaster")
	inst.components.spellcaster.canpoint = false
	inst.components.spellcaster.canuseonpoint = true
	inst.components.spellcaster:SetSpellFn(Spawnclone)

	if type(TUNING.DEMONLORD_DURABILITY) == "number" then
		inst:AddComponent("finiteuses")
		inst.components.finiteuses:SetMaxUses(TUNING.DEMONLORD_DURABILITY)
		inst.components.finiteuses:SetUses(TUNING.DEMONLORD_DURABILITY)
		inst.components.finiteuses:SetOnFinished(inst.Remove)
	end

	inst:AddComponent("weapon")
	inst.components.weapon:SetDamage(TUNING.DEMONLORD_DAMAGE)
	inst.components.weapon:SetRange(12)

	inst.components.weapon:SetProjectile("fire_projectile")

	inst:AddComponent("inspectable")

	inst:AddComponent("equippable")
	inst.components.equippable:SetOnEquip(OnEquip)
	inst.components.equippable:SetOnUnequip(OnUnequip)
	inst.components.equippable.walkspeedmult = 1.25
	inst.components.equippable.dapperness = 0.033

	inst:AddComponent("inventoryitem")

	inst:AddComponent("spawnclonekochosei")

	return inst
end

STRINGS.NAMES.KOCHOSEI_DEMONLORD = "Kochosei Demonlord"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.KOCHOSEI_DEMONLORD = "It makes me scary!"
STRINGS.RECIPE_DESC.KOCHOSEI_DEMONLORD = "Spawn Ancient Fuel"

return Prefab("kochosei_demonlord", fn, assets, prefabs)
