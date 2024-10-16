local JUMP_SPEED = 120
local JUMP_LAND_OFFSET = 3
local JUMP_HEIGHT_DELTA = 1.5

local function StartLight(inst)
    inst._startlighttask = nil
    inst.Light:Enable(true)
    if inst._staffstar == nil then
        inst.AnimState:SetBloomEffectHandle("shaders/anim.ksh")
    end
end

local function StopLight(inst)
    inst._stoplighttask = nil
    inst.Light:Enable(false)
    if inst._staffstar == nil then
        inst.AnimState:ClearBloomEffectHandle()
    end
end

local function StopFX(inst)
    if inst._fxpulse ~= nil then
        inst._fxpulse:KillFX()
        inst._fxpulse = nil
    end
    if inst._fxfront ~= nil or inst._fxback ~= nil then
        if inst._fxback ~= nil then
            inst._fxfront:KillFX()
            inst._fxfront = nil
        end
        if inst._fxback ~= nil then
            inst._fxback:KillFX()
            inst._fxback = nil
        end
        if inst._stoplighttask ~= nil then
            inst._stoplighttask:Cancel()
        end
        inst._stoplighttask = inst:DoTaskInTime(9 * FRAMES, StopLight)
    end
    if inst._startlighttask ~= nil then
        inst._startlighttask:Cancel()
        inst._startlighttask = nil
    end
end

local function StartFX(inst)
    if inst._fxfront == nil or inst._fxback == nil then
        local x, y, z = inst.Transform:GetWorldPosition()

        if inst._fxpulse ~= nil then
            inst._fxpulse:Remove()
        end
        inst._fxpulse = SpawnPrefab("positronpulse")
        inst._fxpulse.Transform:SetPosition(x, y, z)

        if inst._fxfront ~= nil then
            inst._fxfront:Remove()
        end
        inst._fxfront = SpawnPrefab("positronbeam_front")
        inst._fxfront.Transform:SetPosition(x, y, z)

        if inst._fxback ~= nil then
            inst._fxback:Remove()
        end
        inst._fxback = SpawnPrefab("positronbeam_back")
        inst._fxback.Transform:SetPosition(x, y, z)

        if inst._startlighttask ~= nil then
            inst._startlighttask:Cancel()
        end
        inst._startlighttask = inst:DoTaskInTime(3 * FRAMES, StartLight)
    end
    if inst._stoplighttask ~= nil then
        inst._stoplighttask:Cancel()
        inst._stoplighttask = nil
    end
    inst:DoTaskInTime(40 * FRAMES, StopFX)
end





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
	--ActionHandler(ACTIONS.TIGERSHARK_FEED, "feed"),
}

local events =
{
    CommonHandlers.OnSleep(),
	CommonHandlers.OnDeath(),
	CommonHandlers.OnLocomote(true, true),
	CommonHandlers.OnFreeze(),
	CommonHandlers.OnAttack(),
	CommonHandlers.OnAttacked(),
    
}

local function ToggleOffPhysics(inst)
    inst.isphysicstoggle = true
    inst.Physics:ClearCollisionMask()
    inst.Physics:CollidesWith(COLLISION.GROUND)
end

local function ToggleOnPhysics(inst)
    inst.isphysicstoggle = nil
    inst.Physics:ClearCollisionMask()
    inst.Physics:CollidesWith(COLLISION.WORLD)
    inst.Physics:CollidesWith(COLLISION.OBSTACLES)
    inst.Physics:CollidesWith(COLLISION.SMALLOBSTACLES)
    inst.Physics:CollidesWith(COLLISION.CHARACTERS)
    inst.Physics:CollidesWith(COLLISION.GIANTS)
end

local function SpawnSharkittens(inst,target) --Cần thiết thì sẽ đổi luôn tên hàm
	target = target or inst.components.combat.target
	if not (target and target:IsValid()) then 
		return 
	end 
	for i = 1,math.random(4,6) do 
		local pos = inst:GetPosition()
		local theta = 2 * PI * math.random() 
		local radius = 8
		local offset = FindWalkableOffset(pos, theta, radius, 8, true, true) or Vector3(0,0,0)
		
		local tornado = SpawnPrefab("kochosei_tornado")
		
		if inst.components.health:GetPercent() <= 0.5 then 
			tornado.Transform:SetScale(2,2,1)
		else
			tornado.Transform:SetScale(1.5,1.5,1)
		end
		
		tornado.Transform:SetPosition((pos+offset):Get())
		--tornado.components.combat:SetTarget(target)
	end
