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
