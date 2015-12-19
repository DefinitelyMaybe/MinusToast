include("Scripts/Objects/Gauntlet.lua")

ElectroGauntlet = Gauntlet.Subclass("ElectroGauntlet")

ElectroGauntlet.Effect = {
	"Projectiles/ElectroProjectile.txt"
}


function ElectroGauntlet:PostLoad(dt) 
	ElectroGauntlet.__super.PostLoad(self, dt)
end

-------------------------------------------------------------------------------
function ElectroGauntlet:Constructor(args)
	self.m_id = 1
	self.m_charging = false
end

-------------------------------------------------------------------------------
function ElectroGauntlet:GearPrimaryAction(args)
	if ElectricGauntlet_DEBUGGING then
		NKWarn(">> [ElectroGauntlet] ElectroGauntlet:GearPrimaryAction() " .. (self.m_player and "has Player" or "Missing Player") )
	end
	local player = args.player:NKGetInstance()
	
	-- Check stance 
	if player:InCastingStance() and (not self.m_persistent or not self.m_currentProjectile) then
		local effectArgs = NKParseFile( "Data/Effects/".. ElectroGauntlet.Effect[self.m_id] )
		
		local projectileData = self:GetProjectileData()
		local facingRot = GLM.Angle(args.direction, NKMath.Right)
		local temp = self.m_offset:mul_quat(facingRot)
		local effect = Eternus.GameObjectSystem:NKCreateNetworkedGameObject("Electro Ball", true, true, effectArgs):NKGetInstance()
		
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
		effect:Fire(throwablePayload, args.direction, 18)
		
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
	ElectroGauntlet.__super.PostLoad(self, dt)
	
	if self.m_charging then
		
	end
end

-------------------------------------------------------------------------------
function ElectroGauntlet:ServerEvent_Aim(args)
	ElectroGauntlet.__super.PostLoad(self, args)
	
	--self:NKActivateEmitterByName("")
	self.m_charging = true
end

-------------------------------------------------------------------------------
EntityFramework:RegisterGameObject(ElectroGauntlet)
