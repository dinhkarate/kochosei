local JUMP_SPEED = 50
local JUMP_LAND_OFFSET = 3

local function onattackfn(inst)
    if inst.components.health and not inst.components.health:IsDead()
    and (inst.sg:HasStateTag("hit") or not inst.sg:HasStateTag("busy")) then
        if inst.sg:HasStateTag("running") then
            inst.sg:GoToState("attack")
        else
            inst.sg:GoToState("attack_pre")
        end
    end
end

local function onattackedfn(inst)
    if not inst.components.health:IsDead() and not
    inst.sg:HasStateTag("attack") and not
    inst.sg:HasStateTag("specialattack") then
        inst.sg:GoToState("hit")
    end
end

local actionhandlers =
{
    ActionHandler(ACTIONS.EAT, "eat"),
}

local events =
{
    CommonHandlers.OnLocomote(true, true),
    CommonHandlers.OnDeath(),
    CommonHandlers.OnFreeze(),
    EventHandler("doattack", onattackfn),
    EventHandler("attacked", onattackedfn),
    CommonHandlers.OnSleep(),
}

local states =
{
    State{
        name = "idle",
        tags = {"idle", "canrotate"},

        onenter = function(inst)
            inst.components.locomotor:StopMoving()
            inst.AnimState:PlayAnimation("water_idle")
        end,

        events =
        {
            EventHandler("animover", function(inst)
                inst.sg:GoToState("idle")
            end)
        },
    },

    State{
        name = "eat",
        tags = {"busy", "canrotate"},

        onenter = function(inst)
            inst.Physics:Stop()
            --inst.components.rowboatwakespawner:StopSpawning()
            inst.AnimState:PlayAnimation("water_eat_pre")
            inst.AnimState:PushAnimation("water_eat_pst", false)
        end,

        timeline =
        {

            TimeEvent(0*FRAMES, function(inst)
                inst.SoundEmitter:PlaySound("dontstarve_DLC002/creatures/tiger_shark/water_emerge_lrg")
            end),

            TimeEvent(14*FRAMES, function(inst)
                inst:PerformBufferedAction()
                inst.SoundEmitter:PlaySound("dontstarve_DLC002/creatures/tiger_shark/eat")
            end),

            TimeEvent(31*FRAMES, function(inst)
                inst.SoundEmitter:PlaySound("dontstarve_DLC002/creatures/tiger_shark/water_submerge_lrg")
            end),
        },

        events =
        {
            EventHandler("animqueueover", function(inst)
                inst.sg:GoToState("idle")
            end)
        },
    },

    -- dive > jumpwarn > jump > fallwarn > fall > fallpost

    State{
        name = "dive",
        tags = {"busy", "specialattack"},

        onenter = function(inst)
            --inst.components.rowboatwakespawner:StopSpawning()
            inst.AnimState:PlayAnimation("submerge")
            inst.Physics:Stop()
            inst.components.health:SetInvincible(true)
        end,

        events =
        {
            EventHandler("animover", function(inst) inst:Hide() end),
        },

        timeline =
        {
            TimeEvent(10*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC002/creatures/tiger_shark/water_submerge_lrg") end),
            TimeEvent(30*FRAMES, function(inst) inst.sg:GoToState("jumpwarn") end),
        },
    },

    State{
        name = "jumpwarn",
        tags = {"busy", "specialattack"},

        onenter = function(inst)
            inst.Physics:Stop()

            ChangeToUnderwaterCharacterPhysics(inst)

            local old_pt = inst:GetPosition()

            local tar = inst:GetTarget()
            if tar and inst:GroundTypesMatch(tar) then
                inst.Transform:SetPosition(tar:Get())
            end

            local shadow = SpawnPrefab("tigershark_duke_shadow")
            shadow:Water_Jump()
            shadow.Transform:SetPosition(inst:GetPosition():Get())
        end,

        onexit = function(inst)
            inst:Show()
        end,

        timeline=
        {
            TimeEvent(90*FRAMES, function(inst) 
                inst.sg:GoToState("jump") 
            end),
        },
    },

    State{
        name = "jump",
        tags = {"busy", "specialattack"},

        onenter = function(inst)
            inst.Physics:Stop()
            inst.components.locomotor.disable = true

            local splash = SpawnPrefab("splash_water")
            local pos = inst:GetPosition()
            splash.Transform:SetPosition(pos.x, pos.y, pos.z)
            
            inst:Show()

            inst.SoundEmitter:PlaySound("dontstarve_DLC002/creatures/tiger_shark/jump_attack")
            inst.SoundEmitter:PlaySound("dontstarve_DLC002/creatures/tiger_shark/water_emerge_lrg")
            inst.SoundEmitter:PlaySound("dontstarve_DLC002/creatures/tiger_shark/roar")

            inst.AnimState:PlayAnimation("launch_up_pre")
            inst.AnimState:PushAnimation("launch_up_loop", true)
            inst.components.combat:DoAreaAttack(inst, TUNING.TIGERSHARK_SPLASH_RADIUS)

            SpawnWaves(inst, 9, 360)
        end,

        timeline =
        {
            TimeEvent(3*FRAMES, function(inst)
                inst.Physics:SetMotorVelOverride(0,JUMP_SPEED,0)
            end),

            TimeEvent(15*FRAMES, function(inst)
                local tar = inst:GetTarget()

                if tar and not inst:GroundTypesMatch(tar) then
                    inst:MakeGround() --GoToGroundState
                end

                inst.sg:GoToState("fallwarn")
            end)
        },
    },

    State{
        name = "fallwarn",
        tags = {"busy", "specialattack"},

        onenter = function(inst)
            inst.Physics:Stop()

            local tar = inst:GetTarget()
            local pos = tar or inst:GetPosition()

            pos.y = 45
            inst.Transform:SetPosition(pos:Get())

            local shadow = SpawnPrefab("tigershark_duke_shadow")
            shadow:Water_Fall()
            local heading = TheCamera:GetHeading()
            local rotation = 180 - heading
            if inst.AnimState:GetCurrentFacing() == FACING_LEFT then
                rotation = rotation + 180
            end
            if rotation < 0 then
                rotation = rotation + 360
            end
            shadow.Transform:SetRotation(rotation)
            local x,y,z = inst:GetPosition():Get()
            shadow.Transform:SetPosition(x,0,z)

            inst.sg:SetTimeout(25*FRAMES)
        end,

        ontimeout = function(inst)
            inst:Show()
            --Double check that you're landing on the correct tile type.
            --if not inst:GetIsOnWater() then
                inst:MakeGround()
                local pos = inst:GetPosition()
                pos.y = 45
                inst.Transform:SetPosition(pos:Get())
            --end

            inst.sg:GoToState("fall")
        end,
    },

    State{
        name = "fall",
        tags = {"busy", "specialattack"},

        onenter = function(inst)
            inst.components.locomotor.disable = true
            inst.Physics:SetMotorVel(0,-JUMP_SPEED,0)
            inst.AnimState:PlayAnimation("launch_down_loop", true)
            inst.SoundEmitter:PlaySound("dontstarve_DLC002/creatures/tiger_shark/breach_attack")
            inst.SoundEmitter:PlaySound("dontstarve_DLC002/creatures/tiger_shark/dive_attack")
            inst.sg:SetTimeout(JUMP_SPEED/45 + 0.2)
        end,

        timeline =
        {
            TimeEvent(20*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC002/creatures/tiger_shark/roar") end)
        },

        ontimeout = function(inst)
            local pt = Point(inst.Transform:GetWorldPosition())
            pt.y = 0
            inst.Physics:Stop()
            inst.Physics:Teleport(pt.x,pt.y,pt.z)
            inst.CanFly = false
            inst.Physics:SetCollides(true)
            inst.sg:GoToState("fallpost")
        end,

        onupdate= function(inst)
            inst.Physics:SetMotorVel(0,-JUMP_SPEED,0)
            local pt = Point(inst.Transform:GetWorldPosition())
            if pt.y <= 1 then
                pt.y = 0
                inst.Physics:Stop()
                inst.Physics:Teleport(pt.x,pt.y,pt.z)
                inst.CanFly = false
                inst.Physics:SetCollides(true)
                inst.sg:GoToState("fallpost")
            end
        end,
    },

    State{
        name = "fallpost",
        tags = {"busy", "specialattack"},

        onenter = function(inst)

            --print("Enter fall post (water)", GetTime())

            inst.Physics:Stop()
            inst.components.locomotor.disable = false
            inst.AnimState:PlayAnimation("launch_down_pst")
            inst.components.combat:DoAreaAttack(inst, TUNING.TIGERSHARK_SPLASH_RADIUS)
            SpawnWaves(inst, 9, 360)
            inst.SoundEmitter:PlaySound("dontstarve_DLC002/creatures/seacreature_movement/splash_large")
            inst.SoundEmitter:PlaySound("dontstarve_DLC002/creatures/tiger_shark/splash_explode")
        end,

         onexit = function(inst)
           -- print("Exit fall post (water)", GetTime())

            local splash = SpawnPrefab("splash_water")
            local pos = inst:GetPosition()
            splash.Transform:SetPosition(pos.x, pos.y, pos.z)
            inst.components.health:SetInvincible(false)
            inst:Show()
            ChangeToCharacterPhysics(inst)
        end,

        events=
        {
            EventHandler("animover", function(inst) inst:Hide() end),
        },

        timeline=
        {
            TimeEvent(60*FRAMES, function(inst) inst.sg:GoToState("idle") end),
        },
    },

    State{
        name = "attack_pre",
        tags = {"attack", "busy", "canrotate"},

        onenter = function(inst)
            inst.components.locomotor:StopMoving()
            inst.CanRun = false

            --inst.components.rowboatwakespawner:StopSpawning()
            inst.AnimState:PlayAnimation("water_atk_pre")
        end,

        events =
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("attack") end),
        },
    },

    State{
        name = "attack",
        tags = {"busy", "attack"},

        onenter = function(inst)
            inst.components.locomotor:StopMoving()
            inst.components.combat:StartAttack()
            inst.AnimState:PlayAnimation("water_atk")
            inst.AnimState:PushAnimation("water_atk_pst", false)
            inst.CanRun = false
           -- inst.components.rowboatwakespawner:StopSpawning()
            if not inst.components.timer:TimerExists("Run") then
                inst.components.timer:StartTimer("Run", 10)
            end
            inst.SoundEmitter:PlaySound("dontstarve_DLC002/creatures/tiger_shark/roar")
        end,

        timeline =
        {
            TimeEvent(15*FRAMES, function(inst)
                inst.SoundEmitter:PlaySound("dontstarve_DLC002/creatures/tiger_shark/water_attack")
                inst.components.combat:DoAttack()
                SpawnWaves(inst, 5, 110)
            end),

            TimeEvent(27*FRAMES, function(inst)
                inst.SoundEmitter:PlaySound("dontstarve_DLC002/creatures/seacreature_movement/water_submerge_lrg")
            end),
        },

        events =
        {
            EventHandler("animqueueover", function(inst)
                inst.AttackCounter = inst.AttackCounter + 1
                if inst.AttackCounter >= 3 then
                    inst.AttackCounter = 0
                    inst.CanFly = true
                    inst.sg:GoToState("dive")
                else
                    inst.sg:GoToState("idle")
                end
            end),
        },
    },

    State{
        name = "hit",
        tags = {"busy", "hit"},

        onenter = function(inst, cb)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("water_hit")
            --inst.components.rowboatwakespawner:StopSpawning()
        end,

        timeline =
        {
            TimeEvent(1*FRAMES, function(inst)
                inst.SoundEmitter:PlaySound("dontstarve_DLC002/creatures/tiger_shark/hit")
            end),
        },

        events=
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("idle") end),
        },
    },

    State{
        name = "death",
        tags = {"busy"},

        onenter = function(inst)
            inst.AnimState:PlayAnimation("water_death")
            --inst.components.rowboatwakespawner:StopSpawning()
            inst.Physics:Stop()
            RemovePhysicsColliders(inst)
            inst.components.lootdropper:DropLoot(Vector3(inst.Transform:GetWorldPosition()))
        end,

        timeline =
        {
            TimeEvent(1*FRAMES, function(inst)
                inst.SoundEmitter:PlaySound("dontstarve_DLC002/creatures/seacreature_movement/water_emerge_lrg")
            end),
            TimeEvent(11*FRAMES, function(inst)
                inst.SoundEmitter:PlaySound("dontstarve_DLC002/creatures/tiger_shark/death_sea")
                inst.SoundEmitter:PlaySound("dontstarve_DLC002/creatures/seacreature_movement/splash_large")
            end),
        },

    },

    State{
        name = "taunt",
        tags = {"busy"},

        onenter = function(inst)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("water_taunt")
            --inst.components.rowboatwakespawner:StopSpawning()
        end,

        timeline =
        {
            TimeEvent(6*FRAMES, function(inst)
                inst.SoundEmitter:PlaySound("dontstarve_DLC002/creatures/tiger_shark/water_emerge_lrg")
            end),
            TimeEvent(0*FRAMES, function(inst)
                inst.SoundEmitter:PlaySound("dontstarve_DLC002/creatures/tiger_shark/taunt_sea")
            end),
            TimeEvent(33*FRAMES, function(inst)
                inst.SoundEmitter:PlaySound("dontstarve_DLC002/creatures/tiger_shark/taunt_sea")
            end),
            TimeEvent(60*FRAMES, function(inst)
                inst.SoundEmitter:PlaySound("dontstarve_DLC002/creatures/tiger_shark/water_submerge_lrg")
            end),
        },

        events =
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("idle") end)
        },
    },

    State{
        name = "walk_start",
        tags = {"moving", "canrotate"},

        onenter = function(inst) 
            inst.components.locomotor:WalkForward()
            inst.AnimState:PlayAnimation("water_run")
        end,

        events =
        {   
            EventHandler("animover", function(inst) inst.sg:GoToState("walk") end ),        
        },

        timeline =
        {
            TimeEvent(0, function(inst)
                --inst.components.rowboatwakespawner:StopSpawning()
                local target = inst:GetTarget()
                if target and not inst:GroundTypesMatch(target) then
                    inst.sg:GoToState("dive")
                end
            end),
            TimeEvent(9*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC002/creatures/tiger_shark/run_down") end),
        },
    },
        
    State{
            
        name = "walk",
        tags = {"moving", "canrotate"},
        
        onenter = function(inst) 
            inst.components.locomotor:WalkForward()
            inst.AnimState:PlayAnimation("water_run")
            inst.SoundEmitter:PlaySound("dontstarve_DLC002/creatures/tiger_shark/water_swimemerged_lrg_LP", "walk_loop")
        end,

        onexit = function(inst)
            inst.SoundEmitter:KillSound("walk_loop")
        end,

        events =
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("walk") end),
        },

        timeline = 
        {
            TimeEvent(0, function(inst)
                local target = inst:GetTarget()
                if target and not inst:GroundTypesMatch(target) then
                    inst.sg:GoToState("dive")
                end
            end),
        },
    },      
    
    State{
        name = "walk_stop",
        tags = {"canrotate"},
        
        onenter = function(inst) 
            inst.components.locomotor:StopMoving()
            inst.sg:GoToState("idle")
        end,

        timeline =
        {
            TimeEvent(0, function(inst)
                --inst.components.rowboatwakespawner:StopSpawning()
                local target = inst:GetTarget()
                if target and not inst:GroundTypesMatch(target) then
                    inst.sg:GoToState("dive")
                end
            end),
        },
    },

}

