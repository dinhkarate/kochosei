local assets = {
   Asset("ANIM", "anim/lucky_hammer.zip"),
   Asset("ANIM", "anim/swap_lucky_hammer.zip")
}
local check_lucky = false
if type(TUNING.KOCHO_LUCKYHAMMER_DURABILITY) == "number" then 
	check_lucky = true
end

local function onequip(inst, owner)
   owner.AnimState:OverrideSymbol("swap_object", "swap_lucky_hammer", "swap_lucky_hammer")
   owner.AnimState:Show("ARM_carry")
   owner.AnimState:Hide("ARM_normal")
end

local function onunequip(inst, owner)
   owner.AnimState:Hide("ARM_carry")
   owner.AnimState:Show("ARM_normal")
end

local function hieuung(inst)
   local fx_prefab = "explode_reskin"
   local fx = SpawnPrefab(fx_prefab)
   local x, y, z = inst.Transform:GetWorldPosition()
   fx.Transform:SetPosition(x, y, z)
end
local function doiskin(inst)
   if inst:HasTag("kochosei_enemy_skin_1") then
      inst.AnimState:SetBuild("kochosei_snowmiku_skin1")
      inst:AddTag("kochosei_enemy_skin_2")
      inst:RemoveTag("kochosei_enemy_skin_1")
   elseif inst:HasTag("kochosei_enemy_skin_2") then
      inst.AnimState:SetBuild("kochosei")
      inst:AddTag("kochosei_enemy_skin_1")
      inst:RemoveTag("kochosei_enemy_skin_2")
   end
end


local function convert_rocks(inst, replacement)
   -- Kiểm tra đối tượng đang tồn tại và tên đối tượng thay thế đã được xác định
   if inst:IsValid() and replacement ~= nil then
      -- Tạo đối tượng thay thế và đặt số lượng của đối tượng ban đầu (nếu có)
      local replacementObj = SpawnPrefab(replacement)
      if replacementObj ~= nil then
         if replacementObj.components.stackable ~= nil and inst.components.stackable ~= nil then
            replacementObj.components.stackable:SetStackSize(inst.components.stackable.stacksize)
         end
         -- Tìm chủ sở hữu của đối tượng ban đầu và kiểm tra xem đối tượng có phải là vật phẩm trong túi đồ của chủ sở hữu không
         local owner = inst.components.inventoryitem ~= nil and inst.components.inventoryitem.owner or nil
         local holder = owner ~= nil and (owner.components.inventory or owner.components.container) or nil
         if holder ~= nil then
            -- Nếu đối tượng ban đầu là vật phẩm trong túi đồ, thì chuyển đối tượng thay thế vào vị trí của đối tượng ban đầu trong túi đồ
            local slot = holder:GetItemSlot(inst)
            inst:Remove()
            holder:GiveItem(replacementObj, slot)
         else
            -- Nếu đối tượng ban đầu không nằm trong túi đồ của bất kỳ ai, thì đặt đối tượng thay thế vào vị trí của đối tượng ban đầu trên đất
            local x, y, z = inst.Transform:GetWorldPosition()
            inst:Remove()
            replacementObj.Transform:SetPosition(x, y, z)
            if replacementObj ~= nil and replacementObj.prefab == "wall_ruins" then
               if replacementObj.components.health ~= nil then
                  replacementObj.components.health:DoDelta(999)
               end
            end
         end
      end
   end
end
local function UseStaff(inst, target)
   if target ~= nil then
      if target.prefab == "kochosei_enemy" then
         doiskin(target)
		 hieuung(target)
         return
	end
   end
if target ~= nil then
local rocks = {rocks = "nitre", nitre ="goldnugget", goldnugget ="flint", flint = "thulecite_pieces", thulecite_pieces = "moonrocknugget", moonrocknugget = "moonglass", moonglass = "rocks"}
local gems = {redgem = "bluegem", bluegem = "purplegem", purplegem = "greengem", greengem = "orangegem", orangegem = "redgem"}
local tree = {driftwood_tall ="evergreen", evergreen = "evergreen_sparse", evergreen_sparse ="deciduoustree", deciduoustree = "twiggytree", twiggytree = "marsh_tree", marsh_tree = "moon_tree", moon_tree ="kochosei_apple_tree", kochosei_apple_tree ="mushtree_moon", mushtree_moon = "rock_petrified_tree", rock_petrified_tree ="driftwood_tall"}
local other_rocks = {rock1 = "rock2", rock2 = "rock_flintless", rock_flintless = "rock_moon", rock_moon = "stalagmite_full", stalagmite_full = "stalagmite_tall_full", stalagmite_tall_full = "wall_ruins", wall_ruins ="ruins_statue_mage_nogem", ruins_statue_mage_nogem ="ruins_statue_head_nogem", ruins_statue_head_nogem = "atrium_statue", atrium_statue = "rock1"}
local bee = {beebox_hermit = "beehive", beehive = "wasphive", wasphive = "beebox", beebox = "beebox_hermit"}
local aohosongsuoi = {lava_pond = "pond", pond = "pond_mos", pond_mos = "pond_cave", pond_cave = "lava_pond"}
local cocat = {reeds = "grass", grass = "sapling", sapling ="sapling_moon",sapling_moon ="marsh_bush", marsh_bush ="reeds" }
local berry = {berrybush_juicy = "berrybush", berrybush = "berrybush2", berrybush2 = "berrybush_juicy"}
local hat = {kochosei_hat3 = "kochosei_hat1", kochosei_hat1 = "kochosei_hat2", kochosei_hat2 ="kochosei_hat3"}

