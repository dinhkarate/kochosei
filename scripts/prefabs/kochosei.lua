local MakePlayerCharacter = require "prefabs/player_common"

local assets = {
    Asset("SCRIPT", "scripts/prefabs/player_common.lua"),
    Asset("SOUND", "sound/kochosei_voice.fsb"),
    Asset("ANIM", "anim/kochosei.zip"),
    Asset("ANIM", "anim/ghost_kochosei_build.zip"),
    Asset("ANIM", "anim/kochosei_snowmiku_skin1.zip")
}

-- Your character's stats

-- Custom starting inventory
TUNING.GAMEMODE_STARTING_ITEMS.DEFAULT.KOCHOSEI = {
    "flint", "flint", "twigs", "twigs", "cutgrass", "cutgrass", "kochosei_hat2",
    "kochosei_lantern", "kochosei_apple"
}

TUNING.STARTING_ITEM_IMAGE_OVERRIDE.kochosei_lantern = {
    image = "kochosei_lantern.tex"
}

TUNING.STARTING_ITEM_IMAGE_OVERRIDE.kochosei_hat2 = {
    image = "kochosei_hat2.tex"
}
TUNING.STARTING_ITEM_IMAGE_OVERRIDE.kochosei_apple = {
    image = "kochosei_apple.tex"
}

local start_inv = {}
for k, v in pairs(TUNING.GAMEMODE_STARTING_ITEMS) do
    start_inv[string.lower(k)] = v.KOCHOSEI
end
local prefabs = FlattenTree(start_inv, true)

--[[Mio Không Phê Duyệt
local function kochoOnNewSpawn(inst)
    local season = TheWorld.state.season
    local food = nil
    if season == "winter" then
        food = SpawnPrefab("kochofood_bunreal")
    elseif season == "summer" then
        food = SpawnPrefab("kochofood_grape_juice")
    end

    if food and inst.components.inventory then
        inst.components.inventory:GiveItem(food)
    end
end
--]]

-- When the character is revived from human
local function onbecamehuman(inst)
    -- Set speed when not a ghost (optional)
    inst.components.locomotor:SetExternalSpeedMultiplier(inst, "kochosei_speed_mod", 1.25)
end

local function onbecameghost(inst)
    -- Remove speed modifier when becoming a ghost
    inst.components.locomotor:RemoveExternalSpeedMultiplier(inst,"kochosei_speed_mod")
end

-- When loading or spawning the character
local function onload(inst)
    inst:ListenForEvent("ms_respawnedfromghost", onbecamehuman)
    inst:ListenForEvent("ms_becameghost", onbecameghost)

    if inst:HasTag("playerghost") then
        onbecameghost(inst)
    else
        onbecamehuman(inst)
    end
end

local function onpick(inst, data)
    if data.object.prefab == "flower" or data.object:HasTag("flower") then
        inst.components.sanity:DoDelta(-15)
    end
end

local function emoteplants(inst)
    local x, y, z = inst.Transform:GetWorldPosition()
    local ents = TheSim:FindEntities(x, y, z, 15, nil, nil, {"farm_plant"})
    for k, v in pairs(ents) do
        if v.components.farmplanttendable ~= nil then
            v.components.farmplanttendable:TendTo(inst)
        end
    end
end

local function emoteplantsfix(inst) inst.SoundEmitter:KillSound("kochoseitalk") end

local wlist = require "util/weighted_list"

