local MakePlayerCharacter = require("prefabs/player_common")

local assets = {
    Asset("SCRIPT", "scripts/prefabs/player_common.lua"),
    Asset("SOUND", "sound/kochosei_voice.fsb"),
    Asset("ANIM", "anim/kochosei.zip"),
    Asset("ANIM", "anim/ghost_kochosei_build.zip"),
    Asset("ANIM", "anim/kochosei_snowmiku_skin1.zip"),
    Asset("ANIM", "anim/kochosei_skin_shinku_notfull.zip"),
    Asset("ANIM", "anim/kochosei_skin_shinku_full.zip")
}

-- Your character's stats

-- Custom starting inventory
TUNING.GAMEMODE_STARTING_ITEMS.DEFAULT.KOCHOSEI = {
    "flint",
    "flint",
    "twigs",
    "twigs",
    "cutgrass",
    "cutgrass",
    "kochosei_hat2",
    "kochosei_lantern",
    "kochosei_apple",
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

local function haru(inst)
    local dist = 0.5 * math.random()
    local theta = 2 * PI * math.random()
    local x, y, z = inst.Transform:GetWorldPosition()
    local fx = SpawnPrefab("crab_king_icefx")
    if fx then
        fx.Transform:SetPosition(x + dist * math.cos(theta), 0, z + dist * math.sin(theta))
    end
end

local function givefood(inst)
    local season = TheWorld.state.season
    local food = nil
    if season == "winter" then
        food = SpawnPrefab("kochofood_bunreal")
    elseif season == "summer" then
        food = SpawnPrefab("kochofood_grape_juice")
    elseif season == "spring" then
        food = SpawnPrefab("kochosei_umbrella")
    end

    if food and inst.components.inventory then
        inst.components.inventory:GiveItem(food)
    end
end

local function onbecamehuman(inst)
    inst.components.locomotor:SetExternalSpeedMultiplier(inst, "kochosei_speed_mod", 1.25)
end

local function onbecameghost(inst)
    inst.components.locomotor:SetExternalSpeedMultiplier(inst, "kochosei_speed_mod", 5)
    -- Buff tăng tốc khi chết, đỡ tốn time di chuyển
end

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
    local ents = TheSim:FindEntities(x, y, z, 15, nil, nil, {
        "farm_plant"
    })
    for k, v in pairs(ents) do
        if v.components.farmplanttendable ~= nil then
            v.components.farmplanttendable:TendTo(inst)
        end
    end
end

local function emoteplantsfix(inst)
    inst.SoundEmitter:KillSound("kochoseitalk")
end

local wlist = require("util/weighted_list")

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
    pose = wlist({
        pose1 = 1,
        pose2 = 1,
        pose3 = 1
    }), -- pose
    emote_fistshake = "fistshake", -- fistshake
    emote_flex = "flex", -- flex
    emoteXL_pre_dance7 = "step", -- MY GODFATHER --
    emoteXL_pre_dance0 = "dance", -- dance
    emoteXL_pre_dance8 = "robot", -- robot
    emoteXL_pre_dance6 = "chicken", -- chicken
    emote_swoon = "swoon", -- swoon
    carol = wlist({
        carol1 = 1,
        carol2 = 2,
        carol3 = 3,
        carol4 = 4,
        carol5 = 5
    }), -- carol
    emote_slowclap = "slowclap", -- slowclap
    emote_shrug = "shrug", -- shrug
    emote_laugh = "laugh", -- laugh
    emote_jumpcheer = "cheer", -- cheer
    emote_impatient = "impatient", -- impatient
    eye_rub_vo = "sleepy", -- sleepy
    emote_yawn = "yawn" -- yawn
}
local HEAL_MUST_TAGS = {
    "player"
}
local HEAL_CANT_TAGS = {
    "DECOR",
    "eyeofterror",
    "FX",
    "INLIMBO",
    "NOCLICK",
    "notarget",
    "playerghost",
    "wall"
}
local function OnTaskTick(inst)
    if inst.components.health:IsDead() or inst:HasTag("playerghost") then
        return
    end
    if inst.components.sanity:GetPercent() < 1 then
        return
    end
    local x, y, z = inst.Transform:GetWorldPosition()
    local ents = TheSim:FindEntities(x, y, z, 8, HEAL_MUST_TAGS, HEAL_CANT_TAGS)
    for i, v in ipairs(ents) do
        if v.components.health ~= nil and v.components.health:GetPercent() < 1 and not v.components.health:IsDead() then
            v.components.health:DoDelta(1.2)
            v.components.health:DeltaPenalty(-0.01) -- con cò, số gì bé V~
        end
    end
    if inst.kochostop == nil then
        inst.kochostop = 0
    end

    if not inst.components.locomotor.wantstomoveforward then
        inst.kochostop = inst.kochostop + 1
    else
        inst.kochostop = 0
    end

    if inst.kochostop >= 60 then
        haru(inst)
    end
