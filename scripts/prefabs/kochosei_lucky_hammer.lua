local assets = {
	Asset("ANIM", "anim/lucky_hammer.zip"),
	Asset("ANIM", "anim/swap_lucky_hammer.zip"),
	Asset("ANIM", "anim/reskin_tool_fx.zip"),
}

local builds = {
	"kochosei_snowmiku_skin1",
	"kochosei",
	"kochosei_skin_shinku_full",
	"kochosei_skin_shinku_notfull",
}

local buildsmiohm = {
	"miohm",
	"kochosei_purplebattleaxe",
}

local conversion_table = {
	rocks = {
		"nitre",
		"goldnugget",
		"flint",
		"thulecite_pieces",
		"moonrocknugget",
		"moonglass",
		"rocks",
	},
	gems = {
		"redgem",
		"bluegem",
		"purplegem",
		"greengem",
		"orangegem",
	},
	tree = {
		"driftwood_tall",
		"evergreen",
		"evergreen_sparse",
		"deciduoustree",
		"twiggytree",
		"marsh_tree",
		"moon_tree",
		"kochosei_apple_tree",
		"mushtree_moon",
		"rock_petrified_tree",
	},
	other_rocks = {
		"rock1",
		"rock2",
		"rock_flintless",
		"rock_moon",
		"stalagmite_full",
		"stalagmite_tall_full",
		"wall_ruins",
		"ruins_statue_mage_nogem",
		"ruins_statue_head_nogem",
		"atrium_statue",
	},
	bee = {
		"beebox_hermit",
		"beehive",
		"wasphive",
		"beebox",
	},
	aohosongsuoi = {
		"lava_pond",
		"pond",
		"pond_mos",
		"pond_cave",
	},
	cocat = {
		"reeds",
		"grass",
		"sapling",
		"sapling_moon",
		"marsh_bush",
	},
	berry = {
		"berrybush_juicy",
		"berrybush",
		"berrybush2",
	},
	logg = {
		"driftwood_log",
		"log",
		"livinglog",
	},
	atvseeds = {
		"seeds",
		"carrot_seeds",
		"corn_seeds",
		"dragonfruit_seeds",
		"durian_seeds",
		"eggplant_seeds",
		"pomegranate_seeds",
		"pumpkin_seeds",
		"watermelon_seeds",
		"asparagus_seeds",
		"tomato_seeds",
		"potato_seeds",
		"onion_seeds",
		"pepper_seeds",
		"garlic_seeds",
	},
	hoa = {
		"succulent_picked",
		"petals",
		"petals_evil",
		"foliage",
	},
	hoammatdat = {
		"petals_evil",
		"petals",
	},
}
local reskin_fx_info =
{
	abigail = { offset = 1.3, scale = 1.3 },
	anchor = { offset = 0.2, scale = 1.3 },
	arrowsign_post = { offset = 0.9, scale = 1.2 },
	beebox = { scale = 1.4 },
	bernie_big = { offset = 1.2, scale = 1.8 },
	birdcage = { offset = 1.2, scale = 1.8 },
	bugnet = { offset = 0.4 },
	campfire = { scale = 1.2 },
	cane = { offset = 0.4 },
	cavein_boulder = { scale = 1.4 },
	coldfirepit = { scale = 1.2 },
	cookpot = { offset = 0.5, scale = 1.4 },
	critter_dragonling = { offset = 0.8 },
	critter_glomling = { offset = 0.8 },
	dragonflychest = { offset = 0.1, scale = 1.4 },
	dragonflyfurnace = { offset = 0.6, scale = 1.8 },
	endtable = { offset = 0.2, scale = 1.3 },
	featherfan = { scale = 1.3 },
	featherhat = { scale = 1.1 },
	fence = { offset = 0.1, scale = 1.2 },
	fence_gate = { offset = 0.2, scale = 1.3 },
	firepit = { scale = 1.2 },
	firestaff = { offset = 0.4 },
	firesuppressor = { offset = 0.5, scale = 1.5 },
	goldenshovel = { offset = 0.2 },
	grass_umbrella = { offset = 0.4 },
	greenstaff = { offset = 0.4 },
	hambat = { offset = 0.2 },
	icebox = { offset = 0.3, scale = 1.3 },
	icestaff = { offset = 0.4 },
	lightning_rod = { offset = 0.8, scale = 1.3 },
	mast = { offset = 4, scale = 2 },
	mast_malbatross = { offset = 4, scale = 2 },
	meatrack = { offset = 1, scale = 1.7 },
	mermhouse_crafted = { offset = 1.5, scale = 2.2 },
	monkey_mediumhat = { scale = 1.2 },
	mushroom_light = { offset = 1.2, scale = 1.4 },
	mushroom_light2 = { offset = 1.2, scale = 1.8 },
	nightsword = { offset = 0.2 },
	oceanfishingrod = { offset = -0.4 },
	opalstaff = { offset = 0.4 },
	orangestaff = { offset = 0.4 },
	pighouse = { offset = 1.5, scale = 2.2 },
	rabbithouse = { offset = 1.5, scale = 2.2 },
	rainometer = { offset = 0.9, scale = 1.6 },
	researchlab = { offset = 0.5, scale = 1.4 },
	researchlab2 = { offset = 0.5, scale = 1.4 },
	researchlab3 = { offset = 0.5, scale = 1.4 },
	researchlab4 = { offset = 0.5, scale = 1.4 },
	ruins_bat = { offset = 0.4, scale = 1.2 },
	saltbox = { offset = 0.3, scale = 1.3 },
	sculptingtable = { scale = 1.2 },
	seafaring_prototyper = { offset = 0.5, scale = 1.5 },
	shovel = { offset = 0.2 },
	siestahut = { scale = 1.8 },
	spear = { offset = 0.4 },
	spear_wathgrithr = { offset = 0.4 },
	stagehand = { offset = 0.2, scale = 1.3 },
	telebase = { scale = 1.6 },
	tent = { offset = 0.4, scale = 2.0 },
	treasurechest = { offset = 0.1, scale = 1.1 },
	umbrella = { offset = 0.4 },
	wall_moonrock = { offset = 0.2, scale = 1.2 },
	wall_ruins = { offset = 0.2, scale = 1.3 },
	wall_stone = { offset = 0.2, scale = 1.3 },
	wardrobe = { offset = 0.5, scale = 1.4 },
	winterometer = { offset = 0.8, scale = 1.3 },
	wormhole = { scale = 1.3 },
	yellowstaff = { offset = 0.4 },
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

local current_build = 1

local function doiskin(inst)
	current_build = (current_build % 4) + 1
	inst.AnimState:SetBuild(builds[current_build])
end

local current_build_2 = 1

local function doiskin_2(inst)
	current_build_2 = (current_build_2 % 4) + 1
	inst.AnimState:SetBuild(builds[current_build_2])
end

local current_buildmiohm = 1

local function doiskinmiohm(inst)
	current_buildmiohm = (current_buildmiohm % 2) + 1
	inst.AnimState:SetBuild(buildsmiohm[current_buildmiohm])
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

local function next_element_in_list(tbl, current)
	for i = 1, #tbl do
		if tbl[i] == current then
			return tbl[i % #tbl + 1] -- Return the next element, or the first if current is the last element
		end
	end
end

local function can_cast_fn(doer, target, pos)
    local prefab_to_skin = target.prefab
    local is_beard = false

    if table.contains( DST_CHARACTERLIST, prefab_to_skin ) then
        --We found a player, check if it's us
        if doer.userid == target.userid and target.components.beard ~= nil and target.components.beard.is_skinnable then
            prefab_to_skin = target.prefab .. "_beard"
            is_beard = true
        else
            return false
        end
    end

    if PREFAB_SKINS[prefab_to_skin] ~= nil then
        for _,item_type in pairs(PREFAB_SKINS[prefab_to_skin]) do
            if TheInventory:CheckClientOwnership(doer.userid, item_type) then
                return true
            end
        end
    end

    --Is there a skin to turn off?
    local curr_skin = is_beard and target.components.beard.skinname or target.skinname
    if curr_skin ~= nil then
        return true
    end

	-- Kiểm tra xem có nằm trong conversion_table không?
	for category, mapping in pairs(conversion_table) do
		for i, v in ipairs(mapping) do
			if v == target.prefab then
				return true
			end
		end
	end

    return false
end

local function spellCB(tool, target, pos, caster)
	--target = target or caster --if no target, then self target for beards no beards. Beards cút
    if target == nil then -- Bail.
        return
    end

	if target and (target == caster or target.prefab == "kochosei_enemy" or target.prefab == "kochosei_enemyb") then
		doiskin(target)
		--print(target.prefab.AnimState:GetBuild()) --hàm getbuild có tồn tại, có thể sử dụng để lưu current_build.
		hieuung(target)
	end

	for category, mapping in pairs(conversion_table) do
		for i, v in ipairs(mapping) do
			if v == target.prefab then
				local next_prefab = next_element_in_list(mapping, target.prefab)
				convert_rocks(target, next_prefab)
				if check_lucky then
					tool.components.finiteuses:Use(1)
				end
				hieuung(target)
				return
			end
		end
	end

    local fx_prefab = "explode_reskin"
    local skin_fx = SKIN_FX_PREFAB[tool:GetSkinName()]
    if skin_fx ~= nil and skin_fx[1] ~= nil then
        fx_prefab = skin_fx[1]
    end

    local fx = SpawnPrefab(fx_prefab)

    local fx_info = reskin_fx_info[target.prefab] or {}

    local scale_override = fx_info.scale or 1
    fx.Transform:SetScale(scale_override, scale_override, scale_override)

    local fx_pos_x, fx_pos_y, fx_pos_z = target.Transform:GetWorldPosition()
    fx_pos_y = fx_pos_y + (fx_info.offset or 0)
    fx.Transform:SetPosition(fx_pos_x, fx_pos_y, fx_pos_z)

    tool:DoTaskInTime(0, function()

        local prefab_to_skin = target.prefab
        local is_beard = false
        if target.components.beard ~= nil and target.components.beard.is_skinnable then
            prefab_to_skin = target.prefab .. "_beard"
            is_beard = true
        end

        if target:IsValid() and tool:IsValid() and tool.parent and tool.parent:IsValid() then
            local curr_skin = is_beard and target.components.beard.skinname or target.skinname
            local userid = tool.parent.userid or ""
            local cached_skin = tool._cached_reskinname[prefab_to_skin]
            local search_for_skin = cached_skin ~= nil --also check if it's owned
            if curr_skin == cached_skin or (search_for_skin and not TheInventory:CheckClientOwnership(userid, cached_skin)) then
                local new_reskinname = nil

                if PREFAB_SKINS[prefab_to_skin] ~= nil then
                    for _,item_type in pairs(PREFAB_SKINS[prefab_to_skin]) do
                        if search_for_skin then
                            if cached_skin == item_type then
                                search_for_skin = false
                            end
                        else
                            if TheInventory:CheckClientOwnership(userid, item_type) then
                                new_reskinname = item_type
                                break
                            end
                        end
                    end
                end
                tool._cached_reskinname[prefab_to_skin] = new_reskinname
                cached_skin = new_reskinname
            end

            if is_beard then
                target.components.beard:SetSkin( cached_skin )
            else
                TheSim:ReskinEntity( target.GUID, target.skinname, cached_skin, nil, userid )

				--Todo(Peter): make this better one day if we do more skins applied to multiple prefabs in the future
                if target.prefab == "wormhole" then
                    local other = target.components.teleporter.targetTeleporter
                    if other ~= nil then
                        TheSim:ReskinEntity( other.GUID, other.skinname, cached_skin, nil, userid )
                    end
                elseif target.prefab == "cave_entrance" or target.prefab == "cave_entrance_open" or target.prefab == "cave_exit" then
                    if target.components.worldmigrator:IsLinked() and Shard_IsWorldAvailable(target.components.worldmigrator.linkedWorld) then
                        local skin_theme = ""
                        if target.skinname ~= nil then
                            skin_theme = string.sub( target.skinname, string.len(target.prefab) + 2 )
                        end

                        SendRPCToShard(SHARD_RPC.ReskinWorldMigrator, target.components.worldmigrator.linkedWorld, target.components.worldmigrator.id, skin_theme, target.skin_id, TheNet:GetSessionIdentifier() )
                    end
                end
            end
        end
    end )
end


local function UseStaff(inst, target, tool, caster)
	local caster = inst.components.inventoryitem.owner
	spellCB(target)
	if target and (target == caster or target.prefab == "kochosei_enemy" or target.prefab == "kochosei_enemyb") then
		doiskin(target)
		--print(target.prefab.AnimState:GetBuild()) --hàm getbuild có tồn tại, có thể sử dụng để lưu current_build.
		hieuung(target)
	end
	if target == caster then
		doiskin_2(caster)
		hieuung(caster)
	end

	for category, mapping in pairs(conversion_table) do
		for i, v in ipairs(mapping) do
			if v == target.prefab then
				local next_prefab = next_element_in_list(mapping, target.prefab)
				convert_rocks(target, next_prefab)
				if check_lucky then
					inst.components.finiteuses:Use(1)
				end
				hieuung(target)
				return
			end
		end
	end

	--   if target and target.prefab == "miohm" then
	--       doiskinmiohm(target)
	--       hieuung(target)
	--    end
	--  Tính fix nhưng thôi, rắc rối vô hẳn soraapi + reskin_tool để nghiên cứu, lười

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
	MakeInventoryFloatable(inst, "small", 0.1, 1.12)

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
	inst.components.spellcaster:SetSpellFn(spellCB)
	inst.components.spellcaster:SetCanCastFn(can_cast_fn)
	inst.components.spellcaster.canuseontargets = true
	inst.components.spellcaster.quickcast = true
--	inst.components.spellcaster.CanCast = CanCast
--  Bỏ commonent CanCast để có thể dùng cho một số đối tượng giới hạn
	if check_lucky then
		inst:AddComponent("finiteuses")
		inst.components.finiteuses:SetMaxUses(TUNING.KOCHO_LUCKYHAMMER_DURABILITY)
		inst.components.finiteuses:SetUses(TUNING.KOCHO_LUCKYHAMMER_DURABILITY)
		inst.components.finiteuses:SetOnFinished(inst.Remove)
	end

	inst._cached_reskinname = {}
	return inst
end
STRINGS.NAMES.LUCKY_HAMMER = "Lucky Hammer"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.LUCKY_HAMMER = "I know what you want with this!! UwU"
STRINGS.RECIPE_DESC.LUCKY_HAMMER =
	"Change something to what you want from Ore, Tree, gem, mineral. Change free skin of clone and make you become a rich person!!"
return Prefab("lucky_hammer", fn, assets)
