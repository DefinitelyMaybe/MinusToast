--[[
This class is part of the Effects system.
It can not be used outside of EffectsManager.
All classes in this system are singleton classes.
]]--

local TeleportPlayer = EternusEngine.Class.Subclass("TeleportPlayer")
EternusEngine.EffectsManager:RegisterEffect("TeleportPlayer", TeleportPlayer)

-------------------------------------------------------------------------------
function TeleportPlayer:Callback( effectHandler, effectData, callbackData )
	if Eternus.IsServer and not Eternus.IsClient then
		return
	end
	Teleball.instance:RaiseClientEvent("ClientEvent_TeleportPlayer", {position = effectHandler:NKGetWorldPosition()})
end
