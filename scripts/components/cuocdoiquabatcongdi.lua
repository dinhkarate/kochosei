local Cuocdoiquabatcongdi = Class(function(self, inst)
    self.inst = inst
end)
local hat = TUNING.KOCHOSEI_CHECKWIFI * 2 or 0
local kochoseidef = TUNING.KOCHOSEI_CHECKWIFI / 1000 or 0

function Cuocdoiquabatcongdi:Hatitem()
    if self.inst:HasTag("kochoseihat") then
        if self.inst.components.armor then
            self.inst.components.armor:InitCondition(TUNING.KOCHO_HAT1_DURABILITY + hat, TUNING.KOCHO_HAT1_ABSORPTION)
        end
    end
end

function Cuocdoiquabatcongdi:Character()
    if self.inst:HasTag("kochosei") then
        self.inst.components.health.externalabsorbmodifiers:SetModifier(self.inst,
            math.max(kochoseidef, TUNING.KOCHOSEI_ARMOR) or 0, "kocho_def_config")
    end
end

function Cuocdoiquabatcongdi:Vukhi()
    local cangbang = math.max(1.2, (TUNING.KOCHOSEI_CHECKWIFI / 100))
    if self.inst:HasTag("miohm") then
        self.inst.components.tool:SetAction(ACTIONS.MINE, cangbang)
        self.inst.components.tool:SetAction(ACTIONS.HAMMER, cangbang)
    end
    if self.inst:HasTag("purplesword") then self.inst.components.tool:SetAction(ACTIONS.CHOP, cangbang) end
end

return Cuocdoiquabatcongdi
