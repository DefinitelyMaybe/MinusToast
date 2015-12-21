include("Scripts/Objects/Gauntlet.lua")

ElectroGauntlet = Gauntlet.Subclass("ElectroGauntlet")

ElectroGauntlet.Emitters = {
	"Magic Electro Emitter",
	"FireBall Attractor",
	"Magic Electro Trail Emitter"
}

ElectroGauntlet.RegisterScriptEvent("ClientEvent_Channeling",
	{
		player = "gameobject",
		charges = "int"
	}
)

-------------------------------------------------------------------------------
function ElectroGauntlet:Constructor(args)
	self.m_id = 1
	self.m_charging = false
	self.m_emittersRunning = false
	self.m_emitters = {}
	self.m_effect = nil
end

-------------------------------------------------------------------------------
function ElectroGauntlet:GearPrimaryAction(args)
	if ElectricGauntlet_DEBUGGING then
		NKWarn(">> [ElectroGauntlet] ElectroGauntlet:GearPrimaryAction() " .. (self.m_player and "has Player" or "Missing Player") )
	end

	local player = args.player
	
	-- Check stance
	if player:InCastingStance() and (not self.m_persistent or not self.m_currentProjectile) then
	
		local effectArgs = NKParseFile( "Data/Effects/Projectiles/Electro.txt")
		
		local projectileData = self:GetProjectileData()
		local facingRot = GLM.Angle(args.direction, NKMath.Right)
		local temp = self.m_offset:mul_quat(facingRot)
		local effect = Eternus.GameObjectSystem:NKCreateNetworkedGameObject("Electro Projectile", true, true, effectArgs)
		
		effect:NKSetPosition(args.positionW + temp)
		effect:NKSetOrientation(GLM.Angle(args.direction, NKMath.Up))

		effect:NKPlaceInWorld(false, false)
		effect:NKSetShouldRender(true, true)

		local throwablePayload = 
		{
			damage = projectileData.m_damage,
			strikeThreshold = 0.0,
			offset = projectileData.m_offset,
			source = player,
		}

		self.m_effect = effect
		self.m_charging = true
		effect:Fire(throwablePayload, args.direction, 15, player)
		
		-- type is persistent, set currentProjectile
		if self.m_persistent then
			self.m_castingValid = true
			self.m_currentProjectile = currentProjectile
		-- type is single-shot, handle logic here
		end
		
		if self.m_castingSound then
			self:RaiseClientEvent("ClientEvent_PlayWorldSound", {	
									soundName = self.m_castingSound, loop = false,
									position = self.m_player:NKGetWorldPosition(),
									velocity = vec3.new(0.0, 0.0, 0.0),
									minDist = 15.0, maxDist = 64.0 })
		end
		
		-- remove energy from player
		player:_ModifyEnergy(-self.m_energyUsed)
		
		return
	end
end

-------------------------------------------------------------------------------
function ElectroGauntlet:Update( dt )
	ElectroGauntlet.__super.Update(self, dt)

		
	if self.m_charging then

	end
end

-------------------------------------------------------------------------------
function ElectroGauntlet:ServerEvent_Aim(args)
	ElectroGauntlet.__super.ServerEvent_Aim(self, args)

end

-------------------------------------------------------------------------------
function ElectroGauntlet:StartEmitters(player)
	for emitterID, emitterName in ipairs(self.Emitters) do
        self.m_emitters[emitterID] = Eternus.GameObjectSystem:NKCreateGameObject(emitterName, true)
        self.m_emitters[emitterID]:NKSetShouldSave(false)
        self.m_emitters[emitterID]:NKSetPosition(player:NKGetWorldPosition())
        player:NKAddChildObject(self.m_emitters[emitterID])
        self.m_emitters[emitterID]:NKPlaceInWorld(true, false)
        player:NKActivateEmitterByName(emitterName)
    end
	self.m_emittersRunning = true
end

-------------------------------------------------------------------------------
function ElectroGauntlet:StopEmitters(player)
	for emitterID, emitterName in ipairs(self.Emitters) do
		player:NKDeactivateEmitterByName(self.Emitters[i])
		player:NKRemoveChildObject( self.m_emitters[emitterID])
		self.m_emitters[emitterID]:NKDeleteMe()
    end
	self.m_emittersRunning = false
end

-------------------------------------------------------------------------------
--function logToFile(message, file, mode)
-- local file = io.open(file or "dev_log", mode or "a")
-- file:write(tostring(message))
-- file:close()
--end

-------------------------------------------------------------------------------
EntityFramework:RegisterGameObject(ElectroGauntlet)
