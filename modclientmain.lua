PrefabFiles = {
	"kochosei",
	"kochosei_none",
}
GLOBAL.setmetatable(env, {
	__index = function(t, k)
		return GLOBAL.rawget(GLOBAL, k)
	end,
})
GLOBAL.Kochoseiapi = env
modimport("scripts/kochoas")

AddModCharacter("kochosei", "FEMALE")

modimport("scripts/api_skins_soraaaaa") -- Không thấy modded nên dùng api đáng lẽ api cũ cơ