end

---------------------------Kén ăn------------------
local kochoseikhongan = {
    "butterflywings",
    "butterflymuffin",
    "poop",
    "moonbutterflywings",
    "butterflymuffin_spice_chili",
    "butterflymuffin_spice_sugar",
    "butterflymuffin_spice_salt",
    "butterflymuffin_spice_garlic"
}

local function anvaochetnguoiay(inst, food)
    if food ~= nil then
        for k, v in ipairs(kochoseikhongan) do
            if food.prefab == v then
                return false
            end
        end
    end
    return true
end

---------------------------Kén ăn------------------

local common_postinit = function(inst)
    inst:AddTag("kochosei")
    inst:AddTag("masterchef")
    inst:AddTag("puppeteer")
    inst:AddTag("reader")
    inst:AddTag("quagmire_farmhand")
    inst:AddTag("fastpicker")
    inst:AddTag("fastpick")
    inst:AddTag("expertchef")
    inst.MiniMapEntity:SetIcon("kochosei.tex")
end

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
    if tag then
        inst.SoundEmitter:KillSound(tag)
    end
    local name = ""
    if type(talk) == "table" then
        name = talk:getChoice(math.random() * talk:getTotalWeight())
    elseif type(talk) == "string" then
        name = talk
    end
    if name ~= nil then
        inst.SoundEmitter:PlaySound("kochosei_voice/sound/" .. name, tag or "kochoseitalk")
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
        inst.components.sanity.dapperness = inst.components.sanity.dapperness - inst.kochoseiindancing * kochoseidancingsanity / 60
        inst.kochoseiindancing = 0
        inst:RemoveEventCallback("newstate", onnewstate)
    end
end

local function onemote(inst, data)
    local soundname = data.soundoverride or (type(data.anim) == "table" and (type(data.anim[1]) == "table" and data.anim[1][1] or data.anim[1])) or (type(data.anim) == "string" and data.anim) or "emote"
    local sound = emotesoundlist[soundname] or "emote"

    if soundname == "carol" or sound == "dance" or sound == "step" or sound == "robot" or sound == "chicken" then
        inst.components.sanity.dapperness = inst.components.sanity.dapperness - inst.kochoseiindancing * kochoseidancingsanity / 60
        inst.kochoseiindancing = (sound == "dance") and 1 or 1.5
        inst.components.sanity.dapperness = inst.components.sanity.dapperness + inst.kochoseiindancing * kochoseidancingsanity / 60
        if not inst.components.sanityaura then
            inst:AddComponent("sanityaura")
        end
        inst.components.sanityaura.aurafn = CalcSanityAura
        inst:ListenForEvent("newstate", onnewstate)
        if inst.emotefn then
            inst.emotefn:Cancel()
            inst.emotefn = nil
        end
        inst.emotefn = inst:DoTaskInTime(1, emoteplants) -- happytime
        local x, y, z = inst.Transform:GetWorldPosition()
        local players = FindPlayersInRange(x, y, z, 10, true)
        local otherKochoseiInEmoteState = false
        for i, v in ipairs(players) do
            if v ~= inst and v:HasTag("kochosei") and v.sg and v.sg.currentstate.name == "emote" then
                otherKochoseiInEmoteState = true
                break
            end
        end

        if not otherKochoseiInEmoteState then
            KochoseiSound(inst, sound, nil, "kochoseibgm")
        end
    else
        KochoseiSound(inst, sound, nil)
    end

    --  inst:DoTaskInTime(3, emoteplantsfix) --giảm thời gian emote là 3s
