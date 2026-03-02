require("stategraphs/commonstates")

local actionhandlers = {}

local events = {}
local function DetachFX(fx)
    fx.Transform:SetPosition(fx.Transform:GetWorldPosition())
    fx.entity:SetParent(nil)
end
local function DoDespawnFX(inst)
    -- shadow_despawn is in the air => detaches from sinking boats
    -- shadow_glob_fx is on ground => dies with sinking boats
    local x, y, z = inst.Transform:GetWorldPosition()
    local fx1 = SpawnPrefab("shadow_despawn")
    local fx2 = SpawnPrefab("shadow_glob_fx")
    fx2.AnimState:SetScale(math.random() < 0.5 and -1.3 or 1.3, 1.3, 1.3)
    local platform = inst:GetCurrentPlatform()
    if platform ~= nil then
        fx1.entity:SetParent(platform.entity)
        fx2.entity:SetParent(platform.entity)
        fx1:ListenForEvent("onremove", function() DetachFX(fx1) end, platform)
        x, y, z = platform.entity:WorldToLocalSpace(x, y, z)
    end
    fx1.Transform:SetPosition(x, y, z)
    fx2.Transform:SetPosition(x, y, z)
end
local states = {
 State {
        name = "idle",
        tags = {"idle", "canrotate"},

        onenter = function(inst)
            if not inst.isdead then
                inst.AnimState:PlayAnimation("acting_idle1", true)
            end
        end
    }, State {
        name = "refuseeat",
        tags = {"busy", "pausepredict", "keep_pocket_rummage"},

        onenter = function(inst)
            inst.AnimState:PlayAnimation("refuseeat")
            inst.sg:SetTimeout(60 * FRAMES)
        end,
        events = {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("idle")
                end
            end)
        }
    }, State {
        name = "deform_pst",
        tags = {"busy", "nopredict", "transform", "nomorph", "nointerrupt"},

        onenter = function(inst)
            inst.AnimState:PlayAnimation("deform_pst")
        end,

        timeline = {},

        events = {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("idle")
                end
            end)
        }
    }, State {
        name = "cointoss",

        onenter = function(inst)
            inst.AnimState:SetDeltaTimeMultiplier(2)
            inst.AnimState:PlayAnimation("emoteXL_kiss")

        end,

        events = {
            EventHandler("animover", function(inst)
                if inst.AnimState:AnimDone() then
                    inst.sg:GoToState("idle")
                end
            end)
        },
        onexit = function(inst) inst.AnimState:SetDeltaTimeMultiplier(1) end
    }, State {
        name = "talk",
        tags = {"idle", "talking"},

        onenter = function(inst, noanim)
            if inst.AnimState:AnimDone() then

                inst.AnimState:PlayAnimation("dial_loop", true)
            end
            inst.sg:SetTimeout(1.5 + math.random() * .5)
        end,

        ontimeout = function(inst) inst.sg:GoToState("idle") end

    }
}

return StateGraph("kochosei_statue", states, events, "deform_pst")