CommonStates.AddFrozenStates(states, nil, {frozen = "water_frozen", frozen_pst = "water_frozen_loop_pst"})
CommonStates.AddSleepStates(states,
{
    starttimeline = {TimeEvent(0*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC002/creatures/tiger_shark/water_emerge_lrg") end)},
    sleeptimeline = {TimeEvent(0*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC002/creatures/tiger_shark/sleep") end)},
    waketimeline = {TimeEvent(0*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC002/creatures/tiger_shark/water_submerge_lrg") end)},
}, nil, {sleep_pre = "water_sleep_pre", sleep_loop = "water_sleep_loop", sleep_pst = "water_sleep_pst"})

CommonStates.AddRunStates(states,
{
    starttimeline =
    {
        TimeEvent(0, function(inst)
            --inst.components.rowboatwakespawner:StopSpawning()
            local target = inst:GetTarget()
            if target and not inst:GroundTypesMatch(target) then
                inst.sg:GoToState("dive")
            end
        end),
        TimeEvent(0, function(inst) SpawnWaves(inst, 2, 160) end),
        TimeEvent(9*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC002/creatures/tiger_shark/run_down") end),
    },
    runtimeline =
    {
        TimeEvent(0, function(inst)
            --inst.components.rowboatwakespawner:StopSpawning()
            local target = inst:GetTarget()
            if target and not inst:GroundTypesMatch(target) then
                inst.sg:GoToState("dive")
            end
        end),
        TimeEvent(0, function(inst) SpawnWaves(inst, 2, 160) end),
        TimeEvent(9*FRAMES, function(inst) inst.SoundEmitter:PlaySound("dontstarve_DLC002/creatures/tiger_shark/run_down") end),
    },
    endtimeline =
    {
        TimeEvent(0, function(inst)
            --inst.components.rowboatwakespawner:StopSpawning()
            local target = inst:GetTarget()
            if target and not inst:GroundTypesMatch(target) then
                inst.sg:GoToState("dive")
            end
        end),
    },
},
{
    startrun = "water_charge_pre",
    run = "water_charge",
    stoprun = "water_charge_pst",
})

return StateGraph("SGtigershark_duke_water", states, events, "idle", actionhandlers)