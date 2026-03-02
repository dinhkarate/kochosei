local Assets = {Asset("ANIM", "anim/kocho_miku_cos.zip"), Asset("ANIM", "anim/kocho_miku_back.zip"),
                Asset("ANIM", "anim/kochosei_fuji_tree.zip"), Asset("IMAGE", "minimap/kochosei_apple_tree.tex"),
                Asset("ATLAS", "minimap/kochosei_apple_tree.xml"), Asset("ANIM", "anim/kochosei_tele_item.zip")}

local prefabs = {"globalmapicon"}
local RANGE_CUA_CAY_THAN_KY = 15

local small_ram_products = {"twigs", "cutgrass", "petals", "oceantree_leaf_fx_fall", "oceantree_leaf_fx_fall", "frog"}

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

local KHONG_TAG = {"player", "FX", "playerghost", "NOCLICK", "DECOR", "INLIMBO", "epic", "warg"}
local CAN_TAG = {"shadowcreature", "monster", "frog"}
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
        if player.components.debuffable and not player.components.debuffable:HasDebuff("Buff_Cay_Than_Ky") then
            player:AddDebuff("Buff_Cay_Than_Ky", "buff_moistureimmunity")
            print("Buff_Cay_Than_Ky")
        end
        local items = player.components.inventory:ReferenceAllItems()
        for _, item in ipairs(items) do
            if item.components.inventoryitem ~= nil then
                item.components.inventoryitem:DryMoisture()
            end
        end
    end
end

-- fix 23/01/2024
local function OnInit(inst)
    inst.icon = SpawnPrefab("globalmapicon")
    inst.icon:TrackEntity(inst)
end

local FIREFLY_MUST = {"firefly"}
local FIREFLY_CANT = {"FX", "NOBLOCK", "NOCLICK", "DECOR", "flying", "boat", "walkingplank", "_inventoryitem",
                      "structure"}
local function tudienbien_tuchuyenhoa(inst)
    local season = TheWorld.state.season

    if season == "winter" then
        inst.components.heater:SetThermics(true, false)
        inst.components.heater.heat = 80

    elseif season == "spring" then
        inst.components.heater:SetThermics(true, false)
        inst.components.heater.heat = 80

    elseif season == "summer" then
        inst.components.heater:SetThermics(false, true)
        inst.components.heater.heat = -30

    else
        inst.components.heater:SetThermics(false, false)
    end
end

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
                    offset = {
                        x = math.cos(angle) * radius,
                        y = 0,
                        z = math.sin(angle) * radius
                    }
                    count = count + 1

                    pos = {
                        x = x + offset.x,
                        y = 0,
                        z = z + offset.z
                    }

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
    haunter:PushEvent("respawnfromghost", {
        source = inst
    })
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
            if item.prefab == "frog" then
                item.sg:GoToState("fall")
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
local function on_player_far(inst, player)
        player:AddDebuff("Buff_Cay_Than_Ky", "buff_moistureimmunity")

end
local function cay_kocho()
    local inst = CreateEntity()
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()
    inst.entity:AddSoundEmitter()
    inst.entity:AddLight()
    -- 20/01/2024
    -- Do entity không được add minimapentity và mình đã phải vật lộn ở lỗi tại dòng thứ 152 mà không hiểu nguyên do
    -- Ngốn thêm 30p nữa
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
    inst.AnimState:PlayAnimation("idle", true)
    inst.AnimState:SetScale(1.5, 1.5)
    inst:AddTag("shelter")
    inst:AddTag("shadecanopy")

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

    inst:WatchWorldState("season", tudienbien_tuchuyenhoa)

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

    inst:AddComponent("heater")
    inst.components.heater.heat = 80

    inst:AddComponent("playerprox")
    	inst.components.playerprox:SetTargetMode(inst.components.playerprox.TargetModes.AllPlayers)
        inst.components.playerprox:SetDist(3, 10)
        inst.components.playerprox:SetOnPlayerFar(on_player_far)
    tudienbien_tuchuyenhoa(inst)

    return inst
end

local WATER_RADIUS = 3.8
local NO_DEPLOY_RADIUS = WATER_RADIUS + 0.1

