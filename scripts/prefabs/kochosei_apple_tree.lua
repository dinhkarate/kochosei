require("worldsettingsutil")

local seg_time = TUNING.SEG_TIME

local day_segs = TUNING.DAY_SEGS_DEFAULT
local dusk_segs = TUNING.DUSK_SEGS_DEFAULT
local night_segs = TUNING.NIGHT_SEGS_DEFAULT
local total_day_time = TUNING.TOTAL_DAY_TIME
local day_time = seg_time * day_segs
local dusk_time = seg_time * dusk_segs
local night_time = seg_time * night_segs
TUNING.KOCHOSEI_APPLE_TREE_CHOPS_TALL = 20
TUNING.KOCHOSEI_APPLE_TREE_REGROWTH = {
    OFFSPRING_TIME = total_day_time * 100,
    DESOLATION_RESPAWN_TIME = total_day_time * 50,
    DEAD_DECAY_TIME = total_day_time * 30,
}
TUNING.KOCHOSEI_APPLE_TREE_REGROWTH.DEAD_DECAY_TIME = total_day_time * 30

TUNING.KOCHOSEI_APPLE_TREE_GROWTH_TIME = {
    { base = 3 * day_time,  random = 0 * day_time }, -- short
    { base = 7 * day_time,  random = 0 * day_time }, -- normal
    { base = 15 * day_time, random = 0 * day_time }, -- tall
}
TUNING.KOCHOSEI_APPLE_TREE_GROWTIME = {
    base = 0 * day_time,
    random = 0 * day_time,
}

local assets = {
    Asset("ANIM", "anim/kochosei_apple_tree.zip"),

    Asset("SOUND", "sound/forest.fsb"),
    Asset("ATLAS", "minimap/kochosei_apple_tree_burnt.xml"),
    Asset("ATLAS", "minimap/kochosei_apple_tree_stump.xml"),
    Asset("ATLAS", "minimap/kochosei_apple_tree.xml"),
    Asset("IMAGE", "minimap/kochosei_apple_tree_burnt.tex"),
    Asset("IMAGE", "minimap/kochosei_apple_tree_stump.tex"),
    Asset("IMAGE", "minimap/kochosei_apple_tree.tex"),
}

local prefabs = { "log", "charcoal" }

SetSharedLootTable(
    "kochosei_apple_tree_short", -- kochosei_applestree_short
    { { "log", 1.0 }, { "log", 1.0 } }
)

SetSharedLootTable(
    "kochosei_apple_tree_normal", -- kochosei_applestree_normal
    { { "log", 1.0 }, { "log", 1.0 }, { "log", 1.0 }, { "petals", 1.0 }, { "petals", 1.0 } }
)

SetSharedLootTable(
    "kochosei_apple_tree_tall", -- kochosei_applestree_tall
    {
        { "log",            1.0 },
        { "log",            1.0 },
        { "log",            1.0 },
        { "log",            1.0 },
        { "log",            1.0 },
        { "kochosei_apple", 1.0 },
        { "kochosei_apple", 1.0 },
        { "kochosei_apple", 1.0 },
        { "kochosei_apple", 1.0 },
        { "kochosei_apple", 1.0 },
    }
)

SetSharedLootTable(
    "kochosei_apple_tree_burnt", -- kochosei_applestree_burnt
    { { "charcoal", 1.0 }, { "charcoal", 0.5 } }
)

local function makeanims(stage)
    return {
        idle = "idle_" .. stage,
        sway1 = "sway1_loop_" .. stage,
        sway2 = "sway2_loop_" .. stage,
        chop = "chop_" .. stage,
        fallleft = "fallleft_" .. stage,
        fallright = "fallright_" .. stage,
        stump = "stump_" .. stage,
        burning = "burning_loop_" .. stage,
        burnt = "burnt_" .. stage,
        chop_burnt = "chop_burnt_" .. stage,
        idle_chop_burnt = "idle_chop_burnt_" .. stage,
    }
end

local SHORT = "short"
local NORMAL = "normal"
local TALL = "tall"

local kochosei_apple_tree_anims = -- kochosei_appletree
{
    [SHORT] = makeanims(SHORT),
    [TALL] = makeanims(TALL),
    [NORMAL] = makeanims(NORMAL),
}

-- Nơi spawn con child, có thể thay thành butterfly