local talklist = wlist({
    talk1 = 1,
    talk2 = 2,
    talk3 = 3,
    talk4 = 4,
    talk5 = 5,
    talk6 = 6,
    talk7 = 7,
    talk8 = 8,
    talk9 = 9,
    talk10 = 10,
    talk11 = 11,
    talk12 = 12,
    talk13 = 13,
    talk14 = 14,
    talk15 = 15
})
local emotesoundlist = {
    emote = "emote",
    emoteXL_waving1 = "wave", -- wave
    emoteXL_facepalm = "facepalm", -- facepalm
    research = "joy", -- joy
    emoteXL_sad = "cry", -- cry
    emoteXL_annoyed = "no", -- nosay
    emoteXL_waving4 = "rude", -- rude
    emote_pre_sit1 = "squat", -- squat
    emote_pre_sit2 = "sit", -- sit
    emoteXL_angry = "angry", -- angry
    emoteXL_happycheer = "happy", -- happy
    emoteXL_bonesaw = "bonesaw", -- bonesaw
    emoteXL_kiss = "kiss", -- kiss
    pose = wlist({pose1 = 1, pose2 = 1, pose3 = 1}), -- pose
    emote_fistshake = "fistshake", -- fistshake
    emote_flex = "flex", -- flex
    emoteXL_pre_dance7 = "step", -- MY GODFATHER --
    emoteXL_pre_dance0 = "dance", -- dance
    emoteXL_pre_dance8 = "robot", -- robot
    emoteXL_pre_dance6 = "chicken", -- chicken
    emote_swoon = "swoon", -- swoon
    carol = wlist({carol1 = 1, carol2 = 2, carol3 = 3, carol4 = 4, carol5 = 5}), -- carol
    emote_slowclap = "slowclap", -- slowclap
    emote_shrug = "shrug", -- shrug
    emote_laugh = "laugh", -- laugh
    emote_jumpcheer = "cheer", -- cheer
    emote_impatient = "impatient", -- impatient
    eye_rub_vo = "sleepy", -- sleepy
    emote_yawn = "yawn" -- yawn
}

local function OnTaskTick(inst)
    if inst.components.health:IsDead() or inst:HasTag("playerghost") then
        return
    end
    if inst.components.sanity:GetPercent() < 1 then return end
    local x, y, z = inst.Transform:GetWorldPosition()
    local ents = TheSim:FindEntities(x, y, z, 8, {"player"}, {"playerghost"})
    for i, v in ipairs(ents) do
        if v.components.health ~= nil and v.components.health:GetPercent() < 1 and
            not v.components.health:IsDead() then
            v.components.health:DoDelta(1.2, false, "kochosei")
        end
    end
end

---------------------------Kén ăn------------------
local kochoseikhongan = {
    "butterflywings", "butterflymuffin", "poop", "moonbutterflywings"
}

local function anvaochetnguoiay(inst, food)
    if food ~= nil then
        for k, v in ipairs(kochoseikhongan) do
            if food.prefab == v then return false end
        end
    end
    return true
end

---------------------------Kén ăn------------------

-- This initializes for both the server and client. Tags can be added here.
local common_postinit = function(inst)
    inst:AddTag("kochosei")
    inst:AddTag("summonerally")
    inst:AddTag("puppeteer")
    inst:AddTag("reader")
    inst.MiniMapEntity:SetIcon("kochosei.tex")
    inst.AnimState:AddOverrideBuild("wendy_channel")
    inst.AnimState:AddOverrideBuild("player_idles_wendy")
end

-- This initializes for the server only. Components are added here.

local kochoseidancingsanity = 20

local function CalcSanityAura(inst)
    return inst.kochoseiindancing * kochoseidancingsanity / 60
end

local function KochoseiSound(inst, talk, time, tag)
    if inst._kochoseitalk ~= nil then
        inst._kochoseitalk:Cancel()
        inst._kochoseitalk = nil
    end
    inst.SoundEmitter:KillSound("kochoseitalk")
    if tag then inst.SoundEmitter:KillSound(tag) end
    local name = ""
    if type(talk) == "table" then
        name = talk:getChoice(math.random() * talk:getTotalWeight())
    elseif type(talk) == "string" then
        name = talk
    end
    if name ~= nil then
        inst.SoundEmitter:PlaySound("kochosei_voice/sound/" .. name,
                                    tag or "kochoseitalk")
    end

    if time ~= nil then
        inst._kochoseitalk = inst:DoTaskInTime(time, function()
            inst.SoundEmitter:KillSound(tag or "kochoseitalk")
            inst._kochoseitalk:Cancel()
            inst._kochoseitalk = nil
        end)
    end
end

