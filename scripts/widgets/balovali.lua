-- Balovali
GLOBAL.setmetatable(env, {
    __index = function(_, k)
        return GLOBAL.rawget(GLOBAL, k)
    end,
})

local containers = require "containers"
local params = containers.params

--====================================================================--
-- Usagi Backpack (2x6)
--====================================================================--
params.miku_usagi_backpack = {
    widget = {
        slotpos = {},
        animbank = "miku_usagi_backpack_2x4",
        animbuild = "miku_usagi_backpack_2x4",
        pos = Vector3(-70, -170, 0), -- Vị trí hiển thị
    },
    issidewidget = true,
    type = "pack",
}
-- 6 hàng, mỗi hàng 2 slot
for y = 2, 7 do
    table.insert(params.miku_usagi_backpack.widget.slotpos, Vector3(-58, -75 * y + 498, 0))
    table.insert(params.miku_usagi_backpack.widget.slotpos, Vector3(-58 + 75, -75 * y + 498, 0))
end

--====================================================================--
-- Triple Kocho (10x5) - Rương lớn 50 slots
--====================================================================--
params.triple_kocho = {
    widget = {
        slotpos = {},
        animbank = "triple_kocho_UI",
        animbuild = "triple_kocho_UI",
        pos = Vector3(-140, 150, 0),
        side_align_tip = 160,
    },
  --  issidewidget = true,
    type = "chest",
}
-- 5 hàng x 10 cột = 50 slots
for y = 2, -2, -1 do
    for x = -4, 5 do
        table.insert(params.triple_kocho.widget.slotpos, Vector3(x * 75 + 220, y * 75 + 15, 0))
    end
end


--====================================================================--
-- Kochosei Chest (5x5)
--====================================================================--
params.kochosei_chest_5x5 = {
    widget = {
        slotpos = {},
        animbank = "ui_chest_3x3",
        animbuild = "ui_kochosei_chest_5x5",
        pos = Vector3(0, 200, 0),
        side_align_tip = 160,
    },
   -- issidewidget = true,
    type = "chest",
}
-- 5 hàng x 5 cột
for y = 2, -2, -1 do
    for x = -2, 2 do
        table.insert(params.kochosei_chest_5x5.widget.slotpos, Vector3(x * 75 + 15, y * 75, 0))
    end
end

--====================================================================--
-- Kochosei Fridge (5x6)
--====================================================================--
params.kochosei_fridge_5x5 = {
    widget = {
        slotpos = {},
        animbank = "ui_chest_3x3",
        animbuild = "ui_kochosei_fridge_5x5",
        pos = Vector3(0, 200, 0),
        side_align_tip = 160,
    },
   -- issidewidget = true,
    type = "chest",
}
-- 6 hàng x 6 cột
for y = 3, -2, -1 do
    for x = -3, 2 do
        table.insert(params.kochosei_fridge_5x5.widget.slotpos, Vector3(x * 75 + 40, y * 75, 0))
    end
end

-- Giới hạn item chứa trong tủ lạnh (giống icebox)
function params.kochosei_fridge_5x5.itemtestfn(container, item, slot)
    if item:HasTag("icebox_valid") then
        return true
    end
    -- Chỉ nhận item có thuộc tính perish (fresh/stale/spoiled)
    if not (item:HasTag("fresh") or item:HasTag("stale") or item:HasTag("spoiled")) then
        return false
    end
    -- Không cho bỏ sinh vật nhỏ vào
    if item:HasTag("smallcreature") then
        return false
    end
    -- Cho phép tất cả loại food
    for k, v in pairs(FOODTYPE) do
        if item:HasTag("edible_"..v) then
            return true
        end
    end
    return false
end


--====================================================================--
-- Kochosei Cookpot (1x4) - Nồi nấu ăn
--====================================================================--
local cooking = require "cooking"

params.kochosei_cookpot = {
    widget = {
        slotpos =
        {
            Vector3(0, 64 + 32 + 8 + 4, 0),
            Vector3(0, 32 + 4, 0),
            Vector3(0, -(32 + 4), 0),
            Vector3(0, -(64 + 32 + 8 + 4), 0),
        },
        animbank = "ui_cookpot_1x4",
        animbuild = "ui_cookpot_1x4",
        pos = Vector3(200, 0, 0),
        side_align_tip = 100,
        buttoninfo = {
            text = STRINGS.ACTIONS.COOK,
            position = Vector3(0, -165, 0),
            fn = function(inst)
                if inst.components.container ~= nil then
                    for k, _ in pairs(inst.components.container.openlist) do
                        BufferedAction(k, inst, ACTIONS.COOK):Do()
                        break
                    end
                elseif inst.replica.container ~= nil and not inst.replica.container:IsBusy() then
                    SendRPCToServer(RPC.DoWidgetButtonAction, ACTIONS.COOK.code, inst, ACTIONS.COOK.mod_name)
                end
            end,
            validfn = function(inst)
                return inst.replica.container ~= nil and inst.replica.container:IsFull()
            end,
        },
    },
    acceptsstacks = false,
    type = "cooker",
}

function params.kochosei_cookpot.itemtestfn(container, item, slot)
    return cooking.IsCookingIngredient(item.prefab) and not container.inst:HasTag("burnt")
end

--====================================================================--
-- Cập nhật MAXITEMSLOTS cho toàn bộ container
--====================================================================--
for k, v in pairs(params) do
    containers.MAXITEMSLOTS = math.max(
        containers.MAXITEMSLOTS,
        v.widget.slotpos ~= nil and #v.widget.slotpos or 0
    )
end
