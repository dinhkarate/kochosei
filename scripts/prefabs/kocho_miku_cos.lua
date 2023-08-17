local Assets = {
    Asset("ANIM", "anim/kocho_miku_cos.zip"),
    Asset("ANIM", "anim/kocho_miku_back.zip"),
    Asset("ANIM", "anim/cay_kocho.zip")
}
local function OnDropped(inst) inst.components.disappears:PrepareDisappear() end
local function fn()
    local inst = CreateEntity()
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()
    inst.entity:AddSoundEmitter()
    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("kocho_miku_cos")
    inst.AnimState:SetBuild("kocho_miku_cos")
    inst.AnimState:PlayAnimation("idle")

    if not TheWorld.ismastersim then return inst end
    inst.entity:SetPristine()
    MakeSmallBurnable(inst)
    MakeSmallPropagator(inst)
    inst:AddComponent("disappears")
    inst.components.disappears.sound = "dontstarve/common/dust_blowaway"
    inst.components.disappears.anim = "disappear"

    inst:AddTag("preparedfood")

    inst:AddComponent("inspectable")

    inst:AddComponent("inventoryitem")

    inst:AddComponent("stackable")
    inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM

    inst:AddComponent("bait")
    inst:ListenForEvent("ondropped", OnDropped)
    inst.components.disappears:PrepareDisappear()

    inst:AddComponent("tradable")

    return inst
end

local function fnback()
    local inst = CreateEntity()
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()
    inst.entity:AddSoundEmitter()
    inst.entity:AddLight()
    inst.Light:Enable(true) -- originally was false.
    inst.Light:SetRadius(1.1)
    inst.Light:SetFalloff(.5)
    inst.Light:SetIntensity(0.8)
    inst.Light:SetColour(255 / 255, 255 / 255, 0 / 255)
    inst.AnimState:SetBank("kocho_miku_back")
    inst.AnimState:SetBuild("kocho_miku_back")
    inst.AnimState:PlayAnimation("idle")

    if not TheWorld.ismastersim then return inst end
    inst.entity:SetPristine()


    inst:AddComponent("disappears")
    inst.components.disappears.sound = "dontstarve/common/dust_blowaway"
    inst.components.disappears.anim = "disappear"

    inst:AddTag("preparedfood")

    inst:AddComponent("inspectable")

    inst:AddComponent("inventoryitem")

    inst:AddComponent("stackable")
    inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM

    inst:AddComponent("bait")

    inst:AddComponent("tradable")
    inst:ListenForEvent("ondropped", OnDropped)
    inst.components.disappears:PrepareDisappear()

    return inst
end

local KHONG_TAG = {"player", "FX", "playerghost", "NOCLICK", "DECOR", "INLIMBO", "epic"}
local CAN_TAG = {"shadowcreature", "monster"}


local function thithet(inst)
    local x, y, z = inst.Transform:GetWorldPosition()
    local ents = TheSim:FindEntities(x, y, z, 15, nil, KHONG_TAG, CAN_TAG)
    
    for i, v in ipairs(ents) do
        if v.components.health and (not v.components.follower or not v.components.follower:GetLeader()) then
            v.components.health:Kill()
        end
    end
    local players = FindPlayersInRange( x, y, z, 15, true )
            
    for _, player in pairs(players) do
        player.components.temperature:SetTemperature(TUNING.BOOK_TEMPERATURE_AMOUNT)
        player.components.moisture:SetMoistureLevel(0)
        local items = player.components.inventory:ReferenceAllItems()
        for _, item in ipairs(items) do
            if item.components.inventoryitemmoisture ~= nil then
                item.components.inventoryitemmoisture:SetMoisture(0)
            end
        end
    end

end


local function cay_kocho()
    local inst = CreateEntity()
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()
    inst.entity:AddSoundEmitter()
    inst.entity:AddLight()
    inst.Light:Enable(true) -- originally was false.
    inst.Light:SetRadius(6)
    inst.Light:SetFalloff(1)
    inst.Light:SetIntensity(0.6)
    inst.AnimState:SetMultColour(.7, .7, .7, 1)

    inst.Light:SetColour(.65, .65, .5)
    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("cay_kocho")
    inst.AnimState:SetBuild("cay_kocho")
    inst.AnimState:PlayAnimation("cay_kocho")

    if not TheWorld.ismastersim then return inst end
    inst.entity:SetPristine()
    MakeSmallPropagator(inst)

    inst:AddComponent("sanityaura")
    inst.components.sanityaura.aura = TUNING.SANITYAURA_SMALL

    inst:AddComponent("inspectable")

    inst:DoPeriodicTask(2, thithet)
    return inst
end

STRINGS.NAMES.KOCHO_MIKU_COS = "Snow Miku Costume"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.KOCHO_MIKU_COS = "o((>ω< ))o"
STRINGS.RECIPE_DESC.KOCHO_MIKU_COS = "Change Skin Of Clone"

STRINGS.NAMES.KOCHO_MIKU_BACK = "Backpack For Clone"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.KOCHO_MIKU_BACK = "o((>ω< ))o"
STRINGS.RECIPE_DESC.KOCHO_MIKU_BACK = "Are you too lazy and don't want to work?"

STRINGS.NAMES.CAY_KOCHO = "Cây Thần Kỳ... Chắc Thế"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.CAY_KOCHO = "Cây đang thi công, xin lỗi đã làm phiền, mong quý vị thông cảm, chưa biết khi nào xong nhưng chắc còn lâu ヾ(•ω•`)o"

return Prefab("common/inventory/kocho_miku_cos", fn, Assets),
       Prefab("common/inventory/kocho_miku_back", fnback, Assets),
       Prefab("common/inventory/cay_kocho", cay_kocho, Assets)

