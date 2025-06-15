local Spawnclonekochosei = Class(function(self, inst)
	self.inst = inst
end)

function Spawnclonekochosei:Spawclone(inst, target, pos, prefabclone)
    local caster = self.inst.components.inventoryitem.owner
    if not caster then return end

    local sanity = caster.components.sanity
    local petleash = caster.components.petleash
    local talker = caster.components.talker

    if not caster:HasTag("kochosei") then
        talker:Say("Maybe Kochosei knows how to use this")
        return
    end

    if petleash and petleash:IsFull() then
        talker:Say("Toooooooooo many clone")
        return
    end

    if sanity.current <= TUNING.KOCHOSEI_SLAVE_COST then
        talker:Say("Not enough sanity")
        return
    end
    sanity:DoDelta(-TUNING.KOCHOSEI_SLAVE_COST)

    if prefabclone == "dinhcutenhathematroi" then
        local stalker = petleash:SpawnPetAt(pos.x, 0, pos.z, prefabclone)
        if stalker then
            stalker.Transform:SetPosition(pos.x, 0, pos.z)
            stalker.Transform:SetRotation(inst.Transform:GetRotation())
            stalker._playerlink = caster
            stalker.sg:GoToState("resurrect")
        end
    else
        petleash:SpawnPetAt(pos.x, 0, pos.z, prefabclone)
    end
end

return Spawnclonekochosei
