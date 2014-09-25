if not BugGrabber then
	return DEFAULT_CHAT_FRAME:AddMessage("Bugger requires !BugGrabber.")
end

local ADDON, addon = ...
local L = addon.L
Bugger = addon

local MIN_INTERVAL = 10

local ICON_GRAY  = "Interface\\AddOns\\Bugger\\Icons\\Bug-Gray"
local ICON_GREEN = "Interface\\AddOns\\Bugger\\Icons\\Bug-Green"
local ICON_RED   = "Interface\\AddOns\\Bugger\\Icons\\Bug-Red"

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
	BugGrabber.RegisterCallback(self, "BugGrabber_BugGrabbed")

	local session = BugGrabber:GetSessionId()
	for i, err in next, BugGrabber:GetDB() do
		if err.session == session then
			self:BugGrabber_BugGrabbed()
			break
		end
	end
end

function addon:OnLogout()
	-- nothing to do here?
end

function addon:Reset()
	BugGrabber:Reset()
	self:Print(L["All saved errors have been deleted."])
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
	if (self.lastError or 0) + MIN_INTERVAL < GetTime() then
		if self.db.chat then
			self:Print(L["An error has been captured!"])
		end
		if self.db.sound then
			PlaySoundFile(self.db.sound, "Master")
		end
	end
	self.lastError = GetTime()
end

function addon:BugGrabber_CapturePaused()
	-- self.dataObject.icon = ICON_GRAY
	-- TODO: how to detect when it's resumed?
end

--[[ Print the error to the chat frame
function addon:FormatError(errorTable)
	-- !BugGrabber's default printing is OK, just leave it alone.
end
]]

function addon:ToggleUI()
	if self.frame:IsShown() then
		self.frame:Hide()
	else
		self:ShowError(self.currentIndex)
	end
end

function addon:FormatError(err)

end

function addon:ShowError(id)
	local db = BugGrabber:GetDB()
	local total, first, last = 0
		if db then
		local session = BugGrabber:GetSessionId()
		for i, err in next, db do
			if err.session == session then
				total = total + 1
				first = first or i
				last = i
			end
		end
	end
	if not db or #db == 0 or total == 0 then
		return self.frame and self.frame:Hide()
	end

	if not self.frame then
		self:SetupFrame()
	end

	if not id then
		id = #db -- default to most recent error
	end

	local err = db[id]

	if not err then
		err = db[#db]
	end

	local old = #db - total
	self.frame.indexLabel:SetFormattedText(INDEX_ORDER_FORMAT, id - old, total)

	self.editBox:SetText(err.message)
	self.editBox:HighlightText(0)
	self.editBox:SetCursorPosition(0)

	self.scrollFrame:SetVerticalScroll(0)

	self.frame.previous:SetEnabled(id > first)
	self.frame.next:SetEnabled(id < last)

	self.frame:Show()
end

function addon:SetupFrame()
	if not IsAddOnLoaded("Blizzard_DebugTools") then
		LoadAddOn("Blizzard_DebugTools")
	end

	ScriptErrorsFrame_OnError = function() end
	ScriptErrorsFrame_Update = function() end

	self.frame = ScriptErrorsFrame
	self.frame:SetScript("OnShow", nil)
	
	self.scrollFrame = ScriptErrorsFrameScrollFrame

	self.editBox = ScriptErrorsFrameScrollFrameText
	self.editBox:SetFontObject(GameFontHighlightSmall)
	
	self.frame.previous:SetScript("OnClick", function()
	end)
	self.frame.next:SetScript("OnClick", function()
	end)
end
