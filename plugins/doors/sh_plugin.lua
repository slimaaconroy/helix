
PLUGIN.name = "Doors"
PLUGIN.author = "Chessnut"
PLUGIN.description = "A simple door system."

-- luacheck: globals DOOR_OWNER DOOR_TENANT DOOR_GUEST DOOR_NONE
DOOR_OWNER = 3
DOOR_TENANT = 2
DOOR_GUEST = 1
DOOR_NONE = 0

ix.util.Include("sv_plugin.lua")
ix.util.Include("cl_plugin.lua")
ix.util.Include("sh_commands.lua")

do
	local entityMeta = FindMetaTable("Entity")

	function entityMeta:CheckDoorAccess(client, access)
		if (!self:IsDoor()) then
			return false
		end

		access = access or DOOR_GUEST

		local parent = self.ixParent

		if (IsValid(parent)) then
			return parent:CheckDoorAccess(client, access)
		end

		if (hook.Run("CanPlayerAccessDoor", client, self, access)) then
			return true
		end

		if (self.ixAccess and (self.ixAccess[client] or 0) >= access) then
			return true
		end

		return false
	end

	if (SERVER) then
		function entityMeta:RemoveDoorAccessData()
			-- Don't ask why. This happened with 60 player servers.
			if (IsValid(self)) then
				for k, _ in pairs(self.ixAccess or {}) do
					netstream.Start(k, "doorMenu")
				end

				self.ixAccess = {}
				self:SetDTEntity(0, nil)
			end
		end
	end
end

-- Configurations for door prices.
ix.config.Add("doorCost", 10, "The price to purchase a door.", nil, {
	data = {min = 0, max = 500},
	category = "dConfigName"
})
ix.config.Add("doorSellRatio", 0.5, "How much of the door price is returned when selling a door.", nil, {
	form = "Float",
	data = {min = 0, max = 1.0},
	category = "dConfigName"
})
ix.config.Add("doorLockTime", 1, "How long it takes to (un)lock a door.", nil, {
	form = "Float",
	data = {min = 0, max = 10.0},
	category = "dConfigName"
})
