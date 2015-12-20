include("Scripts/Buffs/FrozenDebuff.lua")

-------------------------------------------------------------------------------
if StunDebuff == nil then
	StunDebuff = FrozenDebuff.Subclass("StunDebuff")
	EternusEngine.BuffManager:RegisterBuff("StunDebuff", StunDebuff)
end

StunDebuff.Name = "StunDebuff"
StunDebuff.Emitter = "Lightning Bolts Green Emitter"

-------------------------------------------------------------------------------
function StunDebuff:Construcor()
end

-------------------------------------------------------------------------------
return StunDebuff