end
-- Getkochomap
function IsForestBiomeAtPoint(x, y, z)
    if TheWorld.Map:IsVisualGroundAtPoint(x, y, z) and TheWorld.Map:GetTileAtPoint(x, y, z) == 6 then -- check nó nằm trên phạm vi bản đồ
        -- local node = TheWorld.Map:FindNodeAtPoint(x, y, z) -- câu lệnh tìm node này không hiểu lắm nên cook
        -- return node ~= nil and node.tags ~= nil and table.contains(node.tags, not cherryruins and "cherryarea" or "cherryruinsarea")
        return true
    end
    return false
end

local MAPREVEAL_SCALE = 128
local MAPREVEAL_STEPS = 4

local function GetKochoMap(inst)
    local x, y, z = inst.Transform:GetWorldPosition()
    local stone = TheSim:FindFirstEntityWithTag("kochosei_fuji_tree")
    if stone ~= nil then
        x, y, z = stone.Transform:GetWorldPosition()
    else
        return
    end

    for x2 = x - MAPREVEAL_SCALE, x + MAPREVEAL_SCALE, MAPREVEAL_STEPS do
        for z2 = z - MAPREVEAL_SCALE, z + MAPREVEAL_SCALE, MAPREVEAL_STEPS do
            if IsForestBiomeAtPoint(x2, 0, z2) then
                inst.player_classified.MapExplorer:RevealArea(x2, 0, z2)
            end
        end
    end
end

local function OnNewSpawn(inst)
    inst:DoTaskInTime(1, GetKochoMap)
    inst:DoTaskInTime(3, givefood)
    --inst.components.locomotor:SetExternalSpeedMultiplier(inst, "kochosei_speed_mod", 1.25)
    --Dinh: Bỏ luôn đi
end

--[[---------------------------------Level Miomhm---------------------
local function IsValidVictim(victim)
    return victim ~= nil
               and not (victim:HasTag("prey") or victim:HasTag("veggie") or victim:HasTag("structure") or victim:HasTag("wall")
                   or victim:HasTag("companion")) and victim.components.health ~= nil and victim.components.combat ~= nil
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
--]]

local ghosttalklist = wlist({
    ghosttalk1 = 1,
    ghosttalk2 = 1,
    ghosttalk3 = 1
})
local function ontalk(inst, data)
    if not inst:HasTag("playerghost") then
        KochoseiSound(inst, talklist)
    else
        KochoseiSound(inst, ghosttalklist)
    end
end

-----------------------------------------------------------------------------
local waitMin, waitMax

local function OnEquipCustom(inst, data)
    local checkskin = inst.AnimState:GetBuild()
    if checkskin and checkskin == "kochosei_skin_shinku_full" then
        inst.AnimState:ClearOverrideSymbol("swap_hat")
        inst.AnimState:ClearOverrideSymbol("swap_body")
    end
    if data.item:HasTag("kochosei_hat") then
        if inst:HasTag("scarytoprey") then
            inst:RemoveTag("scarytoprey")
        end
    end
    if data.item:HasTag("fishingrod") then
        local fishingrod = data.item.components.fishingrod
        if fishingrod then
            waitMin, waitMax = data.item.components.fishingrod.minwaittime, data.item.components.fishingrod.maxwaittime
            if waitMin and waitMax then
                fishingrod:SetWaitTimes(waitMin * 0.5, waitMax * 0.5)
            end
        end
    end
end

local function OnUnequipCustom(inst, data)
    if data.item ~= nil then
        if data.item:HasTag("kochosei_hat") then
            if not inst:HasTag("scarytoprey") then
                inst:AddTag("scarytoprey")
            end
        end
        if data.item:HasTag("fishingrod") then
            local fishingrod = data.item.components.fishingrod
            if fishingrod and waitMin and waitMax then
                fishingrod:SetWaitTimes(waitMin, waitMax)
            end
        end
    end
end

local function in_fire(inst)
    if inst.sg:HasStateTag("knockout") then
        local x, y, z = inst.Transform:GetWorldPosition()
        local ents = TheSim:FindEntities(x, y, z, 10, {
            "fire"
        })
        for i, v in ipairs(ents) do
            if v.components.burnable ~= nil and v.components.burnable:IsBurning() then
                if TheWorld.state.isnight then
                    inst.components.sanity:DoDelta(5, false)
                end
            end
        end
    end
