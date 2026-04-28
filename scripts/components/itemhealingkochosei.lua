local Itemhealingkochosei = Class(function(self, inst)
    self.inst = inst
end)

-- ============================================================
-- SpawnFX: public để action bên accmntion.lua gọi được
-- ============================================================
function Itemhealingkochosei:SpawnFX(parent)
    if parent == nil or not parent:IsValid() then return end

    local fx = SpawnPrefab("kochosei_heal")
    if fx then
        fx.entity:SetParent(parent.entity)
        fx.Transform:SetPosition(0, 0, 0)
        fx.AnimState:PlayAnimation("heal_doc")
        fx:ListenForEvent("animover", fx.Remove)
    end
end

-- ============================================================
-- OnHeal: giữ lại phòng khi cần dùng event riêng
-- ============================================================
-- ============================================================
-- KHÔNG còn hook ACTIONS.GIVETOPLAYER ở đây nữa.
-- Toàn bộ logic heal khi đưa cho người khác đã chuyển sang
-- action KOCHOSEI_GIVE_HEAL trong accmntion.lua
-- ============================================================

return Itemhealingkochosei
