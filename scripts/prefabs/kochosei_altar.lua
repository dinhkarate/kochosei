require 'prefabutil'

local function onopen(inst)

    inst.AnimState:PlayAnimation('teleport',true)
    --inst.SoundEmitter:PlaySound('dontstarve/wilson/chest_open')

end

local function onclose(inst)

    inst.AnimState:PlayAnimation('ending')
    inst.AnimState:PushAnimation('ending_loop', true)
    --inst.SoundEmitter:PlaySound('dontstarve/wilson/chest_close')
end

local function onhammered(inst, worker)
  if inst.components.burnable ~= nil and inst.components.burnable:IsBurning() then -- 正在燃烧
    inst.components.burnable:Extinguish() -- 扑灭火
  end
  inst.components.lootdropper:DropLoot() -- 掉落战利品
  if inst.components.container ~= nil then
    inst.components.container:DropEverything() -- 掉落物品
  end
end

local function onhit(inst, worker)
  
    inst.AnimState:PlayAnimation('ending') -- 敲
    inst.AnimState:PushAnimation('ending_loop', true) -- 关闭

    if inst.components.container ~= nil then -- 掉落物品
      inst.components.container:DropEverything()
      inst.components.container:Close()
    end
end

local function onbuilt(inst)

  inst.AnimState:PlayAnimation('ending')
  inst.AnimState:PushAnimation('ending_loop', true)
  --inst.SoundEmitter:PlaySound('dontstarve/common/chest_craft')
end

local function onsave(inst, data)
  if inst.components.burnable ~= nil and inst.components.burnable:IsBurning() or inst:HasTag('burnt') then
    data.burnt = true
  end
end

local function onload(inst, data)
  if data ~= nil and data.burnt and inst.components.burnable ~= nil then
    inst.components.burnable.onburnt(inst)
  end
end

local assets = {
    Asset('ANIM', 'anim/quagmire_altar.zip'),
    Asset("ATLAS", "images/inventoryimages/kochosei_inv.xml"),
    Asset("IMAGE", "images/inventoryimages/kochosei_inv.tex"),
}

local function fn()
  local inst = CreateEntity()

  inst.entity:AddTransform()
  inst.entity:AddAnimState()
  inst.entity:AddSoundEmitter()
  inst.entity:AddMiniMapEntity()
  inst.entity:AddNetwork()

  --inst.MiniMapEntity:SetIcon('treasurechest.png') -- 图标

  inst:AddTag('structure') -- 建筑
  inst:AddTag('chest') -- 箱子

  inst.AnimState:SetBank('quagmire_altar')
  inst.AnimState:SetBuild('quagmire_altar')
  inst.AnimState:PlayAnimation('ending_loop',true)

  MakeSnowCoveredPristine(inst) -- 积雪

  MakeObstaclePhysics(inst, .5)

  inst.entity:SetPristine()

  if not TheWorld.ismastersim then
    return inst
  end
   -- inst:AddComponent("prototyper")
   -- inst.components.prototyper.trees = TUNING.PROTOTYPER_TREES.KOCHOSEI_ALTAR

  inst:AddComponent('inspectable') -- 可检查

  inst:AddComponent('container') -- 容器
  inst.components.container:WidgetSetup('kochosei_altar')
  inst.components.container.onopenfn = onopen
  inst.components.container.onclosefn = onclose


  inst:AddComponent('lootdropper') -- 战利品掉落（锤子锤掉）
  inst:AddComponent('workable') -- 可交互
  inst.components.workable:SetWorkAction(ACTIONS.HAMMER) -- 锤子
  inst.components.workable:SetWorkLeft(9999) 
  inst.components.workable:SetOnWorkCallback(onhit) -- 锤掉
  --inst.components.workable:SetOnFinishCallback(onhammered) -- 交互

  MakeMediumPropagator(inst) -- 制作中号传播者?
  inst:AddComponent('hauntable') -- 作祟
  inst.components.hauntable:SetHauntValue(TUNING.HAUNT_TINY)

  inst:ListenForEvent('onbuilt', onbuilt) -- 建
  MakeSnowCovered(inst) -- 大雪覆盖

  -- Save / load is extended by some prefab variants
  inst.OnSave = onsave
  inst.OnLoad = onload

  return inst
end

return Prefab('kochosei_altar', fn, assets), MakePlacer(
  'kochosei_altar_placer',
  'quagmire_altar',
  'quagmire_altar',
  'idle_empty'
)