end 

local function OnFocusCamera(inst)
    local player = TheFocalPoint.entity:GetParent()
    if player ~= nil then
        TheFocalPoint.components.focalpoint:StartFocusSource(inst, "large", nil, math.huge, math.huge, 3)
    end
end

local function OnStopFocusCamera(inst)
    local player = TheFocalPoint.entity:GetParent()
    if player ~= nil then
        TheFocalPoint.components.focalpoint:StopFocusSource(inst, "large")
    end
end



-- Bây giờ vào con Sonoko nghiên cứu cái StateGraph bay lên bao gồm những Anim gì và sau đó tiến này sử dụng nó cho hoạt ảnh bay lên.
-- Nếu không được thì bỏ tính năng bay lên của con này.
local states =
{

    -- appear_pre > appear
    State{
        name = "appear_pre",
        tags = { "busy", "nopredict", "transform", "nomorph", "nointerrupt" },

        onenter = function(inst)
            inst.Physics:Stop()
            inst.components.locomotor:Stop()
            TheNet:Announce("Kochosei Duke xuất thế!!! Anh em lên đảo chơi nó thôi")
            inst.AnimState:PlayAnimation("deform_pre")
            StartFX(inst)
            OnFocusCamera(inst)
            SpawnPrefab("monkey_deform_pre_fx").Transform:SetPosition(inst.Transform:GetWorldPosition())
        end,

        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:AddStateTag("noattack")
                    inst.components.health:SetInvincible(true)
                    inst.sg:GoToState("appear")
                end
            end),
        },

    },

    State{
        name = "appear",
        tags = { "busy","nopredict", "transform", "nomorph", "nointerrupt" },

        onenter = function(inst)
            inst.components.locomotor:Stop()
            inst.AnimState:PlayAnimation("deform_pst")

            SpawnPrefab("monkey_deform_pst_fx").Transform:SetPosition(inst.Transform:GetWorldPosition())
        end,

        timeline =
        {
            TimeEvent(15*FRAMES, function(inst)
            end),

            TimeEvent(20*FRAMES, function(inst)
                inst.sg:RemoveStateTag("nointerrupt")
                OnStopFocusCamera(inst)
                inst.components.health:SetInvincible(false)
            end),
        },

        events =
        {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("idle")
                end
            end),
        },
    },
    
    State{
        name = "laugh",
        tags = {"idle", "canrotate"},

        onenter = function(inst)
			inst.components.locomotor:Stop()
			inst:ClearBufferedAction()
			if inst.AnimState:IsCurrentAnimation("run_pst") then
				inst.AnimState:PushAnimation("emote_laugh")
			else
				inst.AnimState:PlayAnimation("emote_laugh")
			end
			inst.AnimState:PushAnimation("emote_laugh", true)

        end,

        events =
        {
            EventHandler("animover", function(inst)
                inst.sg:GoToState("idle")
            end)
        },
    },

    State{
		name = "chicken",
		tags = { "idle", "dancing" },

		onenter = function(inst)
			inst.components.locomotor:Stop()
			inst:ClearBufferedAction()
			if inst.AnimState:IsCurrentAnimation("run_pst") then
				inst.AnimState:PushAnimation("emoteXL_loop_dance6")
			else
				inst.AnimState:PlayAnimation("emoteXL_loop_dance6")
			end
			inst.AnimState:PushAnimation("emoteXL_loop_dance6", true)
		end,
	},

    State{
        name = "idle",
        tags = {"idle", "canrotate"},

        onenter = function(inst)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("idle_loop", true)
            inst.SoundEmitter:PlaySound("dontstarve_DLC002/creatures/tiger_shark/idle")
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
            inst.AnimState:PlayAnimation("eat_pre")
            inst.AnimState:PushAnimation("eat_loop")
            inst.AnimState:PushAnimation("eat_pst", false)
    	end,

        timeline =
        {
            TimeEvent(10*FRAMES, function(inst)
                --inst.SoundEmitter:PlaySound("dontstarve_DLC002/creatures/tiger_shark/eat")
				inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/bearger/chew")
                inst:PerformBufferedAction()
            end)
        },

    	events =
    	{
            EventHandler("animqueueover", function(inst)
                inst.sg:GoToState("idle")
            end)
    	},
	},

    State{
        name = "feed",
        tags = {"busy", "canrotate"},

        onenter = function(inst)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("hork")
        end,

        timeline =
        {
            TimeEvent(13*FRAMES, function(inst)
                --inst.SoundEmitter:PlaySound("dontstarve_DLC002/creatures/tiger_shark/meat_hork")
				inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/bearger/chew")
            end),
            TimeEvent(19*FRAMES, function(inst)
                inst:PerformBufferedAction()
            end)
        },

        events =
        {
            EventHandler("animover", function(inst)
                inst.sg:GoToState("idle")
            end)
        },
    },

    -- jump > fallwarn > fall > fallpost

    State{
        name = "jump",
        tags = {"busy", "specialattack"},

        onenter = function(inst)
            inst.components.locomotor:Stop()
            --inst.components.locomotor:EnableGroundSpeedMultiplier(false)
			--inst.components.locomotor:SetExternalSpeedMultiplier(inst, "tigershark_duke_jump",0)
			
            inst.AnimState:PlayAnimation("superjump_lag")
            inst.AnimState:PushAnimation("superjump", false)
        end,
		
		
		onexit = function(inst)
			--inst.components.locomotor:Stop()
            --inst.components.locomotor:EnableGroundSpeedMultiplier(true)
            --inst.Physics:ClearMotorVelOverride()
			inst.components.health:SetInvincible(false)
			--inst.components.locomotor:RemoveExternalSpeedMultiplier(inst,"tigershark_duke_jump")
			--ToggleOnPhysics(inst)
			if inst.JumpUpdateTask then
				inst.JumpUpdateTask:Cancel()
			end
			inst.JumpUpdateTask = nil 
		end,

        timeline =
        {
            -- TimeEvent(0*FRAMES, function(inst)
            --     inst.SoundEmitter:PlaySound("dontstarve_DLC002/creatures/tiger_shark/land_explode")
            -- end),
			
			TimeEvent(20*FRAMES, function(inst)
                --inst.SoundEmitter:PlaySound("dontstarve_DLC002/creatures/tiger_shark/land_explode")
				--ToggleOffPhysics(inst)
            end),

            TimeEvent(23*FRAMES, function(inst)
                --inst.SoundEmitter:PlaySound("dontstarve_DLC002/creatures/tiger_shark/jump_attack")
                --inst.SoundEmitter:PlaySound("dontstarve_DLC002/creatures/tiger_shark/roar")
                --inst.SoundEmitter:PlaySound("dontstarve_DLC002/creatures/tiger_shark/launch_land")
				inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/bearger/swhoosh")
				inst.DynamicShadow:Enable(false)
	            --inst.components.locomotor.disable = true
				--inst.Physics:Stop()
				inst.components.locomotor.disable = true
				inst.components.health:SetInvincible(true)
	            --inst.Physics:SetMotorVelOverride(0,JUMP_SPEED,0)
				inst.JumpUpdateTask = inst:DoPeriodicTask(0,function()
					local x,y,z = inst:GetPosition():Get()
					y = y + JUMP_HEIGHT_DELTA 
					inst.Transform:SetPosition(x,y,z)
				end)
    		end),
			
			--[[TimeEvent(25*FRAMES, function(inst)
	            inst.Physics:SetMotorVelOverride(0,JUMP_SPEED,0)
    		end),
			
			TimeEvent(27*FRAMES, function(inst)
	            inst.Physics:SetMotorVelOverride(0,JUMP_SPEED,0)
    		end),--]]

            TimeEvent(38*FRAMES, function(inst)
                local tar = inst:GetTarget()

                if tar and not inst:GroundTypesMatch(tar) then
                    inst:MakeWater() --GoToWaterState
                end

                inst.sg:GoToState("fallwarn")
            end)
        },
    },

    State{
        name = "fallwarn",
        tags = {"busy", "specialattack"},

        onenter = function(inst)
            inst.sg:SetTimeout(34*FRAMES)

            inst.Physics:Stop()

            local tar = inst:GetTarget()
            local pos = tar or inst:GetPosition()

            pos.y = 45
            inst.Transform:SetPosition(pos:Get())

            local shadow = SpawnPrefab("kochosei_tigershark_duke_shadow")
            shadow:Ground_Fall()
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
        end,

        ontimeout = function(inst)
            inst:Show()

           --[[ if inst:GetIsOnWater() then
                inst:MakeWater()
                local pos = inst:GetPosition()
                pos.y = 45
                inst.Transform:SetPosition(pos:Get())
            end--]]

            inst.sg:GoToState("fall")
        end,
    },

    State{
        name = "fall",
        tags = {"busy", "specialattack"},

        onenter = function(inst)
            ChangeToCharacterPhysics(inst)
	        inst.components.locomotor.disable = true
            inst.Physics:SetMotorVel(0,-JUMP_SPEED,0)
            inst.AnimState:PlayAnimation("superjump", true)
            inst.Physics:SetCollides(false)
            inst.sg:SetTimeout(JUMP_SPEED/45 + 0.2)
            inst.SoundEmitter:PlaySound("dontstarve_DLC002/creatures/tiger_shark/dive_attack")
        end,

        timeline =
        {
            TimeEvent(20*FRAMES, function(inst) 
				--inst.SoundEmitter:PlaySound("dontstarve_DLC002/creatures/tiger_shark/roar") 
				inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/bearger/swhoosh")
			end),
        },

        ontimeout = function(inst)
            local pt = Point(inst.Transform:GetWorldPosition())
            local vx, vy, vz = inst.Physics:GetMotorVel()
            if pt.y <= .1 then
                pt.y = 0
                inst.Physics:Stop()
                inst.Physics:Teleport(pt.x,pt.y,pt.z)
                inst.CanFly = false
                inst.Physics:SetCollides(true)
                inst.sg:GoToState("fallpost")
            end
        end,

        onupdate = function(inst)
            inst.Physics:SetMotorVel(0,-JUMP_SPEED,0)
            local pt = Point(inst.Transform:GetWorldPosition())
            if pt.y <= .1 then
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
            inst.Physics:Stop()
            inst.components.locomotor.disable = false
            inst.AnimState:PlayAnimation("superjump_land")
            inst.components.groundpounder:GroundPound()
            --inst.SoundEmitter:PlaySound("dontstarve_DLC002/creatures/tiger_shark/land_explode")
			inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/bearger/groundpound")
			inst.DynamicShadow:Enable(true)
        end,

        onexit = function(inst)
            inst.components.health:SetInvincible(false)
            inst:Show()
        end,

        events=
        {
            EventHandler("animover", function(inst) inst.sg:GoToState("idle") end),
        },
    },


    State{
        name = "attack",
        tags = {"busy", "attack"},

        onenter = function(inst)
            inst.components.locomotor:StopMoving()
            inst.components.combat:StartAttack()
            inst.AnimState:PlayAnimation("emoteXL_kiss")

            inst.CanRun = false
            --inst.components.rowboatwakespawner:StopSpawning()
            if not inst.components.timer:TimerExists("Run") then
                inst.components.timer:StartTimer("Run", 10)
            end
        end,

        timeline =
        {
            TimeEvent(4*FRAMES, function(inst)
                --inst.SoundEmitter:PlaySound("dontstarve_DLC002/creatures/tiger_shark/land_attack_rear")
				inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/bearger/attack")
            end),
            TimeEvent(23*FRAMES, function(inst)
                --inst.SoundEmitter:PlaySound("dontstarve_DLC002/creatures/tiger_shark/land_attack")
				inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/bearger/swhoosh")
                inst.components.combat:DoAttack()
				local target = inst.components.combat.target
				if target and target:IsValid() then 
					inst.components.combat:DoAreaAttack(target, 1.5, nil, nil, nil, {"LA_mob", "shadow", "INLIMBO", "playerghost", "battlestandard","tadalin"}) 
				end 
			end),
        },

        events =
        {
            EventHandler("animover", function(inst)
                inst.AttackCounter = inst.AttackCounter + 1
                if inst.AttackCounter >= 3 then
                    inst.AttackCounter = 0
                    inst.CanFly = true
                end
                inst.sg:GoToState("idle")
            end),
        },
    },

    State{
        name = "hit",
        tags = {"busy", "hit", "canrotate"},

        onenter = function(inst, cb)
            inst.Physics:Stop()
            inst.AnimState:PlayAnimation("hit")
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
            inst.AnimState:PlayAnimation("death")
            --inst.components.rowboatwakespawner:StopSpawning()
            inst.Physics:Stop()
            RemovePhysicsColliders(inst)
            inst.components.lootdropper:DropLoot(Vector3(inst.Transform:GetWorldPosition()))
			inst.components.lootdropper:SpawnLootPrefab("tigershark_duke_cinder",inst:GetPosition())
        end,

        timeline =
        {
            TimeEvent(1*FRAMES, function(inst)
                inst.SoundEmitter:PlaySound("dontstarve_DLC002/creatures/tiger_shark/death_land")
            end),
            TimeEvent(33*FRAMES, function(inst)
                --inst.SoundEmitter:PlaySound("dontstarve_DLC002/creatures/tiger_shark/death_land_body_fall")
				inst.SoundEmitter:PlaySound("dontstarve/tentacle/tentacle_splat")
				inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/bearger/groundpound")
            end),
        },

    },

    State{
    	name = "taunt",
    	tags = {"busy"},

    	onenter = function(inst)
    		inst.Physics:Stop()
    		inst.AnimState:PlayAnimation("deform_pre")
            local x, y, z = inst.Transform:GetWorldPosition()
                StartFX(inst)
    	end,

        timeline =
        {
            TimeEvent(10*FRAMES, function(inst)
                --inst.SoundEmitter:PlaySound("dontstarve_DLC002/creatures/tiger_shark/taunt_land")
				inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/bearger/taunt")
				SpawnSharkittens(inst)
            end),
        },

    	events =
    	{
    		EventHandler("animover", function(inst) inst.sg:GoToState("idle") end)
    	},
	},
}

