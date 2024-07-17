local Assets = {
	Asset("ANIM", "anim/kocho_miku_cos.zip"),
	Asset("ANIM", "anim/kocho_miku_back.zip"),
	Asset("ANIM", "anim/kochosei_fuji_tree.zip"),
	Asset("IMAGE", "minimap/kochosei_apple_tree.tex"),
	Asset("ATLAS", "minimap/kochosei_apple_tree.xml"),
}

local prefabs = {
	"globalmapicon",
}
local RANGE_CUA_CAY_THAN_KY = 15

local small_ram_products = {
	"twigs",
	"cutgrass",
	"petals",
	"oceantree_leaf_fx_fall",
	"oceantree_leaf_fx_fall",
}
local MIN = TUNING.SHADE_CANOPY_RANGE
local MAX = MIN + TUNING.WATERTREE_PILLAR_CANOPY_BUFFER

local DROP_ITEMS_DIST_MIN = 8
local DROP_ITEMS_DIST_VARIANCE = 12
local NUM_DROP_SMALL_ITEMS_MIN = 10
local NUM_DROP_SMALL_ITEMS_MAX = 14

local function OnDropped(inst)
	inst.components.disappears:PrepareDisappear()
end

local function backcos()
	local inst = CreateEntity()
	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddNetwork()
	inst.entity:AddSoundEmitter()
	MakeInventoryPhysics(inst)

	if not TheWorld.ismastersim then
		return inst
	end
	inst.entity:SetPristine()
	MakeSmallBurnable(inst)
	MakeSmallPropagator(inst)
	inst:AddComponent("disappears")
	inst.components.disappears.sound = "dontstarve/common/dust_blowaway"
	inst.components.disappears.anim = "disappear"

	inst:AddTag("preparedfood")

	inst:AddComponent("inspectable")

	inst:AddComponent("inventoryitem")

	inst:AddComponent("stackable")
	inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM

	inst:AddComponent("bait")
	inst:ListenForEvent("ondropped", OnDropped)
	inst.components.disappears:PrepareDisappear()

	inst:AddComponent("tradable")

	return inst
end
local function fn()
	local inst = backcos()
	inst.AnimState:SetBank("kocho_miku_cos")
	inst.AnimState:SetBuild("kocho_miku_cos")
	inst.AnimState:PlayAnimation("idle")
	return inst
end

local function fnback()
	local inst = backcos()
	inst.AnimState:SetBank("kocho_miku_back")
	inst.AnimState:SetBuild("kocho_miku_back")
	inst.AnimState:PlayAnimation("idle")
	return inst
end

local KHONG_TAG = { "player", "FX", "playerghost", "NOCLICK", "DECOR", "INLIMBO", "epic" }
local CAN_TAG = { "shadowcreature", "monster", "frog"}
local function checkfl(inst)
	local follower = inst.components.follower
	if follower ~= nil then
		local leader = follower:GetLeader()
		if leader and leader:HasTag("player") then
			return true
		end
	end
	if follower == nil then
		return false
	end
end

local function thithet(inst)
	local x, y, z = inst.Transform:GetWorldPosition()
	local ents = TheSim:FindEntities(x, y, z, RANGE_CUA_CAY_THAN_KY, nil, KHONG_TAG, CAN_TAG)

	for i, v in ipairs(ents) do
		if v.components.health and v.components.combat then
			if not checkfl(v) then
				v.components.health:Kill()
			end
		end
	end
end



local function lam_kho_item(inst)
	local x, y, z = inst.Transform:GetWorldPosition()
	local players = FindPlayersInRange(x, y, z, RANGE_CUA_CAY_THAN_KY, true)

	for _, player in pairs(players) do
		if not player:HasTag("moistureimmunity") then
		player:AddDebuff("Buff_Cay_Than_Ky", "buff_moistureimmunity")
		end
		if player.components.temperature then
	    player.components.temperature:SetTemperature(TUNING.BOOK_TEMPERATURE_AMOUNT)
		end

	end
end

--fix 23/01/2024
local function OnInit(inst)
	inst.icon = SpawnPrefab("globalmapicon")
	inst.icon:TrackEntity(inst)
end

local FIREFLY_MUST = { "firefly" }
local FIREFLY_CANT =
	{ "FX", "NOBLOCK", "NOCLICK", "DECOR", "flying", "boat", "walkingplank", "_inventoryitem", "structure" }
