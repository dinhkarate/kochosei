local assets = {
    Asset("ANIM", "anim/kochobook.zip"),
    --Asset("INV_IMAGE", "waxwelljournal_open"),
    Asset("ATLAS", "images/inventoryimages/kochospell.xml"),
    Asset("IMAGE", "images/inventoryimages/kochospell.tex"),
}

local prefabs = {}

local IDLE_SOUND_VOLUME = 0.5
local GARDENING_CANT_TAGS = { "pickable", "stump", "withered", "barren", "INLIMBO" }

local function trygrowth(inst, maximize)
    if
        not inst:IsValid()
        or inst:IsInLimbo()
        or (inst.components.witherable ~= nil and inst.components.witherable:IsWithered())
    then
        return false
    end

    if inst:HasTag("leif") then
        inst.components.sleeper:GoToSleep(1000)
        return true
    end

    if maximize then
        MaximizePlant(inst)
    end

    if inst.components.growable ~= nil then
        -- If we're a tree and not a stump, or we've explicitly allowed magic growth, do the growth.
        if
            inst.components.growable.magicgrowable
            or ((inst:HasTag("tree") or inst:HasTag("winter_tree")) and not inst:HasTag("stump"))
        then
            if inst.components.simplemagicgrower ~= nil then
                inst.components.simplemagicgrower:StartGrowing()
                return true
            elseif inst.components.growable.domagicgrowthfn ~= nil then
                -- The upgraded horticulture book has a delayed start to make sure the plants get tended to first
                inst.magic_growth_delay = maximize and 2 or nil
                inst.components.growable:DoMagicGrowth()

                return true
            else
                return inst.components.growable:DoGrowth()
            end
        end
    end

    if inst.components.pickable ~= nil then
        if inst.components.pickable:CanBePicked() and inst.components.pickable.caninteractwith then
            return false
        end
        if inst.components.pickable:FinishGrowing() then
            inst.components.pickable:ConsumeCycles(1) -- magic grow is hard on plants
            return true
        end
    end

    if inst.components.crop ~= nil and (inst.components.crop.rate or 0) > 0 then
        if inst.components.crop:DoGrow(1 / inst.components.crop.rate, true) then
            return true
        end
    end

    if
        inst.components.harvestable ~= nil
        and inst.components.harvestable:CanBeHarvested()
        and inst:HasTag("mushroom_farm")
    then
        if inst.components.harvestable:IsMagicGrowable() then
            inst.components.harvestable:DoMagicGrowth()
            return true
        else
            if inst.components.harvestable:Grow() then
                return true
            end
        end
    end

    return false
end

--------------------------------------------------------------------------

local function kochospell4(inst, doer, pos)
    for k, v in pairs(AllPlayers) do
        v:PushEvent("respawnfromghost")
        v.rezsource = "Tự nhiên hồi sinh, ai biết gì đâu"
    end
    if doer.components.sanity then
        doer.components.sanity:DoDelta(-100)
    end
end

