-- Balovali--
GLOBAL.setmetatable(env, {
	__index = function(_, k)
		return GLOBAL.rawget(GLOBAL, k)
	end,
})
local params = {}
params.miku_usagi_backpack = {
	widget = {
		slotpos = {},
		animbank = "miku_usagi_backpack_2x4",
		animbuild = "miku_usagi_backpack_2x4",
		pos = Vector3(-70, -170, 0),
	},
	issidewidget = true,
	type = "pack",
}
for y = 2, 7 do
	table.insert(params.miku_usagi_backpack.widget.slotpos, Vector3(-58, -75 * y + 498, 0))
	table.insert(params.miku_usagi_backpack.widget.slotpos, Vector3(-58 + 75, -75 * y + 498, 0))
end
local containers = require("containers")
containers.MAXITEMSLOTS = math.max(
	containers.MAXITEMSLOTS,
	params.miku_usagi_backpack.widget.slotpos ~= nil and #params.miku_usagi_backpack.widget.slotpos or 0
)
local pwidgetsetup = containers.widgetsetup
function containers.widgetsetup(container, prefab, data)
	local pref = prefab or container.inst.prefab
	if pref == "miku_usagi_backpack" then
		local t = params[pref]
		if t ~= nil then
			for k, v in pairs(t) do
				container[k] = v
			end
			container:SetNumSlots(container.widget.slotpos ~= nil and #container.widget.slotpos or 0)
		end
	else
		return pwidgetsetup(container, prefab, data)
	end
end


params.kochosei_chest_5x5 = {
	widget = {
		slotpos = {},
		animbank = "ui_chest_3x3",
		animbuild = "ui_kochosei_chest_5x5",
		pos = Vector3(-850, 200, 0), -- Canh giữa màn hình
	},
	issidewidget = true,
    type = "chest",
}

local spacing = 75 -- khoảng cách giữa các ô
local offset = spacing * 2 -- vì 5 ô nên cần dời từ -2 đến +2

for y = 2, -2, -1 do -- hàng: từ trên xuống
	for x = -2, 2 do -- cột: từ trái sang phải
		local slot_x = x * spacing
		local slot_y = y * spacing
		table.insert(params.kochosei_chest_5x5.widget.slotpos, Vector3(slot_x +15, slot_y, 0))
	end
end

local containers = require("containers")
containers.MAXITEMSLOTS = math.max(
	containers.MAXITEMSLOTS,
	params.kochosei_chest_5x5.widget.slotpos ~= nil and #params.kochosei_chest_5x5.widget.slotpos or 0
)
local pwidgetsetup = containers.widgetsetup
function containers.widgetsetup(container, prefab, data)
	local pref = prefab or container.inst.prefab
	if pref == "kochosei_chest_5x5" then
		local t = params[pref]
		if t ~= nil then
			for k, v in pairs(t) do
				container[k] = v
			end
			container:SetNumSlots(container.widget.slotpos ~= nil and #container.widget.slotpos or 0)
		end
	else
		return pwidgetsetup(container, prefab, data)
	end
end

params.kochosei_fridge_5x5 = {
	widget = {
		slotpos = {},
		animbank = "ui_chest_3x3",
		animbuild = "ui_kochosei_fridge_5x5",
		pos = Vector3(-850, 200, 0), -- Canh giữa màn hình
	},
	issidewidget = true,
    type = "chest",
}

local spacing = 75 -- khoảng cách giữa các ô
local offset = spacing * 2 -- vì 5 ô nên cần dời từ -2 đến +2

for y = 3, -2, -1 do -- hàng: từ trên xuống
	for x = -3, 2 do -- cột: từ trái sang phải
		local slot_x = x * spacing
		local slot_y = y * spacing
		table.insert(params.kochosei_fridge_5x5.widget.slotpos, Vector3(slot_x +40, slot_y, 0))
	end
end

local containers = require("containers")
containers.MAXITEMSLOTS = math.max(
	containers.MAXITEMSLOTS,
	params.kochosei_fridge_5x5.widget.slotpos ~= nil and #params.kochosei_fridge_5x5.widget.slotpos or 0
)
local pwidgetsetup = containers.widgetsetup
function containers.widgetsetup(container, prefab, data)
	local pref = prefab or container.inst.prefab
	if pref == "kochosei_fridge_5x5" then
		local t = params[pref]
		if t ~= nil then
			for k, v in pairs(t) do
				container[k] = v
			end
			container:SetNumSlots(container.widget.slotpos ~= nil and #container.widget.slotpos or 0)
		end
	else
		return pwidgetsetup(container, prefab, data)
	end
end

-- function params.kochosei_fridge_5x5.itemtestfn(container, item, slot)
--     if item:HasTag("icebox_valid") then
--         return true
--     end

--     --Perishable
--     if not (item:HasTag("fresh") or item:HasTag("stale") or item:HasTag("spoiled")) then
--         return false
--     end

-- 	if item:HasTag("smallcreature") then
-- 		return false
-- 	end

--     --Edible
--     for k, v in pairs(FOODTYPE) do
--         if item:HasTag("edible_"..v) then
--             return true
--         end
--     end

--     return false
-- end
