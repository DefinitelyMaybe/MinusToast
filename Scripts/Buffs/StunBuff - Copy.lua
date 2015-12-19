include("Scripts/Buffs/Buff.lua")

-------------------------------------------------------------------------------
if StunBuff == nil then
	StunBuff = Buff.Subclass("StunBuff")
	EternusEngine.BuffManager:RegisterBuff("StunBuff", StunBuff)
end

StunBuff.Name = "StunBuff"
StunBuff.StatToModify = "SpeedMultiplier"
StunBuff.DefaultModification = 1.0
StunBuff.DefaultModificationAction = StatModifier.EStatModAction.eMultiply
StunBuff.Emitter = "Magic FireBall Burnt Seed Emitter"

-------------------------------------------------------------------------------
function StunBuff:Constructor( args )
	if (args.value ~= nil and Eternus.IsServer) then
		-- Mix in a stat modifier and pass args along.
		self:Mixin(StatModifier, args)
		self:InitModifier(args)
	end
	
	if (args.duration == nil) then
		self.m_duration = 5.0
	end
end

-------------------------------------------------------------------------------
function StunBuff:Update( dt, finished )
	StunBuff.__super.Update(self, dt, finished)
	if not Eternus.IsServer then
		return
	end
	
	if (self.m_object:IsDead()) then
		finished.val = true
	end
end

function StunBuff:IsHarmful()
	if self.m_modAction == StatModifier.EStatModAction.eMultiply and self.m_modValue < 1 then
		return true
	end
	if self.m_modAction == StatModifier.EStatModAction.eAdd and self.m_modValue < 0 then
		return true
	end
	return StunBuff.__super.IsHarmful(self)
end

return StunBuff