local function GetFish(inst)
    return "kochosei_gift"
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
    -- inst:SetPhysicsRadiusOverride(3)

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
    -- inst.components.fishable:SetGetFishFn(GetFish)
    inst.components.fishable:AddFish("kochosei_gift")

    inst:AddComponent("hauntable")
    inst.components.hauntable:SetHauntValue(TUNING.HAUNT_TINY)

    inst:AddComponent("watersource")

    inst.isdamp = false
    inst.driedup = false
    inst.regrowth = false

    return inst
end

local function statue_death(inst)
    inst.AnimState:PlayAnimation("death")
    inst.isdead = true
    local x, y, z = inst.Transform:GetWorldPosition()

    inst:DoTaskInTime(2, function()
        local fx1 = SpawnPrefab("shadow_despawn")
        fx1.Transform:SetPosition(x, y, z)
        inst.components.talker:ShutUp()
        inst:Remove()
    end)
end

local function onhammered_statue(inst, worker)
    statue_death(inst)
end
local function onhit_statue(inst, worker)
    inst.AnimState:PlayAnimation("hit")
    inst.AnimState:PushAnimation("acting_idle1", true)

end

local function launchitem(item, angle)
    local speed = math.random() * 4 + 2
    angle = (angle + math.random() * 60 - 30) * DEGREES
    item.Physics:SetVel(speed * math.cos(angle), math.random() * 2 + 8, speed * math.sin(angle) / 2)
end

local function ontradeforgold(inst, item, giver)
    local x, y, z = inst.Transform:GetWorldPosition()
    y = 4.5

    local angle
    if giver ~= nil and giver:IsValid() then
        angle = 180 - giver:GetAngleToPoint(x, 0, z)
    else
        local down = TheCamera:GetDownVec()
        angle = math.atan2(down.z, down.x) / DEGREES
        giver = nil
    end

    for k = 1, item.components.tradable.goldvalue do
        local nug = SpawnPrefab("goldnugget")
        nug.Transform:SetPosition(x, y, z)
        launchitem(nug, angle)
    end

    if item.components.tradable.tradefor ~= nil then
        for _, v in pairs(item.components.tradable.tradefor) do
            local item = SpawnPrefab(v)
            if item ~= nil then
                item.Transform:SetPosition(x, y, z)
                launchitem(item, angle)
            end
        end
    end
end
local function OnGetItemFromPlayer(inst, giver, item)
    -- Chỉ giữ lại logic đổi vàng
    if item.components.tradable and item.components.tradable.goldvalue > 0 then
        inst.sg:GoToState("cointoss")
        inst:DoTaskInTime(2 / 3, ontradeforgold, item, giver)
    end
end

local function OnRefuseItem(inst, giver, item)
    inst.sg:GoToState("refuseeat")
end

local function AbleToAcceptTest(inst, item, giver)
    -- Đã xóa logic kiểm tra mini game, mặc định cho phép thử
    return true
end

local function AcceptTest(inst, item, giver)
    -- Chỉ chấp nhận những món đồ có thuộc tính tradable và có giá trị vàng > 0
    return item.components.tradable ~= nil and item.components.tradable.goldvalue > 0
end
local function iswinter(inst)
    local season = TheWorld.state.season
    if season == "winter" then
        inst.AnimState:OverrideSymbol("swap_object", "swap_kochosei_umbrella", "swap_kochosei_umbrella")
        inst.AnimState:Show("ARM_carry")
        inst.AnimState:Hide("ARM_normal")
        if inst.magicfx ~= nil then
            inst.magicfx:Remove()
            inst.magicfx = nil
        end
        inst.magicfx = SpawnPrefab("cane_candy_fx")
        if inst.magicfx then
            inst.magicfx.entity:AddFollower()
            inst.magicfx.entity:SetParent(inst.entity)
            inst.magicfx.Follower:FollowSymbol(inst.GUID, "swap_object", 0, -350, 3)

        end
    else
        inst.AnimState:Hide("ARM_carry")
        inst.AnimState:Show("ARM_normal")
        inst.AnimState:ClearOverrideSymbol("swap_object")
        if inst.magicfx ~= nil then
            inst.magicfx:Remove()
            inst.magicfx = nil
        end
    end

