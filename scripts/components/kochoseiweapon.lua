local Kochoseiweapon = Class(function(self, inst, damagemiohm)
    self.inst = inst
    self.damagemiohm = damagemiohm or TUNING.MIOHM_DAMAGE
    self.ownmiohm = false
end)

function Kochoseiweapon:OnSave()
    print("SAVE KOCHOSEI WEAPON")
    print(self.damagemiohm)
    return { damagemiohm = self.damagemiohm, ownmiohm = self.ownmiohm }
end

function Kochoseiweapon:OnLoad(data)
    if data and data.damagemiohm and data.ownmiohm then
        self.damagemiohm = data.damagemiohm
        self.ownmiohm = data.ownmiohm
    end
end

return Kochoseiweapon