-- local function OnIsDay(inst, isday)
--	if inst.components.workable and inst.components.workable.lastworktime and inst.components.workable.lastworktime < GetTime() - TUNING.TOTAL_DAY_TIME then
--		local extra = inst:HasTag("cherryhome") and 3 or 0
--		inst.components.workable:SetWorkLeft(TUNING["CHERRY_TREE_CHOPS_"..string.upper(inst.size)] + extra)
--	end
--	if inst.components.childspawner and not isday and not TheWorld.state.iswinter then
--		inst.components.childspawner:StartSpawning()
--	else
--		inst.components.childspawner:StopSpawning()
--	end
-- end

local function OnChopTree(inst, chopper, chops) -- Chặt cây
    local anim_set = kochosei_apple_tree_anims[inst.size]
    inst.AnimState:PlayAnimation(anim_set.chop)
    inst.AnimState:PushAnimation(anim_set.sway1, true)
    if not (chopper ~= nil and chopper:HasTag("playerghost")) then
        inst.SoundEmitter:PlaySound(
            chopper ~= nil and chopper:HasTag("beaver") and
            "dontstarve/characters/woodie/beaver_chop_tree"                                        -- con woodie biến hình
            or "dontstarve/wilson/use_axe_tree"
        )
    end

    -- Spawn Items, ở đây là spawn cherry petals cái đám hoa ở dưới
    --	if math.random() <= GetState(inst).droprate then
    --		local cherry_t = inst:HasTag("cherryhome") and weighted_random_choice(whitecherrytree_loots) or weighted_random_choice(pinkcherrytree_loots)
    --		if cherry_t == "cherry_petals" then
    --			local ents = TheSim:FindEntities(x, y, z, 3, PETALS_TAGS)
    --			if #ents >= 1 then
    --				for i, v in ipairs(ents) do
    --					if v.components.workable ~= nil and inst.state == v.state then
    --						local _workleft = v.components.workable.workleft + 1
    --						if _workleft < v.components.workable.maxwork + 1 then
    --							v.components.workable.workleft = _workleft
    --							v.AnimState:PlayAnimation(v.state.._workleft.."_1")
    --						end
    --						v.components.bloomprintlooter:ActivateTest()
    --					end
    --				end
    --			else
    --				local petals = SpawnPrefab("cherry_petals")
    --				petals.Transform:SetPosition(x, y, z)
    --				petals.components.workable:SetWorkLeft(1)
    --				petals.state = inst.state
    --				petals.AnimState:PlayAnimation(petals.state.."1_1")
    --				petals.components.bloomprintlooter:ActivateTest()
    --			end
    --		elseif inst.size == TALL then
    --			local cherry = SpawnPrefab(cherry_t)
    --			cherry.Transform:SetPosition(x + math.cos(angle), y + 10, z + math.sin(angle))
    --		end
end
local function DigUpStump(inst, chopper) -- Đào gốc cây
    inst.components.lootdropper:SpawnLootPrefab("log")

    if inst.components.growable ~= nil and inst.components.growable.stage == 2 then
        inst.components.lootdropper:SpawnLootPrefab("log")
        inst.components.lootdropper:SpawnLootPrefab("foliage")
    end
    if inst.components.growable ~= nil and inst.components.growable.stage == 3 then
        inst.components.lootdropper:SpawnLootPrefab("log")
        inst.components.lootdropper:SpawnLootPrefab("succulent_picked")
        inst.components.lootdropper:SpawnLootPrefab("foliage")
    end
    inst:Remove()
end

local function DigUpStumpPetrified(inst, chopper) -- cherry làm éo gì có cây hóa thạch nhỉ?
    inst.components.lootdropper:SpawnLootPrefab("rocks")
    if inst.components.growable ~= nil and inst.components.growable.stage > 2 then
        inst.components.lootdropper:SpawnLootPrefab("rocks")
    end

    inst:Remove()
end

local function MakeStumpBurnable(inst) -- đốt cháy gốc cây
    if inst.size == SHORT then
        MakeSmallBurnable(inst)
    elseif inst.size == NORMAL then
        MakeMediumBurnable(inst)
    else
        MakeLargeBurnable(inst)
    end
end

local function MakeStump(inst)
    inst:RemoveComponent("burnable")
    inst:RemoveComponent("propagator")
    inst:RemoveComponent("workable")
    inst:RemoveComponent("hauntable")
    inst:RemoveTag("shelter")

    MakeStumpBurnable(inst)
    MakeMediumPropagator(inst)
    MakeHauntableIgnite(inst)

    RemovePhysicsColliders(inst)

    inst:AddTag("stump")
    if inst.components.growable ~= nil then
        inst.components.growable:StopGrowing()
    end

    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.DIG)
    inst.components.workable:SetWorkLeft(1)
    inst.components.workable:SetOnFinishCallback(DigUpStump)
    inst.MiniMapEntity:SetIcon("kochosei_apple_tree_stump.tex")

    inst.DynamicShadow:Enable(false)

    if inst.components.timer ~= nil and not inst.components.timer:TimerExists("decay") then
        inst.components.timer:StartTimer(
            "decay",
            GetRandomWithVariance(
                TUNING.KOCHOSEI_APPLE_TREE_REGROWTH.DEAD_DECAY_TIME,
                TUNING.KOCHOSEI_APPLE_TREE_REGROWTH.DEAD_DECAY_TIME * 0.5
            )
        )
    end
