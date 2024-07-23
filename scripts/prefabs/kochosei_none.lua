local prefabs = {}
--[[

--]]
if TUNING.KOCHOSEI_CHECKMOD == 1 then
	table.insert(
		prefabs,
		CreatePrefabSkin(
			"kochosei_none", --This skin is the regular default skin we have, You should already have this
			{
				base_prefab = "kochosei", --What Prefab are we skinning? The character of course!
				build_name_override = "kochosei",
				type = "base", --Hornet: Make sure you have this here! You should have it but ive seen some character mods with out
				rarity = "Character",
				skip_item_gen = true,
				skip_giftable_gen = true,
				skin_tags = { "BASE", "kochosei" },
				skins = {
					normal_skin = "kochosei", --These are your skin modes here, now you should have 2. But I actually have 4 for kochosei! Due to her werekochosei form and transformation animation
					ghost_skin = "ghost_kochosei_build",
				},
				assets = {
					Asset("ANIM", "anim/kochosei.zip"), --Self-explanatory, these are the assets your character is using!
					Asset("ANIM", "anim/ghost_kochosei_build.zip"),
				},
			}
		)
	)

	table.insert(
		prefabs,
		CreatePrefabSkin("kochosei_snowmiku_skin1", {
			base_prefab = "kochosei",
			build_name_override = "kochosei_snowmiku_skin1",
			type = "base",

			rarity = "ModMade", --Changing rarity to ‘ModLocked’
			rarity_modifier = "Woven",
			skip_item_gen = true,
			skip_giftable_gen = true,
			skin_tags = { "BASE", "kochosei", "ICE" },
			skins = {
				normal_skin = "kochosei_snowmiku_skin1",
				ghost_skin = "ghost_kochosei_build",
			},

			assets = {
				Asset("ANIM", "anim/kochosei_snowmiku_skin1.zip"),
				Asset("ANIM", "anim/ghost_kochosei_build.zip"),
			},
		})
	)

	table.insert(
		prefabs,
		CreatePrefabSkin("kochosei_skin_shinku_notfull", {
			base_prefab = "kochosei",
			build_name_override = "kochosei_skin_shinku_notfull",
			type = "base",
			rarity = "ModMade",
			rarity_modifier = "Woven",
			skip_item_gen = true,
			skip_giftable_gen = true,
			skin_tags = { "BASE", "kochosei", "ICE" },
			skins = {
				normal_skin = "kochosei_skin_shinku_notfull",
				ghost_skin = "ghost_kochosei_build",
			},

			assets = {
				Asset("ANIM", "anim/kochosei_skin_shinku_notfull.zip"),
				Asset("ANIM", "anim/ghost_kochosei_build.zip"),
			},
		})
	)
	table.insert(
		prefabs,
		CreatePrefabSkin("kochosei_skin_shinku_full", {
			base_prefab = "kochosei",
			build_name_override = "kochosei_skin_shinku_full",
			type = "base",
			rarity = "ModMade",
			rarity_modifier = "Woven",
			skip_item_gen = true,
			skip_giftable_gen = true,
			skin_tags = { "BASE", "kochosei", "ICE" },
			skins = {
				normal_skin = "kochosei_skin_shinku_full",
				ghost_skin = "ghost_kochosei_build",
			},

			assets = {
				Asset("ANIM", "anim/kochosei_skin_shinku_full.zip"),
				Asset("ANIM", "anim/ghost_kochosei_build.zip"),
			},
		})
	)
	table.insert(
		prefabs,
		CreatePrefabSkin("ms_kochosei_hat2", {

			base_prefab = "kochosei_hat1",
			type = "item",
			rarity = "ModMade",
			build_name_override = "ms_kochosei_hat2",
			assets = {
				Asset("ANIM", "anim/kochosei_hat2.zip"),
			},
		})
	)
	table.insert(
		prefabs,
		CreatePrefabSkin("ms_kochosei_hat3", {
			base_prefab = "kochosei_hat1",
			type = "item",
			rarity = "ModMade",
			build_name_override = "kochosei_hat3",
			assets = {
				Asset("ANIM", "anim/kochosei_hat3.zip"),
			},
		})
	)
end

return unpack(prefabs)
