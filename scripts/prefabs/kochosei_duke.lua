--Need to make this enemy much less player focused.
--Doesn't target player by default.
    --Only if hit or if sharkittens threatened.

local assets =
{
    Asset("SCRIPT", "scripts/prefabs/player_common.lua"),
    Asset("SOUND", "sound/kochosei_voice.fsb"),
    Asset("ANIM", "anim/kochosei.zip"),
    Asset("ANIM", "anim/ghost_kochosei_build.zip"),
    Asset("ANIM", "anim/kochosei_snowmiku_skin1.zip"),
    Asset("ANIM", "anim/kochosei_skin_shinku_notfull.zip"),
    Asset("ANIM", "anim/kochosei_skin_shinku_full.zip"),
}

local prefabs =
{
	"tigershark_dukeshadow",
    "splash_water_big",
    "groundpound_fx",
    "groundpoundring_fx",
    "mysterymeat",
    "fish_raw",
    "tigereye",
    "shark_gills",
}

SetSharedLootTable('kochosei_duke',
{
    {"humanmeat", 1.00},
    {"humanmeat", 1.00},
    {"humanmeat", 1.00},
    {"humanmeat", 1.00},
    {"humanmeat", 1.00},
    {"humanmeat", 1.00},
    {"humanmeat", 1.00},
    {"humanmeat", 1.00},
    {"humanmeat", 1.00},
    {"humanmeat", 1.00},

    {"lucky_hammer", 1.00},
    {"kochosei_armor_1", 1.00},
    {"kochosei_umbrella", 1.00},


    {"kochosei_card_attack", 0.33},
    {"kochosei_card_defend", 0.33},
    {"kochosei_card_health", 0.33},
    

    {"deerclops_eyeball", 0.33},

})

local TARGET_DIST = 20
local HEALTH_THRESHOLD = 0.1
local HOME_PROTECTION_DISTANCE = 60

local brain = require "brains/kochosei_dukebrain"


local function PushMusic(inst)
    if ThePlayer == nil then
        inst._playingmusic = false
    elseif ThePlayer:IsNear(inst, inst._playingmusic and 40 or 20) then
		--print(inst,ThePlayer,"Push the triggeredevent at",GetTime())
        inst._playingmusic = true
        ThePlayer:PushEvent("triggeredevent", { name = "tigershark_duke" ,duration = 3})
    elseif inst._playingmusic and not ThePlayer:IsNear(inst, 50) then
        inst._playingmusic = false
    end
end

local function oncollapse(inst, other)
    if other:IsValid() and other.components.workable ~= nil and other.components.workable:CanBeWorked() then
        SpawnPrefab("collapse_small").Transform:SetPosition(other.Transform:GetWorldPosition())
        other.components.workable:Destroy(inst)
    end
end

local function oncollide(inst, other)
    if other ~= nil and
        (other:HasTag("tree") or other:HasTag("boulder")) and --HasTag implies IsValid
        Vector3(inst.Physics:GetVelocity()):LengthSq() >= 1 then
        inst:DoTaskInTime(2 * FRAMES, oncollapse, other)
    end
end

local function ShouldSleep(inst)
    return false
end

local function ShouldWake(inst)
    return true
end

local function GetTarget(inst)
    --Used for logic of moving between land and water states
    local target = inst.components.combat.target and inst.components.combat.target:GetPosition()

    if not target and inst:GetBufferedAction() then
        target = (inst:GetBufferedAction().target and inst:GetBufferedAction().target:GetPosition()) or inst:GetBufferedAction().pos
    end

    --Returns a position
    return target
end

local function GroundTypesMatch(inst, target)
    --[[local target = target or GetTarget(inst)

    if target then
        if target.prefab then
            return inst:HasTag("aquatic") == target:HasTag("aquatic")
        elseif target.x and target.y and target.z then
            local tar_tile = GetMap():GetTileAtPoint(target:Get())
            return WorldSim:IsWater(tar_tile) == inst:GetIsOnWater()
        end
    end--]]

    return true
end

local function FindSharkHome(inst)
    --[[if not inst.sharkHome then
        if TheWorld.components.tigersharker and TheWorld.components.tigersharker.shark_home then
            inst.sharkHome = TheWorld.components.tigersharker.shark_home
        else
            inst.sharkHome = GetClosestInstWithTag("sharkhome", inst, 10000)
        end
    end
    return inst.sharkHome--]]
	return 
