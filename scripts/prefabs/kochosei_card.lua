local function make(code, description, check_des_boolean, alter_description, fileanim)
    local name = (description or STRINGS.NAMES[string.upper(code)] or STRINGS.SKIN_NAMES[string.lower(code)]  or '???')
	STRINGS.NAMES[string.upper("kochosei_card"..code)] = 'Tà thuật - '..name
	STRINGS.RECIPE_DESC[string.upper("kochosei_card"..code)] = check_des_boolean or alter_description
	STRINGS.CHARACTERS.GENERIC.DESCRIBE[string.upper("kochosei_card"..code)] = alter_description or STRINGS.SKIN_DESCRIPTIONS[code] or ('Tà thuật '..(description or STRINGS.NAMES[string.upper(code)] or STRINGS.SKIN_NAMES[string.lower(code)] or '???')..'。')

	return Prefab("kochosei_card"..code, function()
    local inst = CreateEntity()
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()
    MakeInventoryPhysics(inst)
    MakeInventoryFloatable(inst)
    inst.entity:AddDynamicShadow()
    inst.DynamicShadow:SetSize(1, .6)
    inst.entity:AddLight()			
    inst.Light:Enable(true)
    inst.Light:SetRadius(.5)
    inst.Light:SetFalloff(.7)
    inst.Light:SetIntensity(.5)
    inst.Light:SetColour(238/255, 155/255, 143/255)
    inst.AnimState:SetBloomEffectHandle( "shaders/anim.ksh" )    
    inst.AnimState:SetBank("kochosei_card")
    inst.AnimState:SetBuild("kochosei_card")
    inst.AnimState:PlayAnimation('kochosei_card',true)
    inst.Transform:SetScale(1.5 ,1.5, 1.5)
    inst:AddTag("fx_item")
    inst:AddTag("se_item")
    inst:AddTag("addfunctional")
    inst:AddTag("kochosei_card")
    inst.grouptag = "kochosei_card"
    inst.entity:SetPristine()
    if not TheWorld.ismastersim then 
        return inst
    end
    inst:AddComponent("inspectable")
    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.keepondeath = true
    inst.components.inventoryitem.atlasname = "images/inventoryimages/kochosei_card.xml"
    inst.components.inventoryitem.imagename = 'kochosei_card'
    inst:AddComponent("equippable")
    inst.components.equippable.equipslot = EQUIPSLOTS.MEDAL or EQUIPSLOTS.NECK or EQUIPSLOTS.BODY
    local function onbecamehuman(owner)
        owner:DoTaskInTime(3, function()
            owner.AnimState:SetBuild(code)
            owner:DoTaskInTime(1.3, function()
                owner.AnimState:SetBuild(code)
            end)
        end)
    end
    inst.components.equippable:SetOnEquip(function(inst, owner)
        if owner:HasTag("player") then
            -- if owner.prefab == 'sora' then
            --     owner.components.talker:Say("小穹不能替换模型。")
            --     return
            -- end
            owner:ListenForEvent("ms_respawnedfromghost", onbecamehuman)
            --owner:DoTaskInTime(0, function()
            --    if owner:IsValid() and owner.sg and not owner.components.rider:IsRiding() then
            --        owner.components.locomotor:Stop()
                    --owner.sg:GoToState("")
                    --Tạm thời chưa dùng
            --    end
            --end)
            --owner:DoTaskInTime(1.5+FRAMES, function()
                --owner.AnimState:SetBuild(code)
                --Tạm thời chưa dùng
            --end)
        end
    end )
    inst.components.equippable:SetOnUnequip(function(inst, owner)
        if owner:HasTag("player") then
            -- if owner.prefab == 'sora' then
            --     return
            -- end
            owner:RemoveEventCallback("ms_respawnedfromghost", onbecamehuman)
           -- owner:DoTaskInTime(0, function()
            --    if owner:IsValid() and owner.sg and not owner.components.rider:IsRiding() then
            --        owner.components.locomotor:Stop()
            --        owner.sg:GoToState("tz_cosplay")
            --    end
            --end)
            --owner:DoTaskInTime(1.5, function()
            --    local normal_skin = owner.prefab
            --    local skin_name = owner.components.skinner.skin_name
                -- if skin_name and skin_name ~= "" and owner.prefab ~= 'sora' then
            --    if skin_name ~= nil and skin_name ~= "" then
            --        local skin_prefab = Prefabs[skin_name] or nil
            --        if skin_prefab and skin_prefab.skins and skin_prefab.skins.normal_skin ~= nil then
            --            normal_skin = skin_prefab.skins.normal_skin
            --        end
            --    end
            --    owner.AnimState:SetBuild(normal_skin)
            --end)
        end
    end )
    return inst
    end,
    {
        Asset("ANIM", "anim/kochosei_card.zip"),
        Asset("ATLAS", "images/inventoryimages/kochosei_card.xml"),
    })
end

local blank = ""

return
    make(blank, "Kochosei", nil, nil)