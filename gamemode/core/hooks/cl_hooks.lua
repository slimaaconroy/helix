
function GM:ForceDermaSkin()
	return "helix"
end

function GM:ScoreboardShow()
	if (LocalPlayer():GetChar()) then
		vgui.Create("ixMenu")
	end
end

function GM:ScoreboardHide() end

function GM:LoadFonts(font, genericFont)
	surface.CreateFont("ix3D2DFont", {
		font = font,
		size = 2048,
		extended = true,
		weight = 1000
	})

	surface.CreateFont("ixTitleFont", {
		font = font,
		size = ScreenScale(30),
		extended = true,
		weight = 1000
	})

	surface.CreateFont("ixSubTitleFont", {
		font = font,
		size = ScreenScale(18),
		extended = true,
		weight = 500
	})

	surface.CreateFont("ixMenuButtonFont", {
		font = font,
		size = ScreenScale(14),
		extended = true,
		weight = 1000
	})

	surface.CreateFont("ixMenuButtonLightFont", {
		font = font,
		size = ScreenScale(14),
		extended = true,
		weight = 200
	})

	surface.CreateFont("ixToolTipText", {
		font = font,
		size = 20,
		extended = true,
		weight = 500
	})

	surface.CreateFont("ixDynFontSmall", {
		font = font,
		size = ScreenScale(22),
		extended = true,
		weight = 1000
	})

	surface.CreateFont("ixDynFontMedium", {
		font = font,
		size = ScreenScale(28),
		extended = true,
		weight = 1000
	})

	surface.CreateFont("ixDynFontBig", {
		font = font,
		size = ScreenScale(48),
		extended = true,
		weight = 1000
	})

	-- The more readable font.
	font = genericFont

	surface.CreateFont("ixCleanTitleFont", {
		font = font,
		size = 200,
		extended = true,
		weight = 1000
	})

	surface.CreateFont("ixHugeFont", {
		font = font,
		size = 72,
		extended = true,
		weight = 1000
	})

	surface.CreateFont("ixBigFont", {
		font = font,
		size = 36,
		extended = true,
		weight = 1000
	})

	surface.CreateFont("ixMediumFont", {
		font = font,
		size = 25,
		extended = true,
		weight = 1000
	})

	surface.CreateFont("ixMediumLightFont", {
		font = font,
		size = 25,
		extended = true,
		weight = 200
	})

	surface.CreateFont("ixGenericFont", {
		font = font,
		size = 20,
		extended = true,
		weight = 1000
	})

	surface.CreateFont("ixChatFont", {
		font = font,
		size = math.max(ScreenScale(7), 17),
		extended = true,
		weight = 200
	})

	surface.CreateFont("ixChatFontItalics", {
		font = font,
		size = math.max(ScreenScale(7), 17),
		extended = true,
		weight = 200,
		italic = true
	})

	surface.CreateFont("ixSmallFont", {
		font = font,
		size = math.max(ScreenScale(6), 17),
		extended = true,
		weight = 500
	})

	surface.CreateFont("ixItemDescFont", {
		font = font,
		size = math.max(ScreenScale(6), 17),
		extended = true,
		shadow = true,
		weight = 500
	})

	surface.CreateFont("ixSmallBoldFont", {
		font = font,
		size = math.max(ScreenScale(8), 20),
		extended = true,
		weight = 800
	})

	surface.CreateFont("ixItemBoldFont", {
		font = font,
		shadow = true,
		size = math.max(ScreenScale(8), 20),
		extended = true,
		weight = 800
	})


	-- Introduction fancy font.
	font = "Cambria"

	surface.CreateFont("ixIntroTitleFont", {
		font = font,
		size = 200,
		extended = true,
		weight = 1000
	})

	surface.CreateFont("ixIntroBigFont", {
		font = font,
		size = 48,
		extended = true,
		weight = 1000
	})

	surface.CreateFont("ixIntroMediumFont", {
		font = font,
		size = 28,
		extended = true,
		weight = 1000
	})

	surface.CreateFont("ixIntroSmallFont", {
		font = font,
		size = 22,
		extended = true,
		weight = 1000
	})

	surface.CreateFont("ixIconsSmall", {
		font = "fontello",
		size = 22,
		extended = true,
		weight = 500
	})

	surface.CreateFont("ixIconsMedium", {
		font = "fontello",
		extended = true,
		size = 28,
		weight = 500
	})

	surface.CreateFont("ixIconsBig", {
		font = "fontello",
		extended = true,
		size = 48,
		weight = 500
	})
