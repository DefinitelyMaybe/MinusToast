--MinusToast

-------------------------------------------------------------------------------
if MinusToast == nil then
	MinusToast = EternusEngine.ModScriptClass.Subclass("MinusToast")
end

-------------------------------------------------------------------------------
function MinusToast:Constructor()
end

-------------------------------------------------------------------------------
function MinusToast:Enter()
	include("Scripts/Objects/Gauntlet.lua")
	include("Scripts/Mixins/ElectroGauntlet.lua")

	local GauntletConstructor = Gauntlet.Constructor

	if Gauntlet:NKGetName() == "Electro Neuria Gauntlet" then
		Gauntlet.Constructor = function(self, args)
			GauntletConstructor(self, args)
			self:Mixin(ElectroGauntlet, args)
		end
	end
end

-------------------------------------------------------------------------------
function MinusToast:Leave()	
end

-------------------------------------------------------------------------------
function MinusToast:Initialize()
	NKPrint("[IK] MinusToast Mod Loaded")
end

-------------------------------------------------------------------------------
function MinusToast:Process(dt)
end

-------------------------------------------------------------------------------
function MinusToast:Save()
end

-------------------------------------------------------------------------------
function MinusToast:Restore()
end

-------------------------------------------------------------------------------
EntityFramework:RegisterModScript(MinusToast)