CommonStates.AddFrozenStates(states)
CommonStates.AddSleepStates(states,
{
    sleeptimeline = {TimeEvent(0*FRAMES, function(inst) 
		--inst.SoundEmitter:PlaySound("dontstarve_DLC002/creatures/tiger_shark/sleep") 
		inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/bearger/sleep")
	end)},
})
CommonStates.AddWalkStates(states,
{
    starttimeline =
    {
        TimeEvent(0, function(inst)
            --inst.components.rowboatwakespawner:StopSpawning()
            local target = inst:GetTarget()
            if target and not inst:GroundTypesMatch(target) then
                inst.sg:GoToState("jump")
            end
        end),
    },
    walktimeline =
    {
        TimeEvent(0, function(inst)
            --inst.components.rowboatwakespawner:StopSpawning()
            local target = inst:GetTarget()
            if target and not inst:GroundTypesMatch(target) then
                inst.sg:GoToState("jump")
            end
        end),
        TimeEvent(0*FRAMES, function(inst)
            --inst.SoundEmitter:PlaySound("dontstarve_DLC002/creatures/tiger_shark/footstep")
			inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/bearger/step_soft")
        end),
        TimeEvent(20*FRAMES, function(inst)
            --inst.SoundEmitter:PlaySound("dontstarve_DLC002/creatures/tiger_shark/footstep")
			inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/bearger/step_soft")
        end),
    },
    endtimeline =
    {
        TimeEvent(0, function(inst)
            --inst.SoundEmitter:PlaySound("dontstarve_DLC002/creatures/tiger_shark/footstep")
			inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/bearger/step_stomp")
            --inst.components.rowboatwakespawner:StopSpawning()
            local target = inst:GetTarget()
            if target and not inst:GroundTypesMatch(target) then
                inst.sg:GoToState("jump")
            end
        end),
    },
})
CommonStates.AddRunStates(states,
{
    starttimeline =
    {
        TimeEvent(0, function(inst)
            --inst.components.rowboatwakespawner:StopSpawning()
            local target = inst:GetTarget()
            if target then
                local dist = inst:GetPosition():Dist(target)
                if (dist > 15 and inst.CanFly) or not inst:GroundTypesMatch(target) then
                    inst.sg:GoToState("jump")
                end
            end
        end),
    },
    runtimeline =
    {
        TimeEvent(0, function(inst)
            --inst.components.rowboatwakespawner:StopSpawning()
            local target = inst:GetTarget()
            if target and not inst:GroundTypesMatch(target) then
                inst.sg:GoToState("jump")
            end
        end),
        TimeEvent(4*FRAMES, function(inst)
            --inst.SoundEmitter:PlaySound("dontstarve_DLC002/creatures/tiger_shark/land_run")
			inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/bearger/step_soft")
        end),
        TimeEvent(12*FRAMES, function(inst)
            --inst.SoundEmitter:PlaySound("dontstarve_DLC002/creatures/tiger_shark/footstep_run")
			inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/bearger/step_stomp")
        end),
    },
    endtimeline =
    {
        TimeEvent(0, function(inst)
            --inst.components.rowboatwakespawner:StopSpawning()
            local target = inst:GetTarget()
            if target and not inst:GroundTypesMatch(target) then
                inst.sg:GoToState("jump")
            end
        end),
    },
},
{
    run = "run_loop",
})

return StateGraph("SGkochosei_duke", states, events, "idle", actionhandlers)
