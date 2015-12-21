include("Scripts/Objects/Gauntlet.lua")

ElectroGauntlet = Gauntlet.Subclass("ElectroGauntlet")

--[[ElectroGauntlet.Models = {}
ElectroGauntlet.Models[1] = NKLoadStaticModel("Data/eyes.txt")--]]

ElectroGauntlet.Effect = {
	"Projectiles/Electro.txt"
}

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

--function ElectroGauntlet:PostLoad(dt) 
--	ElectroGauntlet.__super.PostLoad(self, dt)
--end

-------------------------------------------------------------------------------
function ElectroGauntlet:Constructor(args)
	self.m_id = 1
	self.m_charging = false
	self.m_emittersRunning = false
	self.m_emitter1 = nil
	self.m_emitter2 = nil
	self.m_emitter3 = nil
end

-------------------------------------------------------------------------------
function ElectroGauntlet:GearPrimaryAction(args)
	if ElectricGauntlet_DEBUGGING then
		NKWarn(">> [ElectroGauntlet] ElectroGauntlet:GearPrimaryAction() " .. (self.m_player and "has Player" or "Missing Player") )
	end

	local player = args.player
	
	-- Check stance
	if player:InCastingStance() and (not self.m_persistent or not self.m_currentProjectile) then
		
		
		
		
		local effectArgs = NKParseFile( "Data/Effects/".. ElectroGauntlet.Effect[self.m_id] )
		
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
		
		--local chargeArgs = effect:Charge()
		--if chargeArgs[1] then

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
	
	if self.m_player ~= nil then
		if not self.m_player:InCastingStance() and self.m_emittersRunning then
			for i = 1, 3 do
				self.m_player:NKDeactivateEmitterByName(self.Emitters[i])
				self.m_player:NKRemoveChildObject(self["m_emitter"..tostring(i)])
				self["m_emitter"..tostring(i)]:NKDeleteMe()
			end
			self.m_emittersRunning = false
		end
	end
	
	--if self.m_charging then
		--local currentScale = effect:NKGetScale()
		--if currentScale > 2.5 then
		--	effect:NKScale(currentScale + 0.5)
		--end
	--end
end

-------------------------------------------------------------------------------
--function ElectroGauntlet:OnGearEquipped( player )
--	ElectroGauntlet.__super.OnGearEquipped(self, player)
--
--end

-------------------------------------------------------------------------------
function ElectroGauntlet:ServerEvent_Aim(args)
	ElectroGauntlet.__super.ServerEvent_Aim(self, args)
	
	--NKWarn("charging")
	--self.m_charging = true
	
	for i = 1, 3 do
		self["m_emitter"..tostring(i)] = Eternus.GameObjectSystem:NKCreateGameObject(self.Emitters[i], true)
		self["m_emitter"..tostring(i)]:NKSetShouldSave(false)
		self["m_emitter"..tostring(i)]:NKSetPosition(self.m_player:NKGetWorldPosition())
		self.m_player:NKAddChildObject(self["m_emitter"..tostring(i)])
		self["m_emitter"..tostring(i)]:NKPlaceInWorld(true, false)
		self.m_player:NKActivateEmitterByName(self.Emitters[i])
		
	end
	self.m_emittersRunning = true
	
	-- Emitters get turned off. Have to detect if still Aiming or not
end

-------------------------------------------------------------------------------
--function ElectroGauntlet:ServerEvent_CancelCasting(args)
--	ElectroGauntlet.__super.ServerEvent_CancelCasting(self, args)
--	
--	
--end

-------------------------------------------------------------------------------
--function logToFile(message, file, mode)
-- local file = io.open(file or "dev_log", mode or "a")
-- file:write(tostring(message))
-- file:close()
--end

-------------------------------------------------------------------------------
EntityFramework:RegisterGameObject(ElectroGauntlet)
