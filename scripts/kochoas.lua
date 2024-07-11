Assets = {

    --------------------------------------------------------------------------------

    Asset("ATLAS", "images/cb_kochofood.xml"),
    Asset("ATLAS", "images/inventoryimages/kochofood.xml"),
    Asset("ATLAS", "images/inventoryimages/kochosei_inv.xml"),
    Asset("ATLAS", "images/inventoryimages/kochosei_purplebattleaxe_icon.xml"),
    Asset("IMAGE", "images/inventoryimages/kochosei_purplebattleaxe_icon.tex"),

    --------------------------------------------------------------------------------

    --------------------------------------------------------------------------------
    Asset("IMAGE", "images/saveslot_portraits/kochosei.tex"),
    Asset("ATLAS", "images/saveslot_portraits/kochosei.xml"),
    Asset("IMAGE", "images/selectscreen_portraits/kochosei.tex"),
    Asset("ATLAS", "images/selectscreen_portraits/kochosei.xml"),
    Asset("IMAGE", "images/selectscreen_portraits/kochosei_silho.tex"),
    Asset("ATLAS", "images/selectscreen_portraits/kochosei_silho.xml"),
    Asset("IMAGE", "bigportraits/kochosei.tex"),
    Asset("ATLAS", "bigportraits/kochosei.xml"),
    Asset("IMAGE", "bigportraits/kochosei_none.tex"),
    Asset("ATLAS", "bigportraits/kochosei_none.xml"),
    Asset("IMAGE", "bigportraits/kochosei_snowmiku_skin1.tex"),
    Asset("ATLAS", "bigportraits/kochosei_snowmiku_skin1.xml"),
    Asset("IMAGE", "bigportraits/ms_kochosei_snowmiku_skin1.tex"),
    Asset("ATLAS", "bigportraits/ms_kochosei_snowmiku_skin1.xml"),
    Asset("IMAGE", "images/map_icons/kochosei.tex"),
    Asset("ATLAS", "images/map_icons/kochosei.xml"),
    Asset("IMAGE", "images/avatars/avatar_kochosei.tex"),
    Asset("ATLAS", "images/avatars/avatar_kochosei.xml"),
    Asset("IMAGE", "images/avatars/avatar_ghost_kochosei.tex"),
    Asset("ATLAS", "images/avatars/avatar_ghost_kochosei.xml"),
    Asset("IMAGE", "images/avatars/self_inspect_kochosei.tex"),
    Asset("ATLAS", "images/avatars/self_inspect_kochosei.xml"),
    Asset("IMAGE", "images/names_gold_kochosei.tex"),
    Asset("ATLAS", "images/names_gold_kochosei.xml"),
    -- I have a pen and I have a pineapple Uhhhh pineapple pen --
    -- Apple pen, Pineapple pen --
    -- Pineapple, Apple pen --

    Asset("ATLAS", "minimap/kochosei_apple_tree_stump.xml"),
    Asset("IMAGE", "minimap/kochosei_apple_tree_stump.tex"),

    Asset("ATLAS", "minimap/kochosei_apple_tree_burnt.xml"),
    Asset("IMAGE", "minimap/kochosei_apple_tree_burnt.tex"),

    Asset("ATLAS", "minimap/kochosei_apple_tree.xml"),
    Asset("IMAGE", "minimap/kochosei_apple_tree.tex"),

    -- TAB kochosei
    Asset("ATLAS", "images/hud/kochoseitab.xml"),
    Asset("IMAGE", "images/hud/kochoseitab.tex"),

    Asset("SOUNDPACKAGE", "sound/kochosei_voice.fev"),
    Asset("SOUND", "sound/kochosei_voice.fsb"),

    Asset("SOUNDPACKAGE", "sound/kochosei_streetlight1_musicbox.fev"),
    Asset("SOUND", "sound/kochosei_streetlight1_musicbox.fsb"),
    Asset("ANIM", "anim/miku_usagi_backpack_2x4.zip"),
}

--RemapSoundEvent("dontstarve/characters/kochosei/talk_LP", "kochosei_voice/sound/talk_LP")
RemapSoundEvent("dontstarve/characters/kochosei/ghost_LP", "kochosei_voice/sound/ghost_LP")
RemapSoundEvent("dontstarve/characters/kochosei/hurt", "kochosei_voice/characters/hurt")
RemapSoundEvent("dontstarve/characters/kochosei/death_voice", "kochosei_voice/sound/death_voice")
RemapSoundEvent("dontstarve/characters/kochosei/carol", "kochosei_voice/sound/carol")
RemapSoundEvent("dontstarve/characters/kochosei/pose", "kochosei_voice/sound/pose")
RemapSoundEvent("kochosei_streetlight1_musicbox/play", "kochosei_streetlight1_musicbox/sound/play")
RemapSoundEvent("kochosei_streetlight1_musicbox/end", "kochosei_streetlight1_musicbox/sound/end")

AddMinimapAtlas("images/map_icons/kochosei.xml")
AddMinimapAtlas("minimap/miku_usagi_backpack.xml")
AddMinimapAtlas("minimap/kochosei_apple_tree_burnt.xml")
AddMinimapAtlas("minimap/kochosei_apple_tree_stump.xml")
AddMinimapAtlas("minimap/kochosei_apple_tree.xml")