------------------------------------------------chicken--------------------------------------------------------
---------------------------------------------------------------------------------------------------------------
local function onnewstate(inst, data)
    if inst.sg.currentstate.name ~= "emote" then
        if inst._kochoseitalk ~= nil then
            inst._kochoseitalk:Cancel()
            inst._kochoseitalk = nil
        end
        if inst.emotefn then
            inst.emotefn:Cancel()
            inst.emotefn = nil
        end

        inst.SoundEmitter:KillSound("kochoseibgm")
        inst.SoundEmitter:KillSound("kochoseitalk")
        inst.components.sanity.dapperness =
            inst.components.sanity.dapperness - inst.kochoseiindancing *
                kochoseidancingsanity / 60
        inst.kochoseiindancing = 0
        inst:RemoveEventCallback("newstate", onnewstate)
    end
end

local function onemote(inst, data)
    local soundname = data.soundoverride or (type(data.anim) == "table" and
                          (type(data.anim[1]) == "table" and data.anim[1][1] or
                              data.anim[1])) or
                          (type(data.anim) == "string" and data.anim) or "emote"
    local loop = data.loop
    local sound = "emote"
    sound = emotesoundlist[soundname] or "emote"

    if soundname == "carol" or sound == "dance" or sound == "step" or sound ==
        "robot" or sound == "chicken" then
        inst.components.sanity.dapperness =
            inst.components.sanity.dapperness - inst.kochoseiindancing *
                kochoseidancingsanity / 60
        inst.kochoseiindancing = (sound == "dance") and 1 or 1.5
        inst.components.sanity.dapperness =
            inst.components.sanity.dapperness + inst.kochoseiindancing *
                kochoseidancingsanity / 60
        if not inst.components.sanityaura then
            inst:AddComponent("sanityaura") -- 回SAN光环
        end
        inst.components.sanityaura.aurafn = CalcSanityAura
        inst:ListenForEvent("newstate", onnewstate)
        if inst.emotefn then
            inst.emotefn:Cancel()
            inst.emotefn = nil
        end

        inst.emotefn = inst:DoTaskInTime(1, emoteplants) -- happytime
        KochoseiSound(inst, sound, nil, "kochoseibgm")
    else
        KochoseiSound(inst, sound, nil)
    end
    inst:DoTaskInTime(3, emoteplantsfix)
end

---------------------------------------------------------------------------------------------------------------
--[[
local lootlist = {
    dragonfly = {
        {
            name = "moonglass",
            probability = 1
        }
    }
}
--]]
-------------Bướm chết ở gần bị trừ sanity----------------------

-------------Bướm chết ở gần bị trừ sanity----------------------