end

local LOWERED_ANGLES = Angle(30, -30, -25)

function GM:CalcViewModelView(weapon, viewModel, oldEyePos, oldEyeAngles, eyePos, eyeAngles)
	if (!IsValid(weapon)) then
		return
	end

	local client = LocalPlayer()
	local value = 0

	if (!client:IsWepRaised()) then
		value = 100
	end

	local fraction = (client.ixRaisedFrac or 0) / 100
	local rotation = weapon.LowerAngles or LOWERED_ANGLES

	if (ix.option.Get("altLower", true) and weapon.LowerAngles2) then
		rotation = weapon.LowerAngles2
	end

	eyeAngles:RotateAroundAxis(eyeAngles:Up(), rotation.p * fraction)
	eyeAngles:RotateAroundAxis(eyeAngles:Forward(), rotation.y * fraction)
	eyeAngles:RotateAroundAxis(eyeAngles:Right(), rotation.r * fraction)

	client.ixRaisedFrac = Lerp(FrameTime() * 2, client.ixRaisedFrac or 0, value)

	viewModel:SetAngles(eyeAngles)
	return self.BaseClass:CalcViewModelView(weapon, viewModel, oldEyePos, oldEyeAngles, eyePos, eyeAngles)
end

function GM:LoadIntro()
	if (IsValid(ix.gui.char)) then
		vgui.Create("ixCharMenu")
	end
end

function GM:InitializedConfig()
	hook.Run("LoadFonts", ix.config.Get("font"), ix.config.Get("genericFont"))

	if (!ix.config.loaded and !IsValid(ix.gui.loading)) then
		local loader = vgui.Create("EditablePanel")
		loader:ParentToHUD()
		loader:Dock(FILL)
		loader.Paint = function(this, w, h)
			surface.SetDrawColor(0, 0, 0)
			surface.DrawRect(0, 0, w, h)
		end

		local statusLabel = loader:Add("DLabel")
		statusLabel:Dock(FILL)
		statusLabel:SetText(L"loading")
		statusLabel:SetFont("ixTitleFont")
		statusLabel:SetContentAlignment(5)
		statusLabel:SetTextColor(color_white)

		timer.Simple(5, function()
			if (IsValid(ix.gui.loading)) then
				local fault = GetNetVar("dbError")

				if (fault) then
					statusLabel:SetText(fault and L"dbError" or L"loading")

					local label = loader:Add("DLabel")
					label:DockMargin(0, 64, 0, 0)
					label:Dock(TOP)
					label:SetFont("ixSubTitleFont")
					label:SetText(fault)
					label:SetContentAlignment(5)
					label:SizeToContentsY()
					label:SetTextColor(Color(255, 50, 50))
				end
			end
		end)

		ix.gui.loading = loader
		ix.config.loaded = true

		hook.Run("LoadIntro")
	end
end

function GM:InitPostEntity()
	ix.joinTime = RealTime() - 0.9716
	ix.option.Sync()
end

function GM:NetworkEntityCreated(entity)
	if (entity:IsPlayer()) then
		entity:SetIK(false)
	end
end

local vignette = ix.util.GetMaterial("helix/gui/vignette.png")
local vignetteAlphaGoal = 0
local vignetteAlphaDelta = 0
local blurGoal = 0
local blurDelta = 0
local hasVignetteMaterial = vignette != "___error"

timer.Create("ixVignetteChecker", 1, 0, function()
	local client = LocalPlayer()

	if (IsValid(client)) then
		local data = {}
			data.start = client:GetPos()
			data.endpos = data.start + Vector(0, 0, 768)
			data.filter = client
		local trace = util.TraceLine(data)

		if (trace.Hit) then
			vignetteAlphaGoal = 80
		else
			vignetteAlphaGoal = 0
		end
	end
end)

local OFFSET_NORMAL = Vector(0, 0, 80)
local OFFSET_CROUCHING = Vector(0, 0, 48)

