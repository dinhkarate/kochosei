local assets = {
	Asset("ANIM", "anim/kochotambourin.zip"),
	Asset("ANIM", "anim/swap_kochotambourin.zip"),
	Asset("ANIM", "anim/lavaarena_heal_flowers_fx.zip"),
}
local function TurnOn(inst, owner)
	inst.light = SpawnPrefab("kochotambourin_light")
	inst.light.entity:AddFollower()
	inst.light.entity:SetParent(owner.entity)
end

local function TurnOff(inst, owner)
	if inst.light ~= nil then
		inst.light:Remove()
		inst.light = nil
	end
end

-- Bloomson credit to Abigail  https://steamcommunity.com/sharedfiles/filedetails/?id=2535962194&searchtext=fantasy

local function SanityCheck(inst, level)
	level = level or inst.components.sanity.current
	if level > 50 then
		inst.components.sanity:DoDelta(-20)
		return true
	end
	return false
end

local PI = math.pi
local Rn = 6 -- Maximum radius
local Zn = 5 -- Effect duration
local DENSITY = 10 -- Adjustable density (reduced for better outer circle)

-- Generate circular points with improved distribution
local function GenerateCircularPoints()
	local points = {}
	local min_radius = 1.0 -- Smaller minimum radius for center coverage

	for radius = Rn, min_radius, -1.2 do -- Smaller steps for smoother distribution
		-- Improved density calculation for outer circles
		local base_density = DENSITY * (0.8 + (radius / Rn) ^ 1.5) -- Better outer circle density
		local circumference = 2 * PI * radius

		-- Minimum segments for outer circles to prevent sparse appearance
		local min_segments = math.max(8, math.floor(radius * 5.5)) -- Ensure minimum density
		local calc_segments = math.floor(circumference / base_density)
		local segments = math.max(min_segments, calc_segments)

		-- Golden angle for optimal distribution (137.5 degrees in radians)
		local golden_angle = 2.39996
		local offset = (radius % 2) * golden_angle / 3 -- Reduced offset for better alignment

		for i = 1, segments do
			local angle = (golden_angle * i) + offset
			local x = math.cos(angle) * radius
			local z = math.sin(angle) * radius
			table.insert(points, {
				pos = Vector3(x, 0, z),
				radius = radius,
				angle = angle, -- Store angle for sequencing
				segment_index = i,
				total_segments = segments,
			})
		end
	end

	-- Sort points by radius first (inside-out), then by angle for smooth progression
	table.sort(points, function(a, b)
		if math.abs(a.radius - b.radius) < 0.1 then -- Same radius group
			return a.angle < b.angle
		end
		return a.radius < b.radius -- Inner circles first
	end)

	return points
end

local PRE_COMPUTED_POINTS = GenerateCircularPoints()
local hstrongtay = STRINGS.NAMES.LYDOHOISINH_THIENSU