local function OnPhaseChanged(inst, phase)
	if phase == "day" then
		local x, y, z = inst.Transform:GetWorldPosition()

		if TheSim:CountEntities(x, y, z, 8, FIREFLY_MUST) < 10 then
			if math.random() < 0.7 then
				local pos = nil
				local offset = nil
				local count = 0
				while offset == nil and count < 10 do
					local angle = 2 * PI * math.random()
					local radius = math.random() * 8
					offset = { x = math.cos(angle) * radius, y = 0, z = math.sin(angle) * radius }
					count = count + 1

					pos = { x = x + offset.x, y = 0, z = z + offset.z }

					if TheSim:CountEntities(pos.x, pos.y, pos.z, 5, nil, FIREFLY_CANT) > 0 then
						offset = nil
					end
				end

				if offset then
					local firefly = SpawnPrefab("fireflies")
					firefly.Transform:SetPosition(x + offset.x, 0, z + offset.z)
				end
			end
		end
	end
end

local function CustomOnHauntkochosei(inst, haunter)
	haunter:PushEvent("respawnfromghost", { source = inst })
end

local function DropLightningItems(inst, items)
	local x, _, z = inst.Transform:GetWorldPosition()
	local num_items = #items

	for i, item_prefab in ipairs(items) do
		local dist = DROP_ITEMS_DIST_MIN + DROP_ITEMS_DIST_VARIANCE * math.random()
		local theta = 2 * PI * math.random()

		inst:DoTaskInTime(i * 5 * FRAMES, function(inst2)
			local item = SpawnPrefab(item_prefab)
			item.Transform:SetPosition(x + dist * math.cos(theta), 20, z + dist * math.sin(theta))

			if i == num_items then
				inst._lightning_drop_task:Cancel()
				inst._lightning_drop_task = nil
			end
		end)
	end
end

