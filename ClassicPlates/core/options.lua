--[[

    options.lua

    Contains functions that add options to blizzard's interface options panel

--]]
local ClassicPlates, _G, CreateFrame, InterfaceOptionsNamesPanel, GetNamePlates, GRAY_FONT_COLOR, HIGHLIGHT_FONT_COLOR =
      ClassicPlates, _G, CreateFrame, InterfaceOptionsNamesPanel, C_NamePlate.GetNamePlates, GRAY_FONT_COLOR, HIGHLIGHT_FONT_COLOR


local OptionCheckButtons = {}
OptionCheckButtons["ShowAggroWarning"] = {var = "showAggroWarnings", dependsOn = nil, text = "Display Aggro Warnings", toolTipText = "Turn this on to enable aggro warnings. Displays a red glow around nameplates for units that you have aggro with.", point = "BOTTOMLEFT", x = 16, y = 95, smallFont = nil, updateFunc = "Update_Threat"}
OptionCheckButtons["ShowCastBars"] = {var = "showCastBars", text = "Show CastBars", dependsOn = {"CurrentTargetOnly", "ShowSpellNames"}, toolTipText = "Turn this on to show cast bars on unit nameplates.", point = "BOTTOMLEFT", x = 16, y = 65, smallFont = nil, updateFunc = "Update_CastBar"}
OptionCheckButtons["CurrentTargetOnly"] = {var = "showCastBarsTargetOnly", dependsOn = nil, text = "Current Target Only", toolTipText = "Turn this on to show cast bars for your current target only.", point = "BOTTOMLEFT", x = 26, y = 44, smallFont = true, updateFunc = "Update_CastBar"}
OptionCheckButtons["ShowSpellNames"] = {var = "showCastBarsSpellName", dependsOn = nil, text = "Show Spell Names", toolTipText = "Turn this on to show spell names on cast bars.", point = "BOTTOMLEFT", x = 26, y = 23,  smallFont = true, updateFunc = "Update_CastBar"}
OptionCheckButtons["ShowClassColors"] = {var = "showClassColors", dependsOn = nil, text = "Show Class Colors", toolTipText = "Turn this on to show class colors on enemy player healthbars.", point = "BOTTOMRIGHT", x = -295, y = 95, smallFont = nil, updateFunc = "Update_HealthColor"}


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
      local button = _G["InterfaceOptions"..name.."Button"]
      if ( button ) then
        OptionCheckButton_SetEnabledState(button, isChecked)
      end
    end
  end
  if ( self.var ) then
    ClassicPlatesDB[self.var] = isChecked
  end
  if ( self.updateFunc and doUpdate ) then
    for _, frame in pairs(GetNamePlates()) do
      local nameplate = frame.NamePlate
      if ( nameplate and nameplate.unit ) then
        nameplate[self.updateFunc](nameplate)
      end
    end
  end
end


local function OptionCheckButton_OnClick(self)
  OptionCheckButton_Update(self, true)
end


local function OptionCheckButton_OnShow(self)
  OptionCheckButton_Update(self)
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
  button:SetChecked(ClassicPlatesDB[buttonInfo.var])
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
