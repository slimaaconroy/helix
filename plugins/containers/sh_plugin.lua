
local PLUGIN = PLUGIN

PLUGIN.name = "Containers"
PLUGIN.author = "Chessnut"
PLUGIN.description = "Provides the ability to store items."
PLUGIN.definitions = PLUGIN.definitions or {}

ix.util.Include("sh_definitions.lua")

for k, v in pairs(PLUGIN.definitions) do
	if (v.name and v.width and v.height) then
		ix.item.RegisterInv("container" .. v.name, v.width, v.height)
	else
		ErrorNoHalt("[Helix] Container for '"..k.."' is missing all inventory information!\n")
		PLUGIN.definitions[k] = nil
	end
end

ix.config.Add("containerSave", true, "Whether or not containers will save after a server restart.", nil, {
	category = "Containers"
})

ix.config.Add("containerOpenTime", 0.7, "How long it takes to open a container.", nil, {
	data = {min = 0, max = 50},
	category = "Containers"
})

function PLUGIN:CanProperty(client, property, entity)
	if (entity:GetClass() == "ix_container" and property == "persist") then
		return false
	end
end

if (SERVER) then
	function PLUGIN:PlayerSpawnedProp(client, model, entity)
		local data = self.definitions[model:lower()]

		if (data) then
			if (hook.Run("CanPlayerSpawnContainer", client, model, entity) == false) then return end

			local container = ents.Create("ix_container")
			container:SetPos(entity:GetPos())
			container:SetAngles(entity:GetAngles())
			container:SetModel(model)
			container:Spawn()

			ix.item.NewInv(0, "container" .. data.name, function(inventory)
				inventory.vars.isContainer = true

				if (IsValid(container)) then
					container:SetInventory(inventory)
				end
			end)

			self:SaveContainer()
			entity:Remove()
		end
	end

	function PLUGIN:CanSaveContainer(entity, inventory)
		return ix.config.Get("containerSave", true)
	end

	function PLUGIN:SaveContainer()
		local data = {}

		for _, v in ipairs(ents.FindByClass("ix_container")) do
			if (hook.Run("CanSaveContainer", v, v:GetInventory()) != false) then
				if (v:GetInventory()) then
					data[#data + 1] = {v:GetPos(), v:GetAngles(), v:GetNetVar("id"), v:GetModel(), v.password}
				end
			else
				local index = v:GetNetVar("id")

				local query = mysql:Delete("ix_items")
					query:Where("inventory_id", index)
				query:Execute()

				query = mysql:Delete("ix_inventories")
					query:Where("inventory_id", index)
				query:Execute()
			end
		end

		self:SetData(data)
	end

	function PLUGIN:SaveData()
		self:SaveContainer()
	end

	function PLUGIN:ContainerItemRemoved(entity, inventory)
		self:SaveContainer()
	end

	function PLUGIN:LoadData()
		local data = self:GetData()

		if (data) then
			for _, v in ipairs(data) do
				local data2 = self.definitions[v[4]:lower()]

				if (data2) then
					local entity = ents.Create("ix_container")
					entity:SetPos(v[1])
					entity:SetAngles(v[2])
					entity:Spawn()
					entity:SetModel(v[4])
					entity:SetSolid(SOLID_VPHYSICS)
					entity:PhysicsInit(SOLID_VPHYSICS)

					if (v[5]) then
						entity.password = v[5]
						entity:SetNetVar("locked", true)
					end

					ix.item.RestoreInv(v[3], data2.width, data2.height, function(inventory)
						inventory.vars.isContainer = true

						if (IsValid(entity)) then
							entity:SetInventory(inventory)
						end
					end)

					local physObject = entity:GetPhysicsObject()

					if (physObject) then
						physObject:EnableMotion()
					end
				end
			end
		end
	end

	netstream.Hook("invLock", function(client, entity, password)
		local dist = entity:GetPos():Distance(client:GetPos())

		if (dist < 128 and password) then
			if (entity.password and entity.password == password) then
				entity:OpenInventory(client)
			else
				client:NotifyLocalized("wrongPassword")
			end
		end
	end)
else
	netstream.Hook("invLock", function(entity)
		Derma_StringRequest(
			L("containerPasswordWrite"),
			L("containerPasswordWrite"),
			"",
			function(val)
				netstream.Start("invLock", entity, val)
			end
		)
	end)
end

ix.command.Add("ContainerSetPassword", {
	description = "@cmdContainerSetPassword",
	adminOnly = true,
	arguments = ix.type.text,
	OnRun = function(self, client, password)
		local trace = client:GetEyeTraceNoCursor()
		local ent = trace.Entity

		if (ent and ent:IsValid()) then
			if (password:len() != 0) then
				ent:SetNetVar("locked", true)
				ent.password = password

				return "@containerPassword", password
			else
				ent:SetNetVar("locked", nil)
				ent.password = nil

				return "@containerPasswordRemove"
			end
		else
			return "@invalid", "Entity"
		end
	end
})