end

local function OnAttacked(inst, data)
	if data.attacker ~= nil then
		if data.attacker.components.combat and data.attacker.userid ~= nil then
			inst.components.combat:SetTarget(data.attacker)
		end
		if data.attacker.components.combat and data.attacker:HasTag("epic") then
			inst.components.combat:SuggestTarget(data.attacker)
		end
	end
end

local function RetargetFn(inst)
    --[[local home = FindSharkHome(inst)

    if home and home:GetPosition():Dist(inst:GetPosition()) < HOME_PROTECTION_DISTANCE then
        --Aggressive to the player if close to home
        return FindEntity(inst, TARGET_DIST, 
            function(tar) return inst.components.combat:CanTarget(tar) end, nil, 
            {"prey", "smallcreature", "bird", "butterfly", "sharkitten"})
    elseif inst.components.health:GetPercent() > HEALTH_THRESHOLD then
        --Not aggressive to the player if far from home
        return FindEntity(inst, TARGET_DIST, 
            function(tar) return inst.components.combat:CanTarget(tar) end, nil,
            {"prey", "smallcreature", "bird", "butterfly", "sharkitten", "player", "companion"})
    end--]]
	local player, distsq = inst:GetNearestPlayer()
    return (player and not player.components.health:IsDead()) and player 
		or FindEntity(inst, 25, function(guy) return inst.components.combat:CanTarget(guy) 
			and not guy.components.health:IsDead() 
			end,nil, { "tadalin", "LA_mob", "battlestandard","monster" })
end

local function KeepTargetFn(inst, target)
    --If this thing is close to my kittens keep target no matter what.
    --[[local home = FindSharkHome(inst)
    if inst.components.health:GetPercent() < HEALTH_THRESHOLD and home and home:GetPosition():Dist(inst:GetPosition()) > HOME_PROTECTION_DISTANCE then
        --If I'm low health & not protecting my home, flee.
        return false
    else
        return inst.components.combat:CanTarget(target)
    end--]]
	return inst.components.combat:CanTarget(target)
end

local function ontimerdone(inst, data)
    if data.name == "Run" then
        inst.CanRun = true
    end
end

local function MakeGround(inst)
    inst:ClearStateGraph()
    inst:SetStateGraph("SGkochosei_duke")
    inst.AnimState:SetBuild("kochosei")
    inst:RemoveTag("aquatic")
    inst.DynamicShadow:Enable(true)
end

local function OnSave(inst, data)
    data.CanRun = inst.CanRun
    data.NextFeedTime = GetTime() - inst.NextFeedTime
end

local function OnLoad(inst, data)
    if data then
        inst.CanRun = data.CanRun or true
        inst.NextFeedTime = data.NextFeedTime or 0
    end
end

local function CanBeAttacked(inst, attacker)
    return not inst.sg:HasStateTag("specialattack")
end

local function OnHitOther(inst, data)
	local target = data.target
	if target ~= nil then
		local health = target.components.health
		if health and health:IsDead() then
			inst.sg:GoToState("chicken")
		end
	end
end

