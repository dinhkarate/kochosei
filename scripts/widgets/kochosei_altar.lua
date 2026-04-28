local Ingredient         = GLOBAL.Ingredient
local Vector3            = GLOBAL.Vector3
local SpawnPrefab        = GLOBAL.SpawnPrefab
local SendModRPCToServer = GLOBAL.SendModRPCToServer
local GetModRPC          = GLOBAL.GetModRPC
local AddModRPCHandler   = GLOBAL.AddModRPCHandler

-- Recipes: ingredients phải khớp đúng slot (theo thứ tự, từ trái sang phải, trên xuống dưới)
local RECIPES = {
    {
        name = "kochosei_duke",
        ingredients = {
            Ingredient("kochosei_apple",      1),
            Ingredient("kochosei_apple",      1),
            Ingredient("kochosei_apple",      1),
            Ingredient("kochosei_apple",      1),
            Ingredient("kochosei_duke_crown", 1),
            Ingredient("kochosei_apple",      1),
            Ingredient("kochosei_apple",      1),
            Ingredient("kochosei_apple",      1),
            Ingredient("kochosei_apple",      1),
        },
    },
}

-- ================================================================================
-- Container (3x3 grid, chuẩn containers.lua pattern)
-- ================================================================================

local containers = require("containers")
local params     = containers.params

params.kochosei_altar = {
    widget = {
        slotpos = {},
        slotbg  = {},
        animbank      = "kochosei_ui_boss",
        animbuild     = "kochosei_ui_boss",
        pos           = Vector3(0, 200, 0),
        side_align_tip = 160,
        buttoninfo = {
            text     = "Summon",
            position = Vector3(0, -160, 0),
        },
    },
    type = "chest",
}

for y = 2, 0, -1 do
    for x = 0, 2 do
        table.insert(params.kochosei_altar.widget.slotpos, Vector3(75 * x - 75, 75 * y - 75, 0))
        table.insert(params.kochosei_altar.widget.slotbg, { atlas = "images/ui/hect_slot.xml", image = "hect_slot.tex" })
    end
end

containers.MAXITEMSLOTS = math.max(containers.MAXITEMSLOTS, #params.kochosei_altar.widget.slotpos)

function params.kochosei_altar.widget.buttoninfo.fn(inst, doer)
    if inst.replica.container ~= nil and not inst.replica.container:IsBusy() then
        SendModRPCToServer(GetModRPC("kochosei_altar", "synthesis"), inst)
    end
end

function params.kochosei_altar.widget.buttoninfo.validfn(inst)
    return inst.replica.container ~= nil and not inst.replica.container:IsEmpty()
end

function params.kochosei_altar.itemtestfn(container, item, slot)
    return item:IsValid() and not item:HasTag("bundle")
end

-- ================================================================================
-- RPC: kiểm tra nguyên liệu, tiêu thụ, spawn boss tại vị trí player
-- ================================================================================

AddModRPCHandler("kochosei_altar", "synthesis", function(player, altar)
    local container = altar.components.container
    if container == nil or not container:IsOpenedBy(player) then return end

    -- Tìm recipe khớp (so slot theo thứ tự)
    local matched_recipe = nil
    for _, recipe in ipairs(RECIPES) do
        local ok = true
        for i, ingr in ipairs(recipe.ingredients) do
            local item = container:GetItemInSlot(i)
            if item == nil or item.prefab ~= ingr.type then
                ok = false
                break
            end
        end
        if ok then
            matched_recipe = recipe
            break
        end
    end

    if matched_recipe == nil then
        player.components.talker:Say("Hình như sai nguyên liệu rồi!")
        return
    end

    -- Tiêu thụ nguyên liệu
    for i, ingr in ipairs(matched_recipe.ingredients) do
        container:ConsumeByName(ingr.type, ingr.amount)
    end

    -- Spawn boss tại vị trí player
    local x, y, z = player.Transform:GetWorldPosition()
    local boss = SpawnPrefab(matched_recipe.name)
    if boss == nil then return end

    boss.Transform:SetPosition(x, y, z)

    if boss.sg ~= nil then
        boss.sg:GoToState("appear_pre")
    end

    player.components.talker:Say("Hảo hảo!")
end)
