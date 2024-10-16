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
	"messagebottle",
	"cursed_monkey_token",
	"driftwood_log",
	"coontail",
	"slurtlehat",
	"armorsnurtleshell",
	"malbatross_beak",
	"beefalowool",
	"gears",
	"horrorfuel",
	"purebrilliance",
	"shroom_skin",
	"spidereggsack",
	"honeycomb",
	"dreadstone",
	"lunarplant_husk",
	"panflute",
	"horn",
	"moon_cap",
	"blue_cap",
	"red_cap",
	"green_cap",
	"moonglass",
	"moonrocknugget",
	"canary_poisoned",
	"twigs",
	"log",
	"eel",
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
	"kochosei_apple",
}
local function tang_sanity(inst)
	inst.components.sanity:DoDelta(15)
	inst.components.talker:Say("Tăng Sanity")
end

local function tang_hp(inst)
	inst.components.health:DoDelta(15)
	inst.components.talker:Say("Tăng HP")
end

local function tang_no(inst)
	inst.components.hunger:DoDelta(15)
	inst.components.talker:Say("Tăng No")
end

local function tang_atk(inst)
	inst:AddDebuff("buff_attack", "buff_attack")
	inst.components.talker:Say("Tăng ATK")
end

local function tang_atk_kochosei(inst)
	inst.tangst = true
	inst.components.talker:Say("Buff Kochosei")
end

local function tang_speed(inst)
	inst.components.locomotor:SetExternalSpeedMultiplier(inst, "speed_tu_magacha", 1.25)
	inst.components.talker:Say("Tăng speed 25%")
end

local function tang_def(inst)
	inst:AddDebuff("buff_playerabsorption", "buff_playerabsorption")
	inst.components.talker:Say("Tăng Def")
end

local function tang_lam_viec(inst)
	inst:AddDebuff("buff_workeffectiveness", "buff_workeffectiveness")
	inst.components.talker:Say("Tăng hiệu suất làm việc")
end

local function giam_sanity(inst)
	inst.components.sanity:DoDelta(-35)
	inst.components.talker:Say("Giảm Sanity")
end

local function giam_hp(inst)
	inst.components.health:DoDelta(-15)
	inst.components.talker:Say("Giảm HP")
end

local function giam_no(inst)
	inst.components.hunger:DoDelta(-35)
	inst.components.talker:Say("Giảm No")
end

local function nhan_full_buff(inst)
	inst.sg:GoToState("nhan_full_buff")
	inst.components.hunger:SetPercent(1)
	inst.components.sanity:SetPercent(1)
	inst.components.health:SetPercent(1)
	inst:AddDebuff("buff_attack","buff_attack")
	inst:AddDebuff("buff_playerabsorption","buff_playerabsorption")
	inst:AddDebuff("buff_workeffectiveness","buff_workeffectiveness")
	inst.tangst = true
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
}

local function random_stats_chr(inst)
	local selected_stat = stats_char[math.random(#stats_char)] -- chọn 1 stats ngẫu nhiên trong bảng để buff
	return selected_stat(inst)
end

for k, v in pairs(require("prkochofood")) do
	table.insert(foodkochosei, v.name)
end

local function Gachatime(inst) -- Tới lúc gacha r
	if not inst.components.timer then
		inst:AddComponent("timer")
	end
	local gifts = {}

	if inst.components.timer:TimerExists("Gacha cooldown") then
		local timeleft = inst.components.timer:GetTimeLeft("Gacha cooldown")
		local formatted_timeleft = math.floor(timeleft) -- lấy 3 số đầu
		inst.components.talker:Say("Từ hoi ba, tham lam vậy đợi " .. formatted_timeleft .. "s nữa đi")
		return
	end

	inst.components.timer:StartTimer("Gacha cooldown", 480) -- 8*6 48 đúng nguyên 1 ngày

	random_stats_chr(inst)

	table.insert(gifts, SpawnPrefab(itemt1[math.random(#itemt1)]))

	local chance = math.random()

	if chance <= 0.5 then -- 50% nhận được đồ ăn
		table.insert(gifts, SpawnPrefab(foodkochosei[math.random(#foodkochosei)]))
	end
	
	if chance <= 0.1 then -- 10% nhận full buff
		nhan_full_buff(inst)
	end
	
	for i, v in ipairs(gifts) do
		v:Remove()
	end

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
	-- MakeInventoryPhysics(inst) -- Nó cần phải bé bé, to quá nó vướng nhà
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
	MakePlacer("kochosei_may_gacha_placer", "kochosei_may_gacha", "kochosei_may_gacha", "idle")
