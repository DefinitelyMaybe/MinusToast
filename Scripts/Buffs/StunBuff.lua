include("Scripts/Buffs/DamageDebuff.lua")

-------------------------------------------------------------------------------
if StunBuff == nil then
	StunBuff = Buff.Subclass("StunBuff")
	EternusEngine.BuffManager:RegisterBuff("StunBuff", StunBuff)
end

StunBuff.Name = "StunBuff"
StunBuff.Emitter = "Magic Electrified Seed Emitter"

StunBuff.StatToModify = "SpeedMultiplier"
StunBuff.DefaultModification = 1.0
StunBuff.DefaultModificationAction = StatModifier.EStatModAction.eMultiply

-------------------------------------------------------------------------------
function StunBuff:OnStart()
	StunBuff.__super.OnStart(self)
	
	NKWarn("StunBuff Applied")
	
	self.m_emitter = Eternus.GameObjectSystem:NKCreateGameObject(self.Emitter, true)
	self.m_emitter:NKSetShouldSave(false)
	self.m_emitter:NKSetPosition(self.m_object:NKGetWorldPosition())
	self.m_object:NKAddChildObject(self.m_emitter)
	self.m_emitter:NKPlaceInWorld(true, false)
	self.m_object:NKActivateEmitterByName(self.Emitter)
	
	--Would like to stop running animations
	--Stop any movement
	--Disable camera movement
	--Apply shocks :P
	--Better Emitter
end

-------------------------------------------------------------------------------
function StunBuff:OnStop()
	StunBuff.__super.OnStop(self)
	if self.Emitter then
		self.m_object:NKDeactivateEmitterByName(self.Emitter)
		self.m_object:NKRemoveChildObject(self.m_emitter)
		self.m_emitter:NKDeleteMe()
	end
	
	if self.m_destroyedSignal and self.__removeCallback then
		self.m_destroyedSignal:Remove(self.__removeCallback)
	end
end

-------------------------------------------------------------------------------
function StunBuff:Constructor( args )
	-- Mixin StatModifier
	if (args.value ~= nil and Eternus.IsServer) then
		-- Mix in StatModifier and pass args along.
		self:Mixin(StatModifier, args)
		-- Initialize the StatModifier
		self:InitModifier(args)
	end
end
-------------------------------------------------------------------------------
return StunBuff