end

local function OnHitOther(inst, data)
    local item = inst.components.combat:GetWeapon()
    local target = data.target
    if item ~= nil and item:HasTag("kochoseiweapon") and target ~= nil and target.components.health and target.components.combat then
        if target:HasTag("epic") then
            inst.components.sttptmau:SatthuongWP(target, TUNING.MIOHM_SAT_THUONG_PT_MAU * 2, false, false, TUNING.MIOHM_SAT_THUONG_PT_MAU_HOAT_DONG)
        else
            inst.components.sttptmau:SatthuongWP(target, TUNING.MIOHM_SAT_THUONG_PT_MAU * 5, false, false, 1000)
        end
    end
end

local function phandamge(inst, data)
    if data and data.afflicter and data.afflicter:IsValid() and data.afflicter.components.health and not data.afflicter.components.health:IsDead() then
        local killer = data.afflicter.components.follower and data.afflicter.components.follower:GetLeader() or data.afflicter:HasTag("player") and data.afflicter or nil
        if killer and killer:HasTag("player") and killer ~= inst then
            killer.components.health:DoDelta(3 * data.amount, nil, nil, true, killer, true)
        end
    end
end

local function chungtakphaidatungladongdoisao(inst, data)
    if data and data.afflicter and data.afflicter:IsValid() and data.afflicter.components.health and not data.afflicter.components.health:IsDead() then
        local killer = data.afflicter.components.follower and data.afflicter.components.follower:GetLeader() or data.afflicter:HasTag("player") and data.afflicter or nil
        if killer and killer:HasTag("player") and killer ~= inst then
            killer.components.health:Kill()
        end
    end
end

local function lai_nhai(inst)
    local durability = tonumber(TUNING.KOCHO_HAT1_DURABILITY)
    local laydoben
    -- Check if durability is a valid number
    if durability then
        laydoben = durability + (TUNING.KOCHOSEI_CHECKWIFI * 2)
    else
        -- Handle the case where durability is not a valid number
        laydoben = "vô hạn" -- or any other fallback value you'd prefer
    end
    
    if inst.components.talker then
       inst.components.talker:Say("Điểm waifu hiện có: " .. TUNING.KOCHOSEI_CHECKWIFI .. "\n Búa max damage: " .. TUNING.KOCHOSEI_MAX_LEVEL + (TUNING.KOCHOSEI_CHECKWIFI * 2) .. "\n Nơ kháng " .. TUNING.KOCHO_HAT1_ABSORPTION*100 .. "% damage" .. " có " .. laydoben ..  " điểm độ bền", 10)
    end
    if inst.lai_nhai_ve_stats ~= nil then
        inst.lai_nhai_ve_stats:Cancel()
        inst.lai_nhai_ve_stats = nil
    end
end