local function onkilled(inst, data)
    --    local victim = data.victim
    if data ~= nil and data.victim ~= nil and data.victim:HasTag("butterfly") then
        print("test butterfly")
        inst.components.sanity:DoDelta(-50, false)
        --        inst.components.hunger:DoDelta(-100)
        inst.components.health:DoDelta(-100, false, "Punishment from God!")
        inst.components.talker:Say("What are you doingggggg!!!")
        TheWorld:PushEvent("ms_sendlightningstrike", inst:GetPosition())
        TheNet:Announce("A punishment from God have been release to " ..
                            inst:GetDisplayName() ..
                            " because of the worst guilty a Kochosei can make")
    end

    if data ~= nil and data.victim ~= nil and data.victim:HasTag("frog") then
        data.victim.components.lootdropper:AddRandomLoot("krampus", 0.1)
        data.victim.components.lootdropper:AddRandomLoot("leif", 0.01)
        data.victim.components.lootdropper:AddRandomLoot("frogleg", 1)
        data.victim.components.lootdropper.numrandomloot = 1

        local math = math.random(1, 100)
        if math == 1 then
            TheWorld:PushEvent("ms_sendlightningstrike", inst:GetPosition())
            TheNet:Announce("Legend has it that onii-chan " ..
                                inst:GetDisplayName() ..
                                " was very very very luckily to get the jackpot from the God.")
        end
    end

    if data ~= nil and data.victim ~= nil and data.victim:HasTag("dragonfly") then
        SetSharedLootTable("dragonfly", {
            {"dragon_scales", 1.00}, {"dragon_scales", 1.00},
            {"dragonflyfurnace_blueprint", 1.00},
            {"chesspiece_dragonfly_sketch", 1.00},
            {"chesspiece_dragonfly_sketch", 1.00}, {"lavae_egg", 0.33},
            {"meat", 1.00}, {"meat", 1.00}, {"meat", 1.00}, {"meat", 1.00},
            {"meat", 1.00}, {"meat", 1.00}, {"meat", 1.00}, {"meat", 1.00},
            {"meat", 1.00}, {"meat", 1.00}, {"meat", 1.00}, {"meat", 1.00},
            {"meat", 1.00}, {"meat", 1.00}, {"meat", 1.00}, {"meat", 1.00},
            {"meat", 1.00}, {"meat", 1.00}, {"goldnugget", 1.00},
            {"goldnugget", 1.00}, {"goldnugget", 1.00}, {"goldnugget", 1.00},
            {"goldnugget", 0.50}, {"goldnugget", 0.50}, {"goldnugget", 0.50},
            {"goldnugget", 0.50}, {"goldnugget", 0.50}, {"goldnugget", 0.50},
            {"goldnugget", 0.50}, {"goldnugget", 0.50}, {"redgem", 1.00},
            {"bluegem", 1.00}, {"purplegem", 1.00}, {"orangegem", 1.00},
            {"yellowgem", 1.00}, {"greengem", 1.00}, {"redgem", 1.00},
            {"bluegem", 1.00}, {"purplegem", 1.00}, {"orangegem", 1.00},
            {"yellowgem", 1.00}, {"greengem", 1.00}, {"redgem", 1.00},
            {"bluegem", 1.00}, {"purplegem", 1.00}, {"orangegem", 1.00},
            {"yellowgem", 1.00}, {"greengem", 1.00}, {"redgem", 0.40},
            {"bluegem", 0.40}, {"purplegem", 0.40}, {"orangegem", 0.40},
            {"yellowgem", 0.40}, {"greengem", 0.40}, {"redgem", 1.00},
            {"bluegem", 1.00}, {"purplegem", 0.50}, {"orangegem", 0.50},
            {"yellowgem", 0.50}, {"greengem", 0.50}
        })
    end
end

---------------------------------Level Miomhm---------------------
local function IsValidVictim(victim)
    return victim ~= nil and
               not (victim:HasTag("prey") or victim:HasTag("veggie") or
                   victim:HasTag("structure") or victim:HasTag("wall") or
                   victim:HasTag("companion")) and victim.components.health ~=
               nil and victim.components.combat ~= nil
end
local function onkilledmiohm(inst, data)
    local victim = data.victim
    if IsValidVictim(victim) then
        local weapon = inst.components.combat:GetWeapon()
        if weapon and weapon:HasTag("miohm") then
            weapon.levelmiohm = weapon.levelmiohm + TUNING.KOCHOSEI_PER_KILL
            weapon:applyupgrades()
        end
    end
end
---------------------------------Level Miomhm---------------------

local ghosttalklist = wlist({ghosttalk1 = 1, ghosttalk2 = 1, ghosttalk3 = 1})
local function ontalk(inst, data)
    if not inst:HasTag("playerghost") then
        KochoseiSound(inst, talklist)
    else
        KochoseiSound(inst, ghosttalklist)
    end
end

-----------------------------------------------------------------------------
--[[
local function OnEquipCustom(inst, data)
    local hat_prefabs = {"kochosei_hat1", "kochosei_hat2", "kochosei_hat3"}
    if table.contains(hat_prefabs, data.item.prefab) then
        if inst:HasTag("scarytoprey") then
            inst:RemoveTag("scarytoprey")
        end
    end
end

local function OnUnequipCustom(inst, data)
    if data.item ~= nil then
        local hat_prefabs = {"kochosei_hat1", "kochosei_hat2", "kochosei_hat3"}
        if table.contains(hat_prefabs, data.item.prefab) then
            if not inst:HasTag("scarytoprey") then
                inst:AddTag("scarytoprey")
            end
        end
    end
end
--]]

