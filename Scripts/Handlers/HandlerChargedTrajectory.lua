include("Scripts/Handlers/HandlerTrajectory.lua")

-------------------------------------------------------------------------------
local HandlerChargedTrajectory = HandlerClass.Subclass("HandlerTrajectory")
EternusEngine.EffectsManager:RegisterHandler("HandlerChargedTrajectory", HandlerChargedTrajectory)

-------------------------------------------------------------------------------
function HandlerChargedTrajectory:Constructor(effectHandler, args)
	HandlerChargedTrajectory.__super.Constructor(self, effectHandler, args)

end

-------------------------------------------------------------------------------
function HandlerChargedTrajectory:Fire(payload, direction, force)
	HandlerChargedTrajectory.__super.Fire(self, payload, direction, force)
	
end

-------------------------------------------------------------------------------
function HandlerChargedTrajectory:OnUpdate(dt)
	HandlerChargedTrajectory.__super.Update(self, dt)
end

-------------------------------------------------------------------------------
return HandlerChargedTrajectory