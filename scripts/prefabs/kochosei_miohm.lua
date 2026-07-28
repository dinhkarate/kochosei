local assets = {Asset("ANIM", "anim/miohm.zip"), Asset("ANIM", "anim/swap_miohm.zip"),
                Asset("ANIM", "anim/swap_kochosei_purplebattleaxe.zip"),
                Asset("ANIM", "anim/kochosei_purplebattleaxe.zip")}

local prefabs = {"lavaarena_creature_teleport_small_fx"}

local function onattack(inst, attacker, target)
    if target ~= nil and target:IsValid() and attacker ~= nil and attacker:IsValid() then
        SpawnPrefab("electrichitsparks"):AlignToTarget(target, attacker, true)
        SpawnPrefab("electricchargedfx").Transform:SetPosition(target.Transform:GetWorldPosition())
        SpawnPrefab("superjump_fx").Transform:SetPosition(target.Transform:GetWorldPosition())
    end
end

local function IsDay()
    return TheWorld.state.isday
end

local function onremovefire(fire)
    fire.miohm.fire = nil
end
local function TurnOn(inst)
    local owner = inst.components.inventoryitem ~= nil and inst.components.inventoryitem.owner or nil
    if owner ~= nil and owner:HasTag("player") then
        if inst.fire == nil then
            inst.fire = SpawnPrefab("miohammer_light")
            inst.fire.miohm = inst
            inst:ListenForEvent("onremove", onremovefire, inst.fire)
        end
        if not IsDay() then
            inst.fire.entity:SetParent(owner.entity)
        end
    end
end

local function TurnOff(inst)
    local owner = inst.components.inventoryitem ~= nil and inst.components.inventoryitem.owner or nil
    if owner ~= nil and owner:HasTag("player") then
        if inst.fire ~= nil then
            inst.fire:Remove()
        end
    end
end

local function OnEquip(inst, owner)
    local spell = SpawnPrefab("electricchargedfx")
    spell.Transform:SetPosition(owner.Transform:GetWorldPosition())

    local skin_build = inst:GetSkinBuild()
    if skin_build ~= nil then
        owner:PushEvent("equipskinneditem", inst:GetSkinName())
        owner.AnimState:OverrideSymbol("swap_object", skin_build, skin_build)
    else
        owner.AnimState:OverrideSymbol("swap_object", "swap_miohm", "swap_miohm")
    end
    owner.AnimState:Show("ARM_carry")
    owner.AnimState:Hide("ARM_normal")
    if IsDay() then
        TurnOff(inst)
    else
        TurnOn(inst)
    end
end

local function OnUnequip(inst, owner)
    owner.AnimState:Hide("ARM_carry")
    owner.AnimState:Show("ARM_normal")
    TurnOff(inst)
end

local function UpdateItemState(inst)
    if TheWorld.state.isday ~= inst._is_day then
        if TheWorld.state.isday then
            TurnOff(inst)
        else
            TurnOn(inst)
        end
        inst._is_day = TheWorld.state.isday
    end
end

local function OnUpdate(inst)
    if inst.components.equippable and inst.components.equippable:IsEquipped() then
        UpdateItemState(inst)
    end
end

local function light_fn()
    local inst = CreateEntity()
    inst.entity:AddTransform()
    inst.entity:AddLight()
    inst.entity:AddNetwork()
    inst.Light:SetIntensity(0.75)
    inst.Light:SetColour(252 / 255, 251 / 255, 237 / 255)
    inst.Light:SetFalloff(0.8)
    inst.Light:SetRadius(2)
    inst.Light:Enable(true)
    inst:AddTag("FX")
    if not TheWorld.ismastersim then
        return inst
    end

    inst.persists = false
    return inst
end

local function freezeSpell(inst, target)
    local weaponDamage = inst.components.weapon.damage + inst.components.planardamage.basedamage or 1
    local attacker = inst.components.inventoryitem.owner
    if target.components.sleeper ~= nil and target.components.sleeper:IsAsleep() then
        target.components.sleeper:WakeUp()
    end
    if target.components.burnable ~= nil then
        if target.components.burnable:IsBurning() then
            target.components.burnable:Extinguish()
        elseif target.components.burnable:IsSmoldering() then
            target.components.burnable:SmotherSmolder()
        end
    end
    if target.components.combat ~= nil then
        target.components.combat:SuggestTarget(attacker)
    end

    if target.components.freezable ~= nil then
        target:PushEvent("attacked", {
            attacker = attacker,
            damage = 0,
            weapon = inst
        })
        if target.components.health then
            target.components.health:DoDelta(-(TUNING.MIOHM_DAMAGE_SPELL + weaponDamage))
        end
        local x, y, z = target.Transform:GetWorldPosition()
        local spell = SpawnPrefab("deer_ice_flakes")
        if spell ~= nil then
            spell.Transform:SetPosition(x, y, z)
            spell:DoTaskInTime(1, spell.KillFX)
            SpawnPrefab("deer_ice_burst").Transform:SetPosition(x, y, z)
            SpawnPrefab("superjump_fx").Transform:SetPosition(x, y, z)
            SpawnPrefab("electricchargedfx").Transform:SetPosition(x, y, z)
        end
    end
