local hoa_chet_choc = require("prefabs/lunarthrall_plant")
local cay_hoa_sang = _G.deepcopy(hoa_chet_choc)
cay_hoa_sang.fn = function(...)
	local inst = hoa_chet_choc.fn(...)
	inst:RemoveTag("hostile")
	inst.vinelimit = 5

	return inst
end

cay_hoa_sang.name = "cay_hoa_sang"

return cay_hoa_sang, MakePlacer("cay_hoa_sang_placer", "lunarthrall_plant", "lunarthrall_plant_front", "idle_med")