local function fn()

	local inst = CreateEntity()
	inst.entity:AddTransform()
	inst.entity:AddAnimState()
    inst.entity:AddLight()
    inst.entity:AddSoundEmitter()
    inst.entity:AddDynamicShadow()
	inst.entity:AddNetwork()
	
    inst.DynamicShadow:SetSize( 6, 3 )
    inst.DynamicShadow:Enable(false)
	
	inst.Transform:SetFourFaced()


    inst:AddTag("aquatic")
	inst:AddTag("tadalin")
	inst:AddTag("monster")
    inst:AddTag("scarytoprey")
    inst:AddTag("tigershark")
    inst:AddTag("largecreature")
    inst:AddTag("epic")


    inst.Light:SetRadius(2)
    inst.Light:SetIntensity(.75)
    inst.Light:SetFalloff(.75)
    inst.Light:SetColour(128 / 255, 128 / 255, 255 / 255)
    inst.Light:Enable(false)

    --MakePoisonableCharacter(inst)
    MakeCharacterPhysics(inst, 1000, 1.33)
	--MakeGiantCharacterPhysics(inst, 1000, 1.33)

    --inst:AddComponent("rowboatwakespawner")

    inst:SetStateGraph("SGkochosei_duke")

    inst.AnimState:SetBank("wilson")
    inst.AnimState:SetBuild("kochosei_snowmiku_skin1")
    inst.AnimState:Hide("ARM_carry")
    inst.AnimState:SetScale(4, 4)
    inst.AnimState:PlayAnimation("idle")
    --inst.AnimState:AddOverrideBuild("tigershark_water_ripples_build")
	
	inst._playingmusic = false
	if not TheNet:IsDedicated() then
        inst:DoPeriodicTask(1, PushMusic,0)
    end
	
	inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end
	
	inst.Physics:SetCollisionCallback(oncollide)

    inst:AddComponent("focalpoint")

    inst:AddComponent("inspectable")
    inst.no_wet_prefix = true
	
	inst:AddComponent("locomotor")
	inst.components.locomotor.walkspeed = TUNING.TIGERSHARK_WALK_SPEED
	inst.components.locomotor.runspeed = TUNING.TIGERSHARK_RUN_SPEED

	inst:AddComponent("knownlocations")

    inst:AddComponent("health")
    inst.components.health:SetMaxHealth(TUNING.DEERCLOPS_HEALTH*21.5)

    inst:AddComponent("eater")
    inst.components.eater.foodprefs = { "MEAT" }
    inst.components.eater.ablefoods = { "MEAT", "VEGGIE", "GENERIC" }

    inst:AddComponent("lootdropper")
    inst.components.lootdropper:SetChanceLootTable('kochosei_duke')

    inst:AddComponent("groundpounder")
    inst.components.groundpounder.destroyer = true
    inst.components.groundpounder.damageRings = 3
    inst.components.groundpounder.destructionRings = 1
    inst.components.groundpounder.numRings = 3
    inst.components.groundpounder.noTags = {"sharkitten","tadalin"}

    inst:AddComponent("combat")
    inst.components.combat:SetDefaultDamage(300)
    inst.components.combat:SetRange(TUNING.TIGERSHARK_ATTACK_RANGE, TUNING.TIGERSHARK_ATTACK_RANGE)
    --inst.components.combat:SetAreaDamage(TUNING.TIGERSHARK_SPLASH_RADIUS, TUNING.TIGERSHARK_SPLASH_DAMAGE/TUNING.TIGERSHARK_DAMAGE)
    inst.components.combat:SetAttackPeriod(TUNING.TIGERSHARK_ATTACK_PERIOD)
    inst.components.combat:SetRetargetFunction(3, RetargetFn)
    inst.components.combat:SetKeepTargetFunction(KeepTargetFn)
    inst.components.combat:SetHurtSound("dontstarve_DLC001/creatures/bearger/hurt")
    --inst.components.combat.canbeattackedfn = CanBeAttacked
    --inst.components.combat.notags = {"sharkitten","tadalin"}

    inst:AddComponent("sleeper")
    inst.components.sleeper:SetResistance(4)
    inst.components.sleeper:SetSleepTest(ShouldSleep)
    inst.components.sleeper:SetWakeTest(ShouldWake)

    inst:ListenForEvent("killed", function(inst, data)
        if inst.components.combat and data and data.victim == inst.components.combat.target then
            inst.components.combat.target = nil
        end
    end)

    inst.CanRun = true --Can do charge attack

    inst.CanFly = false --Can do leap attack

    --[[
        - While in water, tigershark jumps every third attack.
        - While on ground, tigershark *can* jump after every third attack, but will
            only jump to close distance.

        This logic is controlled through the tigershark's stategraphs.
    --]]

    inst.AttackCounter = 0
    inst.NextFeedTime = 0
    inst.OnSave = OnSave
    inst.OnLoad = OnLoad
    inst.GroundTypesMatch = GroundTypesMatch
    inst.FindSharkHome = FindSharkHome
    inst.GetTarget = GetTarget
    inst.MakeGround = MakeGround


    inst:SetBrain(brain)

    inst:AddComponent("timer")
    inst:ListenForEvent("timerdone", ontimerdone)
    inst:ListenForEvent("attacked", OnAttacked)
    inst:ListenForEvent("onhitother", OnHitOther)

	return inst
end

STRINGS.CHARACTERS.GENERIC.DESCRIBE.KOCHOSEI_DUKE = "Công tước Kochosei"
--STRINGS.RECIPE_DESC.KOCHOSEI_DUKE = "Công tước Kochosei"
STRINGS.NAMES.KOCHOSEI_DUKE = "Công tước Kochosei"

return Prefab("kochosei_duke", fn, assets, prefabs)