function GM:CalcView(client, origin, angles, fov)
	local view = self.BaseClass:CalcView(client, origin, angles, fov) or {}
	local entity = Entity(client:GetLocalVar("ragdoll", 0))
	local ragdoll = client:GetRagdollEntity() or entity

	if ((!client:ShouldDrawLocalPlayer() and IsValid(entity) and entity:IsRagdoll()) or
		(!LocalPlayer():Alive() and IsValid(ragdoll))) then
		local ent = LocalPlayer():Alive() and entity or ragdoll
		local index = ent:LookupAttachment("eyes")

		if (index) then
			local data = ent:GetAttachment(index)

			if (data) then
				view.origin = data.Pos
				view.angles = data.Ang
			end

			return view
		end
	end

	return self.BaseClass:CalcView(client, origin, angles, fov)
end

local paintedEntitiesCache = {}
local nextUpdate = 0
local lastTrace = {}
local lastEntity
local mathApproach = math.Approach
local surface = surface
local hookRun = hook.Run
local toScreen = FindMetaTable("Vector").ToScreen

function GM:HUDPaintBackground()
	local localPlayer = LocalPlayer()

	if (!localPlayer.GetChar(localPlayer)) then
		return
	end

	local realTime = RealTime()
	local frameTime = FrameTime()
	local scrW, scrH = surface.ScreenWidth(), surface.ScreenHeight()

	if (hasVignetteMaterial and ix.config.Get("vignette")) then
		vignetteAlphaDelta = mathApproach(vignetteAlphaDelta, vignetteAlphaGoal, frameTime * 30)

		surface.SetDrawColor(0, 0, 0, 175 + vignetteAlphaDelta)
		surface.SetMaterial(vignette)
		surface.DrawTexturedRect(0, 0, scrW, scrH)
	end

	if (localPlayer.GetChar(localPlayer) and nextUpdate < realTime) then
		nextUpdate = realTime + 0.5

		lastTrace.start = localPlayer.GetShootPos(localPlayer)
		lastTrace.endpos = lastTrace.start + localPlayer.GetAimVector(localPlayer)*160
		lastTrace.filter = localPlayer
		lastTrace.mins = Vector( -4, -4, -4 )
		lastTrace.maxs = Vector( 4, 4, 4 )
		lastTrace.mask = MASK_SHOT_HULL

		lastEntity = util.TraceHull(lastTrace).Entity
		local bShouldDrawEntityInfo = lastEntity.OnShouldDrawEntityInfo and lastEntity:OnShouldDrawEntityInfo()

		if (IsValid(lastEntity) and
			(lastEntity.DrawEntityInfo or bShouldDrawEntityInfo or hookRun("ShouldDrawEntityInfo", lastEntity))) then
			paintedEntitiesCache[lastEntity] = true
		end
	end

	for entity, drawing in pairs(paintedEntitiesCache) do
		if (IsValid(entity)) then
			local goal = drawing and 255 or 0
			local alpha = mathApproach(entity.ixAlpha or 0, goal, frameTime * 1000)

			if (lastEntity != entity) then
				paintedEntitiesCache[entity] = false
			end

			if (alpha > 0) then
				local client = entity.GetNetVar(entity, "player")

				if (IsValid(client)) then
					local position = toScreen(entity.LocalToWorld(entity, entity.OBBCenter(entity)))

					hookRun("DrawEntityInfo", client, alpha, position)
				elseif (entity.OnDrawEntityInfo) then
					entity.OnDrawEntityInfo(entity, alpha)
				else
					hookRun("DrawEntityInfo", entity, alpha)
				end
			end

			entity.ixAlpha = alpha

			if (alpha == 0 and goal == 0) then
				paintedEntitiesCache[entity] = nil
			end
		else
			paintedEntitiesCache[entity] = nil
		end
	end

	blurGoal = localPlayer.GetLocalVar(localPlayer, "blur", 0) + (hookRun("AdjustBlurAmount", blurGoal) or 0)

	if (blurDelta != blurGoal) then
		blurDelta = mathApproach(blurDelta, blurGoal, frameTime * 20)
	end

	if (blurDelta > 0 and !localPlayer.ShouldDrawLocalPlayer(localPlayer)) then
		ix.util.DrawBlurAt(0, 0, scrW, scrH, blurDelta)
	end

	self.BaseClass.PaintWorldTips(self.BaseClass)

	if (hook.Run("CanDrawAmmoHUD") != false) then
		local weapon = localPlayer.GetActiveWeapon(localPlayer)

		if (IsValid(weapon) and weapon.DrawAmmo != false) then
			local clip = weapon.Clip1(weapon)
			local clipMax = weapon:GetMaxClip1()
			local count = localPlayer.GetAmmoCount(localPlayer, weapon.GetPrimaryAmmoType(weapon))
			local secondary = localPlayer.GetAmmoCount(localPlayer, weapon.GetSecondaryAmmoType(weapon))
			local x, y = scrW - 80, scrH - 80

			if (secondary > 0) then
				ix.util.DrawBlurAt(x, y, 64, 64)

				surface.SetDrawColor(255, 255, 255, 5)
				surface.DrawRect(x, y, 64, 64)
				surface.SetDrawColor(255, 255, 255, 3)
				surface.DrawOutlinedRect(x, y, 64, 64)

				ix.util.DrawText(secondary, x + 32, y + 32, nil, 1, 1, "ixBigFont")
			end

			if (weapon.GetClass(weapon) != "weapon_slam" and clip > 0 or count > 0) then
				x = x - (secondary > 0 and 144 or 64)

				ix.util.DrawBlurAt(x, y, 128, 64)

				surface.SetDrawColor(255, 255, 255, 5)
				surface.DrawRect(x, y, 128, 64)
				surface.SetDrawColor(255, 255, 255, 3)
				surface.DrawOutlinedRect(x, y, 128, 64)

				ix.util.DrawText((clip == -1 or clipMax == -1) and count or clip.."/"..count, x + 64, y + 32, nil, 1, 1, "ixBigFont")
			end
		end
	end

	if (localPlayer.GetLocalVar(localPlayer, "restricted") and !localPlayer.GetLocalVar(localPlayer, "restrictNoMsg")) then
		ix.util.DrawText(L"restricted", scrW * 0.5, scrH * 0.33, nil, 1, 1, "ixBigFont")
	end

	ix.hud.DrawAll(false)