end
local function spawnfcmnx(inst)
    local dist = 0.5 * math.random()
    local theta = 2 * PI * math.random()
    local x, y, z = inst.Transform:GetWorldPosition()
    local fx = SpawnPrefab("crab_king_icefx")
    if fx then
        fx.Transform:SetPosition(x + dist * math.cos(theta), 0, z + dist * math.sin(theta))
    end
end
local function onteleport(inst)
    statue_death(inst)
end
local function kochosei_statue()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()
    inst.AnimState:Hide("ARM_carry")
    MakeObstaclePhysics(inst, 0.66)

    inst.AnimState:SetBank("wilson")
    inst.AnimState:SetBuild("kochosei_snowmiku_skin1")
    inst.AnimState:PlayAnimation("acting_idle1", true)
    inst:AddTag("statue")
    inst:AddTag("kochosei_statue")
    -- inst.Transform:SetFourFaced(inst)

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inspectable")
    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
    inst.components.workable:SetWorkLeft(4)
    inst.components.workable:SetOnFinishCallback(onhammered_statue)
    inst.components.workable:SetOnWorkCallback(onhit_statue)
    --   inst:ListenForEvent("onbuilt", onbuilt_statue)
    inst:AddComponent("talker")
    inst:DoPeriodicTask(60, function()
        inst.sg:GoToState("talk")
        inst.components.talker:Say("Bạn muốn đổi đồ à, liên hệ lông xanh tôi đây!!!")
        iswinter(inst)
    end)
    inst:DoPeriodicTask(1, spawnfcmnx)
    inst:ListenForEvent("teleport", onteleport)
    inst:SetStateGraph("SGkochosei_statue")
    -- inst:SetStateGraph("SGkochosei_enemy")

    inst:AddComponent("trader")

    inst.components.trader:SetAbleToAcceptTest(AbleToAcceptTest)
    inst.components.trader:SetAcceptTest(AcceptTest)
    inst.components.trader.onaccept = OnGetItemFromPlayer
    inst.components.trader.onrefuse = OnRefuseItem
    return inst
end

local function kochosei_statue_item()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()
    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("kochosei_tele_item")
    inst.AnimState:SetBuild("kochosei_tele_item")
    inst.AnimState:PlayAnimation("idle")
    inst.AnimState:SetScale(0.5, 0.5, 0.5)
    inst:AddTag("kochosei_statue_item")

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inspectable")

    inst:AddComponent("inventoryitem")

    inst:AddComponent("kochoseiteleport")

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
    "Cây đã thi công xong, xin lỗi đã làm phiền, mong quý vị thông cảm ヾ(•ω•`)o\nDinh last visited: 20/01/2024"
STRINGS.NAMES.KOCHOSEI_OC_CMNDAO = "Cái Gì Đó...Giống Như Ốc Đảo"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.KOCHOSEI_OC_CMNDAO = "Có ếch ở dưới hồ không nhỉ?"
STRINGS.NAMES.KOCHOSEI_STATUE = "Tượng Kochosei"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.KOCHOSEI_STATUE =     "Tượng của Kochosei... Mà người ta còn sống nhăn sao lại tạc tượng rồi?"

STRINGS.NAMES.KOCHOSEI_STATUE_ITEM = "Tele To Kochosei Statue"
STRINGS.RECIPE_DESC.KOCHOSEI_STATUE_ITEM = "Dùng nó để teleport đến chỗ có tượng Kochosei"

STRINGS.CHARACTERS.GENERIC.DESCRIBE.KOCHOSEI_STATUE_ITEM = "Dùng nó để teleport đến chỗ có tượng Kochosei"
return Prefab("kocho_miku_cos", fn, Assets), Prefab("kocho_miku_back", fnback, Assets),
    Prefab("kochosei_fuji_tree", cay_kocho, Assets, prefabs), Prefab("kochosei_oc_cmndao", oc_cmndao, Assets, prefabs),
    Prefab("kochosei_statue", kochosei_statue, Assets, prefabs),
    Prefab("kochosei_statue_item", kochosei_statue_item, Assets, prefabs),
    MakePlacer("kochosei_statue_placer", "wilson", "kochosei_snowmiku_skin1", "acting_idle1", nil, nil, nil)

