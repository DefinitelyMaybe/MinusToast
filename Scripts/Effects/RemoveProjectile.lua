--[[
This class is part of the Effects system.
It can not be used outside of EffectsManager.
All classes in this system are singleton classes.
]]--

local RemoveProjectile = EternusEngine.Class.Subclass("RemoveProjectile")
EternusEngine.EffectsManager:RegisterEffect("RemoveProjectile", RemoveProjectile)

-------------------------------------------------------------------------------
function RemoveProjectile:Callback( effectHandler, effectData, callbackData )
	effectHandler:NKRemoveFromWorld(true, true)
end
