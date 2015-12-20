include("Scripts/Objects/EquipableGear.lua")

NewGauntlet = EquipableGear.Subclass("NewGauntlet")

--[[NewGauntlet.Models = {}
NewGauntlet.Models[1] = NKLoadStaticModel("Data/eyes.txt")--]]

NewGauntlet.Effect = {
	"Projectiles/Electro.txt"
}

-------------------------------------------------------------------------------
function NewGauntlet:Constructor(args)
	self.m_charging = false
	if args == nil then
		NKError(self:NKGetName() .. " has no args!", false)
	end

	self.m_id = 1
	self.effectArgs = NKParseFile( "Data/Effects/".. NewGauntlet.Effect[self.m_id] )
	self.effect = Eternus.GameObjectSystem:NKCreateNetworkedGameObject("Electro Projectile", true, true, effectArgs)

	self.m_emptyContainer = args.emptyContainer
	self.m_energyUsed = args.energyUsed or 10
	self.m_energyThreshold = args.energyThreshold or 3
	
	self.m_currentProjectile = nil
	
	self.m_persistent = (args.persistent == 1) or false
	self.m_energyPerTick = args.energyPerTick or 0
	self.m_durabilityPerTick = args.durabilityPerTick or 1
	self.m_castingTimerTick = args.castingTimerTick or 1
	self.m_castingTimer = 0
	
	self.m_spellName = args.spellName or "Unnamed"
	self.m_spellIcon = args.spellIcon or "TUGIcons/NoIcon"
	
	self.m_castingValid = false
	self.m_isControlling = false
	
	
	self.m_castingSound = args.castingSound or nil
	self.m_endCastingSound = args.endCastingSound or nil
	self.m_noEnergySound = args.noEnergySound or nil
	self.m_noEnergyEmitter = args.noEnergyEmitter or nil
	self.m_stoneBreakEmitter = args.stoneBreakEmitter or nil
	
	self.m_lookVector = nil

	--self.m_playerDestroyedCallback = nil
	--self.m_playerDestroyedSignal = nil
	
	self.m_projectile = {}
	--self.m_offset = args.offset or vec3.new(1.0, 0.0, 0.0)
	--if args.Projectile == nil then
	--	NKError(self:NKGetName() .. " missing projectile data!", false)
	--else
	--	self.m_projectile.name = args.Projectile.name or self:NKGetName()
	--	
	--	self.m_projectile.m_strikeThreshold = args.Projectile.strikeThreshold or Gauntlet.--ProjectileStrikeThreshold
	--	self.m_projectile.m_force = args.Projectile.force or Gauntlet.ProjectileForce
	--	self.m_projectile.m_damage = args.Projectile.damage or Gauntlet.ProjectileDamage
	--	self.m_projectile.m_offset = self.m_offset
	--end

end

-------------------------------------------------------------------------------
function NewGauntlet:GearPrimaryAction(args)
	if ElectricGauntlet_DEBUGGING then
		NKWarn(">> [NewGauntlet] NewGauntlet:GearPrimaryAction() " .. (self.m_player and "has Player" or "Missing Player") )
	end
	local player = args.player
	
	-- Check stance 
	if player:InCastingStance() and (not self.m_persistent or not self.m_currentProjectile) then
		
		local facingRot = GLM.Angle(args.direction, NKMath.Right)
		local temp = self.m_offset:mul_quat(facingRot)

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
		effect:Fire(throwablePayload, args.direction, 15)
		
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
EntityFramework:RegisterGameObject(NewGauntlet)
