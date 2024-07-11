local function IsValidVictim(victim)
    return victim ~= nil
               and not (victim:HasTag("prey") or victim:HasTag("veggie") or victim:HasTag("structure") or victim:HasTag("wall")
                   or victim:HasTag("companion")) and victim.components.health ~= nil and victim.components.combat ~= nil
end

function onkilled(inst, data)
    local victim = data and data.victim
    if victim then
        local lootdropper = victim.components.lootdropper

        if victim:HasTag("butterfly") then
            inst.components.sanity:DoDelta(-100, false)
            inst.components.health:DoDelta(-100, false, "Punishment from God!")
            inst.components.talker:Say("What are you doingggggg!!!")
            TheWorld:PushEvent("ms_sendlightningstrike", inst:GetPosition())
            TheNet:Announce("A punishment from God have been release to " .. inst:GetDisplayName().. " because of the worst guilty a Kochosei can make")
        elseif victim:HasTag("frog") then
            local chance = math.random(1, 100)
            if chance == 1 then
                TheWorld:PushEvent("ms_sendlightningstrike", inst:GetPosition())
                TheNet:Announce("Legend has it that onii-chan " .. inst:GetDisplayName() .. " was very lucky to get the jackpot from the God.")
            end
            lootdropper:AddChanceLoot("krampus", .1)
            lootdropper:AddChanceLoot("leif", .01)
		    lootdropper:AddChanceLoot("ruinshat", .01)	 --Psyche
            lootdropper:AddChanceLoot("froglegs", .5)
        elseif victim:HasTag("dragonfly") then
            lootdropper:AddChanceLoot("dragon_scales", 1)
            lootdropper:AddChanceLoot("dragon_scales", .5)
            lootdropper:AddChanceLoot("dragonflyfurnace_blueprint", .5)
            lootdropper:AddChanceLoot("chesspiece_dragonfly_sketch", .5)
            lootdropper:AddChanceLoot("chesspiece_dragonfly_sketch", 1)
            lootdropper:AddChanceLoot("lavae_egg", 1)

            lootdropper:AddChanceLoot("meat", 1)
            lootdropper:AddChanceLoot("meat", 1)
            lootdropper:AddChanceLoot("meat", 1)
            lootdropper:AddChanceLoot("meat", .5)
            lootdropper:AddChanceLoot("meat", .5)
            lootdropper:AddChanceLoot("meat", .5)
            lootdropper:AddChanceLoot("meat", .5)

            lootdropper:AddChanceLoot("goldnugget", 1)
            lootdropper:AddChanceLoot("goldnugget", 1)
            lootdropper:AddChanceLoot("goldnugget", 1)
            lootdropper:AddChanceLoot("goldnugget", 0.5)
            lootdropper:AddChanceLoot("goldnugget", 0.5)
            lootdropper:AddChanceLoot("goldnugget", 0.5)

            lootdropper:AddChanceLoot("bluegem", 1)
            lootdropper:AddChanceLoot("bluegem", 1)
            lootdropper:AddChanceLoot("bluegem", .5)

            lootdropper:AddChanceLoot("redgem", 1)
            lootdropper:AddChanceLoot("redgem", 1)
            lootdropper:AddChanceLoot("redgem", .5)

            lootdropper:AddChanceLoot("purplegem", 1)
            lootdropper:AddChanceLoot("purplegem", .5)

            lootdropper:AddChanceLoot("orangegem", 1)
            lootdropper:AddChanceLoot("orangegem", .5)

            lootdropper:AddChanceLoot("yellowgem", 1)
            lootdropper:AddChanceLoot("yellowgem", .5)

            lootdropper:AddChanceLoot("greengem", 1)
            lootdropper:AddChanceLoot("greengem", .5)
        end

        if IsValidVictim(victim) then
            local weapon = inst.components.combat:GetWeapon()
            if weapon and weapon:HasTag("miohm") then
                weapon.levelmiohm = weapon.levelmiohm + TUNING.KOCHOSEI_PER_KILL
                weapon:applyupgrades()
            end
        end
    end
end

local Kochoseimain = Class(function(self, inst)
    self.inst = inst
    self.inst:ListenForEvent("killed", onkilled)
end)

return Kochoseimain
