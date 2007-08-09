

local TourGuide = TourGuide
local ww = WidgetWarlock


local ROWHEIGHT = 26
local ROWOFFSET = 4
local NUMROWS = math.floor(305/(ROWHEIGHT+4))


local offset = 0


local function OnShow()
	offset = TourGuide.current - NUMROWS/2 - 1
	if offset < 0 then offset = 0
	elseif (offset + NUMROWS) > #TourGuide.actions then offset = #TourGuide.actions - NUMROWS end
	TourGuide:UpdateOHPanel()
end


function TourGuide:CreateObjectivePanel()
	local frame = ww.SummonOptionHouseBaseFrame()

	frame.rows = {}
	for i=1,NUMROWS do
		local row = CreateFrame("Button", nil, frame)
		row:SetPoint("TOPLEFT", i == 1 and frame or frame.rows[i-1], i == 1 and "TOPLEFT" or "BOTTOMLEFT", 0, -ROWOFFSET)
		row:SetWidth(630)
		row:SetHeight(ROWHEIGHT)

		local check = ww.SummonCheckBox(ROWHEIGHT, row, "TOPLEFT", ROWOFFSET, 0)
		local icon = ww.SummonTexture(row, ROWHEIGHT, ROWHEIGHT, nil, "TOPLEFT", check, "TOPRIGHT", ROWOFFSET, 0)
		local text = ww.SummonFontString(row, nil, nil, "GameFontNormal", nil, "LEFT", icon, "RIGHT", ROWOFFSET, 0)
		local detail = ww.SummonFontString(row, nil, nil, "GameFontNormal", nil, "RIGHT", -ROWOFFSET, 0)
		detail:SetPoint("LEFT", text, "RIGHT", ROWOFFSET*3, 0)
		detail:SetJustifyH("RIGHT")
		detail:SetTextColor(240/255, 121/255, 2/255)

		check:SetScript("OnClick", function(f) self:SetTurnedIn(row.i, f:GetChecked()) end)

		row.text = text
		row.detail = detail
		row.check = check
		row.icon = icon
		frame.rows[i] = row
	end

	frame:EnableMouseWheel()
	frame:SetScript("OnMouseWheel", function(f, val)
		offset = offset - val
		if offset < 0 then offset = 0
		elseif (offset + NUMROWS) > #self.actions then offset = #self.actions - NUMROWS end
		self:UpdateOHPanel()
	end)

	self.OHFrame = frame
	frame:SetScript("OnShow", OnShow)
	OnShow()
	return frame
end


local accepted = {}
function TourGuide:UpdateOHPanel()
	if not self.OHFrame or not self.OHFrame:IsVisible() then return end

	for i in pairs(accepted) do accepted[i] = nil end

	for i,row in ipairs(self.OHFrame.rows) do
		row.i = i + offset
		local action, name, note, logi, complete, hasitem, turnedin, fullquestname = self:GetObjectiveInfo(i + offset)
		local shortname = name:gsub("%s%(Part %d+%)", "")
		logi = not turnedin and (accepted[name] or not accepted[shortname]) and logi
		complete = not turnedin and (accepted[name] or not accepted[shortname]) and complete
		local checked = turnedin or action == "ACCEPT" and logi or action == "COMPLETE" and complete

		if action == "ACCEPT" and logi then
			accepted[name] = true
			accepted[shortname] = true
		end

		row.icon:SetTexture(self.icons[action])
		row.text:SetText(name)
		row.detail:SetText(note)
		row.check:SetChecked(checked)
	end
end