end

local function OnChopTreeDown(inst, chopper, child)
    inst.AnimState:PlayAnimation(kochosei_apple_tree_anims[inst.size].fallleft)
    inst.AnimState:PushAnimation(kochosei_apple_tree_anims[inst.size].stump)
    if not (chopper ~= nil and chopper:HasTag("playerghost")) then
        inst.SoundEmitter:PlaySound("dontstarve/wilson/use_axe_tree")
    end
    inst.SoundEmitter:PlaySound("dontstarve/forest/treeCrumble")

    inst.components.lootdropper:DropLoot()
    MakeStump(inst)
    inst:ListenForEvent("animover", inst.DynamicShadow:Enable(false))
end

local function OnChopTreeBurntDown(inst, chopper)
    inst.SoundEmitter:PlaySound("dontstarve/forest/treeCrumble")
    if not (chopper ~= nil and chopper:HasTag("playerghost")) then
        inst.SoundEmitter:PlaySound("dontstarve/wilson/use_axe_tree")
    end
    inst.AnimState:PlayAnimation(kochosei_apple_tree_anims[inst.size].chop_burnt)
    MakeStump(inst)
    RemovePhysicsColliders(inst)
    inst:ListenForEvent("animover", inst.Remove)
    inst.components.lootdropper:SpawnLootPrefab("charcoal")
end

local function BurntChanges(inst)
    if inst.components.burnable ~= nil then
        inst.components.burnable:Extinguish()
    end

    inst:RemoveComponent("burnable")
    inst:RemoveComponent("propagator")
    inst:RemoveComponent("growable")
    inst:RemoveComponent("hauntable")
    MakeHauntableWork(inst)

    inst:RemoveTag("shelter")

    inst.components.lootdropper:SetChanceLootTable("kochosei_apple_tree_burnt")

    if inst.components.workable then
        inst.components.workable:SetWorkLeft(1)
        inst.components.workable:SetOnWorkCallback(nil)
        inst.components.workable:SetOnFinishCallback(OnChopTreeBurntDown)
    end
end

local function MakeBurnt(inst, immediate)
    if immediate then
        BurntChanges(inst)
    else
        inst:DoTaskInTime(0.5, BurntChanges)
    end

    if inst.components.growable ~= nil then
        inst:RemoveComponent("growable")
    end

    inst.AnimState:PlayAnimation(kochosei_apple_tree_anims[inst.size].burnt, true)
    inst.MiniMapEntity:SetIcon("kochosei_apple_tree_burnt.tex")

    inst.AnimState:SetRayTestOnBB(true)
    inst:AddTag("burnt")

    if inst.components.timer ~= nil and not inst.components.timer:TimerExists("decay") then
        inst.components.timer:StartTimer(
            "decay",
            GetRandomWithVariance(
                TUNING.KOCHOSEI_APPLE_TREE_REGROWTH.DEAD_DECAY_TIME,
                TUNING.KOCHOSEI_APPLE_TREE_REGROWTH.DEAD_DECAY_TIME * 0.5
            )
        )
    end
end

local function OnBurnt(inst)
    inst:RemoveComponent("burnable")
    inst:RemoveComponent("propagator")
    inst:RemoveComponent("hauntable")
    MakeHauntableWork(inst)

    inst.components.lootdropper:SetLoot({ "charcoal" })

    inst.components.workable:SetWorkLeft(1)
    inst.components.workable:SetOnWorkCallback(nil)
    inst.components.workable:SetOnFinishCallback(OnChopTreeBurntDown)
    inst.AnimState:PlayAnimation(kochosei_apple_tree_anims[inst.size].burnt)
    inst:AddTag("burnt")
    inst.MiniMapEntity:SetIcon("kochosei_apple_tree_burnt.tex")
    inst.DynamicShadow:Enable(false)
    if inst.components.timer ~= nil and not inst.components.timer:TimerExists("decay") then
        inst.components.timer:StartTimer("decay",
            GetRandomWithVariance(TUNING.KOCHOSEI_APPLE_TREE_REGROWTH.DEAD_DECAY_TIME,
                TUNING.KOCHOSEI_APPLE_TREE_REGROWTH.DEAD_DECAY_TIME * 0.5))
    end
