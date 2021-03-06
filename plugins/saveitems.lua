
PLUGIN.name = "Save Items"
PLUGIN.author = "Chessnut"
PLUGIN.description = "Saves items that were dropped."

--[[
	function PLUGIN:OnSavedItemLoaded(items)
		for k, v in ipairs(items) do
			-- do something
		end
	end

	function PLUGIN:ShouldDeleteSavedItems()
		return true
	end
]]--

-- as title says.

function PLUGIN:CanProperty(client, property, entity)
	if (entity:GetClass() == "ix_item" and property == "persist") then
		return false
	end
end

function PLUGIN:LoadData()
	local items = self:GetData()

	if (items) then
		local idRange = {}
		local positions = {}

		for _, v in ipairs(items) do
			idRange[#idRange + 1] = v[1]
			positions[v[1]] = v[2]
		end

		if (#idRange > 0) then
			if (hook.Run("ShouldDeleteSavedItems") == true) then
				-- don't spawn saved item and just delete them.
				local query = mysql:Delete("ix_items")
					query:WhereIn("item_id", idRange)
				query:Execute()

				print("Server Deleted Server Items (does not includes Logical Items)")
			else
				local query = mysql:Select("ix_items")
					query:Select("item_id")
					query:Select("unique_id")
					query:Select("data")
					query:WhereIn("item_id", idRange)
					query:Callback(function(result)
						if (istable(result)) then
							local loadedItems = {}

							for _, v in ipairs(result) do
								local itemID = tonumber(v.item_id)
								local data = util.JSONToTable(v.data or "[]")
								local uniqueID = v.unique_id
								local itemTable = ix.item.list[uniqueID]

								if (itemTable and itemID) then
									local position = positions[itemID]
									local item = ix.item.New(uniqueID, itemID)
									item.data = data or {}
									item:Spawn(position).ixItemID = itemID

									item.invID = 0
									table.insert(loadedItems, item)
								end
							end

							hook.Run("OnSavedItemLoaded", loadedItems) -- when you have something in the dropped item.
						end
					end)
				query:Execute()
			end
		end
	end
end

function PLUGIN:SaveData()
	local items = {}

	for _, v in ipairs(ents.FindByClass("ix_item")) do
		if (v.ixItemID and !v.temp) then
			items[#items + 1] = {v.ixItemID, v:GetPos()}
		end
	end

	self:SetData(items)
end
