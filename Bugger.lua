local ADDON, addon = ...
local L = addon.L
Bugger = addon

local ICON_GRAY  = "Interface\\AddOns\\Bugger\\Bug-Gray"
local ICON_GREEN = "Interface\\AddOns\\Bugger\\Bug-Green"
local ICON_RED   = "Interface\\AddOns\\Bugger\\Bug-Red"

if GetLocale() == "deDE" then
	L["Errors"] = "Fehler"
	L["An error has been captured!"] = "Ein Fehler wurde eingefangen!"
	L["Click to open the error window."] = "Klick, um das Fehler-Fenster anzuzeigen."
	L["Alt-click to clear all saved errors."] = "Alt-klick, um alle gespeicherten Fehler zu löschen."
	L["All saved errors have been deleted."] = "Alle gespeicherten Fehler wurden gelöscht."
	L["Shift-click to reload the UI."] = "Shift-klick, um die UI neuzuladen."
	L["Right-click for options."] = "Rechtsklick für Optionen."
elseif GetLocale():match("^es") then
	L["Errors"] = "Errors"
	L["An error has been captured!"] = "Un error se ha capturado!"
	L["Click to open the error window."] = "Clic para mostrar el error más reciente."
	L["Alt-click to clear all saved errors."] = "Alt-clic para borrar todos errores guardados."
	L["All saved errors have been deleted."] = "Todos los errores guardados se han borrados."
	L["Shift-click to reload the UI."] = "Mayús-clic para recargar la IU."
	L["Right-click for options."] = "Clic derecho para opciones."
end

addon.db = "BuggerDB"
addon.dbDefaults = {
	limit = 50,    -- maximum number of errors to keep in the DB
	chat = false,  -- show a message in the chat frame when an error is captured
	sound = false, -- play a sound when an error is captured
	minimap = {},
}

addon.dataObject = {
	type = "data source",
	icon = ICON_GREEN,
	label = L["Errors"],
	text = "0",
	OnClick = function(self, button)
		if button == "RightButton" then
			-- TODO: options
		elseif IsShiftKeyDown() then
			ReloadUI()
		elseif IsAltKeyDown() then
			-- TODO: clear errors
		else
			-- TODO: open window to latest error
		end
	end,
	OnTooltipShow = function(tt)
		tt:AddLine(BUGGER, 1, 1, 1)
		tt:AddLine(L["Click to open the error window."])
		tt:AddLine(L["Alt-click to clear all saved errors."])
		tt:AddLine(L["Shift-click to reload the UI."])
		tt:AddLine(L["Right-click for options."])
	end,
}

function addon:OnLoad()
	-- TODO: register for BugGrabber callbacks

	LibStub("LibDataBroker-1.1"):NewDataObject(ADDON, self.dataObject)

	-- Only create a minimap icon if the user doesn't have another Broker display
	local displays = { "Barrel", "Bazooka", "ButtonBin", "ChocolateBar", "DockingStation", "HotCorners", "NinjaPanel", "StatBlockCore", "TitanPanel" }
	if GetAddOnEnableState then
		-- WOD
		local character = UnitName("player")
		for i = 1, #displays do
			if GetAddOnEnableState(character, displays[i]) then
				return
			end
		end
	else
		-- MOP
		for i = 1, #displays do
			local _, _, _, enabled = GetAddOnInfo(displays[i])
			if enabled then
				return
			end
		end
	end
	LibStub("LibDBIcon-1.0"):Register(ADDON, self.dataObject, self.db.settings.minimap)
end

function addon:OnLogin()
	-- nothing to do here?
end

function addon:OnLogout()
	-- nothing to do here?
end

--[[
	errorObject = {
		message = sanitizedMessage,
		stack = table.concat(tmp, "\n"),
		locals = debuglocals(4),
		session = BugGrabber:GetSessionId(),
		time = date("%Y/%m/%d %H:%M:%S"),
		counter = 1,
	}
]]
function addon:BugGrabber_BugGrabbed(errorObject)
	self.dataObject.icon = ICON_RED
	if self.db.chat then
		DEFAULT_CHAT_FRAME:AddMessage("|cffff9f7fBugger:|r " .. L["An error has been captured!"])
	end
	if self.db.sound then
		PlaySoundFile(self.db.sound, "Master")
	end
end

function addon:BugGrabber_CapturePaused()
	self.dataObject.icon = ICON_GRAY
	-- TODO: how to detect when it's resumed?
end

--[[ Print the error to the chat frame
function addon:FormatError(errorTable)
	-- !BugGrabber's default printing is OK, just leave it alone.
end
]]

function addon:CreateUI()
	local frame = CreateFrame("Frame", "BuggerFrame", UIParent, "UIPanelDialogTemplate")
	self.frame = frame

	frame:Hide()
	frame:SetMovable(true)
	frame:SetClampedToScreen(true)
	frame:SetToplevel(true)
	frame:SetSize(384, 260)
	frame:SetPoint("CENTER")

	local index = frame:CreateFontString(nil, "ARTWORK", "GameFontNormalCenter")
	index:SetSize(70, 16)
	index:SetPoint("BOTTOMLEFT", 208, 16)
	frame.index = index

	local title = CreateFrame("Button", nil, frame)
	title:SetPoint("TOPLEFT", "BuggerFrameTitleBG")
	title:SetPoint("TOPRIGHT", "BuggerFrameTitleBG")
	title:RegisterForDrag("LeftButton")
	title:SetScript("OnDragStart", function() frame:StartMoving() end)
	title:SetScript("OnDragStop", function() frame:StopMovingOrSizing() end)
	frame.title = title

	local scroll = CreateFrame("ScrollFrame", "$parentScrollFrame", frame, "UIPanelScrollFrameTemplate")
	scroll:SetSize(343, 194)
	scroll:SetPoint("TOPLEFT", 12, -30)
	frame.scrollFrame = scroll

	local edit = CreateFrame("EditBox", nil, scroll)
	scroll:SetScrollChild(edit)

	edit:SetMultiLine(true)
	edit:SetAutoFocus(false)
	edit:SetSize(343, 914)
	edit:SetFontObject(GameFontHighlightSmall)
	edit:SetScript("OnCursorChanged", ScrollingEdit_OnCursorChanged)
	edit:SetScript("OnEscapePressed", EditBox_ClearFocus)
	edit:SetScript("OnEditFocusGained", function(self) self:HighlightText(0) end)
	edit:SetScript("OnUpdate", function(self, elapsed) ScrollingEdit_OnUpdate(self, elapsed, scroll) end)
	frame.editBox = edit

	local prev = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
end

function addon:ToggleUI()
	if self.frame and self.frame:IsShown() then
		self.frame:Hide()
	else
		if not self.frame then
			self:CreateUI()
		end
		self.frame:Show()
	end
end

function addon:ShowError(id, session)
end