end

local MIOHM_CANT_TAGS = {"DECOR", "FX", "INLIMBO", "NOCLICK", "playerghost", "player", "beefalo"}

local function aoeSpell(inst, target, caster)
    caster = inst.components.inventoryitem.owner or target or caster

    if caster.components.sanity.current <= 50 then
        caster.components.talker:Say("My sanity is not enough!!")
        return
    end

    if caster.components.hunger.current <= 50 then
        caster.components.talker:Say("My hunger is not enough!!")
        return
    end

    if target:HasTag("beefalo") then
        caster.components.talker:Say("Please don't!!, We are goodfriend! :>")
        return
    end

    caster.components.talker:Say("Thunder attack!")

    if type(TUNING.MIOHM_DURABILITY) == "number" then
        inst.components.finiteuses:Use(10)
    end

    caster.components.sanity:DoDelta(-10)
    caster.components.hunger:DoDelta(-10)

    local x, y, z = target.Transform:GetWorldPosition()
    local ents = TheSim:FindEntities(x, y, z, 7, {"freezable"}, MIOHM_CANT_TAGS)

    local damage = 0
    if target.components.health and TUNING.KOCHOSEI_VANILLA_MODE == 1 then
        damage = target.components.health.maxhealth / 30
    end

    -- Freeze AOE vẫn giữ nguyên
    for _, ent in pairs(ents) do
        freezeSpell(inst, ent)
    end

    -- ✅ Không gây damage nếu là player
    if not target:HasTag("player") then
        local healthComponent = target.components.health
        if healthComponent and healthComponent.currenthealth > 100000 then
            healthComponent:DoDelta(-damage)
        end
    end

    -- FX vẫn giữ nguyên
    local lightningfx = SpawnPrefab("lavaarena_creature_teleport_small_fx")
    lightningfx.Transform:SetPosition(x, y, z)

local lightningPrefab = "kochosei_moonstorm_ground_lightning_fx"
local numLightnings = 8 -- Số lượng tia sét (tăng lên để vòng tròn đầy đặn hơn)
local radius = 3        -- Khoảng cách từ tâm đến tia sét

for i = 1, numLightnings do
    -- Tính toán góc cho mỗi tia sét (đơn vị là Radian)
    -- Chia 2*PI (360 độ) cho tổng số lượng tia sét
    local angle = (i - 1) * (2 * math.pi / numLightnings)
    
    -- Tính tọa độ x và z dựa trên góc và bán kính
    local dx = radius * math.cos(angle)
    local dz = radius * math.sin(angle)
    
    local lightning = SpawnPrefab(lightningPrefab)
    if lightning ~= nil then
        -- Đặt vị trí cho tia sét tỏa ra xung quanh tâm (x, z)
        lightning.Transform:SetPosition(x + dx, y, z + dz)
        
        -- (Tùy chọn) Xoay tia sét hướng về tâm hoặc theo hướng tỏa ra
        -- Chuyển đổi từ Radian sang Độ (Degrees) vì SetRotation dùng Độ
        lightning.Transform:SetRotation(-angle * RADIANS) 
    end
end

    if not inst.components.timer:TimerExists("miohmcrabking") then
        local freeze_fx = SpawnPrefab("kochosei_crabking_feeze")
        freeze_fx.Transform:SetPosition(x, y, z)
        inst.components.timer:StartTimer("miohmcrabking", 15)
    end
    if target == caster then
        caster:DoTaskInTime(0.2, function()
            caster.sg:GoToState("hit")

        end)
    end
end

local function castFreeze(inst, target)
    if target ~= nil and target:IsValid() and target.components.health then
        aoeSpell(inst, target)
    end
end

-------------level-------------------

