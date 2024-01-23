local spicedfoods = {}
local kochofood = require("prkochofood")

GenerateSpicedFoods(kochofood)

local spices = require("spicedfoods")

for k, data in pairs(spices) do
	for name, v in pairs(kochofood) do
		if data.basename == name then
			spicedfoods[k] = data
		end
	end
end

return spicedfoods
