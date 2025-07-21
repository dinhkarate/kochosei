-- Tối ưu hóa mã "kochosei_thien_su_ban_phuc.lua"

local kochosei_thiensu_assets = {
    Asset("ANIM", "anim/swap_thiensu_xanh.zip"),
    Asset("ANIM", "anim/thiensu_xanh.zip"),
    Asset("ANIM", "anim/swap_thiensu_hong.zip"),
    Asset("ANIM", "anim/thiensu_hong.zip"),
    Asset("ANIM", "anim/swap_thiensu_cam.zip"),
    Asset("ANIM", "anim/thiensu_cam.zip"),
    Asset("ANIM", "anim/doro_xamchiemtraidat.zip"),
    Asset("ANIM", "anim/swap_doro_xamchiemtraidat.zip"),
}

local EQUIP_SYMBOL_MAP = {
    kochosei_thien_su_ban_phuc_xanh = "swap_thiensu_xanh",
    kochosei_thien_su_ban_phuc_hong = "swap_thiensu_hong",
    kochosei_thien_su_ban_phuc_cam  = "swap_thiensu_cam",
    doro_xamchiemtraidat            = "swap_doro_xamchiemtraidat",
}

local function onequip(inst, owner)
    local symbol = EQUIP_SYMBOL_MAP[inst.prefab]
    if symbol then
        owner.AnimState:OverrideSymbol("swap_object", symbol, symbol)
    end
    owner.AnimState:Show("ARM_carry")
    owner.AnimState:Hide("ARM_normal")
end

local function onunequip(inst, owner)
    owner.AnimState:Hide("ARM_carry")
    owner.AnimState:Show("ARM_normal")
end

local function onthrown(inst)
    inst:AddTag("NOCLICK")
    inst.persists = false
    inst.AnimState:PlayAnimation("spin_loop", true)
    inst.Physics:SetMass(1)
    inst.Physics:SetCapsule(0.2, 0.2)
    inst.Physics:SetFriction(0)
    inst.Physics:SetDamping(0)
    inst.Physics:SetCollisionGroup(COLLISION.CHARACTERS)
    inst.Physics:ClearCollisionMask()
    inst.Physics:CollidesWith(COLLISION.GROUND)
    inst.Physics:CollidesWith(COLLISION.OBSTACLES)
    inst.Physics:CollidesWith(COLLISION.ITEMS)
end

local function ReticuleTargetFn()
    local player = ThePlayer
    local ground = TheWorld.Map
    local pos = Vector3()
    for r = 6.5, 3.5, -0.25 do
        pos.x, pos.y, pos.z = player.entity:LocalToWorldSpace(r, 0, 0)
        if ground:IsPassableAtPoint(pos:Get()) and not ground:IsGroundTargetBlocked(pos) then
            return pos
        end
    end
    return pos
end

local function onuseaswatersource(inst)
    if inst.components.stackable:IsStack() then
        inst.components.stackable:Get():Remove()
    else
        inst:Remove()
    end
end
local PI = math.pi
local Rn = 6       -- Maximum radius
local Zn = 5       -- Effect duration
local DENSITY = 1.3 -- Adjustable density (reduced for better outer circle)

