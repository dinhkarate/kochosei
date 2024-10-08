local assets = {
	Asset("ANIM", "anim/kochosei_may_gacha.zip"),
}

local function onhammered(inst, worker)
	if inst.components.burnable ~= nil and inst.components.burnable:IsBurning() then
		inst.components.burnable:Extinguish()
	end
	inst.components.lootdropper:DropLoot()
	local fx = SpawnPrefab("collapse_big")
	fx.Transform:SetPosition(inst.Transform:GetWorldPosition())
	fx:SetMaterial("wood")
	inst:Remove()
end

local foodkochosei = {}

local itemt1 = {
	"twigs",
	"log",
	"rocks",
	"goldnugget",
	"nightmarefuel",
	"rottenegg",
	"poop",
	"fertilizer",
	"compost",
	"purplegem",
	"bluegem",
	"redgem",
	"orangegem",
	"yellowgem",
	"greengem",
	"flint",
	"cutgrass",
	"mosquitosack",
	"tillweedsalve",
	"kochosei_apple"
}
local function tang_sanity(inst)
	print("tang_sanity")		
	inst.components.talker:Say("tang_sanity")
end

local function tang_hp(inst)
	print("tang_hp")
	inst.components.talker:Say("tang_hp")
end

local function tang_no(inst)
	print("tang_no")
	inst.components.talker:Say("tang_no")
end

local function tang_atk(inst)
	print("tang_atk")
	inst.components.talker:Say("tang_atk")
end

local function tang_atk_kochosei(inst)
	print("tang_atk_kochosei")
	inst.components.talker:Say("tang_atk_kochosei")
end

local function tang_speed(inst)
	print("tang_speed")
	inst.components.talker:Say("tang_speed")
end

local function tang_def(inst)
	print("tang_def")
	inst.components.talker:Say("tang_def")
end

local function tang_lam_viec(inst)
	print("tang_lam_viec")
	inst.components.talker:Say("tang_lam_viec")
end

local function giam_sanity(inst)
	print("giam_sanity")
	inst.components.talker:Say("giam_sanity")
end

local function giam_hp(inst)
	print("giam_hp")
	inst.components.talker:Say("giam_hp")
end

local function giam_no(inst)
	print("giam_no")
	inst.components.talker:Say("giam_no")
end

local function giam_atk(inst)
	print("giam_atk")
	inst.components.talker:Say("giam_atk")
end

local function giam_def(inst)
	print("giam_def")
	inst.components.talker:Say("giam_def")
end

local function giam_speed(inst)
	print("giam_speed")
	inst.components.talker:Say("giam_speed")
end



local stats_char = {
	tang_sanity,
	tang_hp,
	tang_no,
	tang_atk,
	tang_atk_kochosei,
	tang_speed,
	tang_def,
	tang_lam_viec,
	giam_sanity,
	giam_hp,
	giam_no,
	giam_atk,
	giam_def,
	giam_speed,
}

local function random_stats_chr(inst)
	print("random_stats_chr")
	local selected_stat = stats_char[math.random(#stats_char)] -- chọn 1 stats ngẫu nhiên trong bảng để buff
	return selected_stat(inst) 
end

--[[ local stats_char = {
	tang_sanity,
	tang_hp,
	tang_no,
	tang_atk,
	tang_atk_kochosei,
	tang_speed,
	tang_def,
	tang_lam_viec,
	giam_sanity,
	giam_hp,
	giam_no,
	giam_atk,
	giam_def,
	giam_speed,
}  ]]

for k, v in pairs(require("prkochofood")) do
	table.insert(foodkochosei, v.name)
end

local function Gachatime(inst) -- Tới lúc gacha r
	if not inst.components.timer then
		inst:AddComponent("timer")
	end
	--[[ 
	if inst.components.timer:TimerExists("Gacha cooldown") then
		local timeleft = inst.components.timer:GetTimeLeft("Gacha cooldown")
		local formatted_timeleft = math.floor(timeleft) -- lấy 3 số đầu
		inst.components.talker:Say("Từ hoi ba, tham lam vậy đợi " .. formatted_timeleft .. "s nữa đi")
		return
	end

 ]]
 	random_stats_chr(inst)
	local gifts = {}
	table.insert(gifts, SpawnPrefab(itemt1[math.random(#itemt1)]))
	table.insert(gifts, SpawnPrefab(foodkochosei[math.random(#foodkochosei)]))

	for i, v in ipairs(gifts) do
		v:Remove()
	end
	inst.components.timer:StartTimer("Gacha cooldown", 480) -- 8*6 48 đúng nguyên 1 ngày

	local kochosei_gift = SpawnPrefab("kochosei_gift")
	kochosei_gift.components.unwrappable:WrapItems(gifts)

	if inst.components.inventory and kochosei_gift then
		inst.components.inventory:GiveItem(kochosei_gift)
	end
end

local function banoidungnghiennua(inst, data)
	local doer = data.doer -- Nhận doer từ event
	if doer ~= nil then
		Gachatime(doer)
	end

	if TheWorld.state.precipitation ~= "none" then
		TheWorld:PushEvent("ms_forceprecipitation", false)
	else
		TheWorld:PushEvent("ms_forceprecipitation", true)
	end
end

local function fn()
	local inst = CreateEntity()
	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddSoundEmitter()
	inst.entity:AddNetwork()
	--MakeInventoryPhysics(inst) -- Nó cần phải bé bé, to quá nó vướng nhà
	inst:SetPhysicsRadiusOverride(1.5)

	inst.AnimState:SetBank("kochosei_may_gacha")
	inst.AnimState:SetBuild("kochosei_may_gacha")
	inst.AnimState:PlayAnimation("idle")
	inst.entity:SetPristine()

	if not TheWorld.ismastersim then
		return inst
	end

	inst:AddComponent("inspectable")

	inst:AddComponent("kochoseimaygacha")

	inst:AddComponent("timer")

	inst:AddComponent("lootdropper")
	--[[
    local constructionsite = inst:AddComponent("constructionsite")
    constructionsite:SetConstructionPrefab("construction_container")
    constructionsite:SetOnConstructedFn(function ()
        
    end)
--]]
	inst:AddComponent("workable")
	inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
	inst.components.workable:SetWorkLeft(4)
	inst.components.workable:SetOnFinishCallback(onhammered)
	inst.components.workable:SetOnWorkCallback(function() end)
	inst:ListenForEvent("banoidungnghiennua", banoidungnghiennua)

	return inst
end

STRINGS.NAMES.KOCHOSEI_MAY_GACHA = "Máy gacha hợp pháp"
STRINGS.RECIPE_DESC.KOCHOSEI_MAY_GACHA = "Bạn ơi đừng nghiện nữa, nhà mình còn gì nữa đâu"

return Prefab("kochosei_may_gacha", fn, assets),
	MakePlacer("kochosei_may_gacha_placer", "kochosei_may_gacha", "kochosei_may_gacha", "idle", nil, nil, nil)
