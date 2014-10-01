local BUGGER, Bugger = ...

if not BugGrabber then
	function Bugger:OnLogin()
		DEFAULT_CHAT_FRAME:AddMessage(L["Bugger can't function without !BugGrabber. Find it on Curse or WoWInterface."])
	end
	return
end

_G[BUGGER] = Bugger

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

local L = Bugger.L

local c = {
	BLUE   = BATTLENET_FONT_COLOR_CODE,
	GOLD   = NORMAL_FONT_COLOR_CODE,
	GRAY   = "|cff9f9f9f",
	GREEN  = "|cff7fff7f",
	ORANGE = "|cffff9f7f",
	PURPLE = "|cff9f7fff",
}

------------------------------------------------------------------------

Bugger.dataObject = {
	type = "data source",
	icon = ICON_GREEN,
	text = 0,
	label = L["Errors"],
	OnClick = function(self, button)
		if button == "RightButton" then
			-- TODO: options
		elseif IsControlKeyDown() then
			ReloadUI()
		elseif IsAltKeyDown() then
			BugGrabber:Reset()
		else
			Bugger:ToggleFrame()
		end
	end,
	OnTooltipShow = function(tt)
		local total = Bugger:GetNumErrors()

		tt:AddDoubleLine(BUGGER, total > 0 and total or "", nil, nil, nil, 1, 1, 1)

		if total > 0 then
			tt:AddLine(" ")
			local errors = BugGrabber:GetDB()
			for i = 1, min(total, 3) do
				local err = errors[#errors + 1 - i]
				tt:AddLine(format("%s%d.|r %s", c.GRAY, total + 1 - i, Bugger:FormatError(err, true)), 1, 1, 1)
			end
			tt:AddLine(" ")
		end

		tt:AddLine(L["Click to open the error window."])
		tt:AddLine(L["Alt-click to clear all saved errors."])
		tt:AddLine(L["Ctrl-click to reload the UI."])
	--	tt:AddLine(L["Right-click for options."]) -- TODO
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
	BugGrabber.RegisterCallback(self, "BugGrabber_BugGrabbed")
	if self:GetNumErrors() > 0 then
		return self:BugGrabber_BugGrabbed()
	end
end

function Bugger:OnLogout()
	-- nothing to do here?
end

hooksecurefunc(BugGrabber, "Reset", function()
	Bugger:Print(L["All saved errors have been deleted."])

	Bugger.dataObject.icon = ICON_GREEN
	Bugger.dataObject.text = 0
end)

function Bugger:GetNumErrors(session)
	local errors = BugGrabber:GetDB()
	local total = #errors
	if total == 0 then return end

	if session == "all" then
		return total, 1, total
	end

	if session == "previous" then
		session = BugGrabber:GetSessionId() - 1
	else
		session = BugGrabber:GetSessionId()
	end

	local total, first, last = 0
	for i = 1, #errors do
		if errors[i].session == session then
			total = total + 1
			first = first or i
			last = i
		end
	end
	return total, first, last
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
function Bugger:BugGrabber_BugGrabbed(callback, err)
	self.dataObject.text = self:GetNumErrors()
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

------------------------------------------------------------------------

do
	local FILE_TEMPLATE   = c.GRAY .. "%1%2\\|r%3:" .. c.GREEN .. "%4|r" .. c.GRAY .. "%5|r%6"
	local STRING_TEMPLATE = c.GRAY .. "%1[string |r\"" .. c.BLUE .. "%2\"|r" .. c.GRAY .. "]|r:" .. c.GREEN .. "%3|r" .. c.GRAY .. "%4|r%5"
	local NAME_TEMPLATE   = c.BLUE .. "'%1'|r"

	function Bugger:FormatStack(message, stack)
		message = message and tostring(message)
		if not message then return "" end
		stack = stack and tostring(stack)
		if stack then
			message = message .. "\n" .. stack
		end
		message = gsub(message, "(<?)Interface\\A?d?d?[Oo]?n?s?\\?(%a+)\\(.-%.[lx][um][al]):(%d+)(>?)(:?)", FILE_TEMPLATE)
		message = gsub(message, "(<?)%[string \"(.-)\"]:(%d+)(>?)(:?)", STRING_TEMPLATE)
		message = gsub(message, "['`]([^`']+)'", NAME_TEMPLATE)
		return message
	end
end

do
	local LOCALS_TEMPLATE = "\n\n" .. c.GOLD .. "Locals:|r%s"
	local EQUALS  = c.GRAY .. " = |r"
	local BOOLEAN = EQUALS .. c.PURPLE .. "%1"
	local NUMBER  = EQUALS .. c.ORANGE .. "%1"
	local STRING  = EQUALS .. c.BLUE .. "\"%1\""
	-- TODO: color other types

	function Bugger:FormatLocals(locals)
		locals = locals and tostring(locals)
		if not locals then return "" end
		locals = "\n" .. locals
		locals = gsub(locals, " = ([ft][ar][lu]s?e)", BOOLEAN)
		locals = gsub(locals, " = (%d+)", NUMBER)
		locals = gsub(locals, " = \"(.-)\"", STRING)
		return format(LOCALS_TEMPLATE, locals)
	end
end

do
	local FULL_TEMPLATE = "%d" .. c.GRAY .. "x|r %s%s"
	local SHORT_TEMPLATE = "%s " .. c.GRAY .. "(x%d)|r"

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

	self.frame:Show()

	local total, first, last = self:GetNumErrors(self.session)

	if total == 0 then
		self.current = 0
		self.editBox:SetText(c.GRAY .. L["There are no errors to display."])
		self.editBox:SetCursorPosition(0)
		self.editBox:ClearFocus()
		self.scrollFrame:SetVerticalScroll(0)
		self.previous:Disable()
		self.next:Disable()
		self.clear:SetEnabled(#AllErrors > 0)
		return
	end

	local errors = BugGrabber:GetDB()
	local err = index and index >= first and index <= last and errors[index]
	if not err then
		index = last
		err = errors[index]
	end

	self.first, self.last, self.current = first, last, index
	
	-- TODO: set title text

	self.indexLabel:SetFormattedText("%d / %d", index + 1 - first, total)

	self.editBox:SetText(self:FormatError(err))
	self.editBox:SetCursorPosition(strlen(err.message))
	self.editBox:ClearFocus()

	self.scrollFrame:SetVerticalScroll(0)

	self.previous:SetEnabled(index > first)
	self.next:SetEnabled(index < last)
	self.clear:Enable()
end

------------------------------------------------------------------------

function Bugger:SwitchSession(session)
	if session ~= "all" and session ~= "previous" then
		session = "current"
	end
	self.session = session
	self:ShowError()
end

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
	ScriptErrorsFrame_Update  = function() end

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

	self.editBox:SetFontObject(GameFontHighlight)
	self.editBox:SetTextColor(0.9, 0.9, 0.9)

	local addWidth = 150
	self.frame:SetWidth(self.frame:GetWidth() + addWidth)
	self.scrollFrame:SetWidth(self.scrollFrame:GetWidth() + addWidth - 4)
	self.editBox:SetWidth(self.editBox:GetWidth() + addWidth)

	local addHeight = 50
	self.frame:SetHeight(self.frame:GetHeight() + addHeight)
	self.scrollFrame:SetHeight(self.scrollFrame:GetHeight() + addHeight - 4)

	self.scrollFrame:SetPoint("TOPLEFT", 16, -32)
	self.scrollFrame.ScrollBar:SetPoint("TOPLEFT", self.scrollFrame, "TOPRIGHT", 6, -13)

	self.clear:ClearAllPoints()
	self.clear:SetPoint("BOTTOMLEFT", 12, 12)
	self.clear:SetText(CLEAR_ALL)
	self.clear:SetWidth(self.clear:GetFontString():GetStringWidth() + 20)
	self.clear:SetScript("OnClick", function()
		BugGrabber:Reset()
		self:ShowError()
	end)

	self.next:ClearAllPoints()
	self.next:SetPoint("BOTTOMRIGHT", -10, 12)

	self.previous:ClearAllPoints()
	self.previous:SetPoint("RIGHT", self.next, "LEFT", -4, 0)

	self.indexLabel:ClearAllPoints()
	self.indexLabel:SetPoint("LEFT", self.clear, "RIGHT", 4, 0)
	self.indexLabel:SetPoint("RIGHT", self.previous, "LEFT", -4, 0)
	self.indexLabel:SetJustifyH("CENTER")

	self.current = 0

	self.previous:SetScript("OnClick", function()
		if IsShiftKeyDown() then
			self:ShowError(self.first)
		else
			self:ShowError(self.current - 1)
		end
	end)

	self.next:SetScript("OnClick", function()
		if IsShiftKeyDown() then
			self:ShowError(self.last)
		else
			self:ShowError(self.current + 1)
		end
	end)
	
	-- TODO: add tabs along the bottom
	
	-- TODO: add button for opening options
end

------------------------------------------------------------------------

SLASH_BUGGER1 = "/bugger"
SLASH_BUGGER2 = L["/bugger"]

SlashCmdList["BUGGER"] = function(cmd)
	cmd = strlower(strtrim(cmd or ""))
	if cmd == "reset" then
		BugGrabber:Reset()
	else
		Bugger:ToggleFrame()
	end
end