local master_postinit = function(inst)
    inst.starting_inventory = start_inv[TheNet:GetServerGameMode()] or start_inv.default
    inst.OnNewSpawn = OnNewSpawn
    inst.soundsname = "kochosei"
    inst.kochoseiindancing = 0
    inst.components.talker.ontalkfn = ontalk

    --inst.lai_nhai_ve_stats = inst:DoTaskInTime(5, lai_nhai)

    inst:AddComponent("locomotor")
    inst.components.locomotor:SetExternalSpeedMultiplier(inst, "kochosei_speed_mod", 1.25)

    inst:AddComponent("reader")
    inst.components.health:SetMaxHealth(TUNING.KOCHOSEI_HEALTH)
    inst.components.hunger:SetMax(TUNING.KOCHOSEI_HUNGER)
    inst.components.sanity:SetMax(TUNING.KOCHOSEI_SANITY)

    inst.components.combat.externaldamagemultipliers:SetModifier(inst, TUNING.KOCHOSEI_DAMAGE, "kocho_damage_config") -- Damage multiplier (optional)

    inst.components.sanity.dapperness = -5 / 60

    inst.components.petleash:SetMaxPets(TUNING.KOCHOSEI_SLAVE_MAX_FIX)

    inst:DoPeriodicTask(1, OnTaskTick)
    inst:DoPeriodicTask(5, in_fire)

    inst.components.hunger.hungerrate = TUNING.WILSON_HUNGER_RATE
    inst.components.eater.PrefersToEat = anvaochetnguoiay
    inst.customidleanim = "idle_wilson"
    inst.OnLoad = onload

    inst:AddComponent("locomotor")
    inst.components.locomotor:SetExternalSpeedMultiplier(inst, "kochosei_speed_mod", 1.25)

    inst:AddComponent("kochoseimain") -- Giết ếch, giết df, giết bướm, nó lỗi thì xóa dòng này

    inst:AddComponent("sttptmau") -- Sát thương theo pt máu kiểm tra hàm OnHitOther

    inst:AddComponent("cuocdoiquabatcongdi") -- Wifi không nên thế
    inst.components.cuocdoiquabatcongdi:Character()

    inst:ListenForEvent("emote", onemote)
    inst:ListenForEvent("equip", OnEquipCustom)
    inst:ListenForEvent("unequip", OnUnequipCustom)
    inst:ListenForEvent("ms_respawnedfromghost", onbecamehuman)
    inst:ListenForEvent("death", onbecameghost)
    inst:ListenForEvent("death", chungtakphaidatungladongdoisao)
    inst:ListenForEvent("healthdelta", phandamge)
    inst:ListenForEvent("picksomething", onpick)
    inst:ListenForEvent("onhitother", OnHitOther)

    inst.wlist = wlist
    ---------------------------Kén ăn------------------
    local inedibles = {}
    local old_CanEat = inst.components.eater.CanEat
    inst.components.eater.CanEat = function(self, food_inst)
        for i, v in ipairs(inedibles) do
            if food_inst.prefab == v then
                return false
            end
        end
        return old_CanEat(self, food_inst)
    end
end
-- Không dùng khi có modded được phát hiện--
if TUNING.KOCHOSEI_CHECKMOD ~= 1 and Kochoseiapi.MakeCharacterSkin ~= nil then -- Kiểm tra để chắc chắn sau này API có bị lỗi cũng không kéo theo thứ gì đó
    Kochoseiapi.MakeCharacterSkin("kochosei", "kochosei_none", {
        name = "Kochosei",
        des = "o((>ω< ))o",
        quotes = "<3 Hora hora",
        rarity = "Character",
        skins = {
            normal_skin = "kochosei",
            ghost_skin = "ghost_kochosei_build"
        },
        skin_tags = {
            "BASE",
            "kochosei",
            "CHARACTER"
        },
        build_name_override = "kochosei"
    })

    Kochoseiapi.MakeCharacterSkin("kochosei", "kochosei_snowmiku_skin1", {
        name = "Kochosei cosplay Miku",
        des = "o((>ω< ))o",
        quotes = "Miku chan Ohayo!",
        rarity = "Elegant",
        skins = {
            normal_skin = "kochosei_snowmiku_skin1",
            ghost_skin = "ghost_kochosei_build"
        },
        skin_tags = {
            "BASE",
            "kochosei",
            "CHARACTER",
            "ICE"
        }
    })
    Kochoseiapi.MakeCharacterSkin("kochosei", "kochosei_skin_shinku_notfull", {
        name = "Kochosei cosplay Shinku",
        des = "o((>ω< ))o",
        quotes = "Shinku chan, Xinh xinh! o((>ω< ))o", -- Shinku chan WT????? Cái đồng bằng gì thế?
        rarity = "Elegant",
        skins = {
            normal_skin = "kochosei_skin_shinku_notfull",
            ghost_skin = "ghost_kochosei_build"
        },
        skin_tags = {
            "BASE",
            "kochosei",
            "CHARACTER",
            "ICE"
        }
    })
    Kochoseiapi.MakeCharacterSkin("kochosei", "kochosei_skin_shinku_full", {
        name = "Kochosei cosplay Shinku",
        des = "o((>ω< ))o",
        quotes = "Shinku chan, Xinh xinh! o((>ω< ))o",
        rarity = "Elegant",
        skins = {
            normal_skin = "kochosei_skin_shinku_full",
            ghost_skin = "ghost_kochosei_build"
        },
        skin_tags = {
            "BASE",
            "kochosei",
            "CHARACTER",
            "ICE"
        }
    })
end
-- Không dùng khi có modded được phát hiện--

return MakePlayerCharacter("kochosei", prefabs, assets, common_postinit, master_postinit)