end

local function GetStatus(inst)
    return (inst:HasTag("burnt") and "BURNT")
        or (inst:HasTag("stump") and "CHOPPED")
        or (inst.components.burnable ~= nil and inst.components.burnable:IsBurning() and "BURNING")
        or nil
end
------------------------------------------------------------------------------------------------NOTE TO Ở kochosei_apple_tree_anims
local function Sway(inst)
    local anim_to_play = (math.random() > 0.5 and kochosei_apple_tree_anims[inst.size].sway1)
        or kochosei_apple_tree_anims[inst.size].sway2
    inst.AnimState:PlayAnimation(anim_to_play, true)
end

local function PushAway(inst)
    local anim_to_play = (math.random() > 0.5 and kochosei_apple_tree_anims[inst.size].sway1)
        or kochosei_apple_tree_anims[inst.size].sway2
    inst.AnimState:PushAnimation(anim_to_play, true)
end
-- Chỉ dùng mỗi autumn nên không cần đoạn này, đồng thời cần phải sửa các đoạn kochosei_apple_tree_anims thành kochosei_appletree.
-- Còn nữa cái cherry tree dùng dạng table nên cái bảng của nó có phần unique, may mà lúc trước có xem qua khóa lua nên biết được vụ table kochosei_apple_tree_anims[inst.size].abcxyz nghĩa là gì
local function SetShort(inst)
    inst.size = SHORT
    inst.components.lootdropper:SetChanceLootTable("kochosei_apple_tree_short")
    MakeObstaclePhysics(inst, 0.2)
    inst.DynamicShadow:SetSize(3, 1.5)
    inst:AddTag("shelter")
    Sway(inst)
end

local function GrowShort(inst)
    inst.AnimState:PlayAnimation("grow_tall_to_short")
    inst.SoundEmitter:PlaySound("dontstarve/forest/treeGrowFromWilt")
    PushAway(inst)
end

local function SetNormal(inst)
    --	inst.MiniMapEntity:SetIcon("kochosei_apple_tree.tex")
    inst.size = NORMAL
    inst.components.lootdropper:SetChanceLootTable("kochosei_apple_tree_normal")
    MakeObstaclePhysics(inst, 0.4)
    inst.DynamicShadow:SetSize(6, 3)
    inst:AddTag("shelter")
    Sway(inst)
end

local function GrowNormal(inst)
    inst.AnimState:PlayAnimation("grow_short_to_normal")
    inst.SoundEmitter:PlaySound("dontstarve/forest/treeGrow")
    PushAway(inst)
end

local function SetTall(inst)
    inst.size = TALL

    inst.components.lootdropper:SetChanceLootTable("kochosei_apple_tree_tall")
    MakeObstaclePhysics(inst, 0.6)
    inst.DynamicShadow:SetSize(9, 6)
    inst:AddTag("shelter")
    Sway(inst)
    if inst.components.growable then
        inst.components.growable.stage = 3
        inst.components.growable:Pause()
    end
end

local function GrowTall(inst)
    inst.AnimState:PlayAnimation("grow_normal_to_tall")
    inst.SoundEmitter:PlaySound("dontstarve/forest/treeGrow")
    PushAway(inst)
end

local GROWTH_STAGES = {
    {
        name = SHORT,
        time = function(inst)
            return 60 * 8 * 3 -- 3 days
        end,
        fn = SetShort,
        growfn = GrowShort,
    },
    {
        name = NORMAL,
        time = function(inst)
            return 60 * 8 * 7 -- 7 days
        end,
        fn = SetNormal,
        growfn = GrowNormal,
    },
    {
        name = TALL,
        time = function(inst)
            return
        end,
        fn = SetTall,
        growfn = GrowTall,
    },
}

local function GrowFromSeed(inst)
    inst.components.growable:SetStage(1)
    inst.AnimState:PlayAnimation("grow_seed_to_short")
    inst.SoundEmitter:PlaySound("dontstarve/forest/treeGrow")
    PushAway(inst)
end

local function OnTimerDone(inst, data)
    if data.name == "decay" then
        local x, y, z = inst.Transform:GetWorldPosition()
        local entities = TheSim:FindEntities(x, y, z, 6)
        local leftone = false
        for k, entity in pairs(entities) do
            if entity.prefab == "log" or entity.prefab == "charcoal" then
                if leftone then
                    entity:Remove()
                else
                    leftone = true
                end
            end
        end

        inst:Remove()
    end
end

