PrefabFiles = {

    "kochosei",
    "kochosei_none",
}
GLOBAL.setmetatable(env, {__index = function(t,k) return GLOBAL.rawget(GLOBAL,k) end})
GLOBAL.Kochoseiapi = env
modimport("scripts/kochoas")

local skin_modes = {
    {
        type = "ghost_skin",
        anim_bank = "ghost",
        idle_anim = "idle",
        scale = 0.75,
        offset = {
            0,
            -25,
        },
    },
}

AddModCharacter("kochosei", "FEMALE", skin_modes)

modimport("scripts/api_skins_soraaaaa") -- Không thấy modded nên dùng api đáng lẽ api cũ cơ

