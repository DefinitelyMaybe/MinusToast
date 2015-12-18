include("Scripts/Mixins/EventExecutorMixin.lua")
include("Scripts/Mixins/HandlerContainerMixin.lua")
include("Scripts/Handlers/HandlerTrajectory.lua")
-------------------------------------------------------------------------------
TestProjectile = PlaceableObject.Subclass("TestProjectile")

-------------------------------------------------------------------------------
function TestProjectile:Constructor( args )
	self:Mixin(HandlerContainerMixin, args)
	
	self.m_source = nil
	self.m_sourceDestroyedCallback = nil
	self.m_sourceDestroyedSignal = nil
	
	self.m_fired = false
	self.m_reset = false
end

-------------------------------------------------------------------------------
function TestProjectile:Fire(payload, direction, force)
	if payload ~= nil then
		self:SetSource(payload.source)
	end
	if Eternus.IsServer then
		self:ChangeHandler("Trajectory")
		
		self.m_fired = true
		if self.m_handler and self.m_handler.Fire then
			self.m_handler:Fire(payload, direction, force)
		end
	end
end

-------------------------------------------------------------------------------
function TestProjectile:Stop()
	self.m_fired = false
	if self.m_handler and self.m_handler.Stop then
		self.m_handler:Stop()
	end
end

function TestProjectile:NetSerializeConstruction( stream )
end

function TestProjectile:NetDeserializeConstruction( stream )
end

-------------------------------------------------------------------------------
function TestProjectile:NetSerialize( stream )
	stream:NKWriteBool(self.m_fired)
	if self.m_fired then
		if self.m_source and self.m_source.object then
			stream:NKWriteBool(true)
			stream:NKWriteGameObject(self.m_source.object)
		else
			stream:NKWriteBool(false)
		end
	end
end

-------------------------------------------------------------------------------
function TestProjectile:NetDeserialize( stream )
	self.m_fired = stream:NKReadBool()
	if self.m_fired then
		if stream:NKReadBool() then
			local source = stream:NKReadGameObject()
			if source then
				source = source:NKGetInstance()
				if source then
					self:SetSource(source)
				end
			end
		end
	end
end

--------------------------------------------------------------------------------
function TestProjectile:SetSource( source )
	-- same source, no change required
	if source == self.m_source then
		--No source to set
		return 
	end
	
	--remove the old callback
	if self.m_sourceDestroyedSignal ~= nil and self.m_sourceDestroyedCallback ~= nil then
		self.m_sourceDestroyedSignal:Remove(self.m_sourceDestroyedCallback)
	end

	if source == nil then
		--No source to set
		self.m_source = nil
		self.m_sourceDestroyedCallback = nil
		self.m_sourceDestroyedSignal = nil
		return 
	end
	
	self.m_sourceDestroyedCallback = function() 
		if self.m_sourceDestroyedSignal ~= nil then
			self.m_sourceDestroyedSignal:Remove(self.m_sourceDestroyedCallback)
		end

		self.m_source = nil
		self.m_sourceDestroyedSignal = nil
	end

	self.m_source = source
	self.m_sourceDestroyedSignal = self.m_source.m_destroyedSignal
	self.m_sourceDestroyedSignal:Add(self.m_sourceDestroyedCallback)
end


-------------------------------------------------------------------------------
EntityFramework:RegisterGameObject(TestProjectile)