if rocks[target.prefab] then
    convert_rocks(target, rocks[target.prefab])
	if check_lucky then
    inst.components.finiteuses:Use(1)
	end
    hieuung(target)
elseif gems[target.prefab] then
    convert_rocks(target, gems[target.prefab])
	if check_lucky then
    inst.components.finiteuses:Use(1)
	end
    hieuung(target)
elseif other_rocks[target.prefab] then
    convert_rocks(target, other_rocks[target.prefab])
	if check_lucky then
    inst.components.finiteuses:Use(1)
	end
    hieuung(target)
elseif tree[target.prefab] then
    convert_rocks(target, tree[target.prefab])
	if check_lucky then
    inst.components.finiteuses:Use(1)
	end
    hieuung(target)

elseif bee[target.prefab] then
    convert_rocks(target, bee[target.prefab])
	if check_lucky then
    inst.components.finiteuses:Use(1)
	end
    hieuung(target)

elseif aohosongsuoi [target.prefab] then
    convert_rocks(target, aohosongsuoi[target.prefab])
	if check_lucky then
    inst.components.finiteuses:Use(1)
	end
    hieuung(target)
elseif cocat [target.prefab] then
    convert_rocks(target, cocat[target.prefab])
	if check_lucky then
    inst.components.finiteuses:Use(1)
	end
    hieuung(target)
elseif berry [target.prefab] then
    convert_rocks(target, berry[target.prefab])
	if check_lucky then
    inst.components.finiteuses:Use(1)
	end
    hieuung(target)
elseif hat [target.prefab] then
    convert_rocks(target, hat[target.prefab])
	if check_lucky then
    inst.components.finiteuses:Use(1)
	end
    hieuung(target)
end
end
end

local function CanCast(doer, target, pos)
   return true
end

local function fn()
   local inst = CreateEntity()

   inst.entity:AddTransform()
   inst.entity:AddAnimState()
   inst.entity:AddSoundEmitter()

   MakeInventoryPhysics(inst)

   inst.AnimState:SetBank("lucky_hammer")
   inst.AnimState:SetBuild("lucky_hammer")
   inst.AnimState:PlayAnimation("idle")

   inst:AddTag("staff")
   inst.entity:AddNetwork()

   if not TheWorld.ismastersim then
      return inst
   end

   inst.entity:SetPristine()
   inst:AddComponent("weapon")
   inst.components.weapon:SetDamage(10)

   inst:AddComponent("inspectable")

   inst:AddComponent("inventoryitem")

   inst:AddComponent("equippable")
   inst.components.equippable:SetOnEquip(onequip)
   inst.components.equippable:SetOnUnequip(onunequip)

   inst:AddComponent("spellcaster")
   inst.components.spellcaster:SetSpellFn(UseStaff)
   inst.components.spellcaster.canuseontargets = true
   inst.components.spellcaster.quickcast = true
   inst.components.spellcaster.CanCast = CanCast
if check_lucky then
   inst:AddComponent("finiteuses")
   inst.components.finiteuses:SetMaxUses(TUNING.KOCHO_LUCKYHAMMER_DURABILITY)
   inst.components.finiteuses:SetUses(TUNING.KOCHO_LUCKYHAMMER_DURABILITY)
   inst.components.finiteuses:SetOnFinished(inst.Remove)
	end
   return inst
end
STRINGS.NAMES.LUCKY_HAMMER = "Lucky Hammer"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.LUCKY_HAMMER = "I know what you want with this!! UwU"
STRINGS.RECIPE_DESC.LUCKY_HAMMER = "Change something to what you want from Ore, Tree, gem, mineral. Change free skin of clone and make you become a rich person!!"
return Prefab("lucky_hammer", fn, assets)
