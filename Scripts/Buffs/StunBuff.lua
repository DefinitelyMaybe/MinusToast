include("Scripts/Buffs/DamageDebuff.lua")

-------------------------------------------------------------------------------
if StunBuff == nil then
	StunBuff = Buff.Subclass("StunBuff")
	EternusEngine.BuffManager:RegisterBuff("StunBuff", StunBuff)
end

StunBuff.Name = "StunBuff"
--StunBuff.Emitter = "Magic Electrified Seed Emitter"
StunBuff.Emitter = "LightningBolt01 Emitter"
StunBuff.EmitterNames = {
	"LightningBolt01 Emitter",
	"LightningBolt02 Emitter",
	"LightningBolt03 Emitter",
	"LightningBolt04 Emitter",
	"LightningBolt05 Emitter",
	"LightningBolt06 Emitter"
}

StunBuff.StatToModify = "SpeedMultiplier"
StunBuff.DefaultModification = 1.0
StunBuff.DefaultModificationAction = StatModifier.EStatModAction.eMultiply

-------------------------------------------------------------------------------
function StunBuff:OnStart()
	StunBuff.__super.OnStart(self)
	
	NKWarn("StunBuff Applied")
	
	self.m_emitter = {}
	
	if self.EmitterNames then
		for i = 1, 6 do
			self.m_emitter[i] = Eternus.GameObjectSystem:NKCreateGameObject(self.EmitterNames[i], true)
			self.m_emitter[i]:NKSetShouldSave(false)
			self.m_emitter[i]:NKSetPosition(self.m_object:NKGetWorldPosition() + vec3.new(0,1.75,0))
			self.m_object:NKAddChildObject(self.m_emitter[i])
			self.m_emitter[i]:NKPlaceInWorld(true, false)
			self.m_object:NKActivateEmitterByName(self.EmitterNames[i])
		end
	end
	
	--Would like to stop running animations
	--Stop any movement
	--Disable camera movement
	--Apply shocks :P
	--Better Emitter
end

-------------------------------------------------------------------------------
function StunBuff:OnStop()
	StunBuff.__super.OnStop(self)
	
	--self.emitters = {}
	
	if self.EmitterNames then
		for i = 1, 6 do
			self.m_object:NKDeactivateEmitterByName(self.EmitterNames[i])
			self.m_object:NKRemoveChildObject(self.m_emitter[i])
			self.m_emitter[i]:NKDeleteMe()
		end
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