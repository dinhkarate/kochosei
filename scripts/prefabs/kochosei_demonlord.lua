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

-- Tên FX hardcode thẳng, không cần qua SKIN_FX_PREFAB như skin system
local DEMONLORD_VFX    = nil              -- FX bám theo vũ khí (swap_object), đặt tên prefab nếu có
local DEMONLORD_TRAIL  = "cane_ancient_fx" -- FX trail spawn dưới đất khi di chuyển
local DEMONLORD_VFX_OFFSET = -105         -- offset dọc của vfx (giống cane skin)

local TRAIL_FLAGS = { "shadowtrail" }

-- inst = weapon (giống cane_do_trail chuẩn, lấy owner qua GetGrandOwner)
local function PlantTick(inst)
    local owner = inst.components.inventoryitem ~= nil
        and inst.components.inventoryitem:GetGrandOwner()
        or nil
    if owner == nil or not owner.entity:IsVisible() then
        return
    end

    local x, y, z = owner.Transform:GetWorldPosition()

    -- Dịch điểm spawn theo hướng & tốc độ thực nếu đang di chuyển
    if owner.sg ~= nil and owner.sg:HasStateTag("moving") then
        local theta = -owner.Transform:GetRotation() * DEGREES
        local speed = owner.components.locomotor ~= nil
            and owner.components.locomotor:GetRunSpeed() * .1
            or 0
        x = x + speed * math.cos(theta)
        z = z + speed * math.sin(theta)
    end

    local mounted = owner.components.rider ~= nil and owner.components.rider:IsRiding()
    local map = TheWorld.Map

    local offset = FindValidPositionByFan(
        math.random() * TWOPI,
        (mounted and 1 or .5) + math.random() * .5,
        4,
        function(offset)
            local pt = Vector3(x + offset.x, 0, z + offset.z)
            return map:IsPassableAtPoint(pt:Get())
                and not map:IsPointNearHole(pt)
                and #TheSim:FindEntities(pt.x, 0, pt.z, .7, TRAIL_FLAGS) <= 0
        end
    )

    if offset ~= nil then
        SpawnPrefab(DEMONLORD_TRAIL).Transform:SetPosition(x + offset.x, 0, z + offset.z)
    end
end

local function OnEquip(inst, owner)
	owner.AnimState:OverrideSymbol("swap_object", "swap_demonlord", "swap_demonlord")
	owner.AnimState:Show("ARM_carry")
	owner.AnimState:Hide("ARM_normal")

	-- VFX bám theo vũ khí (tương đương _vfx_fx_inst trong cane skin)
	if DEMONLORD_VFX ~= nil and inst._vfx_inst == nil then
		inst._vfx_inst = SpawnPrefab(DEMONLORD_VFX)
		inst._vfx_inst.entity:AddFollower()
		inst._vfx_inst.entity:SetParent(owner.entity)
		inst._vfx_inst.Follower:FollowSymbol(owner.GUID, "swap_object", 0, DEMONLORD_VFX_OFFSET, 0)
	end

	-- Trail FX task trên weapon (inst), lấy owner qua GetGrandOwner bên trong PlantTick
	if DEMONLORD_TRAIL ~= nil and inst._trailtask == nil then
		inst._trailtask = inst:DoPeriodicTask(6 * FRAMES, PlantTick, 2 * FRAMES)
	end

	TurnOn(inst, owner)
end

local function OnUnequip(inst, owner)
	owner.AnimState:Hide("ARM_carry")
	owner.AnimState:Show("ARM_normal")

	if inst._vfx_inst ~= nil then
		inst._vfx_inst:Remove()
		inst._vfx_inst = nil
	end

	if inst._trailtask ~= nil then
		inst._trailtask:Cancel()
		inst._trailtask = nil
	end

	TurnOff(inst, owner)
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
