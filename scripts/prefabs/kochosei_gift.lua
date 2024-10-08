local loottable = {}
local trincmnket = {}
local oceanfishdef = require("prefabs/oceanfishdef")

local ca_bien = {
	"wobster_sheller_land",
}
local ca_ao = {
	"pondeel",
	"eel",
	"fish",
	"frog",
	"mosquito",
	"killerbee",
	"butterfly",
}

for k = 1, NUM_TRINKETS do
	table.insert(trincmnket, "trinket_" .. tostring(k))
end

for _, v in pairs(oceanfishdef.fish) do
	table.insert(ca_bien, v.prefab .. "_inv")
end

local image = {
	"idle_small2",
	"idle_small1",
	"idle_medium2",
	"idle_medium1",
	"idle_large2",
	"idle_large1",
}

local function updateimage(inst)
	local gifts = {}
	local num_trinkets = math.random(1, 5)

	for _ = 1, num_trinkets do
		table.insert(gifts, SpawnPrefab(trincmnket[math.random(#trincmnket)]))
	end

	table.insert(gifts, SpawnPrefab(ca_bien[math.random(#ca_bien)]))
	table.insert(gifts, SpawnPrefab(ca_ao[math.random(#ca_ao)]))

	local imageupdate = image[math.random(#image)]

	inst.AnimState:PlayAnimation(imageupdate)

	-- Replace 'idle' with 'gift' in the image name
	local newImageName = string.gsub(imageupdate, "idle", "gift")
	inst.components.inventoryitem:ChangeImageName(newImageName)
	inst.components.unwrappable:WrapItems(gifts)
	for i, v in ipairs(gifts) do
		v:Remove()
	end
end

local function OnUnwrapped(inst, pos, doer)
	if inst.burnt then
		SpawnPrefab("ash").Transform:SetPosition(pos:Get())
	else
		if loottable ~= nil then
			local moisture = inst.components.inventoryitem:GetMoisture()
			local iswet = inst.components.inventoryitem:IsWet()
			for i, v in ipairs(loottable) do
				local item = SpawnPrefab(v)
				if item ~= nil then
					if item.Physics ~= nil then
						item.Physics:Teleport(pos:Get())
					else
						item.Transform:SetPosition(pos:Get())
					end
					if item.components.inventoryitem ~= nil then
						item.components.inventoryitem:InheritMoisture(moisture, iswet)

						item.components.inventoryitem:OnDropped(true, 0.5)
					end
				end
			end
		end
		SpawnPrefab("gift_unwrap").Transform:SetPosition(pos:Get())
	end
	if doer ~= nil and doer.SoundEmitter ~= nil then
		doer.SoundEmitter:PlaySound(inst.skin_wrap_sound or "dontstarve/common/together/packaged")
	end
	inst:Remove()
end

local function fn()
	local inst = CreateEntity()

	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddNetwork()

	MakeInventoryPhysics(inst)

	inst.AnimState:SetBank("gift")
	inst.AnimState:SetBuild("gift")
	inst.AnimState:PlayAnimation("idle_large1")

	inst:AddTag("bundle")
	inst:AddTag("nosteal")
	inst:AddTag("unwrappable")

	-- MakeInventoryFloatable(inst)

	inst.entity:SetPristine()

	if not TheWorld.ismastersim then
		return inst
	end
	inst.build = "wetpouch" --This is used within SGwilson, sent from an event in fishingrod.lua
	-- Tạo build với folder fish01 và build  wilson /build

	inst:AddComponent("inventoryitem")

	inst:AddComponent("inspectable")
	inst:AddComponent("tradable")

	inst:AddComponent("unwrappable")

	inst.components.unwrappable:SetOnUnwrappedFn(OnUnwrapped)

	updateimage(inst)

	MakeHauntableLaunch(inst)

	return inst
end

return Prefab("kochosei_gift", fn)
