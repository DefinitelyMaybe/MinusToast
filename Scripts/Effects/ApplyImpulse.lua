--[[
This class is part of the Effects system.
It can not be used outside of EffectsManager.
All classes in this system are singleton classes.
]]--

local ApplyImpulse = EternusEngine.Class.Subclass("ApplyImpulse")
EternusEngine.EffectsManager:RegisterEffect("ApplyImpulse", ApplyImpulse)

-------------------------------------------------------------------------------
function ApplyImpulse:Callback( effectHandler, effectData, callbackData )
	--if callbackData.targetType == EffectsManager.HitType.ePlayer or callbackData.targetType == EffectsManager.HitType.eCharacter then
	local impulse = vec3.new(0, 100.0, 0)
	local offset = vec3.new(0, 0, 0)
	
		callbackData.targetData:NKGetCharacterController():NKApplyImpulse(impulse--[[, offset--]])
	--end
end
