local HandlerClass = include("Scripts/Handlers/HandlerClass.lua")

local NKPhysics = include("Scripts/Core/NKPhysics.lua")

-------------------------------------------------------------------------------
local HandlerHoming = HandlerClass.Subclass("HandlerHoming")
EternusEngine.EffectsManager:RegisterHandler("HandlerHoming", HandlerHoming)

HandlerHoming.DefaultDamage = 1.0
HandlerHoming.DefaultStrikeThreshold = -0.5

-------------------------------------------------------------------------------
function HandlerHoming:Constructor(effectHandler, args)
	if args == nil then
		args = {}
	end
	
	self.m_target = nil
	self.m_targetDestroyedCallback = nil
	self.m_targetDestroyedSignal = nil
	
	self.m_stopped = true
	self.m_speed = args.speed or 0.3
end

-------------------------------------------------------------------------------
function HandlerHoming:Fire(payload, direction, force)

	self.m_stopped = false
	
	--self:SetThrowablePayload(payload)

	self.m_direction = direction;
	self.m_initialThrowOrin = self.m_effectHandler:NKGetOrientation()
end

-------------------------------------------------------------------------------
function HandlerHoming:Stop()
	self.m_stopped = true
	self:SetTarget(nil)
end

-------------------------------------------------------------------------------
function HandlerHoming:OnUpdate(dt)
	if self.m_stopped then
		return
	end
	local pos = self.m_effectHandler:NKGetPosition()
		
	local ignoredObject = {self.m_effectHandler.object}
	if self.m_effectHandler.m_source and self.m_effectHandler.m_source.object then
		table.insert(ignoredObject,self.m_effectHandler.m_source.object)
	end
	
	local targetDistance = 1000
	if self.m_target then
		targetDistance = (pos-self.m_target:NKGetWorldPosition()):NKLength()
	end
	--self:NKSetWorldOrientation()
	if (Eternus.IsServer and targetDistance > 50) then
		local collectedObjects = NKPhysics.SphereOverlapCollect(50, self.m_effectHandler:NKGetPosition(), ignoredObject )
		
		
		local newTarget = nil
		local distance = 1000
		if collectedObjects then
			for key,collectedObject in pairs(collectedObjects) do
				if collectedObject:NKGetInstance() then
					local gameobjectsInstance = collectedObject:NKGetInstance()
					
					local newDistance = (pos-gameobjectsInstance:NKGetWorldPosition()):NKLength()
					if newDistance < distance then
						if gameobjectsInstance:InstanceOf(AICharacter) or gameobjectsInstance:InstanceOf(BasePlayer) then 
							newTarget = gameobjectsInstance
							distance = newDistance
							targetDistance = newDistance
						end
					end
				end
			end
		end
		self:SetTarget(newTarget)
	end
	
	if self.m_target then
		if targetDistance < 5 then
			self.m_direction = (self.m_target:NKGetWorldPosition()-pos):NKNormalize()
		else
			self.m_direction = ((self.m_target:NKGetWorldPosition()+vec3(0,3,0))-pos):NKNormalize()
		end
	end
	
	self.m_effectHandler:NKSetPosition(pos + self.m_direction:mul_scalar(self.m_speed))
	
	local hit = NKPhysics.RayCastCollect(pos, self.m_direction, self.m_speed+0.2, ignoredObject)
	if hit then
		local targetType, targetData = EternusEngine.EffectsManager:GetContactData(hit.gameobject, hit, true)
		if (not Eternus.IsServer) then
			-- something is in the way, wait for server input 
			if targetType ~= EffectsManager.HitType.eInvalid then
				self.m_stopped = true
			end
			return
		end
		self.m_effectHandler:ExecuteEvent("OnContact", {targetType=targetType, targetData=targetData})
	end

end

-------------------------------------------------------------------------------
function HandlerHoming:HandlerSerializeConstruction( data )
end

-------------------------------------------------------------------------------
function HandlerHoming:HandlerDeserializeConstruction( data )
end

function HandlerHoming:HandlerSerialize( stream )
	stream:NKWriteBool(self.m_stopped)
	if self.m_target and self.m_target.object then
		stream:NKWriteBool(true)
		stream:NKWriteGameObject(self.m_target.object)
	else
		stream:NKWriteBool(false)
	end
	if not self.m_stopped then
		stream:NKWriteDouble(self.m_direction:x())
		stream:NKWriteDouble(self.m_direction:y())
		stream:NKWriteDouble(self.m_direction:z())
	end
end

function HandlerHoming:HandlerDeserialize( stream )
	self.m_stopped = stream:NKReadBool()
	if stream:NKReadBool() then
		local newTarget = stream:NKReadGameObject()
		self:SetTarget(newTarget:NKGetInstance())
	end
	if not self.m_stopped then
		local x = stream:NKReadDouble()
		local y = stream:NKReadDouble()
		local z = stream:NKReadDouble()
		self.m_direction = vec3(x,y,z)
	end
end

--------------------------------------------------------------------------------
function HandlerHoming:SetTarget( target )
	-- same target, no change required
	if target == self.m_target then
		--No target to set
		return 
	end
	
	--remove the old callback
	if self.m_targetDestroyedSignal ~= nil and self.m_targetDestroyedCallback ~= nil then
		self.m_targetDestroyedSignal:Remove(self.m_targetDestroyedCallback)
	end

	if target == nil then
		--No target to set
		self.m_target = nil
		self.m_targetDestroyedCallback = nil
		self.m_targetDestroyedSignal = nil
		return 
	end
	
	self.m_targetDestroyedCallback = function() 
		if self.m_targetDestroyedSignal ~= nil then
			self.m_targetDestroyedSignal:Remove(self.m_targetDestroyedCallback)
		end

		self.m_target = nil
		self.m_targetDestroyedSignal = nil
	end

	self.m_target = target
	self.m_targetDestroyedSignal = self.m_target.m_destroyedSignal
	self.m_targetDestroyedSignal:Add(self.m_targetDestroyedCallback)
end

return HandlerHoming