local function OnEquipCustom(inst, data)
    if data.item:HasTag("kochosei_hat") then
        if inst:HasTag("scarytoprey") then inst:RemoveTag("scarytoprey") end
    end
end

local function OnUnequipCustom(inst, data)
    if data.item ~= nil then
        if data.item:HasTag("kochosei_hat") then
            if not inst:HasTag("scarytoprey") then
                inst:AddTag("scarytoprey")
            end
        end
    end
end

-----------------------------------------------------------------------------
-----------------------------------------------------------------------------
local function in_fire(inst)
    if inst.sg:HasStateTag("knockout") then
        local x, y, z = inst.Transform:GetWorldPosition()
        local ents = TheSim:FindEntities(x, y, z, 10, {"fire"})
        for i, v in ipairs(ents) do
            if v.components.burnable ~= nil and
                v.components.burnable:IsBurning() then
                if TheWorld.state.isnight then
                    inst.components.sanity:DoDelta(5, false)
                end
            end
        end
    end
end
-----------------------------------------------------------------------------

-----------------------------------------------------------------------------
local function haru(inst)
    local x, y, z = inst.Transform:GetWorldPosition()
    local spell = SpawnPrefab("crab_king_icefx")
    spell.Transform:SetPosition(x - .11, y, z + .1)
end

local function harulevel(inst)
    --[[
if inst.components.skinner:Kochosei_GetSkinName() == "kochosei_snowmiku_skin1"
then
print("baideo2")
end
--]]
    if inst.components.health:IsDead() or inst:HasTag("playerghost") then
        return
    end

    if inst.kochostop == nil then inst.kochostop = 0 end

    if not inst.components.locomotor.wantstomoveforward then
        inst.kochostop = inst.kochostop + 1
    else
        inst.kochostop = 0
    end

    if inst.kochostop >= 60 then haru(inst) end
end


