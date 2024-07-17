local assets = {
	Asset("ANIM", "anim/miku_usagi_backpack.zip"),
	Asset("ANIM", "anim/swap_miku_usagi_backpack.zip"),
	Asset("ANIM", "anim/miku_usagi_backpack_2x4.zip"),
	Asset("ATLAS", "minimap/miku_usagi_backpack.xml"),
	Asset("IMAGE", "minimap/miku_usagi_backpack.tex"),
}

local prefabs = {
	"ash",
}
local function onequip(inst, owner)
    owner.AnimState:OverrideSymbol("swap_body", "swap_miku_usagi_backpack", "usagi")
    owner.AnimState:OverrideSymbol("swap_body", "swap_miku_usagi_backpack", "swap_body")

    if inst.components.container then
        inst.components.container:Open(owner)
    end

    local fastpickerAdded = false
    local expertchefAdded = false

    if not owner:HasTag("fastpicker") and not owner:HasTag("fastpick") then
        owner:AddTag("fastpicker")
        owner:AddTag("fastpick")
        fastpickerAdded = true
    end

    if not owner:HasTag("expertchef") then
        owner:AddTag("expertchef")
        expertchefAdded = true
    end
    owner.fastpickerAdded = fastpickerAdded
    owner.expertchefAdded = expertchefAdded
end

local function onunequip(inst, owner)
    local fastpickerAdded = owner.fastpickerAdded
    local expertchefAdded = owner.expertchefAdded

    if fastpickerAdded and not owner:HasTag("kochosei") then
        owner:RemoveTag("fastpick")
        owner:RemoveTag("fastpicker")
    end
    if expertchefAdded and not owner:HasTag("kochosei") then
        owner:RemoveTag("expertchef")
    end

    local skin_build = inst:GetSkinBuild()
    owner.AnimState:ClearOverrideSymbol("swap_body")
    owner.AnimState:ClearOverrideSymbol("miku_usagi_backpack")

    if inst.components.container then
        inst.components.container:Close(owner)
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
	MakeInventoryFloatable(inst, "small", 0.1, 1.12)

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
		inst.OnEntityReplicated = function(inst)
			inst.replica.container:WidgetSetup("miku_usagi_backpack")
		end
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

	MakeSmallPropagator(inst)

	inst:AddComponent("preserver")
	inst.components.preserver:SetPerishRateMultiplier(TUNING.MIKU_USAGI_BACKPACK)

	MakeHauntableLaunchAndDropFirstItem(inst)

	return inst
end

STRINGS.NAMES.MIKU_USAGI_BACKPACK = "Usagi backpack"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.MIKU_USAGI_BACKPACK = "Its Bunny!!!"
STRINGS.RECIPE_DESC.MIKU_USAGI_BACKPACK = "Bunny backpack"

return Prefab("miku_usagi_backpack", fn, assets, prefabs)
