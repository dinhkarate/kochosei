local assets=
{
	Asset("ANIM", "anim/catcoon_basic.zip"),
	Asset("ANIM", "anim/kitcoon_basic.zip"),
	Asset("ANIM", "anim/catcoon_actions.zip"),
	Asset("SOUND", "sound/hound.fsb"),
}

local function grow(inst, dt)
    if inst.components.scaler.scale < 0.75 then
        local new_scale = math.min(inst.components.scaler.scale + TUNING.ROCKY_GROW_RATE*dt, 0.75)
        inst.components.scaler:SetScale(new_scale)
    else
        if inst.growtask then
            inst.growtask:Cancel()
            inst.growtask = nil
        end
    end
end

local function applyscale(inst, scale)
	inst.DynamicShadow:SetSize(2.5 * scale, 1.5 * scale)
end

local function canhit(inst,owner,target)
	return target and target:IsValid() 
		and target.components.combat and target.components.health  
		and target ~= owner and not target:HasTag("tadalin") 
		and (target:HasTag("player") or target.components.combat.target == owner)
end 

local function onthrown(inst)
	local speed = inst.components.ly_projectile.speed
	
	if speed > 15 then 
		inst.AnimState:PlayAnimation("walk_loop", true)

	else
		inst.AnimState:PlayAnimation("walk_loop", true)
	end 
	
	inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/catcoon/attack")
end 

local function onhit(inst,owner,target)
	inst.components.health:Kill()
	
	local fx = SpawnPrefab("impact")
	fx.Transform:SetPosition(inst:GetPosition():Get())
	--fx:FacePoint(owner.Transform:GetWorldPosition())
end 

local function onmiss(inst)
	inst.components.health:Kill()
end 

local function ondeath(inst)
	inst.AnimState:PlayAnimation("death")
	inst.SoundEmitter:PlaySound("dontstarve_DLC001/creatures/catcoon/death")
	
	inst.components.ly_projectile:Stop()
end 


local function kittenfn(TenBuild_Catcoon)
	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
	local anim = inst.entity:AddAnimState()
    local physics = inst.entity:AddPhysics()
	local sound = inst.entity:AddSoundEmitter()
	local shadow = inst.entity:AddDynamicShadow()
	inst.entity:AddNetwork()

    MakeCharacterPhysics(inst, 10, .5)
    --MakePoisonableCharacter(inst)
    --MakeSmallBurnable(inst)
    --MakeSmallPropagator(inst)
	MakeInventoryPhysics(inst)
    RemovePhysicsColliders(inst)

	shadow:SetSize( 2.5, 1.5 )
    trans:SetFourFaced()

    inst:AddTag("sharkitten")
    inst:AddTag("scarytoprey")
    inst:AddTag("prey")
	inst:AddTag("tadalin")

    anim:SetBank("catcoon")
    anim:SetBuild(TenBuild_Catcoon)
    anim:PlayAnimation("idle_loop")
	
	inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("scaler")
    inst.components.scaler.OnApplyScale = applyscale
	
	inst:AddComponent("health")
	inst.components.health:SetMaxHealth(3)
	
	inst:AddComponent("combat")
	
	inst:AddComponent("ly_projectile")
	inst.components.ly_projectile.damage = 20
	inst.components.ly_projectile:SetRange(math.random()*10 + 20)
	inst.components.ly_projectile:SetSpeed(15)
	inst.components.ly_projectile:SetCanHit(canhit)
	inst.components.ly_projectile:SetOnThrownFn(onthrown)
	inst.components.ly_projectile:SetOnHitFn(onhit)
	inst.components.ly_projectile:SetOnMissFn(onmiss)

    local min_scale = 0.75
    local max_scale = 1.00

    local scaleRange = max_scale - min_scale
    local start_scale = min_scale + math.random() * scaleRange

    inst.components.scaler:SetScale(start_scale)

    inst.OnLongUpdate = grow
	
	inst:ListenForEvent("death",ondeath)

    return inst
end


local function make(TenBuild_Catcoon)
	return Prefab(TenBuild_Catcoon.."_projectile", function()
		local inst = CreateEntity()
		local trans = inst.entity:AddTransform()
		local anim = inst.entity:AddAnimState()
		local physics = inst.entity:AddPhysics()
		local sound = inst.entity:AddSoundEmitter()
		local shadow = inst.entity:AddDynamicShadow()
		inst.entity:AddNetwork()

		MakeCharacterPhysics(inst, 10, .5)
		--MakePoisonableCharacter(inst)
		--MakeSmallBurnable(inst)
		--MakeSmallPropagator(inst)
		MakeInventoryPhysics(inst)
		RemovePhysicsColliders(inst)

		shadow:SetSize( 2.5, 1.5 )
		trans:SetFourFaced()

		inst:AddTag("sharkitten")
		inst:AddTag("scarytoprey")
		inst:AddTag("prey")
		inst:AddTag("tadalin")

		anim:SetBank("catcoon")
		anim:SetBuild(TenBuild_Catcoon)
		anim:PlayAnimation("idle_loop")
		
		inst.entity:SetPristine()

		if not TheWorld.ismastersim then
			return inst
		end

		inst:AddComponent("scaler")
		inst.components.scaler.OnApplyScale = applyscale
		
		inst:AddComponent("health")
		inst.components.health:SetMaxHealth(3)
		
		inst:AddComponent("combat")
		
		inst:AddComponent("ly_projectile")
		inst.components.ly_projectile.damage = 20
		inst.components.ly_projectile:SetRange(math.random()*10 + 20)
		inst.components.ly_projectile:SetSpeed(15)
		inst.components.ly_projectile:SetCanHit(canhit)
		inst.components.ly_projectile:SetOnThrownFn(onthrown)
		inst.components.ly_projectile:SetOnHitFn(onhit)
		inst.components.ly_projectile:SetOnMissFn(onmiss)

		local min_scale = 0.75
		local max_scale = 1.00

		local scaleRange = max_scale - min_scale
		local start_scale = min_scale + math.random() * scaleRange

		inst.components.scaler:SetScale(start_scale)

		inst.OnLongUpdate = grow
		
		inst:ListenForEvent("death", ondeath)

		return inst
	end, 
	assets)
end


return
	make("catcoon_build")

