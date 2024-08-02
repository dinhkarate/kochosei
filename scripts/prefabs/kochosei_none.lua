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

	local skin_data = {
		{
			skin_name = "kochosei_snowmiku_skin1",
			build_name = "kochosei_snowmiku_skin1",
			anim_file = "anim/kochosei_snowmiku_skin1.zip",
		},
		{
			skin_name = "kochosei_skin_shinku_notfull",
			build_name = "kochosei_skin_shinku_notfull",
			anim_file = "anim/kochosei_skin_shinku_notfull.zip",
		},
		{
			skin_name = "kochosei_skin_shinku_full",
			build_name = "kochosei_skin_shinku_full",
			anim_file = "anim/kochosei_skin_shinku_full.zip",
		},
	}

	for _, skin in ipairs(skin_data) do
		table.insert(
			prefabs,
			CreatePrefabSkin(skin.skin_name, {
				base_prefab = "kochosei",
				build_name_override = skin.build_name,
				type = "base",
				rarity = "ModMade",
				rarity_modifier = "Woven",
				skip_item_gen = true,
				skip_giftable_gen = true,
				skin_tags = { "BASE", "kochosei", "ICE" },
				skins = {
					normal_skin = skin.skin_name,
					ghost_skin = "ghost_kochosei_build",
				},
				assets = {
					Asset("ANIM", skin.anim_file),
					Asset("ANIM", "anim/ghost_kochosei_build.zip"),
				},
			})
		)
	end
end

return unpack(prefabs)
