local assets = {
	Asset("ANIM", "anim/kochosei_may_gacha.zip"),
}

local function onhammered(inst, worker)
	if inst.components.burnable ~= nil and inst.components.burnable:IsBurning() then
		inst.components.burnable:Extinguish()
	end
	inst.components.lootdropper:DropLoot()
	local fx = SpawnPrefab("collapse_big")
	fx.Transform:SetPosition(inst.Transform:GetWorldPosition())
	fx:SetMaterial("wood")
	inst:Remove()
end

local function Gachatime(inst)
	print(inst)
end

local function banoidungnghiennua(inst, data)
	local doer = data.doer -- Nhận doer từ event
	if doer ~= nil then
		Gachatime(doer)
	end
	local fx = SpawnPrefab("fx_book_rain")
	local x, y, z = inst.Transform:GetWorldPosition()

	fx.Transform:SetPosition(x + 1.5, y + 7, z)
	if TheWorld.state.precipitation ~= "none" then
		TheWorld:PushEvent("ms_forceprecipitation", false)
	else
		TheWorld:PushEvent("ms_forceprecipitation", true)
	end
end

local function fn()
	local inst = CreateEntity()
	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddSoundEmitter()
	inst.entity:AddNetwork()
	--MakeInventoryPhysics(inst) -- Nó cần phải bé bé, to quá nó vướng nhà
	inst:SetPhysicsRadiusOverride(1.5)

	inst.AnimState:SetBank("kochosei_may_gacha")
	inst.AnimState:SetBuild("kochosei_may_gacha")
	inst.AnimState:PlayAnimation("idle")
	inst.entity:SetPristine()

	if not TheWorld.ismastersim then
		return inst
	end

	inst:AddComponent("inspectable")

	inst:AddComponent("kochoseimaygacha")

	inst:AddComponent("timer")

	inst:AddComponent("lootdropper")
	--[[
    local constructionsite = inst:AddComponent("constructionsite")
    constructionsite:SetConstructionPrefab("construction_container")
    constructionsite:SetOnConstructedFn(function ()
        
    end)
--]]
	inst:AddComponent("workable")
	inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
	inst.components.workable:SetWorkLeft(4)
	inst.components.workable:SetOnFinishCallback(onhammered)
	inst.components.workable:SetOnWorkCallback(function() end)
	inst:ListenForEvent("banoidungnghiennua", banoidungnghiennua)

	return inst
end

STRINGS.NAMES.KOCHOSEI_MAY_GACHA = "Máy gacha hợp pháp"
STRINGS.RECIPE_DESC.KOCHOSEI_MAY_GACHA = "Bạn ơi đừng nghiện nữa, nhà mình còn gì nữa đâu"

return Prefab("kochosei_may_gacha", fn, assets),
	MakePlacer("kochosei_may_gacha_placer", "kochosei_may_gacha", "kochosei_may_gacha", "idle", nil, nil, nil)
