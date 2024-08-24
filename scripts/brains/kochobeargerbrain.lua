require("behaviours/chaseandattack")
require("behaviours/wander")
require("behaviours/doaction")
require("behaviours/follow")
local BrainCommon = require("brains/braincommon")
local MIN_FOLLOW_DIST = 0
local TARGET_FOLLOW_DIST = 20
local MAX_FOLLOW_DIST = 20
local DIG_TAGS = { "DIG_workable", "tree" }
local DIG_CANT_TAGS = { "carnivalgame_part", "event_trigger", "waxedplant" }
local FARM_DEBRIS_TAGS = {"farm_debris"}


local function GetLeader(inst)
	return inst.components.follower.leader
end

local function GetLeaderPos(inst)
    return inst.components.follower.leader:GetPosition()
end

local KochoBeargerBrain = Class(Brain, function(self, inst)
	Brain._ctor(self, inst)
end)

local function findtillpos(inst)
    local tiles = {}
    
    if not inst.digtile then

        -- collect garden tiles in a 9x9 grid
        local RANGE = 4
        local pos = Vector3(inst.Transform:GetWorldPosition())

        for x=-RANGE,RANGE,1 do
            for z=-RANGE,RANGE,1 do
                local tx = pos.x + (x*4)
                local tz = pos.z + (z*4)
                local tile = TheWorld.Map:GetTileAtPoint(tx, 0, tz)
                if tile == WORLD_TILES.FARMING_SOIL then
                    table.insert(tiles,{tx,tz})
                end
            end
        end
    else
        table.insert(tiles,inst.digtile)
    end

    -- find diggable places in those tiles.
    local digsites = {}
    for i,tile in ipairs(tiles)do
        digsites = collectdigsites(inst,digsites, tile)
    end

    if #digsites > 0 then
        local pos = digsites[math.random(1,#digsites)].pos
        inst.digtile = digsites[math.random(1,#digsites)].tile
        return pos
    end

    inst.digtile = nil
end

local function findTillTarget(inst,finddist)
    return findtillpos(inst)
end
local function findDigTarget(inst,finddist)
    return FindEntity(inst, finddist, nil, FARM_DEBRIS_TAGS)
end

local function TillAction(inst, leaderdist, finddist)
    local pos = findtillpos(inst)
    local tool = inst.components.inventory ~= nil and inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS) or nil
    if pos and tool then

        pos = Vector3(pos.x -0.02 + math.random()*0.04,0,pos.z -0.02 + math.random()*0.04)

        local marker = SpawnPrefab("merm_soil_marker")
        marker.Transform:SetPosition(pos.x,pos.y,pos.z)
        return BufferedAction(inst, nil, ACTIONS.TILL, tool, pos )
    end
end

local function DigAction(inst, leaderdist, finddist)
    local target = FindEntity(inst, finddist, nil, FARM_DEBRIS_TAGS)
    if target == nil and inst.components.follower.leader ~= nil then
        target = FindEntity(inst.components.follower.leader, finddist, nil, FARM_DEBRIS_TAGS)
    end

    if target ~= nil then
        if inst.stump_target ~= nil then
            target = inst.stump_target
            inst.stump_target = nil
        end

        return BufferedAction(inst, target, ACTIONS.DIG)
    end
end

   ----

local dig_clump_starter = function(inst,finddist)
    local target = findDigTarget(inst,finddist)

    if not target then
        target = findTillTarget(inst,finddist)
    end

    local leaderisdigging = inst.components.follower.leader ~= nil and
                    inst.components.follower.leader.sg ~= nil and
                    inst.components.follower.leader.sg:HasStateTag("digging")

    local leaderistilling = inst.components.follower.leader ~= nil and
                    inst.components.follower.leader.sg ~= nil and
                    inst.components.follower.leader.sg:HasStateTag("tilling")

    return (leaderisdigging or leaderistilling) and (inst.stump_target or target) or nil
end
local dig_clump_keepgoing = function(inst, leaderdist, finddist)
    return inst.stump_target ~= nil
        or (inst.components.follower.leader ~= nil and
            inst:IsNear(inst.components.follower.leader, leaderdist))
end
local dig_clump_finder = function(inst, leaderdist, finddist)
    local action = DigAction(inst, leaderdist, finddist)
    if not action then
        action = TillAction(inst, leaderdist, finddist)
    end
    return action
end

   ----

local function dig_stump_starter(inst,finddist)
    local target = FindEntity(inst, finddist, nil, DIG_TAGS, DIG_CANT_TAGS)
    return inst.stump_target or target or nil
end

local function dig_stump_keepgoing(inst, leaderdist, finddist)
    return inst.stump_target ~= nil
        or (inst.components.follower.leader ~= nil and
            inst:IsNear(inst.components.follower.leader, leaderdist))
end

local function dig_stump_finder(inst, leaderdist, finddist)
    local target = FindEntity(inst, finddist, nil, DIG_TAGS, DIG_CANT_TAGS)
    if target == nil and inst.components.follower.leader ~= nil then
        target = FindEntity(inst.components.follower.leader, finddist, nil, DIG_TAGS, DIG_CANT_TAGS)
    end
    if target ~= nil then
        if inst.stump_target ~= nil then
            target = inst.stump_target
            inst.stump_target = nil
        end

        return BufferedAction(inst, target, ACTIONS.DIG)
    end
end
local function HasDigTool(inst)
    return true
end

function KochoBeargerBrain:OnStart()
    local root = PriorityNode({
        ChaseAndAttack(self.inst),
        Follow(self.inst, GetLeader, MIN_FOLLOW_DIST, TARGET_FOLLOW_DIST, MAX_FOLLOW_DIST),
        BrainCommon.NodeAssistLeaderDoAction(self, {
            action = "CHOP", -- Required.
        }),
        WhileNode(HasDigTool, "dig stump with tool",
            BrainCommon.NodeAssistLeaderDoAction(self, {
                action = "CHOP", -- Required.
                starter = dig_stump_starter,
                keepgoing = dig_stump_keepgoing,
                finder = dig_stump_finder,
            })
        ),
        BrainCommon.NodeAssistLeaderDoAction(self, {
            action = "MINE", -- Required.
        }),
        WhileNode(function()
            return GetLeader(self.inst) ~= nil
        end, "Has Leader", 
            Wander(self.inst, GetLeaderPos, MAX_FOLLOW_DIST)
        ),
    }, 0.25)

    self.bt = BT(self.inst, root)
end

return KochoBeargerBrain