local function OnSave(inst, data)
    if inst:HasTag("burnt") or (inst.components.burnable ~= nil and inst.components.burnable:IsBurning()) then
        data.burnt = true
    end
    if inst:HasTag("stump") then
        data.stump = true
    end
    data.size = inst.size
end

local function OnLoad(inst, data)
    if data == nil then
        return
    end

    inst.size = data.size ~= nil and data.size or TALL
    if inst.size == SHORT then
        SetShort(inst)
    elseif inst.size == NORMAL then
        SetNormal(inst)
    else
        SetTall(inst)
    end

    local is_burnt = data.burnt or inst:HasTag("burnt")
    if data.stump then
        MakeStump(inst)
        inst.AnimState:PlayAnimation(kochosei_apple_tree_anims[inst.size].stump)
    elseif is_burnt then
        MakeBurnt(inst, true)
    end
end

local function kochosei_apple_tree(name, stage, data)
    local function fn()
        local inst = CreateEntity()

        inst.entity:AddTransform()
        inst.entity:AddAnimState()
        inst.entity:AddDynamicShadow()
        inst.entity:AddSoundEmitter()
        inst.entity:AddMiniMapEntity()
        inst.entity:AddNetwork()

        MakeObstaclePhysics(inst, 0.6)

        inst.MiniMapEntity:SetIcon("kochosei_apple_tree.tex")
        -- inst.MiniMapEntity:SetPriority(-1)

        inst:AddTag("plant")
        inst:AddTag("tree")
        inst:AddTag("kochosei_apple_tree")

        inst.AnimState:SetBuild("kochosei_apple_tree")
        inst.AnimState:SetBank("kochosei_apple_tree")
        inst:SetPrefabName("kochosei_apple_tree")

        MakeSnowCoveredPristine(inst)

        inst.entity:SetPristine()

        if not TheWorld.ismastersim then
            return inst
        end

        inst.colour = 0.75 + math.random() * 0.25
        inst.AnimState:SetMultColour(inst.colour, inst.colour, inst.colour, 1)

        inst.state = TheWorld.state.season or "spring"
        inst.size = (stage == 1 and SHORT) or (stage == 2 and NORMAL) or (stage == 3 and TALL) or nil

        MakeLargeBurnable(inst)
        inst.components.burnable:SetOnBurntFn(OnBurnt)
        MakeLargePropagator(inst)

        inst:AddComponent("lootdropper")

        inst:AddComponent("workable")
        inst.components.workable:SetWorkAction(ACTIONS.CHOP)
        inst.components.workable:SetWorkLeft(TUNING.KOCHOSEI_APPLE_TREE_CHOPS_TALL)
        inst.components.workable:SetOnWorkCallback(OnChopTree)
        inst.components.workable:SetOnFinishCallback(OnChopTreeDown)

        inst:AddComponent("growable")
        inst.components.growable.stages = GROWTH_STAGES
        inst.components.growable:SetStage(stage == 0 and math.random(1, 3) or stage)
        inst.components.growable.loopstages = true
        inst.components.growable.springgrowth = true
        inst.components.growable:StartGrowing()

        inst:AddComponent("timer")
        inst:ListenForEvent("timerdone", OnTimerDone)

        inst:AddComponent("inspectable")
        inst.components.inspectable.getstatus = GetStatus

        inst.growfromseed = GrowFromSeed

        inst.OnSave = OnSave
        inst.OnLoad = OnLoad

        if data == "stump" then
            MakeStump(inst)
            inst.AnimState:PlayAnimation(kochosei_apple_tree_anims[inst.size].stump)
        elseif data == "burnt" then
            MakeBurnt(inst, true)
        end

        if POPULATING then
            Sway(inst)
        end

        inst.AnimState:SetTime(math.random() * 0.2)

        MakeHauntableWorkAndIgnite(inst)

        return inst
    end

    return Prefab(name, fn, assets, prefabs)
end

STRINGS.NAMES.KOCHOSEI_APPLE_TREE = "Kochosei's apple tree"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.KOCHOSEI_APPLE_TREE = "A lovely tree in my memories!"
-- STRINGS.RECIPE_DESC.KOCHOSEI_APPLE_TREE_SHORT = "using in crafting"

return kochosei_apple_tree("kochosei_apple_tree", 0),
    kochosei_apple_tree("kochosei_apple_tree_short", 1),
    kochosei_apple_tree("kochosei_apple_tree_normal", 2),
    kochosei_apple_tree("kochosei_apple_tree_tall", 3),
    kochosei_apple_tree("kochosei_apple_tree_stump", 0, "stump"),
    kochosei_apple_tree("kochosei_apple_tree_burnt", 0, "burnt")
