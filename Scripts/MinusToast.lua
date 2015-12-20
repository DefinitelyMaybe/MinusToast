--MinusToast

-------------------------------------------------------------------------------
if MinusToast == nil then
	MinusToast = EternusEngine.ModScriptClass.Subclass("MinusToast")
end

-------------------------------------------------------------------------------
function MinusToast:Constructor()
end

-------------------------------------------------------------------------------
function MinusToast:Initialize()
	NKPrint("[IK] MinusToast Mod Loaded")
	Eternus.GameState:RegisterSlashCommand("xmod", self, "SpawnModsObjects")
end

-------------------------------------------------------------------------------

function MinusToast:SpawnModsObjects(userInput, args, commandName, player)
	local pos = player:NKGetWorldPosition()
	local vec = pos
	player:RaiseServerEvent("Server_Pickup", { name = "Electro Neuria Gauntlet", count = 1 })
	player:RaiseServerEvent("Server_Pickup", { name = "Cooked Meat", count = 10 })
	player:SpawnLootCommand("Cooked Meat", 10, pos, vec)
end

-------------------------------------------------------------------------------
EntityFramework:RegisterModScript(MinusToast)
