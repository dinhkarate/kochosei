local NHAC_THA_T_RA = GLOBAL.Action({
    distance = 1
})
NHAC_THA_T_RA.str = "Thả t ra để t cắn nó"
NHAC_THA_T_RA.id = "NHAC CON CO"

NHAC_THA_T_RA.fn = function(act)
    if act.target.components.follower and act.target.components.follower.leader == act.doer then
        act.doer.components.leader:RemoveFollower(act.target)
        -- act.target.components.follower:StopFollowing()
        act.target:AddTag("clone_tha_xich")
        if act.target.components.kochoseienemy then
            act.target.components.kochoseienemy:Setbrain() -- Sorry nhé, trình không đủ tích hợp 2 brain làm một, t làm kiểu 2 brain luôn
            act.target.components.kochoseienemy:Setlocation()
        end
    end
    return true
end

local NHAC_BAT_LAI = GLOBAL.Action({
    distance = 1
})
NHAC_BAT_LAI.str = "Bắt Lại"
NHAC_BAT_LAI.id = "NHAC CON CO Mio"

NHAC_BAT_LAI.fn = function(act)
    if act.target.components.follower and act.target.components.follower.leader == nil and act.doer:HasTag("kochosei") then
        act.target.components.follower:SetLeader(act.doer)
        act.target.components.kochoseienemy:Setbackbrain()
        act.target:RemoveTag("clone_tha_xich")
    end
    return true
end

AddAction(NHAC_THA_T_RA)
AddAction(NHAC_BAT_LAI)

AddComponentAction("SCENE", "kochoseienemy", function(inst, doer, actions, right)
    if right then
        if inst:HasTag("clone_tha_xich") then
            table.insert(actions, NHAC_BAT_LAI)
        end
    end
end)
AddComponentAction("SCENE", "follower", function(inst, doer, actions, right)
    if right then
        if inst:HasTag("kochosei_enemy") and not inst:HasTag("clone_tha_xich") and not inst:HasTag("balo_vali") then
            table.insert(actions, NHAC_THA_T_RA)
        end
    end
end)

local KOCHOSEI_MAY_GACHA = GLOBAL.Action({
    distance = 1
})
KOCHOSEI_MAY_GACHA.str = "Làm tí bạn, sợ gì"
KOCHOSEI_MAY_GACHA.id = "IT GACHA TIME"

KOCHOSEI_MAY_GACHA.fn = function(act)
    if act.target ~= nil and act.doer ~= nil then
        if act.target.components.timer and not act.target.components.timer:TimerExists("maygacha") then
            act.target.components.kochoseimaygacha:Gachatime(act.doer) -- Truyền act.doer
            return true
        end
    end
end

AddAction(KOCHOSEI_MAY_GACHA)

AddComponentAction("SCENE", "kochoseimaygacha", function(inst, doer, actions, right)
    if right then
        table.insert(actions, KOCHOSEI_MAY_GACHA)
    end
end)

local KOCHOSEI_TELEPORT = GLOBAL.Action()
KOCHOSEI_TELEPORT.str = "Teleport To Statue"
KOCHOSEI_TELEPORT.id = "Kocho Teleport"
KOCHOSEI_TELEPORT.fn = function(act)
    if act.invobject ~= nil and act.doer ~= nil then
        act.doer:PushEvent("kochoseiteleport")
        act.invobject:Remove()
    end
    return true
end
AddAction(KOCHOSEI_TELEPORT)

AddComponentAction("INVENTORY", "kochoseiteleport", function(inst, doer, actions, right)
    table.insert(actions, KOCHOSEI_TELEPORT)
end)

-- ============================================================
-- ACTION: Đưa kochosei_heal_item cho người chơi khác để heal
-- ============================================================
local KOCHOSEI_GIVE_HEAL = GLOBAL.Action({
    distance      = 2,     -- khoảng cách tay với tay
    canforce      = false,
    rmb           = true,  -- gắn vào chuột phải
})
KOCHOSEI_GIVE_HEAL.str      = "Hồi máu bạn ơi"
KOCHOSEI_GIVE_HEAL.id       = "KOCHOSEI GIVE HEAL"

KOCHOSEI_GIVE_HEAL.fn = function(act)
    -- Guard cơ bản
    if not (act.doer and act.target and act.invobject) then return false end
    if act.doer == act.target then return false end  -- không tự cho mình

    local target = act.target
    local item   = act.invobject

    -- Target phải là người chơi còn sống, có component health
    if not (target.components.health
            and not target:HasTag("playerghost")
            and target:HasTag("player") and target.components.health) then
        return false
    end

    -- Heal target
    target.components.health:DoDelta(50, nil, "kochosei_heal")
    act.doer.components.health:DoDelta(50, nil, "kochosei_heal") -- Trừ máu người cho một ít để cân bằng
    target:AddDebuff("elysia_3_buff", "elysia_3_buff")
    act.doer:AddDebuff("elysia_3_buff", "elysia_3_buff")
    -- Spawn FX trên cả 2 người (dùng hàm nội bộ của component)
    if item.components.itemhealingkochosei then
        item.components.itemhealingkochosei:SpawnFX(act.doer)
        item.components.itemhealingkochosei:SpawnFX(target)
    end

    -- Trừ 1 item khỏi stack (hoặc xóa thẳng nếu không stack)
    if item.components.stackable then
        local popped = item.components.stackable:Get(1)
        if popped then popped:Remove() end
    elseif item:IsValid() then
        item:Remove()
    end

    return true
end

AddAction(KOCHOSEI_GIVE_HEAL)

-- Hiện action khi cầm kochosei_heal_item rồi click phải vào người chơi khác
AddComponentAction("USEITEM", "itemhealingkochosei", function(inst, doer, target, actions, right)
    -- inst = item đang cầm, target = người được click
    if right
        and target ~= nil
        and target ~= doer
        and target:HasTag("player")
        and not target:HasTag("playerghost")
    then
        table.insert(actions, KOCHOSEI_GIVE_HEAL)
    end
end)

-- StateGraph handler (dùng dolongaction để có animation đưa tay)
AddStategraphActionHandler("wilson",        GLOBAL.ActionHandler(NHAC_BAT_LAI,      "dolongaction"))
AddStategraphActionHandler("wilson_client", GLOBAL.ActionHandler(NHAC_BAT_LAI,      "dolongaction"))

AddStategraphActionHandler("wilson",        GLOBAL.ActionHandler(NHAC_THA_T_RA,     "dolongaction"))
AddStategraphActionHandler("wilson_client", GLOBAL.ActionHandler(NHAC_THA_T_RA,     "dolongaction"))

AddStategraphActionHandler("wilson",        GLOBAL.ActionHandler(KOCHOSEI_MAY_GACHA,"dolongaction"))
AddStategraphActionHandler("wilson_client", GLOBAL.ActionHandler(KOCHOSEI_MAY_GACHA,"dolongaction"))

AddStategraphActionHandler("wilson",        GLOBAL.ActionHandler(KOCHOSEI_TELEPORT, "doshortaction"))
AddStategraphActionHandler("wilson_client", GLOBAL.ActionHandler(KOCHOSEI_TELEPORT, "doshortaction"))

AddStategraphActionHandler("wilson",        GLOBAL.ActionHandler(KOCHOSEI_GIVE_HEAL,"dolongaction"))
AddStategraphActionHandler("wilson_client", GLOBAL.ActionHandler(KOCHOSEI_GIVE_HEAL,"dolongaction"))