local function applyupgrades(inst)
    local maxUpgrades = TUNING.KOCHOSEI_MAX_LEVEL + (TUNING.KOCHOSEI_CHECKWIFI * 2)

    -- Lấy level hiện tại
    local level = inst.levelmiohm or 0

    -- Nếu vượt maxUpgrades, tính phần dư với hệ số giảm 20 lần
    local upgrades
    if level > maxUpgrades then
        local extra = (level - maxUpgrades) / 20
        upgrades = maxUpgrades + extra
    else
        upgrades = level
    end

    -- Tính damage cơ bản
    local damage = upgrades + TUNING.MIOHM_DAMAGE

    -- Kiểm tra VANILLA_MODE: Nếu bật, damage tối đa không vượt quá MAX_LEVEL
    if TUNING.KOCHOSEI_VANILLA_MODE == 1 then
        damage = math.min(damage, TUNING.KOCHOSEI_MAX_LEVEL)
    end

    -- Áp dụng damage vào component
    if inst.caybuasidanay == 1 then
        inst.components.weapon:SetDamage(TUNING.MIOHM_DAMAGE)
        inst.components.planardamage:SetBaseDamage(damage)
    else
        inst.components.weapon:SetDamage(damage)
        inst.components.planardamage:SetBaseDamage(TUNING.MIOHM_DAMAGE)
    end
end

local function onUse(inst, owner)
    inst.caybuasidanay = 1 - inst.caybuasidanay
    applyupgrades(inst)

    if inst.components.inventoryitem.owner then
        local weaponDamage = inst.components.weapon.damage
        local planarDamage = inst.components.planardamage.basedamage
        inst.components.inventoryitem.owner.components.talker:Say(string.format(
            "Đã đổi loại, Damage mặc định %d, Damage xuyên giáp %d", weaponDamage, planarDamage), nil,
            nil, nil, nil, {255 / 255, 255 / 255, 0 / 255, 1})
    end
    return false -- Sora id daze bezt, làm như này ngăn nó bị biến mất khi đã dùng
end

local function OnSave(inst, data)
    data.levelmiohm = inst.levelmiohm
end
local function OnLoad(inst, data)
    if data then
        inst.levelmiohm = data.levelmiohm or 0
        applyupgrades(inst)
    end
end

-------------level-------------------
-------------Sửa Chữa----------------

local function OnGetItemFromPlayer(inst, giver, item, count)
    count = count or 1
    if item.prefab == "goldnugget" then
        for i = 1, count do
            inst.levelmiohm = inst.levelmiohm + TUNING.KOCHOSEI_PER_KILL + (TUNING.KOCHOSEI_CHECKWIFI / 50)
            print("MioHM level up: " .. inst.levelmiohm)
            applyupgrades(inst)
            if type(TUNING.MIOHM_DURABILITY) == "number" then
                local doben = inst.components.finiteuses:GetUses() + 50
                inst.components.finiteuses:SetUses(math.min(doben, TUNING.MIOHM_DURABILITY))
            end
        end
    end
end

-- Đau Lưng vaelu--
local function OnRefuseItem(inst, giver, item)
    if item.prefab ~= "goldnugget" then
        giver.components.talker:Say("Only Gold", nil, nil, nil, nil, {255 / 0, 255 / 0, 0 / 255, 1})
    end
end

local function AcceptTest(inst, item)
    return item.prefab == "goldnugget"
