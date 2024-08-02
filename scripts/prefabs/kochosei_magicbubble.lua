local assets = {
	Asset("ANIM", "anim/kochosei_magicbubble.zip"),
}
local function OnHit(inst, owner, target)
	inst.SoundEmitter:PlaySound("dontstarve/common/balloon_pop")
	inst:DoTaskInTime(0.1, inst.Remove)
	local x, y, z = target.Transform:GetWorldPosition()
	local fx = SpawnPrefab("deer_ice_burst") --sparks
	fx.Transform:SetPosition(x, y + 2, z)
end

local function fn()
	local inst = CreateEntity()

	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddNetwork()
	inst.entity:AddSoundEmitter()

	MakeInventoryPhysics(inst)
	RemovePhysicsColliders(inst)

	MakeHauntableLaunch(inst)
	inst.AnimState:SetBank("kochosei_magicbubble")
	-- This is the name of your compiled*.zip file.
	inst.AnimState:SetBuild("kochosei_magicbubble")
	-- This is the animation name while item is on the ground.
	inst.AnimState:PlayAnimation("idle")

	inst:AddTag("sharp")

	-- Glow in the Dark!
	inst.entity:AddLight()
	inst.Light:Enable(true) -- originally was false.
	inst.Light:SetRadius(1)
	inst.Light:SetFalloff(0.5)
	inst.Light:SetIntensity(0.8)
	inst.Light:SetColour(187 / 255, 147 / 255, 247 / 255)

	inst:AddTag("projectile")

	inst.entity:SetPristine()

	if not TheWorld.ismastersim then
		return inst
	end

	inst:AddComponent("weapon")

	inst:AddComponent("projectile")
	inst.components.projectile:SetSpeed(30)
	inst.components.projectile:SetCanCatch(false)
	inst.components.projectile:SetHoming(true)

	inst.components.projectile:SetOnHitFn(OnHit)
	inst.components.projectile:SetOnMissFn(inst.Remove)

	inst:DoTaskInTime(15, inst.Remove)

	return inst
end

return Prefab("kochosei_magicbubble", fn, assets, prefabs)