local function OnLightningStrike(inst)
	if inst._lightning_drop_task ~= nil then
		return
	end

	local num_small_items = math.random(NUM_DROP_SMALL_ITEMS_MIN, NUM_DROP_SMALL_ITEMS_MAX)
	local items_to_drop = {}

	for i = 1, num_small_items do
		table.insert(items_to_drop, small_ram_products[math.random(1, #small_ram_products)])
	end

	inst._lightning_drop_task = inst:DoTaskInTime(20 * FRAMES, DropLightningItems, items_to_drop)
end

local function on_find_fire(inst, firePos)
	inst.components.wateryprotection:SpreadProtectionAtPoint(firePos:Get())
end
local function cay_kocho()
	local inst = CreateEntity()
	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddNetwork()
	inst.entity:AddSoundEmitter()
	inst.entity:AddLight()
	--20/01/2024
	--Do entity không được add minimapentity và mình đã phải vật lộn ở lỗi tại dòng thứ 152 mà không hiểu nguyên do
	--Ngốn thêm 30p nữa
	inst.entity:AddMiniMapEntity()

	inst.Light:Enable(true) -- originally was false.
	inst.Light:SetRadius(12)
	inst.Light:SetFalloff(1)
	inst.Light:SetIntensity(0.8)
	inst.AnimState:SetMultColour(0.7, 0.7, 0.7, 1)

	inst.MiniMapEntity:SetIcon("kochosei_apple_tree.tex")
	inst.MiniMapEntity:SetCanUseCache(false)
	inst.MiniMapEntity:SetDrawOverFogOfWar(true)

	inst.Light:SetColour(0.75, 0.75, 0.6)
	MakeInventoryPhysics(inst)
	inst.AnimState:SetBloomEffectHandle("shaders/anim.ksh")
	inst.AnimState:SetBank("kochosei_fuji_tree")
	inst.AnimState:SetBuild("kochosei_fuji_tree")
	inst.AnimState:PlayAnimation("idle")
	inst.AnimState:SetScale(1.5, 1.5)
	inst:AddTag("shelter")
	if not TheWorld.ismastersim then
		return inst
	end

	inst:DoTaskInTime(5, OnInit)
	inst:AddTag("flower")

	inst:AddTag("kochosei_fuji_tree")
	inst:AddTag("shelter")
	inst.entity:SetPristine()
	MakeSmallPropagator(inst)
	inst:ListenForEvent("phasechanged", function(src, phase)
		OnPhaseChanged(inst, phase)
	end, TheWorld)

	inst:AddComponent("sanityaura")
	inst.components.sanityaura.aura = TUNING.SANITYAURA_SMALL

	inst:AddComponent("inspectable")

	inst:AddComponent("hauntable")
	inst.components.hauntable:SetOnHauntFn(CustomOnHauntkochosei)

	inst:AddComponent("lightningblocker")
	inst.components.lightningblocker:SetBlockRange(TUNING.SHADE_CANOPY_RANGE)
	inst.components.lightningblocker:SetOnLightningStrike(OnLightningStrike)

	inst:DoPeriodicTask(1, thithet)
	inst:DoPeriodicTask(5, lam_kho_item)

	inst:AddComponent("firedetector")
	inst.components.firedetector:SetOnFindFireFn(on_find_fire)
	inst.components.firedetector.range = RANGE_CUA_CAY_THAN_KY
	inst.components.firedetector.detectPeriod = 3
	inst.components.firedetector.fireOnly = true
	inst.components.firedetector:Activate(true)

	inst:AddComponent("wateryprotection")
	inst.components.wateryprotection.extinguishheatpercent = TUNING.FIRESUPPRESSOR_EXTINGUISH_HEAT_PERCENT
	inst.components.wateryprotection.temperaturereduction = TUNING.FIRESUPPRESSOR_TEMP_REDUCTION
	inst.components.wateryprotection.witherprotectiontime = TUNING.FIRESUPPRESSOR_PROTECTION_TIME
	inst.components.wateryprotection.addcoldness = TUNING.FIRESUPPRESSOR_ADD_COLDNESS
	inst.components.wateryprotection:AddIgnoreTag("player")
	return inst
end

local WATER_RADIUS = 3.8
local NO_DEPLOY_RADIUS = WATER_RADIUS + 0.1

local function GetFish(inst)
	return math.random() < 0.6 and "wetpouch" or "pondfish"
end

local function oc_cmndao()
	local inst = CreateEntity()

	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddSoundEmitter()
	inst.entity:AddMiniMapEntity()
	inst.entity:AddNetwork()

	inst.Transform:SetRotation(45)

	MakeObstaclePhysics(inst, 6)
	--inst:SetPhysicsRadiusOverride(3)

	inst.AnimState:SetBuild("oasis_tile")
	inst.AnimState:SetBank("oasis_tile")
	inst.AnimState:PlayAnimation("idle", true)
	inst.AnimState:SetOrientation(ANIM_ORIENTATION.OnGround)
	inst.AnimState:SetLayer(LAYER_BACKGROUND)
	inst.AnimState:SetSortOrder(-3)

	inst.MiniMapEntity:SetIcon("oasis.png")

	-- From watersource component
	inst:AddTag("watersource")
	inst:AddTag("birdblocker")
	inst:AddTag("antlion_sinkhole_blocker")
	inst:AddTag("allow_casting")

	inst.no_wet_prefix = true
	inst:SetDeployExtraSpacing(NO_DEPLOY_RADIUS)

	if not TheNet:IsDedicated() then
		inst:AddComponent("pointofinterest")
		inst.components.pointofinterest:SetHeight(320)
	end

	inst.entity:SetPristine()

	if not TheWorld.ismastersim then
		return inst
	end

	inst:AddComponent("inspectable")

	inst:AddComponent("fishable")
	inst.components.fishable.maxfish = 999
	inst.components.fishable.fishleft = 999
	inst.components.fishable:SetRespawnTime(TUNING.OASISLAKE_FISH_RESPAWN_TIME)
	inst.components.fishable:SetGetFishFn(GetFish)
	

	inst:AddComponent("hauntable")
	inst.components.hauntable:SetHauntValue(TUNING.HAUNT_TINY)

	inst:AddComponent("watersource")

	inst.isdamp = false
	inst.driedup = false
	inst.regrowth = false

	return inst
end
STRINGS.NAMES.KOCHO_MIKU_COS = "Snow Miku Costume"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.KOCHO_MIKU_COS = "o((>ω< ))o"
STRINGS.RECIPE_DESC.KOCHO_MIKU_COS = "Change Skin Of Clone"

STRINGS.NAMES.KOCHO_MIKU_BACK = "Backpack For Clone"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.KOCHO_MIKU_BACK = "o((>ω< ))o"
STRINGS.RECIPE_DESC.KOCHO_MIKU_BACK = "Are you too lazy and don't want to work?"

STRINGS.NAMES.KOCHOSEI_FUJI_TREE = "Cây Đ Gì Thần Kỳ v~"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.KOCHOSEI_FUJI_TREE =
	"Cây đang thi công, xin lỗi đã làm phiền, mong quý vị thông cảm, chưa biết khi nào xong nhưng sắp xong rồi ヾ(•ω•`)o\nDinh last visited: 20/01/2024"
STRINGS.NAMES.KOCHOSEI_OC_CMNDAO = "Cái Gì Đó...Giống Như Ốc Đảo"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.KOCHOSEI_OC_CMNDAO = "Có cá ở dưới hồ không nhỉ?"

return Prefab("common/inventory/kocho_miku_cos", fn, Assets),
Prefab("common/inventory/kocho_miku_back", fnback, Assets),
Prefab("kochosei_fuji_tree", cay_kocho, Assets, prefabs),
Prefab("kochosei_oc_cmndao", oc_cmndao, Assets, prefabs)