-- Generate circular points with improved distribution
local function GenerateCircularPoints()
    local points = {}
    local min_radius = 1.0 -- Smaller minimum radius for center coverage
    
    for radius = Rn, min_radius, -1.2 do -- Smaller steps for smoother distribution
        -- Improved density calculation for outer circles
        local base_density = DENSITY * (0.8 + (radius/Rn)^1.5) -- Better outer circle density
        local circumference = 2 * PI * radius
        
        -- Minimum segments for outer circles to prevent sparse appearance
        local min_segments = math.max(8, math.floor(radius * 5.5)) -- Ensure minimum density
        local calc_segments = math.floor(circumference / base_density)
        local segments = math.max(min_segments, calc_segments)
        
        -- Golden angle for optimal distribution (137.5 degrees in radians)
        local golden_angle = 2.39996
        local offset = (radius % 2) * golden_angle/3 -- Reduced offset for better alignment
        
        for i = 1, segments do
            local angle = (golden_angle * i) + offset
            local x = math.cos(angle) * radius
            local z = math.sin(angle) * radius
            table.insert(points, {
                pos = Vector3(x, 0, z),
                radius = radius,
                angle = angle, -- Store angle for sequencing
                segment_index = i,
                total_segments = segments
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

local function thiensu_xanh(inst)
    local pos = Vector3(inst.Transform:GetWorldPosition())
    
    -- Water splash effect
    local splash = SpawnPrefab("waterballoon_splash")
    if splash then splash.Transform:SetPosition(pos:Get()) end
    
    -- Resurrection + health buff
    inst.components.wateryprotection:SpreadProtection(inst)
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

local function thiensu_hong(inst)
    SpawnPrefab("sporecloud").Transform:SetPosition(inst.Transform:GetWorldPosition())
    local dungnham = SpawnPrefab("lavae")
    dungnham.Transform:SetPosition(inst.Transform:GetWorldPosition())
    dungnham.components.combat:SetRetargetFunction(1, function(inst)
        return FindEntity(inst, 16, function(guy)
            return inst.components.combat:CanTarget(guy)
        end, {"_combat"}, {"prey", "smallcreature", "INLIMBO"})
    end)
end

local function thiensu_cam(inst)
    SpawnPrefab("explode_small").Transform:SetPosition(inst.Transform:GetWorldPosition())
    inst.components.explosive:OnBurnt()
end

local function doro_xamchiemtraidat(inst, attacker, target, pos)
    inst:AddTag("NOCLICK")
    inst:AddTag("NOBLOCK")
    pos = pos or Vector3(inst.Transform:GetWorldPosition())
    local spacing = 1.3
    for i = -1, 1 do
        for j = -1, 1 do
            local x = pos.x + i * spacing
            local z = pos.z + j * spacing
            TheWorld.Map:CollapseSoilAtPoint(x, 0, z)
            SpawnPrefab("farm_soil").Transform:SetPosition(x, 0, z)
        end
    end
    attacker.components.talker:Say("Điên à, ném ra đất làm gì?")
end

local ON_HIT_BEHAVIOR = {
    kochosei_thien_su_ban_phuc_xanh = function(inst) thiensu_xanh(inst) end,
    kochosei_thien_su_ban_phuc_hong = function(inst) thiensu_hong(inst) end,
    kochosei_thien_su_ban_phuc_cam  = function(inst) thiensu_cam(inst) end,
    doro_xamchiemtraidat = function(inst, a, t, p) doro_xamchiemtraidat(inst, a, t, p) end,
}

local function OnHitWater(inst, attacker, target, pos)
    local handler = ON_HIT_BEHAVIOR[inst.prefab]
    if handler then handler(inst, attacker, target, pos) end
    inst:Remove()
end

local function common_fn(bank, build)
    local inst = CreateEntity()
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)
    inst:AddTag("weapon")
    inst:AddTag("projectile")
    inst:AddTag("watersource")
    inst.AnimState:SetBank(bank)
    inst.AnimState:SetBuild(build)
    inst.AnimState:PlayAnimation("idle", true)

    inst:AddComponent("reticule")
    inst.components.reticule.targetfn = ReticuleTargetFn
    inst.components.reticule.ease = true

    MakeInventoryFloatable(inst, "med", 0.05, 0.65)
    inst.entity:SetPristine()

    if not TheWorld.ismastersim then return inst end

    inst:AddComponent("locomotor")
    inst:AddComponent("wateryprotection")
    inst.components.wateryprotection.extinguishheatpercent = TUNING.WATERBALLOON_EXTINGUISH_HEAT_PERCENT
    inst.components.wateryprotection.temperaturereduction = TUNING.WATERBALLOON_TEMP_REDUCTION
    inst.components.wateryprotection.witherprotectiontime = TUNING.WATERBALLOON_PROTECTION_TIME
    inst.components.wateryprotection.addwetness = TUNING.WATERBALLOON_ADD_WETNESS

    inst:AddComponent("complexprojectile")
    inst.components.complexprojectile:SetHorizontalSpeed(15)
    inst.components.complexprojectile:SetGravity(-35)
    inst.components.complexprojectile:SetLaunchOffset(Vector3(0.25, 1, 0))
    inst.components.complexprojectile:SetOnLaunch(onthrown)
    inst.components.complexprojectile:SetOnHit(OnHitWater)

    inst:AddComponent("weapon")
    inst.components.weapon:SetDamage(0)
    inst.components.weapon:SetRange(8, 14)

    inst:AddComponent("inspectable")
    inst:AddComponent("inventoryitem")
    inst:AddComponent("stackable")
    inst:AddComponent("equippable")
    inst.components.equippable:SetOnEquip(onequip)
    inst.components.equippable:SetOnUnequip(onunequip)
    inst.components.equippable.equipstack = true

    inst:AddComponent("watersource")
    inst.components.watersource.onusefn = onuseaswatersource
    inst.components.watersource.override_fill_uses = 10

    MakeHauntableLaunch(inst)
    return inst
end

local PREFAB_DEFS = {
    kochosei_thien_su_ban_phuc_xanh = { bank = "thiensu_xanh", build = "thiensu_xanh" },
    kochosei_thien_su_ban_phuc_hong = { bank = "thiensu_hong", build = "thiensu_hong" },
    kochosei_thien_su_ban_phuc_cam  = { bank = "thiensu_cam",  build = "thiensu_cam", extra = "explosive" },
    doro_xamchiemtraidat            = { bank = "doro_xamchiemtraidat", build = "doro_xamchiemtraidat" },
}

local function MakePrefab(prefabname)
    local def = PREFAB_DEFS[prefabname]
    local function fn()
        local inst = common_fn(def.bank, def.build)
        if TheWorld.ismastersim and def.extra == "explosive" then
            inst:AddComponent("explosive")
        end
        return inst
    end
    return Prefab(prefabname, fn, kochosei_thiensu_assets)
end

-- String definitions (giữ nguyên)
STRINGS.NAMES.KOCHOSEI_THIEN_SU_BAN_PHUC_XANH = "Thiên Sứ Ban Phúc"
STRINGS.NAMES.KOCHOSEI_THIEN_SU_BAN_PHUC_HONG = "Thiên Sứ Ban Lộc"
STRINGS.NAMES.KOCHOSEI_THIEN_SU_BAN_PHUC_CAM = "Thiên Sứ Ban Lửa"
STRINGS.NAMES.DORO_XAMCHIEMTRAIDAT = "Doro Xâm Chiếm Trái Đất"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.KOCHOSEI_THIEN_SU_BAN_PHUC_XANH = "Hàng nhái kém chất lượng"
STRINGS.RECIPE_DESC.KOCHOSEI_THIEN_SU_BAN_PHUC_XANH = "Không phải chúng ta đã thề sẽ quét sạch mod và đám author ra khỏi dst sao?"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.KOCHOSEI_THIEN_SU_BAN_PHUC_HONG = "Hàng nhái kém chất lượng"
STRINGS.RECIPE_DESC.KOCHOSEI_THIEN_SU_BAN_PHUC_HONG = "Không phải chúng ta đã thề sẽ quét sạch mod và đám author ra khỏi dst sao?"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.KOCHOSEI_THIEN_SU_BAN_PHUC_CAM = "Hàng nhái kém chất lượng"
STRINGS.RECIPE_DESC.KOCHOSEI_THIEN_SU_BAN_PHUC_CAM = "Không phải chúng ta đã thề sẽ quét sạch mod và đám author ra khỏi dst sao?"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.DORO_XAMCHIEMTRAIDAT = "Hàng nhái kém chất lượng"
STRINGS.RECIPE_DESC.DORO_XAMCHIEMTRAIDAT = "Chế xong rồi ném ra đất?"

-- Return all prefabs
local prefabs = {}
for name, _ in pairs(PREFAB_DEFS) do
    table.insert(prefabs, MakePrefab(name))
end
return unpack(prefabs)
