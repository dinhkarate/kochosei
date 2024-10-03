local assets = {
    Asset("ANIM", "anim/kochosei_may_gacha.zip"),
}

local SCALE = 1.25

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

local function onhit(inst)

end


local function fn()
    local inst = CreateEntity()
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()
	--MakeInventoryPhysics(inst) -- Nó cần phải bé bé, to quá nó vương nhà
    MakeObstaclePhysics(inst, 0.5)

    inst.AnimState:SetBank("kochosei_may_gacha")
    inst.AnimState:SetBuild("kochosei_may_gacha")
    inst.AnimState:PlayAnimation("idle")
    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inspectable")
    
    inst:AddComponent("kochoseimaygacha")

    inst:AddComponent("lootdropper")
    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
    inst.components.workable:SetWorkLeft(4)
    inst.components.workable:SetOnFinishCallback(onhammered)
    inst.components.workable:SetOnWorkCallback(function()
        
    end)

    return inst
end

STRINGS.NAMES.KOCHOSEI_MAY_GACHA = "Máy gacha hợp pháp"
STRINGS.RECIPE_DESC.KOCHOSEI_MAY_GACHA = "Bạn ơi đừng nghiện nữa, nhà mình còn gì nữa đâu"

return Prefab("kochosei_may_gacha", fn, assets), 
		MakePlacer("kochosei_may_gacha_placer", "kochosei_may_gacha", "kochosei_may_gacha", "idle", nil, nil, nil, SCALE)
