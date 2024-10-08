GLOBAL.setmetatable(env, {
	__index = function(t, k)
		return GLOBAL.rawget(GLOBAL, k)
	end,
})

require("map/terrain")
require("constants")
require("map/lockandkey")
require("map/tasks")
require("map/lockandkey")
local Layouts = require("map/layouts").Layouts
local StaticLayout = require("map/static_layout")

if GetModConfigData("regemapkochosei") == 0 then
	Layouts["KochoseiIsland"] = StaticLayout.Get("map/kochosei_island", {
		start_mask = PLACE_MASK.IGNORE_IMPASSABLE_BARREN_RESERVED,
		fill_mask = PLACE_MASK.IGNORE_IMPASSABLE_BARREN_RESERVED,
		layout_position = LAYOUT_POSITION.CENTER,
		disable_transform = true,
	})

	AddLevelPreInitAny(function(level)
		if level.location == "forest" then
			if level.ocean_prefill_setpieces ~= nil then
				level.ocean_prefill_setpieces["KochoseiIsland"] = 1
			end
		end
	end)
end

-- some math helpers
local function mymathclamp(num, min, max)
	return num <= min and min or (num >= max and max or num)
end
local function myround(num, idp)
	return GLOBAL.tonumber(string.format("%." .. (idp or 0) .. "f", num))
end

-- some math helpers
local function mymathclamp(num, min, max)
	return num <= min and min or (num >= max and max or num)
end
local function myround(num, idp)
	return GLOBAL.tonumber(string.format("%." .. (idp or 0) .. "f", num))
end

-- roomincrease is an array of the rooms where you want to add your prefab and a percentage how many.
-- {BGMarsh=0.8,Badlands=2,BGSavanna=1} this would result in 0.8% of the space in BGMarsh, 2% of space in Badlands and 1% of space in BGSavanna.
-- The percentage is percentage of total available space! I suggest at max 10, not more! A more common value would be ~ 0.8
local function AddThingtoWorldGeneration(prefab, roomincrease)
	local Increase = 0
	for roomstr, add in pairs(roomincrease) do
		Increase = add / 100
		if Increase > 0 and Increase <= 0.2 then
			local oldpercent = 0
			local oldsum = 0
			local prefabvalue = 0
			AddRoomPreInit(
				roomstr, -- if the room does not exist, it is added... so in case we want to support mod rooms, we shoudl call all active rooms first, and test if this room is active at the moment
				function(room)
					if room.contents then
						oldpercent = room.contents.distributepercent or 0
						if not room.contents.distributeprefabs or oldpercent == 0 then
							room.contents.distributeprefabs = {}
							prefabvalue = 1 -- here this value does not matter, cause it is the only one
							room.contents.distributeprefabs[prefab] = (
								room.contents.distributeprefabs[prefab]
								and room.contents.distributeprefabs[prefab] + prefabvalue
							) or prefabvalue
							room.contents.distributepercent = Increase
						else
							oldsum = 0
							for distprefab, number in pairs(room.contents.distributeprefabs) do
								if type(number) == "table" then -- eg: smallmammal = {weight = 0.025, prefabs = {"rabbithole", "molehill"}},
									-- print("number ist eine table bei: "..tostring(distprefab).." in room: "..tostring(roomstr))
									for k, v in pairs(number) do
										-- print("k: "..tostring(k).." v: "..tostring(v))
										if type(v) == "number" and k == "weight" then
											oldsum = oldsum + v
										end
									end
								elseif type(number) == "number" then
									oldsum = oldsum + number
								end
							end
							room.contents.distributepercent = mymathclamp(oldpercent + Increase, 0, 1)
							prefabvalue = myround((oldsum * (room.contents.distributepercent / oldpercent)) - oldsum, 8)
							room.contents.distributeprefabs[prefab] = (
								room.contents.distributeprefabs[prefab]
								and room.contents.distributeprefabs[prefab] + prefabvalue
							) or prefabvalue
						end
						-- print("Increaser Debug: "..roomstr..": added "..prefab..". oldpercent: "..oldpercent..", oldsum: "..oldsum..", newpercent: "..room.contents.distributepercent..", prefabvalue: "..prefabvalue..", newvalue: "..room.contents.distributeprefabs[prefab])
					end
				end
			)
			print(
				"Increaser: Add " .. tostring(myround(Increase * 100, 2)) .. "% " .. prefab .. " to room: " .. roomstr
			)
		elseif Increase > 0.2 then
			print("Increaser: Value of Increase is too high for " .. prefab .. ", reduce it!")
		end
	end
end
local spawn_rates = {
	["Default"] = {
		BGDeciduous = 0.4,
		DeepDeciduous = 0.4,
		DeciduousMole = 0.4,
		MolesvilleDeciduous = 0.4,
		DeciduousClearing = 0.4,
		MagicalDeciduous = 0.4,
		BGForest = 0.2,
		BGDeepForest = 0.2,
		DeepForest = 0.2,
		Forest = 0.2,
		ForestMole = 0.2,
		BGGrass = 0.2,
		BGGrassBurnt = 0.2,
	},
	["More"] = {
		BGDeciduous = 0.8,
		DeepDeciduous = 0.8,
		DeciduousMole = 0.8,
		MolesvilleDeciduous = 0.8,
		DeciduousClearing = 0.8,
		MagicalDeciduous = 0.8,
		BGForest = 0.4,
		BGDeepForest = 0.4,
		DeepForest = 0.4,
		Forest = 0.4,
		ForestMole = 0.4,
		BGGrass = 0.4,
		BGGrassBurnt = 0.4,
	},
	["Less"] = {
		BGDeciduous = 0.2,
		DeepDeciduous = 0.2,
		DeciduousMole = 0.2,
		MolesvilleDeciduous = 0.2,
		DeciduousClearing = 0.2,
		MagicalDeciduous = 0.2,
		BGForest = 0.1,
		BGDeepForest = 0.1,
		DeepForest = 0.1,
		Forest = 0.1,
		ForestMole = 0.1,
		BGGrass = 0.1,
		BGGrassBurnt = 0.1,
	},
}

local config = GetModConfigData("Kochosei's apple spawn rates")
if spawn_rates[config] then
	AddThingtoWorldGeneration("kochosei_apple_tree", spawn_rates[config])
end

GLOBAL.terrain.filter.kochosei_apple_tree = {
	GLOBAL.GROUND.ROAD,
	GLOBAL.GROUND.WOODFLOOR,
	GLOBAL.GROUND.CARPET,
	GLOBAL.GROUND.CHECKER,
	GLOBAL.GROUND.ROCKY,
	GLOBAL.GROUND.MARSH,
}
