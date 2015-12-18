include("Scripts/Objects/Gauntlet.lua")
include("Scripts/Interactable.lua")

-------------------------------------------------------------------------------
TestGauntlet = Gauntlet.Subclass("TestGauntlet")

--[[TestGauntlet.Models = {}
TestGauntlet.Models[1] = NKLoadStaticModel("Data/eyes.txt")--]]

TestGauntlet.Effect = {
	"Projectiles/TestProjectile.txt",
	"Projectiles/Fireball.txt",
	"Projectiles/Teleball.txt"
}


function TestGauntlet:PostLoad(dt) 
	TestGauntlet.__super.PostLoad(self, dt)
	
	
end

-------------------------------------------------------------------------------
function TestGauntlet:Constructor(args)
	TestGauntlet.__super.Constructor(self, args)
	self.m_id = 1
end

-------------------------------------------------------------------------------
function TestGauntlet:Interact(args)
	self.m_id = next(TestGauntlet.Effect, self.m_id) or 1
	
	local str = "Using Effect Test: " .. TestGauntlet.Effect[self.m_id]
	args.player:SendChatMessage(str)
end

-------------------------------------------------------------------------------
function TestGauntlet:GearPrimaryAction(args)
	if TestGauntlet_DEBUGGING then
		NKWarn(">> [TestGauntlet] TestGauntlet:GearPrimaryAction() " .. (self.m_player and "has Player" or "Missing Player") )
	end
	local player = args.player:NKGetInstance()
	
	-- Check stance 
	if player:InCastingStance() and (not self.m_persistent or not self.m_currentProjectile) then
		local testArgs = NKParseFile( "Data/Effects/".. TestGauntlet.Effect[self.m_id] )
		
		local projectileData = self:GetProjectileData()
		local facingRot = GLM.Angle(args.direction, NKMath.Right)
		local temp = self.m_offset:mul_quat(facingRot)
		local effect = Eternus.GameObjectSystem:NKCreateNetworkedGameObject("Test Projectile", true, true, testArgs):NKGetInstance()
		
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
--[[function TestGauntlet:OnGearEquipped( player )
	if GAUNTLET_DEBUGGING then
		NKWarn(">> [Gauntlet] Gauntlet:OnGearEquipped() " .. (player and "has Player" or "Missing Player") )
	end
	self:SetPlayer(player)
	--self.m_player = player
	self.m_gauntletEquipped = true
	
	player:NKSetGraphics(TestGauntlet.Models[1])
	player:NKGetPhysics():NKGetColliders()[1]:NKSetMesh(TestGauntlet.Models[1])
	player:NKGetStaticGraphics():NKSetSubmeshTexture(EternusEngine.ETextureType.Normal, "baseplayer", "pixel")
end--]]

-------------------------------------------------------------------------------
EntityFramework:RegisterGameObject(TestGauntlet)