local master_postinit = function(inst)

    inst.starting_inventory = start_inv[TheNet:GetServerGameMode()] or
                                  start_inv.default

    -- choose which sounds this character will play
    inst.soundsname = "kochosei"
    inst.kochoseiindancing = 0
    inst.components.talker.ontalkfn = ontalk

    -- Stats
    inst:AddComponent("reader")
    inst.components.health:SetMaxHealth(TUNING.KOCHOSEI_HEALTH)
    inst.components.hunger:SetMax(TUNING.KOCHOSEI_HUNGER)
    inst.components.sanity:SetMax(TUNING.KOCHOSEI_SANITY)
    --[[
    inst.components.health.absorb = TUNING.KOCHOSEI_ARMOR
     inst.components.combat.damagemultiplier = TUNING.KOCHOSEI_DAMAGE
     inst.components.combat.externaldamagetakenmultipliers:SetModifier(inst, TUNING.KOCHOSEI_ARMOR, "kocho_def_config") -- Def multiplier
     ]]
    inst.components.combat.externaldamagemultipliers:SetModifier(inst, TUNING.KOCHOSEI_DAMAGE, "kocho_damage_config") -- Damage multiplier (optional)

    if  TUNING.KOCHOSEI_CHECKWIFI/1000 > TUNING.KOCHOSEI_ARMOR then
      inst.components.health.externalabsorbmodifiers:SetModifier(inst, TUNING.KOCHOSEI_CHECKWIFI/1000, "kocho_def_config") -- Vì sợ đau nên tôi nâng max phòng thủ
      print("wifi hoat dong")
    else
        inst.components.health.externalabsorbmodifiers:SetModifier(inst, TUNING.KOCHOSEI_ARMOR, "kocho_def_config") -- Vì sợ đau nên tôi nâng max phòng thủ
        print("wifi k hoat dong")
    end
    inst.components.sanity.dapperness = -5 / 60

    inst.components.petleash:SetMaxPets(TUNING.KOCHOSEI_SLAVE_MAX_FIX)

    inst:DoPeriodicTask(1, OnTaskTick)
    inst:DoPeriodicTask(5, in_fire)
    inst:DoPeriodicTask(1, harulevel)

    inst.components.hunger.hungerrate = TUNING.WILSON_HUNGER_RATE
    inst.components.eater.PrefersToEat = anvaochetnguoiay
    inst.customidleanim = "idle_wilson"
    inst.OnLoad = onload

    inst:ListenForEvent("emote", onemote)
    ------------
    inst:ListenForEvent("equip", OnEquipCustom)
    inst:ListenForEvent("unequip", OnUnequipCustom)
    ------------

    inst:ListenForEvent("ms_respawnedfromghost", onbecamehuman)
    inst:ListenForEvent("death", onbecameghost)
    inst:ListenForEvent("death", function(inst, data)
        if data and data.afflicter and data.afflicter:IsValid() and
            data.afflicter.components.health and
            not data.afflicter.components.health:IsDead() then
            local killer = data.afflicter.components.follower and
                               data.afflicter.components.follower:GetLeader() or
                               data.afflicter:HasTag("player") and
                               data.afflicter or nil
            if killer and killer:HasTag("player") and killer ~= inst then
                killer.components.health:Kill()
            end
        end
    end)
    inst:ListenForEvent("healthdelta", function(inst, data)
        if data and data.afflicter and data.afflicter:IsValid() and
            data.afflicter.components.health and
            not data.afflicter.components.health:IsDead() then
            local killer = data.afflicter.components.follower and
                               data.afflicter.components.follower:GetLeader() or
                               data.afflicter:HasTag("player") and
                               data.afflicter or nil
            if killer and killer:HasTag("player") and killer ~= inst then
                killer.components.health:DoDelta(3 * data.amount, nil, nil,
                                                 true, killer, true)
            end
        end
    end)

    inst.wlist = wlist
    inst:ListenForEvent("killed", onkilled)
    inst:ListenForEvent("killed", onkilledmiohm)
    inst:ListenForEvent("picksomething", onpick)
    ---------------------------Kén ăn------------------
    local inedibles = {}
    local old_CanEat = inst.components.eater.CanEat
    inst.components.eater.CanEat = function(self, food_inst)
        for i, v in ipairs(inedibles) do
            if food_inst.prefab == v then return false end
        end
        return old_CanEat(self, food_inst)
    end
    ---------------------------Kén ăn------------------
    -------------Bướm chết ở gần bị trừ sanity----------------------
    -- inst._onentitydeathfn = function(src, data) apdungtrungphat(inst, data) end
    -- inst:ListenForEvent("entity_death", inst._onentitydeathfn, TheWorld)
    -------------Bướm chết ở gần bị trừ sanity----------------------

end
-- Không dùng khi có modded được phát hiện--
if TUNING.KOCHOSEI_CHECKMOD ~= 1 then
    Kochoseiapi.MakeCharacterSkin("kochosei", "kochosei_none", {
        name = "Kochosei",
        des = "o((>ω< ))o",
        quotes = "<3 Hora hora",
        rarity = "Character",
        skins = {normal_skin = "kochosei", ghost_skin = "ghost_kochosei_build"},
        skin_tags = {"BASE", "kochosei", "CHARACTER"},
        build_name_override = "kochosei"

    })

    Kochoseiapi.MakeCharacterSkin("kochosei", "kochosei_snowmiku_skin1", {
        name = "Kochosei cosplay Miku",
        des = "o((>ω< ))o",
        quotes = "Ai đó đã phải làm việc như trâu để có skin này. Congratulation",
        rarity = "Elegant",
        skins = {
            normal_skin = "kochosei_snowmiku_skin1",
            ghost_skin = "ghost_kochosei_build"
        },
        skin_tags = {"BASE", "kochosei", "CHARACTER", "ICE"}

    })
end
-- Không dùng khi có modded được phát hiện--

return MakePlayerCharacter("kochosei", prefabs, assets, common_postinit,
                           master_postinit)