end
-------------Sửa Chữa----------------

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("miohm")
    inst.AnimState:SetBuild("miohm")
    inst.AnimState:PlayAnimation("idle")

    inst:AddTag("kochoseiweapon")
    inst:AddTag("miohm")
    inst:AddTag("lightningrod")
    MakeInventoryFloatable(inst, "small", 0.1, 1.12)
    -- Glow in the Dark!
    inst.entity:AddLight()
    inst.Light:Enable(true) -- originally was false.
    inst.Light:SetRadius(1.1)
    inst.Light:SetFalloff(0.5)
    inst.Light:SetIntensity(0.8)
    inst.Light:SetColour(255 / 255, 255 / 255, 0 / 255)

    if not TheWorld.ismastersim then
        return inst
    end
    inst:AddTag("kochoseiweapon")
    inst.cantrader = function(inst, giver, item)
        -- ví dụ: chỉ nhận tối đa 10 item một lần
        return math.min(item.components.stackable.stacksize, 10)
    end
    inst.entity:SetPristine()

    inst:AddComponent("weapon")
    inst.components.weapon:SetDamage(TUNING.MIOHM_DAMAGE)
    inst.components.weapon:SetOnAttack(onattack)
    inst.components.weapon:SetRange(1, 8)

    inst:AddComponent("planardamage")

    inst:AddComponent("tool")
    inst.components.tool:SetAction(ACTIONS.MINE, 3) 
    inst.components.tool:SetAction(ACTIONS.HAMMER, 1.2)

    if type(TUNING.MIOHM_DURABILITY) == "number" then -- Giá trị của TUNING.KOCHOSEI_CHECKMOD là một số
        inst:AddComponent("finiteuses")
        inst.components.finiteuses:SetMaxUses(TUNING.MIOHM_DURABILITY)
        inst.components.finiteuses:SetUses(TUNING.MIOHM_DURABILITY)
        inst.components.finiteuses:SetOnFinished(inst.Remove)
    end

    inst:AddComponent("inspectable")

    inst:AddComponent("useableitem") -- Đổi damage sang dạng bình thường, tránh 1 số mod ghi đè planardamage khiến cây búa trở nên kỳ lạ
    inst.components.useableitem:SetOnUseFn(onUse)

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.keepondeath = true
    inst.fxcolour = {21 / 255, 25 / 255, 242 / 255}
    inst:AddComponent("spellcaster")
    inst.components.spellcaster:SetSpellFn(castFreeze)
    inst.components.spellcaster.canuseontargets = true
    inst.components.spellcaster.canonlyuseonlocomotors = true
    inst.components.spellcaster.quickcast = true

    inst:AddComponent("equippable")
    inst.components.equippable.restrictedtag = "kochosei"
    inst.components.equippable:SetOnEquip(OnEquip)
    inst.components.equippable:SetOnUnequip(OnUnequip)
    inst.components.inventoryitem.keepondeath = true
    inst.components.equippable.walkspeedmult = TUNING.CANE_SPEED_MULT
    inst:AddComponent("trader")
    -- Oke dinh, bỏ vào đây luôn, sau này bị sida dinh bảo trì hết, khỏi lo )

    local oldAcceptGift = inst.components.trader.AcceptGift
    inst.components.trader.AcceptGift = function(self, giver, item, count)
        if item.components.stackable and count == nil then
            if self.inst.cantrader then
                count = self.inst:cantrader(giver, item)
            else
                count = item.components.stackable.stacksize
            end

            if count < 1 then
                count = 1
            end
        end

        return oldAcceptGift(self, giver, item, count)
    end

    inst.components.trader:SetAcceptTest(AcceptTest)
    inst.components.trader.onaccept = OnGetItemFromPlayer
    inst.components.trader.onrefuse = OnRefuseItem

    inst:DoPeriodicTask(0.2, OnUpdate)

    inst:AddComponent("timer")

    inst:AddComponent("cuocdoiquabatcongdi")
    inst.components.cuocdoiquabatcongdi:Vukhi()

    inst.lights = {}

    inst:DoPeriodicTask(5, function()
        local owner = inst.components.inventoryitem ~= nil and inst.components.inventoryitem.owner or nil
        if owner == nil then -- owner có thể là rương, balo v...v nên không cần thiết phải ra fx, nó chỉ fx khi dưới măt đất thôi
            local fx = SpawnPrefab("electricchargedfx")
            fx.Transform:SetPosition(inst.Transform:GetWorldPosition())
        end
    end)
    MakeHauntableLaunch(inst)

    -------------level-------------------
    inst.levelmiohm = 0
    applyupgrades(inst)
    inst.OnSave = OnSave
    inst.OnLoad = OnLoad
    inst.applyupgrades = applyupgrades
    inst.caybuasidanay = 0 -- con cò
    -------------level-------------------

    return inst
end
if TUNING.KOCHOSEI_CHECKMOD ~= 1 and Kochoseiapi.MakeItemSkin ~= nil then
    Kochoseiapi.MakeItemSkin("miohm", "swap_kochosei_purplebattleaxe", {
        name = "Purple Battle Axe",
        atlas = "images/inventoryimages/kochosei_inv.xml",
        image = "kochosei_purplebattleaxe_icon",
        build = "kochosei_purplebattleaxe",
        bank = "kochosei_purplebattleaxe",
        basebuild = "miohm",
        basebank = "miohm"
    })
    Kochoseiapi.MakeItemSkin("kocho_purplesword", "swap_new_nier_sword2", {
        name = "Cây Kiếm Của Ông Mạ Non, Trông Mẻ Mẻ Nhưng Hình Như Vẫn Dùng Được",
        atlas = "images/inventoryimages/kochosei_inv.xml",
        image = "swap_new_nier_sword2",
        build = "new_nier_sword2",
        bank = "new_nier_sword2",
        basebuild = "kocho_purplesword",
        basebank = "kocho_purplesword"
    })

end
STRINGS.NAMES.MIOHM = "MioHM"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.MIOHM = "Woaaah, i want it!! XD"
STRINGS.RECIPE_DESC.MIOHM = "Electric hammer"

return Prefab("miohm", fn, assets, prefabs), Prefab("miohammer_light", light_fn)
