local assets =
{
    Asset("ANIM", "anim/miku_usagi_backpack.zip"),
    Asset("ANIM", "anim/swap_miku_usagi_backpack.zip"),
	Asset("ANIM", "anim/miku_usagi_backpack_2x4.zip"),
	Asset("ATLAS", "minimap/miku_usagi_backpack.xml"),
	Asset("IMAGE", "minimap/miku_usagi_backpack.tex"),
	

}

local prefabs =
{
    "ash",
}

local function onequip(inst, owner)

      --  owner.AnimState:OverrideSymbol("miku_usagi_backpack", "swap_miku_usagi_backpack", "miku_usagi_backpack")
	  	owner.AnimState:OverrideSymbol("swap_body", "swap_miku_usagi_backpack", "usagi")
        owner.AnimState:OverrideSymbol("swap_body", "swap_miku_usagi_backpack", "swap_body")
	
        owner:AddTag("fastpicker") 
		owner:AddTag("fastpick") 
		owner:AddTag("expertchef") 		
    if inst.components.container ~= nil then
        inst.components.container:Open(owner)
    end
end

local function onunequip(inst, owner)
    owner:RemoveTag("fastpick")
    owner:RemoveTag("fastpicker")
    owner:RemoveTag("expertchef")
    local skin_build = inst:GetSkinBuild()
    owner.AnimState:ClearOverrideSymbol("swap_body")
    owner.AnimState:ClearOverrideSymbol("miku_usagi_backpack")
    if inst.components.container ~= nil then
        inst.components.container:Close(owner)
    end
end

local function onburnt(inst)
    if inst.components.container ~= nil then
        inst.components.container:DropEverything()
        inst.components.container:Close()
    end

    SpawnPrefab("ash").Transform:SetPosition(inst.Transform:GetWorldPosition())

    inst:Remove()
end

local function onignite(inst)
    if inst.components.container ~= nil then
        inst.components.container.canbeopened = false
    end
end

local function onextinguish(inst)
    if inst.components.container ~= nil then
        inst.components.container.canbeopened = true
    end
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

	
    inst.AnimState:SetBank("miku_usagi_backpack")
    inst.AnimState:SetBuild("miku_usagi_backpack")
    inst.AnimState:PlayAnimation("idle")

    inst:AddTag("miku_usagi_backpack")
	inst:AddTag("fridge")
    inst:AddTag("nocool")

    inst.MiniMapEntity:SetIcon("miku_usagi_backpack.tex")

    inst.foleysound = "dontstarve/movement/foley/backpack"


    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
	inst.OnEntityReplicated = function(inst) inst.replica.container:WidgetSetup("miku_usagi_backpack") end
	return inst
end
    inst:AddComponent("inspectable")

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.cangoincontainer = false



    inst:AddComponent("equippable")
    inst.components.equippable.equipslot = EQUIPSLOTS.BACK or EQUIPSLOTS.BODY
    inst.components.equippable:SetOnEquip(onequip)
    inst.components.equippable:SetOnUnequip(onunequip)

    inst:AddComponent("container")
    inst.components.container:WidgetSetup("miku_usagi_backpack")
    inst.components.container.skipclosesnd = true
    inst.components.container.skipopensnd = true

    MakeSmallBurnable(inst)
    MakeSmallPropagator(inst)
	
    inst.components.burnable:SetOnBurntFn(onburnt)
    inst.components.burnable:SetOnIgniteFn(onignite)
    inst.components.burnable:SetOnExtinguishFn(onextinguish)
	 
	inst:AddComponent("preserver")
    inst.components.preserver:SetPerishRateMultiplier(TUNING.MIKU_USAGI_BACKPACK)

    MakeHauntableLaunchAndDropFirstItem(inst)

    return inst
end

STRINGS.NAMES.MIKU_USAGI_BACKPACK = "Usagi backpack"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.MIKU_USAGI_BACKPACK= "Its Bunny!!!"
STRINGS.RECIPE_DESC.MIKU_USAGI_BACKPACK = "Bunny backpack"

return Prefab("miku_usagi_backpack", fn, assets, prefabs)
