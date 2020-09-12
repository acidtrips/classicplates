--[[

    options.lua

    Contains functions that add options to blizzard's interface options panel

--]]
local _G, CreateFrame, InterfaceOptionsNamesPanel, GetNamePlates, UnitExists, GRAY_FONT_COLOR, HIGHLIGHT_FONT_COLOR =
      _G, CreateFrame, InterfaceOptionsNamesPanel, C_NamePlate.GetNamePlates, UnitExists, GRAY_FONT_COLOR, HIGHLIGHT_FONT_COLOR

local OptionCheckButtons = {}
OptionCheckButtons["ShowAggroWarning"] = {var = "showAggroWarnings", dependsOn = nil, text = "Display Aggro Warnings", toolTipText = "Turn this on to enable aggro warnings.\r\n\r\nThis will show a glow around nameplates colored to represent the level of threat you have with each unit.", point = "BOTTOMLEFT", x = 16, y = 95, smallFont = nil, updateFunc = "UpdateThreat"}
OptionCheckButtons["ShowCastBars"] = {var = "showCastBars", text = "Show Cast Bars", dependsOn = {"InterfaceOptionsCurrentTargetOnlyButton", "InterfaceOptionsShowSpellNamesButton"}, toolTipText = "Turn this on to show cast bars on nameplates.", point = "BOTTOMLEFT", x = 16, y = 65, smallFont = nil, updateFunc = "UpdateCastBar"}
OptionCheckButtons["CurrentTargetOnly"] = {var = "showCastBarsTargetOnly", dependsOn = nil, text = "Current Target Only", toolTipText = "Turn this on to show the cast bar for your current target only.", point = "BOTTOMLEFT", x = 26, y = 44, smallFont = true, updateFunc = "UpdateCastBar"}
OptionCheckButtons["ShowSpellNames"] = {var = "showCastBarsSpellName", dependsOn = nil, text = "Show Spell Name", toolTipText = "Turn this on to show the spell name on cast bars.", point = "BOTTOMLEFT", x = 26, y = 23,  smallFont = true, updateFunc = "UpdateCastBar"}
OptionCheckButtons["ShowClassColors"] = {var = "showClassColors", dependsOn = nil, text = "Show Class Color", toolTipText = "Turn this on to use enemy class colors on healthbars.", point = "BOTTOMRIGHT", x = -295, y = 95, smallFont = nil, updateFunc = "UpdateHealthColor"}


local function OptionCheckButton_SetEnabledState(button, isEnabled)
  if ( isEnabled ) then
    button.Text:SetTextColor(HIGHLIGHT_FONT_COLOR:GetRGB())
    button:Enable()
  else
    button.Text:SetTextColor(GRAY_FONT_COLOR:GetRGB())
    button:Disable()
  end
end


local function OptionCheckButton_Update(self, doUpdate)
  local isChecked = self:GetChecked()
  if ( self.dependsOn ) then
    for _, name in pairs(self.dependsOn) do
      local button = _G[name]
      if ( button ) then
        OptionCheckButton_SetEnabledState(button, isChecked)
      end
    end
  end
  if ( self.var ) then
    ClassicPlatesOptions[self.var] = isChecked
  end
  if ( self.updateFunc ) then
    for _, frame in pairs(GetNamePlates()) do
      local nameplate = frame.NamePlate
      if ( nameplate and UnitExists(nameplate.unit) ) then
        nameplate:UpdateOption(self.var, isChecked, self.updateFunc, doUpdate)
      end
    end
  end
end


local function OptionCheckButton_OnClick(self)
  OptionCheckButton_Update(self, true)
end


local function OptionCheckButton_OnShow(self)
  OptionCheckButton_Update(self, nil)
end


local function OptionCheckButton_Create(buttonName, buttonInfo)
  local button = CreateFrame("CheckButton", "InterfaceOptions"..buttonName.."Button", InterfaceOptionsNamesPanel, "InterfaceOptionsCheckButtonTemplate")
  button.Text:SetText(buttonInfo.text)
  if ( buttonInfo.smallFont ) then
    button.Text:SetFontObject("GameFontHighlightSmall")
  end
  button.var = buttonInfo.var
  button.tooltipText = buttonInfo.toolTipText
  button.dependsOn = buttonInfo.dependsOn
  button.updateFunc = buttonInfo.updateFunc
  button:SetPoint(buttonInfo.point, buttonInfo.x, buttonInfo.y)
  button:SetChecked(ClassicPlatesOptions[buttonInfo.var])
  button:SetScript("OnClick", OptionCheckButton_OnClick)
  button:SetScript("OnShow", OptionCheckButton_OnShow)
end


function ClassicPlates:SetupOptionPanel(name)
  local title = InterfaceOptionsNamesPanel:CreateFontString(nil, "ARTWORK", "GameFontNormal")
  title:SetPoint("BOTTOMLEFT", 16, 130)
  title:SetText(name)
  for buttonName, buttonInfo in pairs(OptionCheckButtons) do
    OptionCheckButton_Create(buttonName, buttonInfo)
  end
end
