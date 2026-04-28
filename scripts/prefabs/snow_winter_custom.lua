local TEXTURE = "fx/wintersnow_cane.tex"
local SHADER = "shaders/vfx_particle.ksh"

local COLOUR_ENVELOPE_NAME = "snowcolourenvelope"
local WINTER_SCALE_ENVELOPE_NAME = "wintersnowscaleenvelope"

local assets =
{
    Asset("IMAGE", TEXTURE),
    Asset("SHADER", SHADER),
}

local function IntColour(r, g, b, a)
    return { r / 255, g / 255, b / 255, a / 255 }
end

local function InitEnvelope()
    EnvelopeManager:AddColourEnvelope(
        COLOUR_ENVELOPE_NAME,
        {
            { 0,   IntColour(255, 255, 255, 200) },
            { 0.9, IntColour(255, 255, 255, 200) },
            { 1,   IntColour(255, 255, 255, 0)   },
        }
    )

    local max_scale = .3    -- Winter's Feast scale, nhỏ hơn snow thường (1.0)
    EnvelopeManager:AddVector2Envelope(
        WINTER_SCALE_ENVELOPE_NAME,
        {
            { 0, { max_scale, max_scale } },
            { 1, { max_scale, max_scale } },
        }
    )
end

local MAX_LIFETIME = 7.5
local MIN_LIFETIME = 4.5

local function fn()
    local inst = CreateEntity()

    inst:AddTag("FX")
    inst.entity:SetCanSleep(false)
    inst.persists = false
    inst.entity:AddTransform()

    if InitEnvelope ~= nil then
        InitEnvelope()
        InitEnvelope = nil
    end

    local effect = inst.entity:AddVFXEffect()
    effect:InitEmitters(1)

    local tick_time = TheSim:GetTickTime()
    inst.particles_per_tick = 0
    inst.num_particles_to_emit = 0

    local bx, by, bz = 0, 20, 0
    local emitter_shape = CreateBoxEmitter(bx, by, bz, bx + 20, by, bz + 20)

    local function emit_fn()
        local lifetime = MIN_LIFETIME + (MAX_LIFETIME - MIN_LIFETIME) * UnitRand()
        local px, py, pz = emitter_shape()
        local angle = math.random() * 360
        local uv_offset = math.random(0, 7) * .125
        local ang_vel = UnitRand() * 4.0
        effect:AddRotatingParticleUV(
            0,
            lifetime,
            px, py, pz,
            0, 0, 0,
            angle, ang_vel,
            uv_offset, 0
        )
    end

    local init_effect = true
    local function update_fn()
        if init_effect then
            init_effect = nil
            -- Hardcode Winter's Feast style, không check event
            effect:SetRenderResources(0, TEXTURE, SHADER)
            effect:SetScaleEnvelope(0, WINTER_SCALE_ENVELOPE_NAME)
            effect:SetUVFrameSize(0, .125, 1)
            effect:SetRotationStatus(0, true)
            effect:SetAcceleration(0, -1, -9.80, 1)
            effect:SetDragCoefficient(0, .85)
            effect:SetMaxNumParticles(0, 4800)
            effect:SetMaxLifetime(0, MAX_LIFETIME)
            effect:SetColourEnvelope(0, COLOUR_ENVELOPE_NAME)
            effect:SetBlendMode(0, BLENDMODE.Premultiplied)
            effect:SetSortOrder(0, 3)
            effect:EnableDepthTest(0, true)
        end

        -- particle_mult = 2 như Winter's Feast gốc
        while inst.num_particles_to_emit > 1 do
            emit_fn()
            inst.num_particles_to_emit = inst.num_particles_to_emit - 1
        end
        inst.num_particles_to_emit = inst.num_particles_to_emit + inst.particles_per_tick * 2
    end

    EmitterManager:AddEmitter(inst, nil, update_fn)

    function inst:PostInit()
        local dt = 1 / 30
        local t = MAX_LIFETIME
        while t > 0 do
            t = t - dt
            update_fn()
            effect:FastForward(0, dt)
        end
    end

    return inst
end

return Prefab("kochosei_snow_winter_custom", fn, assets)