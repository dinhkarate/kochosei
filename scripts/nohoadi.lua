local UIAnim = require "widgets/uianim"

print("[kochosei] mod file loaded OK")

local FLOWER_COUNT = 50
local PANEL_W = 480
local PANEL_H = 380
local PANEL_CY = -20

local function SpawnFlowerOverlays(root)
    local flowers = {}

    local hw = PANEL_W / 2 + 10
    local hh = PANEL_H / 2 + 10

    local positions = {}
    local per_side = math.floor(FLOWER_COUNT / 4)

    for i = 0, per_side - 1 do
        local t = -hw + (hw * 2) / per_side * i + (hw * 2) / per_side * 0.5
        table.insert(positions, {t, hh, 180})
        table.insert(positions, {t, -hh, 0})
        table.insert(positions, {-hw, t, 90})
        table.insert(positions, {hw, t, -90})
    end

    for i = #positions, 2, -1 do
        local j = math.random(i)
        positions[i], positions[j] = positions[j], positions[i]
    end

    -- Pool variation để tránh lặp liên tiếp cùng 1 loại
    local function NextVariation(last)
        local v = math.random(4)
        -- Nếu trùng với lần trước thì random lại 1 lần
        if v == last then v = (v % 4) + 1 end
        return v
    end

    for i = 1, math.min(FLOWER_COUNT, #positions) do
        local pos = positions[i]
        local jx = (math.random() - 0.5) * 30
        local jy = (math.random() - 0.5) * 30
        local rotation = pos[3]

        local flower = root:AddChild(UIAnim())
        flower:GetAnimState():SetBuild("wormwood_plant_fx")
        flower:GetAnimState():SetBank("wormwood_plant_fx")
        flower:SetPosition(pos[1] + jx, PANEL_CY + pos[2] + jy)
        flower:SetScale(0.4, 0.4)
        flower:SetRotation(rotation)

        local delay = math.random() * 2.0
        flower:Hide()

        root.inst:DoTaskInTime(delay, function()
            if flower == nil then return end
            flower:Show()

            local variation = math.random(4)
            flower:GetAnimState():PlayAnimation("grow_" .. variation)
            flower:GetAnimState():PushAnimation("idle_" .. variation, true)

            local function CycleFlower(last_variation)
                root.inst:DoTaskInTime(4 + math.random() * 8, function()
                    if flower == nil then return end
                    -- Random variation mới, tránh lặp lại loại vừa rồi
                    local next_v = NextVariation(last_variation)
                    flower:GetAnimState():PlayAnimation("ungrow_" ..
                                                            last_variation)
                    flower:GetAnimState():PushAnimation("grow_" .. next_v)
                    flower:GetAnimState():PushAnimation("idle_" .. next_v, true)
                    CycleFlower(next_v)
                end)
            end
            CycleFlower(variation)
        end)

        table.insert(flowers, flower)
    end

    return flowers
end
local _
-- ── Override puppet animation cho kochosei trong PlayerAvatarPopup ──
AddClassPostConstruct("widgets/playeravatarpopup", function(self)
    if self.currentcharacter ~= "kochosei" then return end
    if self.puppet == nil then return end
    if self.puppet.puppet == nil then return end

    local skinspuppet = self.puppet.puppet
    if skinspuppet.animstate == nil then return end

    skinspuppet.animstate:PlayAnimation("deform_pst", false)
    skinspuppet.animstate:PushAnimation("acting_idle1", true)
    print("[kochosei] animation set!")
end)

AddClassPostConstruct("screens/playerinfopopupscreen", function(self)
    print("[kochosei] PostConstruct fired")

    local prefab = self.currentcharacter or
                       (self.data and (self.data.prefab or self.data.character))

    if prefab ~= "kochosei" then
        print("[kochosei] SKIP: not kochosei")
        return
    end

    if self.root == nil then return end

    -- ── Hoa xung quanh bảng ──────────────────────────────────────────
    local flowers = SpawnFlowerOverlays(self.root)
    print("[kochosei] Spawned", #flowers, "flowers")

    -- ── Cleanup khi đóng popup ───────────────────────────────────────
    local orig_OnDestroy = self.OnDestroy
    self.OnDestroy = function(s)
        for _, f in ipairs(flowers) do if f ~= nil then f:Kill() end end
        flowers = {}
        if orig_OnDestroy then orig_OnDestroy(s) end
    end
end)
