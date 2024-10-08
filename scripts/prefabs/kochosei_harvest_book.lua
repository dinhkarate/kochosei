local assets = {
	Asset("ANIM", "anim/book_maxwell.zip"),
	Asset("INV_IMAGE", "waxwelljournal_open"),
	Asset("ANIM", "anim/kochosei_ancient_books.zip"),
	Asset("ATLAS", "images/inventoryimages/elysia_scmn_pell.xml"),
	Asset("IMAGE", "images/inventoryimages/elysia_scmn_pell.tex"),
}
local reader

local book_defs = {
	{
		name = "kochosei_harvest_book",
		uses = 8,
		fn = function(inst, reader)
			reader.components.sanity:DoDelta(0)
			local function tryharvest(inst)
				local objc = inst.components
				if objc.crop ~= nil then
					objc.crop:Harvest(reader)
				elseif objc.harvestable ~= nil then
					objc.harvestable:Harvest(reader)
				elseif objc.stewer ~= nil then
					objc.stewer:Harvest(reader)
				elseif objc.dryer ~= nil then
					objc.dryer:Harvest(reader)
				elseif objc.occupiable ~= nil and objc.occupiable:IsOccupied() then
					local item = objc.occupiable:Harvest(reader)
					if item ~= nil then
						reader.components.inventory:GiveItem(item)
					end
				elseif objc.pickable ~= nil and objc.pickable:CanBePicked() then
					objc.pickable:Pick(reader)
				end
			end

			local x, y, z = reader.Transform:GetWorldPosition()

			local ents = TheSim:FindEntities(x, y, z, 30)
			for k, obj in pairs(ents) do
				if
					not obj:HasTag("reader")
					and not obj:HasTag("flower")
					and not obj:HasTag("mushroom_farm")
					and not obj:HasTag("trap")
					and not obj:HasTag("mine")
					and not obj:HasTag("cage")
					and obj ~= TheWorld
					and obj.AnimState
					and obj.components
					and obj.prefab
					and not string.find(obj.prefab, "mandrake")
					and not string.find(obj.prefab, "moonbase")
					and not string.find(obj.prefab, "gemsocket")
				then
					tryharvest(obj)
				end
				if obj:HasTag("flower") and obj:HasTag("bush") then
					tryharvest(obj)
				end
			end
			return true
		end,
	},
}
local function MakeBook(def)
	local function fn()
		local inst = CreateEntity()

		inst.entity:AddTransform()
		inst.entity:AddAnimState()
		inst.entity:AddSoundEmitter()
		inst.entity:AddNetwork()

		MakeInventoryPhysics(inst)

		inst.AnimState:SetBank("kochosei_ancient_books")
		inst.AnimState:SetBuild("kochosei_ancient_books")
		inst.AnimState:PlayAnimation("idle")

		inst.entity:SetPristine()

		if not TheWorld.ismastersim then
			return inst
		end

		-----------------------------------

		inst:AddComponent("inspectable")
		inst:AddComponent("book")
		inst.components.book.onread = def.fn

		inst:AddComponent("finiteuses")
		inst.components.finiteuses:SetMaxUses(8)
		inst.components.finiteuses:SetUses(8)
		inst.components.finiteuses:SetOnFinished(inst.Remove)

		inst:AddComponent("inventoryitem")
		inst.components.inventoryitem.imagename = "kochosei_ancient_books"
		inst.components.inventoryitem.atlasname = "images/inventoryimages/kochosei_inv.xml"

		inst:AddComponent("fuel")
		inst.components.fuel.fuelvalue = TUNING.MED_FUEL

		MakeSmallBurnable(inst, TUNING.MED_BURNTIME)
		MakeSmallPropagator(inst)
		MakeHauntableLaunch(inst)

		return inst
	end

	return Prefab("common/inventory/kochosei_harvest_book", fn, assets)
end

STRINGS.NAMES.KOCHOSEI_HARVEST_BOOK = "Kochosei Harvest Book"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.KOCHOSEI_HARVEST_BOOK = "Gomen Amanai"
STRINGS.RECIPE_DESC.KOCHOSEI_HARVEST_BOOK = "Gomen Amanai"

local books = {}
for i, v in ipairs(book_defs) do
	table.insert(books, MakeBook(v))
end
book_defs = nil
return unpack(books)