local function HealFunc2(inst, target, pos)
	local hstrongtay = STRINGS.NAMES.LYDOHOISINH
	local caster = inst.components.inventoryitem.owner
	if not caster then
		caster = target or caster
	end

	if not SanityCheck(caster) then
		caster.components.talker:Say("I need more sanity!")
		return
	else
		--local pos = Vector3(caster.Transform:GetWorldPosition())
		local players = FindPlayersInRange(pos.x, pos.y, pos.z, Rn)
		for _, player in ipairs(players) do
			if player and player:IsValid() then
				if player.components.health and player.components.health:IsDead() or player:HasTag("playerghost") then
					player:PushEvent("respawnfromghost")
					player.rezsource = hstrongtay
				end
				player:AddDebuff("kocho_buff_heal", "kocho_buff_heal")
			end
		end

		-- Improved concentric circle effect with better timing
		local fx_center = CreateEntity()
		fx_center.entity:AddTransform()
		fx_center.Transform:SetPosition(pos:Get())

		-- Improved timing parameters
		local base_delay = 0.1 -- Base delay between effects
		local radius_multiplier = 0.12 -- Radius-based delay multiplier
		local wave_speed = 0.3 -- Wave propagation speed (higher = faster)

		for i, data in ipairs(PRE_COMPUTED_POINTS) do
			-- Improved delay calculation for smoother outward wave
			local radius_delay = (data.radius / Rn) * radius_multiplier / wave_speed
			local sequence_delay = (i * 0.002) -- Small sequential delay
			local angular_variation = math.sin(data.angle * 0.3) * 0.01 -- Subtle angular variation

			local total_delay = base_delay + radius_delay + sequence_delay + angular_variation

			fx_center:DoTaskInTime(total_delay, function()
				local fx = SpawnPrefab("lavaarena_bloom_kocho1")
				if fx then
					local offset_pos = pos + data.pos
					-- Add slight vertical variation for more organic feel
					offset_pos.y = offset_pos.y + math.sin(data.angle * 2) * 0.2
					fx.Transform:SetPosition(offset_pos:Get())

					if fx.chixu then
						-- Slightly varied duration for natural look
						local duration_variance = 0.2 + math.random() * 0.3
						fx:chixu(Zn + duration_variance)
					end
				end
			end)
		end

		-- Clean up fx_center after all effects are done
		local max_delay = base_delay + (radius_multiplier / wave_speed) + (#PRE_COMPUTED_POINTS * 0.002)
		fx_center:DoTaskInTime(max_delay + Zn + 1, function()
			if fx_center and fx_center:IsValid() then
				fx_center:Remove()
			end
		end)
	end
end

-- Bloomson credit to Abigail  https://steamcommunity.com/sharedfiles/filedetails/?id=2535962194&searchtext=fantasy

local function OnEquip(inst, owner)
	owner.AnimState:OverrideSymbol("swap_object", "swap_kochotambourin", "swap_kochotambourin")
	owner.AnimState:Show("ARM_carry")
	owner.AnimState:Hide("ARM_normal")
	TurnOn(inst, owner)
end

local function OnUnequip(inst, owner)
	owner.AnimState:Hide("ARM_carry")
	owner.AnimState:Show("ARM_normal")
	TurnOff(inst, owner)
end

local function onhaunt(inst, haunter)
	if haunter:HasTag("playerghost") then
		haunter:PushEvent("respawnfromghost", {
			source = inst,
		})
		inst:Remove()
	end
end

local function light_fn()
	local inst = CreateEntity()
	inst.entity:AddTransform()
	inst.entity:AddLight()
	inst.entity:AddNetwork()
	inst.Light:Enable(true)
	inst.Light:SetFalloff(0.5)
	inst.Light:SetIntensity(0.7)
	inst.Light:SetColour(200 / 255, 100 / 255, 200 / 255)
	inst.Light:SetRadius(5)

	inst.persists = false
	inst:AddTag("FX")
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
	inst.entity:AddMiniMapEntity()
	inst.entity:AddNetwork()

	MakeInventoryPhysics(inst)

	inst.AnimState:SetBank("kochotambourin")
	inst.AnimState:SetBuild("kochotambourin")
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

	inst.fxcolour = {
		0 / 255,
		255 / 255,
		0 / 255,
	}
	inst:AddComponent("spellcaster")
	inst.components.spellcaster.canpoint = false
	inst.components.spellcaster.canuseonpoint = true
	inst.components.spellcaster:SetSpellFn(HealFunc2)

	inst:AddComponent("finiteuses")
	inst.components.finiteuses:SetOnFinished(inst.Remove)

	inst:AddComponent("weapon")
	inst.components.weapon:SetDamage(20)

	inst:AddComponent("inspectable")
	inst:AddComponent("tradable")

	inst:AddComponent("equippable")
	inst.components.equippable.restrictedtag = "kochosei"
	inst.components.equippable:SetOnEquip(OnEquip)
	inst.components.equippable:SetOnUnequip(OnUnequip)
	inst.components.equippable.walkspeedmult = 1.25
	inst.components.equippable.dapperness = 0.033

	inst:AddComponent("inventoryitem")
	inst:AddComponent("hauntable")
	inst.components.hauntable.onhaunt = onhaunt
	inst.lights = {}

	return inst
end

STRINGS.NAMES.KOCHOTAMBOURIN = "Kochotambourin"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.KOCHOTAMBOURIN = "I want this!! :D"
STRINGS.RECIPE_DESC.KOCHOTAMBOURIN = "Healing teammate"

return Prefab("kochotambourin", fn, assets, prefabs), Prefab("kochotambourin_light", light_fn)
