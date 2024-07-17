local Assets = {
	Asset("ANIM", "anim/kocho_miku_cos.zip"),
	Asset("ANIM", "anim/kocho_miku_back.zip"),
	Asset("ANIM", "anim/kochosei_fuji_tree.zip"),
	Asset("IMAGE", "minimap/kochosei_apple_tree.tex"),
	Asset("ATLAS", "minimap/kochosei_apple_tree.xml"),
}

local prefabs =
{
    "globalmapicon",
}

local function OnDropped(inst)
	inst.components.disappears:PrepareDisappear()
end
local function fn()
	local inst = CreateEntity()
	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddNetwork()
	inst.entity:AddSoundEmitter()
	MakeInventoryPhysics(inst)

	inst.AnimState:SetBank("kocho_miku_cos")
	inst.AnimState:SetBuild("kocho_miku_cos")
	inst.AnimState:PlayAnimation("idle")

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

local function fnback()
	local inst = CreateEntity()
	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddNetwork()
	inst.entity:AddSoundEmitter()
	inst.entity:AddLight()
	inst.Light:Enable(true) -- originally was false.
	inst.Light:SetRadius(1.1)
	inst.Light:SetFalloff(0.5)
	inst.Light:SetIntensity(0.8)
	inst.Light:SetColour(255 / 255, 255 / 255, 0 / 255)
	inst.AnimState:SetBank("kocho_miku_back")
	inst.AnimState:SetBuild("kocho_miku_back")
	inst.AnimState:PlayAnimation("idle")

	if not TheWorld.ismastersim then
		return inst
	end
	inst.entity:SetPristine()

	inst:AddComponent("disappears")
	inst.components.disappears.sound = "dontstarve/common/dust_blowaway"
	inst.components.disappears.anim = "disappear"

	inst:AddTag("preparedfood")

	inst:AddComponent("inspectable")

	inst:AddComponent("inventoryitem")

	inst:AddComponent("stackable")
	inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM

	inst:AddComponent("bait")

	inst:AddComponent("tradable")
	inst:ListenForEvent("ondropped", OnDropped)
	inst.components.disappears:PrepareDisappear()

	return inst
end

local KHONG_TAG = { "player", "FX", "playerghost", "NOCLICK", "DECOR", "INLIMBO", "epic" }
local CAN_TAG = { "shadowcreature", "monster" }


local function thithet(inst)
	local x, y, z = inst.Transform:GetWorldPosition()
	local ents = TheSim:FindEntities(x, y, z, 15, nil, KHONG_TAG, CAN_TAG)

    for i, v in ipairs(ents) do
        if v.components.health then
            local follower = v.components.follower
            if not follower or not follower.leader then
                v.components.health:Kill()
            elseif follower.leader:HasTag("player") then
                -- Đối tượng có leader và leader là người chơi, không gọi :Kill()
            else
                v.components.health:Kill()
            end
        end
    end
	local players = FindPlayersInRange(x, y, z, 15, true)

	for _, player in pairs(players) do
		player.components.temperature:SetTemperature(TUNING.BOOK_TEMPERATURE_AMOUNT)
	--	player.components.moisture:SetMoistureLevel(0)
		local items = player.components.inventory:ReferenceAllItems()
		for _, item in ipairs(items) do
			if item.components.inventoryitemmoisture ~= nil then
				item.components.inventoryitemmoisture:SetMoisture(0)
			end
		end
	end
end

--fix 23/01/2024
local function OnInit(inst)
	inst.icon = SpawnPrefab("globalmapicon")
	inst.icon:TrackEntity(inst)
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
	inst.Light:SetRadius(6)
	inst.Light:SetFalloff(1)
	inst.Light:SetIntensity(0.6)
	inst.AnimState:SetMultColour(0.7, 0.7, 0.7, 1)

	inst.MiniMapEntity:SetIcon("kochosei_apple_tree.tex")
	inst.MiniMapEntity:SetCanUseCache(false)
	inst.MiniMapEntity:SetDrawOverFogOfWar(true)
	



	inst.Light:SetColour(0.65, 0.65, 0.5)
	MakeInventoryPhysics(inst)

	inst.AnimState:SetBank("kochosei_fuji_tree")
	inst.AnimState:SetBuild("kochosei_fuji_tree")
	inst.AnimState:PlayAnimation("idle")
	inst.AnimState:SetScale(1.5, 1.5)
	inst:AddTag("shelter")
	if not TheWorld.ismastersim then
		return inst
	end

	inst:DoTaskInTime(0, OnInit)
	


	inst:AddTag("kochosei_fuji_tree")
	inst:AddTag("shelter")
	inst.entity:SetPristine()
	MakeSmallPropagator(inst)

	inst:AddComponent("sanityaura")
	inst.components.sanityaura.aura = TUNING.SANITYAURA_SMALL

	inst:AddComponent("inspectable")

	inst:DoPeriodicTask(2, thithet)
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
    inst.components.fishable.maxfish = TUNING.OASISLAKE_MAX_FISH
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

STRINGS.NAMES.KOCHOSEI_FUJI_TREE = "Cây Thần Kỳ... Chắc Thế"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.KOCHOSEI_FUJI_TREE =
	"Cây đang thi công, xin lỗi đã làm phiền, mong quý vị thông cảm, chưa biết khi nào xong nhưng chắc còn lâu ヾ(•ω•`)o\nDinh last visited: 20/01/2024"
STRINGS.NAMES.KOCHOSEI_OC_CMNDAO = "Cây Thần Kỳ... Chắc Thế"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.KOCHOSEI_OC_CMNDAO =
	"Cây đang thi công, xin lỗi đã làm phiền, mong quý vị thông cảm, chưa biết khi nào xong nhưng chắc còn lâu ヾ(•ω•`)o\nDinh last visited: 20/01/2024"

return Prefab("common/inventory/kocho_miku_cos", fn, Assets),
	Prefab("common/inventory/kocho_miku_back", fnback, Assets),
	Prefab("kochosei_fuji_tree", cay_kocho, Assets, prefabs),
		Prefab("kochosei_oc_cmndao", oc_cmndao, Assets, prefabs)

