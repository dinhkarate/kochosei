local assets = { Asset("ANIM", "anim/kochosei_ancient_books.zip") }

local function onuse(inst)
    local fx = SpawnPrefab("wortox_portal_jumpout_fx")
    if inst.components.rechargeable:IsCharged() then -- Thêm () để gọi hàm IsCharged()
        for k, v in pairs(AllPlayers) do
            if v.components.timer and v:HasTag("player") then
                if v.components.timer:TimerExists("kochobuffspeed_time") then
                    v.components.timer:SetTimeLeft("kochobuffspeed_time", 20)
                    fx.Transform:SetPosition(v.Transform:GetWorldPosition())
                    if v.components.talker then
                        v.components.talker:Say("Speed Buff From Kochosei item", 5, false)
                    end
                else
                    v.components.timer:StartTimer("kochobuffspeed_time", 20)
                    v.components.locomotor:SetExternalSpeedMultiplier(v, "kochosei_speed_mod", 2)
                    fx.Transform:SetPosition(v.Transform:GetWorldPosition())
                    if v.components.talker then
                        v.components.talker:Say("Speed Buff From Kochosei", 5, false)
                    end
                end
            end
        end
        inst.components.rechargeable:Discharge(TUNING.KOCHO_ACIENTBOOKS_COOLDOWN)
    else
        return false
    end
end

local function OnDischarged(inst)
    if inst.components.book ~= nil then
        inst:RemoveComponent("book")
    end
end
local function OnCharged(inst)
    if inst.components.book ~= nil then
        return
    else
        inst:AddComponent("book")
        inst.components.book:SetOnRead(onuse)
    end
end
local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()

    inst.entity:AddNetwork()
    MakeInventoryPhysics(inst)
    inst:AddTag("book")
    inst.AnimState:SetBank("kochosei_ancient_books")
    inst.AnimState:SetBuild("kochosei_ancient_books")
    inst.AnimState:PlayAnimation("idle")
    MakeInventoryFloatable(inst, "small", 0.1, 1.12)
    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inspectable")
    inst:AddComponent("inventoryitem")

    inst:AddComponent("book")
    inst.components.book:SetOnRead(onuse)
    inst:AddComponent("rechargeable")
    inst.components.rechargeable:SetOnDischargedFn(OnDischarged)
    inst.components.rechargeable:SetOnChargedFn(OnCharged)
    ---------------------
    MakeSmallBurnable(inst, TUNING.SMALL_FUEL)
    MakeSmallPropagator(inst)
    MakeHauntableIgnite(inst)
    ---------------------

    return inst
end
STRINGS.NAMES.KOCHOSEI_ANCIENT_BOOKS = "Ancient Books"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.KOCHOSEI_ANCIENT_BOOKS = "Woah! Its secrets of Shinobi"
STRINGS.RECIPE_DESC.KOCHOSEI_ANCIENT_BOOKS = "Secrets of Shinobi, increase your speed in 20s and cooldown 3 min"

return Prefab("kochosei_ancient_books", fn, assets)