end

function GM:PostDrawHUD()
	ix.hud.DrawAll(true)
	ix.bar.DrawAll()
end

function GM:ShouldDrawEntityInfo(entity)
	local entityPlayer = entity:GetNetVar("player")

	if (entity:IsPlayer() or IsValid(entityPlayer)) then
		if ((entity == LocalPlayer() and !LocalPlayer():ShouldDrawLocalPlayer()) or LocalPlayer() == entityPlayer) then
			return false
		end

		return true
	end

	return false
end

local injTextTable = {
	[.3] = {"injMajor", Color(192, 57, 43)},
	[.6] = {"injLittle", Color(231, 76, 60)},
}

function GM:GetInjuredText(client)
	local health = client:Health()

	for k, v in pairs(injTextTable) do
		if ((health / LocalPlayer():GetMaxHealth()) < k) then
			return v[1], v[2]
		end
	end
end

local colorAlpha = ColorAlpha
local teamGetColor = team.GetColor
local drawText = ix.util.DrawText

function GM:DrawCharInfo(client, character, info)
	local injText, injColor = hookRun("GetInjuredText", client)

	if (injText) then
		info[#info + 1] = {L(injText), injColor}
	end
end

local charInfo = {}

function GM:DrawEntityInfo(entity, alpha, position)
	if (entity.IsPlayer(entity)) then
		local character = entity.GetChar(entity)

		position = position or toScreen(entity.GetPos(entity) + (entity.Crouching(entity) and OFFSET_CROUCHING or OFFSET_NORMAL))

		if (character) then
			local x, y = position.x, position.y

			charInfo = {}
			charInfo[1] = {hookRun("GetDisplayedName", entity) or character.GetName(character), teamGetColor(entity.Team(entity))}

			local description = character.GetDescription(character)

			if (description != entity.ixDescCache) then
				entity.ixDescCache = description
				entity.ixDescTrim = string.len(description) > 128 and string.format("%s...", string.sub(description, 1, 125)) or description
				entity.ixDescLines = ix.util.WrapText(entity.ixDescTrim, ScrW() * 0.7, "ixSmallFont")
			end

			for i = 1, #entity.ixDescLines do
				charInfo[#charInfo + 1] = {entity.ixDescLines[i]}
			end

			hookRun("DrawCharInfo", entity, character, charInfo)

			for i = 1, #charInfo do
				local info = charInfo[i]
				local _, newY = drawText(info[1], x, y, colorAlpha(info[2] or color_white, alpha), 1, 1, "ixSmallFont")

				y = y + newY
			end
		end
	end
end

function GM:KeyRelease(client, key)
	if (!IsFirstTimePredicted()) then
		return
	end

	if (key == IN_USE) then
		if (!ix.menu.IsOpen()) then
			local data = {}
			data.start = client:GetShootPos()
			data.endpos = data.start + client:GetAimVector() * 96
			data.filter = client

			local entity = util.TraceLine(data).Entity

			if (IsValid(entity) and isfunction(entity.GetEntityMenu)) then
				hook.Run("ShowEntityMenu", entity)
			end
		end

		timer.Remove("ixItemUse")

		client.ixInteractionTarget = nil
		client.ixInteractionStartTime = nil
	end
end

function GM:PlayerBindPress(client, bind, pressed)
	bind = bind:lower()

	if (bind:find("use") and pressed) then
		local pickupTime = ix.config.Get("itemPickupTime", 0.5)

		if (pickupTime > 0) then
			local data = {}
				data.start = client:GetShootPos()
				data.endpos = data.start + client:GetAimVector() * 96
				data.filter = client
			local entity = util.TraceLine(data).Entity

			if (IsValid(entity) and entity.ShowPlayerInteraction and !ix.menu.IsOpen()) then
				client.ixInteractionTarget = entity
				client.ixInteractionStartTime = SysTime()

				timer.Create("ixItemUse", pickupTime, 1, function()
					client.ixInteractionTarget = nil
					client.ixInteractionStartTime = nil
				end)
			end
		end
	elseif (bind:find("jump")) then
		local entity = Entity(client:GetLocalVar("ragdoll", 0))

		if (IsValid(entity)) then
			ix.command.Send("CharGetUp")
		end
	elseif (bind:find("speed") and client:KeyDown(IN_WALK) and pressed) then
		if (LocalPlayer():Crouching()) then
			RunConsoleCommand("-duck")
		else
			RunConsoleCommand("+duck")
		end
	end
end

-- Called when use has been pressed on an item.
function GM:ShowEntityMenu(entity)
	local options = entity:GetEntityMenu(LocalPlayer())

	if (istable(options) and table.Count(options) > 0) then
		ix.menu.Open(options, entity)
	end
end

local hidden = {}
hidden["CHudHealth"] = true
hidden["CHudBattery"] = true
hidden["CHudAmmo"] = true
hidden["CHudSecondaryAmmo"] = true
hidden["CHudCrosshair"] = true
hidden["CHudHistoryResource"] = true

function GM:HUDShouldDraw(element)
	if (hidden[element]) then
		return false
	end

	return true
end

function GM:ShouldDrawLocalPlayer(client)
	if (IsValid(ix.gui.char) and ix.gui.char:IsVisible()) then
		return false
	end
end

function GM:OnCharInfoSetup(infoPanel)
	if (infoPanel.model) then
		-- Get the F1 ModelPanel.
		local mdl = infoPanel.model
		local ent = mdl.Entity
		local client = LocalPlayer()

		if (client and client:Alive() and IsValid(client:GetActiveWeapon())) then
			local weapon = client:GetActiveWeapon()
			local weapModel = ClientsideModel(weapon:GetModel(), RENDERGROUP_BOTH)

			if (weapModel) then
				weapModel:SetParent(ent)
				weapModel:AddEffects(EF_BONEMERGE)
				weapModel:SetSkin(weapon:GetSkin())
				weapModel:SetColor(weapon:GetColor())
				weapModel:SetNoDraw(true)
				ent.weapon = weapModel

				local act = ACT_MP_STAND_IDLE
				local model = ent:GetModel():lower()
				local class = ix.anim.GetModelClass(model)
				local tree = ix.anim[class]

				if (tree) then
					local subClass = weapon.HoldType or weapon:GetHoldType()
					subClass = HOLDTYPE_TRANSLATOR[subClass] or subClass

					if (tree[subClass] and tree[subClass][act]) then
						local branch = tree[subClass][act]
						local act2 = type(branch) == "table" and branch[1] or branch

						if (type(act2) == "string") then
							--act2 = ent:LookupSequence(act2)
							return
						else
							act2 = ent:SelectWeightedSequence(act2)
						end

						ent:ResetSequence(act2)
					end
				end
			end
		end
	end
end

function GM:ShowPlayerOptions(client, options)
	options["viewProfile"] = {"icon16/user.png", function()
		if (IsValid(client)) then
			client:ShowProfile()
		end
	end}
	options["Copy Steam ID"] = {"icon16/user.png", function()
		if (IsValid(client)) then
			SetClipboardText(client:SteamID())
		end
	end}
end

function GM:DrawHelixModelView(panel, ent)
	if (ent.weapon and IsValid(ent.weapon)) then
		ent.weapon:DrawModel()
	end
end

netstream.Hook("strReq", function(time, title, subTitle, default)
	if (title:sub(1, 1) == "@") then
		title = L(title:sub(2))
	end

	if (subTitle:sub(1, 1) == "@") then
		subTitle = L(subTitle:sub(2))
	end

	Derma_StringRequest(title, subTitle, default or "", function(text)
		netstream.Start("strReq", time, text)
	end)
end)

function GM:PostPlayerDraw(client)
	if (client and client:GetChar() and client:GetNoDraw() != true) then
		local wep = client:GetActiveWeapon()
		local curClass = ((wep and wep:IsValid()) and wep:GetClass():lower() or "")

		for _, v in pairs(client:GetWeapons()) do
			if (v and IsValid(v)) then
				local class = v:GetClass():lower()
				local drawInfo = HOLSTER_DRAWINFO[class]

				if (drawInfo and drawInfo.model) then
					client.holsteredWeapons = client.holsteredWeapons or {}

					if (!client.holsteredWeapons[class] or !IsValid(client.holsteredWeapons[class])) then
						client.holsteredWeapons[class] = ClientsideModel(drawInfo.model, RENDERGROUP_TRANSLUCENT)
						client.holsteredWeapons[class]:SetNoDraw(true)
					end

					local drawModel = client.holsteredWeapons[class]
					local boneIndex = client:LookupBone(drawInfo.bone)

					if (boneIndex and boneIndex > 0) then
						local bonePos, boneAng = client:GetBonePosition(boneIndex)

						if (curClass != class and drawModel and IsValid(drawModel)) then
							local Right 	= boneAng:Right()
							local Up 		= boneAng:Up()
							local Forward 	= boneAng:Forward()

							boneAng:RotateAroundAxis(Right, drawInfo.ang[1])
							boneAng:RotateAroundAxis(Up, drawInfo.ang[2])
							boneAng:RotateAroundAxis(Forward, drawInfo.ang[3])

							bonePos = bonePos + drawInfo.pos[1] * Right
							bonePos = bonePos + drawInfo.pos[2] * Forward
							bonePos = bonePos + drawInfo.pos[3] * Up

							drawModel:SetRenderOrigin(bonePos)
							drawModel:SetRenderAngles(boneAng)
							drawModel:DrawModel()
						end
					end
				end
			end
		end

		if (client.holsteredWeapons) then
			for k, v in pairs(client.holsteredWeapons) do
				local weapon = client:GetWeapon(k)

				if (!weapon or !IsValid(weapon)) then
					v:Remove()
				end
			end
		end
	end
end

function GM:ScreenResolutionChanged(oldW, oldH)
	RunConsoleCommand("fixchatplz")
	hook.Run("LoadFonts", ix.config.Get("font"), ix.config.Get("genericFont"))
end

function GM:DrawDeathNotice()
	return false
end

function GM:HUDAmmoPickedUp()
	return false
end

function GM:HUDDrawPickupHistory()
	return false
end

function GM:HUDDrawTargetID()
	return false
end
