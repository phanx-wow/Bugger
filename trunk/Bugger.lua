local BUGGER, Bugger = ...

if not BugGrabber then
	function Bugger:OnLogin()
		DEFAULT_CHAT_FRAME:AddMessage(L["Bugger can't function without !BugGrabber. Find it on Curse or WoWInterface."])
	end
	return
end

------------------------------------------------------------------------

Bugger.db = "BuggerDB"
Bugger.dbDefaults = {
	chat  = true,  -- show a message in the chat frame when an error is captured
	sound = false, -- play a sound when an error is captured
	minimap = {},
}

------------------------------------------------------------------------

local MIN_INTERVAL = 10

local ICON_GRAY  = "Interface\\AddOns\\Bugger\\Icons\\Bug-Gray"
local ICON_GREEN = "Interface\\AddOns\\Bugger\\Icons\\Bug-Green"
local ICON_RED   = "Interface\\AddOns\\Bugger\\Icons\\Bug-Red"

local ERRORS, CURRENT_SESSION

local L = Bugger.L

_G[BUGGER] = Bugger

------------------------------------------------------------------------

Bugger.dataObject = {
	type = "data source",
	icon = ICON_GREEN,
	text = 0,
	label = L["Errors"],
	OnClick = function(self, button)
		if button == "RightButton" then
			-- TODO: options
		elseif IsShiftKeyDown() then
			ReloadUI()
		elseif IsAltKeyDown() then
			Bugger:Reset()
		else
			Bugger:ToggleFrame()
		end
	end,
	OnTooltipShow = function(tt)
		local total = 0
		for i = #ERRORS, 1, -1 do
			if ERRORS[i].session ~= CURRENT_SESSION then
				break
			end
			total = total + 1
		end

		tt:AddDoubleLine(BUGGER, total > 0 and total or "", nil, nil, nil, 1, 1, 1)

		if total > 0 then
			tt:AddLine(" ")
			for i = 1, min(total, 3) do
				local err = ERRORS[#ERRORS + 1 - i]
				tt:AddLine(format("%s%d.|r %s", GRAY_FONT_COLOR_CODE, total + 1 - i, Bugger:FormatError(err, true)), 1, 1, 1)
			end
			tt:AddLine(" ")
		end

		tt:AddLine(L["Click to open the error window."])
		tt:AddLine(L["Alt-click to clear all saved errors."])
		tt:AddLine(L["Shift-click to reload the UI."])
		tt:AddLine(L["Right-click for options."])
	end,
}

------------------------------------------------------------------------

function Bugger:OnLoad()
	LibStub("LibDataBroker-1.1"):NewDataObject(BUGGER, self.dataObject)

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
	LibStub("LibDBIcon-1.0"):Register(BUGGER, self.dataObject, self.db.settings.minimap)
end

function Bugger:OnLogin()
	ERRORS = BugGrabber:GetDB()
	CURRENT_SESSION = BugGrabber:GetSessionId()

	BugGrabber.RegisterCallback(self, "BugGrabber_BugGrabbed")

	for i = #ERRORS, 1, -1 do
		if ERRORS[i].session == CURRENT_SESSION then
			return self:BugGrabber_BugGrabbed()
		end
	end
end

function Bugger:OnLogout()
	-- nothing to do here?
end

function Bugger:Reset()
	BugGrabber:Reset()
	self:Print(L["All saved errors have been deleted."])
	self.dataObject.icon = ICON_GREEN
	self.dataObject.text = 0
end

------------------------------------------------------------------------

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
function Bugger:BugGrabber_BugGrabbed(errorObject)
	local n = 0
	for i = #ERRORS, 1, -1 do
		if ERRORS[i].session == CURRENT_SESSION then
			n = n + 1
		end
	end
	self.dataObject.text = n
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

function Bugger:BugGrabber_CapturePaused()
	-- self.dataObject.icon = ICON_GRAY
	-- TODO: how to detect when it's resumed?
end

------------------------------------------------------------------------

do
	local FILE_TEMPLATE   = GRAY_FONT_COLOR_CODE .. "%1\\|r%2:" .. GREEN_FONT_COLOR_CODE .. "%3|r:"
	local STRING_TEMPLATE = GRAY_FONT_COLOR_CODE .. "%1[string |r\"" .. BATTLENET_FONT_COLOR_CODE .. "%2\"|r" .. GRAY_FONT_COLOR_CODE .. "]|r:" .. GREEN_FONT_COLOR_CODE .. "%3|r" .. GRAY_FONT_COLOR_CODE .. "%4|r%5"
	local NAME_TEMPLATE   = BATTLENET_FONT_COLOR_CODE .. "'%1'|r"

	function Bugger:FormatStack(message, stack)
		message = message and tostring(message)
		if not message then return "" end
		stack = stack and tostring(stack)
		if stack then
			message = message .. "\n" .. stack
		end
		message = gsub(message, "Interface\\(%a+)\\(.-%.[lx][um][al]):(%d+):", FILE_TEMPLATE)
		message = gsub(message, "(<?)%[string \"(.-)\"]:(%d+)(>?)(:?)", STRING_TEMPLATE)
		message = gsub(message, "['`]([^`']+)'", NAME_TEMPLATE)
		return message
	end
end

do
	local LOCALS_TEMPLATE = "\n\n" .. NORMAL_FONT_COLOR_CODE .. "Locals:|r\n%s"
	local LOCAL_STRING = "%1 " .. GRAY_FONT_COLOR_CODE .. "=|r " .. BATTLENET_FONT_COLOR_CODE .. "\"%2\""

	function Bugger:FormatLocals(locals)
		locals = locals and tostring(locals)
		if not locals then return "" end
		locals = gsub(locals, "(%a+) = \"(.-)\"\n", LOCAL_STRING)
		return format(LOCALS_TEMPLATE, locals)
	end
end

do
	local FULL_TEMPLATE = "%d" .. GRAY_FONT_COLOR_CODE .. "x|r %s%s"
	local SHORT_TEMPLATE = "%s " .. GRAY_FONT_COLOR_CODE .. "(x%d)|r"

	function Bugger:FormatError(err, short)
		if short then
			return format(SHORT_TEMPLATE, self:FormatStack(err.message), err.counter or 1)
		end
		return format(FULL_TEMPLATE, err.counter or 1, self:FormatStack(err.message, err.stack), self:FormatLocals(err.locals))
	end
end

------------------------------------------------------------------------

function Bugger:ShowError(index)
	if not self.frame then
		self:SetupFrame()
	end

	local total, first, last = 0
	for i = 1, #ERRORS do
		if ERRORS[i].session == CURRENT_SESSION then
			total = total + 1
			first = first or i
			last = i
		end
	end

	self.frame:Show()

	if not ERRORS or #ERRORS == 0 or total == 0 then
		print(ERRORS and "db." or "NO DB!", ERRORS and #ERRORS or "", total)
		self.currentError = 0
		self.editBox:SetText(GRAY_FONT_COLOR_CODE .. L["No errors have been captured."])
		self.editBox:SetCursorPosition(0)
		self.editBox:ClearFocus()
		self.scrollFrame:SetVerticalScroll(0)
		self.previous:Disable()
		self.next:Disable()
		self.clear:Disable()
		return
	end

	if not index or index < first or index > last then
		index = #ERRORS -- default to most recent error
	end

	local err = ERRORS[index]

	if not err then
		err = ERRORS[#ERRORS]
	end

	self.currentError = index

	local old = #ERRORS - total
	self.indexLabel:SetFormattedText("%d / %d", index - old, total)

	self.editBox:SetText(self:FormatError(err))
	self.editBox:SetCursorPosition(strlen(err.message))
	self.editBox:ClearFocus()

	self.scrollFrame:SetVerticalScroll(0)

	self.previous:SetEnabled(index > first)
	self.next:SetEnabled(index < last)
	self.clear:Enable()
end

------------------------------------------------------------------------

function Bugger:ToggleFrame()
	if self.frame and self.frame:IsShown() then
		self.frame:Hide()
	else
		self:ShowError()
	end
end

function Bugger:SetupFrame()
	if not IsAddOnLoaded("Blizzard_DebugTools") then
		LoadAddOn("Blizzard_DebugTools")
	end

	ScriptErrorsFrame_OnError = function() end
	ScriptErrorsFrame_Update = function() end

	self.frame       = ScriptErrorsFrame
	self.scrollFrame = ScriptErrorsFrameScrollFrame
	self.editBox     = ScriptErrorsFrameScrollFrameText
	self.title       = self.frame.title
	self.indexLabel  = self.frame.indexLabel
	self.previous    = self.frame.previous
	self.next        = self.frame.next
	self.clear       = self.frame.close

	self.frame:SetParent(UIParent)
	self.frame:SetScript("OnShow", nil)
	tinsert(UISpecialFrames, self.frame) -- close on Escape

	self.editBox:SetFontObject(GameFontHighlight)
	self.editBox:SetTextColor(0.9, 0.9, 0.9)

	local addWidth = 150
	self.frame:SetWidth(self.frame:GetWidth() + addWidth)
	self.scrollFrame:SetWidth(self.scrollFrame:GetWidth() + addWidth)
	self.editBox:SetWidth(self.editBox:GetWidth() + addWidth)

	local addHeight = 50
	self.frame:SetHeight(self.frame:GetHeight() + addHeight)
	self.scrollFrame:SetHeight(self.scrollFrame:GetHeight() + addHeight)

	self.clear:ClearAllPoints()
	self.clear:SetPoint("BOTTOMLEFT", 12, 12)
	self.clear:SetText(CLEAR_ALL)
	self.clear:SetScript("OnClick", function() self:Reset() self:ShowError() end)

	self.next:ClearAllPoints()
	self.next:SetPoint("BOTTOMRIGHT", -10, 12)

	self.previous:ClearAllPoints()
	self.previous:SetPoint("RIGHT", self.next, "LEFT", -4, 0)

	self.indexLabel:ClearAllPoints()
	self.indexLabel:SetPoint("LEFT", self.clear, "RIGHT", 4, 0)
	self.indexLabel:SetPoint("RIGHT", self.previous, "LEFT", -4, 0)
	self.indexLabel:SetJustifyH("CENTER")

	self.currentError = 0

	self.previous:SetScript("OnClick", function()
		if IsShiftKeyDown() then
			for i = 1, #ERRORS do
				if ERRORS[i].session == CURRENT_SESSION then
					return self:ShowError(i)
				end
			end
		else
			self:ShowError(self.currentError - 1)
		end
	end)

	self.next:SetScript("OnClick", function()
		if IsShiftKeyDown() then
			for i = #ERRORS, 1, -1 do
				if ERRORS[i].session == CURRENT_SESSION then
					return self:ShowError(i)
				end
			end
		else
			self:ShowError(self.currentError + 1)
		end
	end)
end

------------------------------------------------------------------------

SLASH_BUGGER1 = "/bugger"
SLASH_BUGGER2 = L["/bugger"]

SlashCmdList["BUGGER"] = function(cmd)
	cmd = strlower(strtrim(cmd or ""))
	if cmd == "reset" then
		Bugger:Reset()
	else
		Bugger:ToggleFrame()
	end
end