local function kochospell3(inst, doer, pos)
    if doer.components.sanity then
        doer.components.sanity:DoDelta(-100)
    end
    local x, y, z = doer.Transform:GetWorldPosition()
    local range = 50
    local ents = TheSim:FindEntities(x, y, z, range, nil, GARDENING_CANT_TAGS)
    if #ents > 0 then
        trygrowth(table.remove(ents, math.random(#ents)))
        if #ents > 0 then
            local timevar = 1 - 1 / (#ents + 1)
            for i, v in ipairs(ents) do
                v:DoTaskInTime(timevar * math.random(), trygrowth)
            end
        end
    end
end

local function rainfn(inst, doer, pos)
    if doer.components.sanity then
        doer.components.sanity:DoDelta(-100)
    end
    if TheWorld.state.precipitation ~= "none" then
        TheWorld:PushEvent("ms_forceprecipitation", false)
    else
        TheWorld:PushEvent("ms_forceprecipitation", true)
    end

    local x, y, z = doer.Transform:GetWorldPosition()
    local size = TILE_SCALE

    for i = x - size, x + size do
        for j = z - size, z + size do
            if TheWorld.Map:GetTileAtPoint(i, 0, j) == WORLD_TILES.FARMING_SOIL then
                TheWorld.components.farming_manager:AddSoilMoistureAtPoint(i, y, j, 100)
            end
        end
    end
end

local function fullmoonfn(inst, doer, pos)
    if doer.components.sanity then
        doer.components.sanity:DoDelta(-100)
    end
    if TheWorld:HasTag("cave") then
        return false, "NOMOONINCAVES"
    elseif TheWorld.state.moonphase == "full" then
        return false, "ALREADYFULLMOON"
    end

    TheWorld:PushEvent("ms_setmoonphase", { moonphase = "full" })
end

local function ReticuleTargetAllowWaterFn()
    local player = ThePlayer
    local ground = TheWorld.Map
    local pos = Vector3()
    --Cast range is 8, leave room for error
    --4 is the aoe range
    for r = 7, 0, -0.25 do
        pos.x, pos.y, pos.z = player.entity:LocalToWorldSpace(r, 0, 0)
        if ground:IsPassableAtPoint(pos.x, 0, pos.z, true) and not ground:IsGroundTargetBlocked(pos) then
            return pos
        end
    end
    return pos
end

local function StartAOETargeting(inst)
    local playercontroller = ThePlayer.components.playercontroller
    if playercontroller ~= nil then
        playercontroller:StartAOETargetingUsing(inst)
    end
end

local ICON_SCALE = 0.6
local ICON_RADIUS = 50
local SPELLBOOK_RADIUS = 100
local SPELLBOOK_FOCUS_RADIUS = SPELLBOOK_RADIUS + 2
local SPELLSKOCHO = {
    {
        label = STRINGS.SPELLS.KOCHO_1,
        onselect = function(inst)
            inst.components.spellbook:SetSpellName(STRINGS.SPELLS.KOCHO_1)
            inst.components.aoetargeting:SetDeployRadius(0)
            inst.components.aoetargeting:SetShouldRepeatCastFn(nil)
            inst.components.aoetargeting.reticule.reticuleprefab = "reticuleaoe_1_6"
            inst.components.aoetargeting.reticule.pingprefab = "reticuleaoeping_1d2_12"
            if TheWorld.ismastersim then
                inst.components.aoetargeting:SetTargetFX("reticuleaoecctarget")
                inst.components.aoespell:SetSpellFn(rainfn)
                inst.components.spellbook:SetSpellFn(nil)
            end
        end,
        execute = StartAOETargeting,
        atlas = "images/inventoryimages/kochospell.xml",
        normal = "kochospell_1.tex",
        widget_scale = ICON_SCALE,
        hit_radius = ICON_RADIUS,
    },
    {
        label = STRINGS.SPELLS.KOCHO_2,
        onselect = function(inst)
            inst.components.spellbook:SetSpellName(STRINGS.SPELLS.KOCHO_2)
            inst.components.aoetargeting:SetDeployRadius(0)
            inst.components.aoetargeting:SetShouldRepeatCastFn(nil)
            inst.components.aoetargeting.reticule.reticuleprefab = "reticuleaoe_1_6"
            inst.components.aoetargeting.reticule.pingprefab = "reticuleaoeping"
            if TheWorld.ismastersim then
                inst.components.aoetargeting:SetTargetFX("reticuleaoecctarget")
                inst.components.aoespell:SetSpellFn(fullmoonfn)
                inst.components.spellbook:SetSpellFn(nil)
            end
        end,
        execute = StartAOETargeting,
        atlas = "images/inventoryimages/kochospell.xml",
        normal = "kochospell_2.tex",
        widget_scale = ICON_SCALE,
        hit_radius = ICON_RADIUS,
    },
    {
        label = STRINGS.SPELLS.KOCHO_3,
        onselect = function(inst)
            inst.components.spellbook:SetSpellName(STRINGS.SPELLS.KOCHO_3)
            inst.components.aoetargeting:SetDeployRadius(1)
            inst.components.aoetargeting:SetShouldRepeatCastFn(nil)
            inst.components.aoetargeting.reticule.reticuleprefab = "reticuleaoe_1_6"
            inst.components.aoetargeting.reticule.pingprefab = "reticuleaoeping"
            if TheWorld.ismastersim then
                inst.components.aoetargeting:SetTargetFX("reticuleaoecctarget")
                inst.components.aoespell:SetSpellFn(kochospell3)
                inst.components.spellbook:SetSpellFn(nil)
            end
        end,
        execute = StartAOETargeting,
        atlas = "images/inventoryimages/kochospell.xml",
        normal = "kochospell_3.tex",
        widget_scale = ICON_SCALE,
        hit_radius = ICON_RADIUS,
    },
    {
        label = STRINGS.SPELLS.KOCHO_4,
        onselect = function(inst)
            inst.components.spellbook:SetSpellName(STRINGS.SPELLS.KOCHO_4)
            inst.components.aoetargeting:SetDeployRadius(0)
            inst.components.aoetargeting:SetShouldRepeatCastFn(nil)
            inst.components.aoetargeting.reticule.reticuleprefab = "reticuleaoe_1_6"
            inst.components.aoetargeting.reticule.pingprefab = "reticuleaoeping"
            if TheWorld.ismastersim then
                inst.components.aoetargeting:SetTargetFX("reticuleaoecctarget")
                inst.components.aoespell:SetSpellFn(kochospell4)
                inst.components.spellbook:SetSpellFn(nil)
            end
        end,
        execute = StartAOETargeting,
        atlas = "images/inventoryimages/kochospell.xml",
        normal = "kochospell_4.tex",
        widget_scale = ICON_SCALE,
        hit_radius = ICON_RADIUS,
    },
}

local function OnOpenSpellBook(inst)
    local inventoryitem = inst.replica.inventoryitem
    if inventoryitem ~= nil then
        inventoryitem:OverrideImage("kochobook")
    end
end

local function OnCloseSpellBook(inst)
    local inventoryitem = inst.replica.inventoryitem
    if inventoryitem ~= nil then
        inventoryitem:OverrideImage(nil)
    end
end

--------------------------------------------------------------------------

local function CLIENT_PlayFuelSound(inst)
    local parent = inst.entity:GetParent()
    local container = parent ~= nil and (parent.replica.inventory or parent.replica.container) or nil
    if container ~= nil and container:IsOpenedBy(ThePlayer) then
        TheFocalPoint.SoundEmitter:PlaySound("dontstarve/common/nightmareAddFuel")
    end
end

--------------------------------------------------------------------------

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("kochobook")
    inst.AnimState:SetBuild("kochobook")
    inst.AnimState:PlayAnimation("idle")

    inst:AddTag("book")
    inst:AddTag("shadowmagic")

    MakeInventoryFloatable(inst, "med", nil, 0.75)

    inst:AddComponent("spellbook")
    inst.components.spellbook:SetRequiredTag("kochosei")
    inst.components.spellbook:SetRadius(SPELLBOOK_RADIUS)
    inst.components.spellbook:SetFocusRadius(SPELLBOOK_FOCUS_RADIUS)
    inst.components.spellbook:SetItems(SPELLSKOCHO)
    inst.components.spellbook:SetOnOpenFn(OnOpenSpellBook)
    inst.components.spellbook:SetOnCloseFn(OnCloseSpellBook)
    inst.components.spellbook.opensound = "dontstarve/common/together/book_maxwell/use"
    inst.components.spellbook.closesound = "dontstarve/common/together/book_maxwell/close"

    inst:AddComponent("aoetargeting")
    inst.components.aoetargeting:SetAllowWater(true)
    inst.components.aoetargeting.reticule.targetfn = ReticuleTargetAllowWaterFn
    inst.components.aoetargeting.reticule.validcolour = { 1, 0.75, 0, 1 }
    inst.components.aoetargeting.reticule.invalidcolour = { 0.5, 0, 0, 1 }
    inst.components.aoetargeting.reticule.ease = true
    inst.components.aoetargeting.reticule.mouseenabled = true
    inst.components.aoetargeting.reticule.twinstickmode = 1
    inst.components.aoetargeting.reticule.twinstickrange = 8

    inst.playfuelsound = net_event(inst.GUID, "waxwelljournal.playfuelsound")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        --delayed because we don't want any old events
        inst:DoTaskInTime(0, inst.ListenForEvent, "waxwelljournal.playfuelsound", CLIENT_PlayFuelSound)

        return inst
    end

    inst.swap_build = "kochobook"
    inst:AddComponent("inspectable")

    inst:AddComponent("inventoryitem")

    inst:AddComponent("aoespell")

    MakeSmallBurnable(inst, TUNING.MED_BURNTIME)
    MakeSmallPropagator(inst)

    inst._activetask = nil
    inst._soundtasks = {}

    inst.castsound = "maxwell_rework/shadow_magic/cast"

    return inst
end

STRINGS.NAMES.KOCHOBOOK = "Kochobook"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.KOCHOBOOK = "Woaaah, i want it!! XD"
STRINGS.RECIPE_DESC.KOCHOBOOK = "Kochobook"

return Prefab("kochobook", fn, assets, prefabs)
