--[[

    options.lua

    Contains functions that add options to blizzard's interface options panel

--]]
local ClassicPlates, _G, CreateFrame = ClassicPlates, _G, CreateFrame


local ClassicPlatesDefaultOptions = {
  showAggroWarnings = true,
  showClassColors = false,
  showCastBars = true,
  showCastBarsTargetOnly = false,
  showCastBarsSpellName = false,
  setupCVars = true
}


local OptionCheckButtons, OptionCheckButtonsControls = {}, {}
OptionCheckButtons["ShowAggroWarning"] = {var = "showAggroWarnings", dependsOn = nil, text = "Display Aggro Warnings", toolTipText = "Turn this on to enable aggro warnings. Displays a red glow around unit nameplates that you have aggro with.", point = "BOTTOMLEFT", x = 16, y = 95, smallFont = nil, updateFunc = "Update_Threat"}
OptionCheckButtons["ShowCastBars"] = {var = "showCastBars", text = "Show CastBars", dependsOn = {"CurrentTargetOnly", "ShowSpellNames"}, toolTipText = "Turn this on to show cast bars on unit nameplates.", point = "BOTTOMLEFT", x = 16, y = 65, smallFont = nil, updateFunc = "Update_CastBar"}
OptionCheckButtons["CurrentTargetOnly"] = {var = "showCastBarsTargetOnly", dependsOn = nil, text = "Current Target Only", toolTipText = "Turn this on to show cast bars for your current target only.", point = "BOTTOMLEFT", x = 26, y = 44, smallFont = nil, updateFunc = "Update_CastBar"}
OptionCheckButtons["ShowSpellNames"] = {var = "showCastBarsSpellName", dependsOn = nil, text = "Show Spell Names", toolTipText = "Turn this on to show spell names on cast bars.", point = "BOTTOMLEFT", x = 26, y = 23,  smallFont = nil, updateFunc = "Update_CastBar"}
OptionCheckButtons["ShowClassColors"] = {var = "showClassColors", dependsOn = nil, text = "Show Class Colors", toolTipText = "Turn this on to show class colors on enemy player healthbars.", point = "BOTTOMRIGHT", x = -295, y = 95, smallFont = nil, updateFunc = "Update_HealthColor"}


local function OptionCheckButton_Update(self)
  local checkedValue = self:GetChecked()
  if ( self.dependsOn ) then
    for _, name in pairs(self.dependsOn) do
      local button = _G["InterfaceOptions"..name.."Button"]
      if ( button ) then
        button[checkedValue and "Enable" or "Disable"](button)
      end
    end
  end
  if ( self.var ) then
    ClassicPlatesDB[self.var] = checkedValue
  end
  if ( self.updateFunc ) then
    ClassicPlates:CallUpdateFunc(self.updateFunc)
  end
end


local function OptionCheckButton_OnClick(self, ...)
  OptionCheckButton_Update(self)
end


local function OptionCheckButton_Create(text, name, var, tooltipText, point, x, y, smallFont, dependsOn, updateFunc)
  local button = CreateFrame("CheckButton", "InterfaceOptions"..name.."Button", InterfaceOptionsNamesPanel, "InterfaceOptionsCheckButtonTemplate")
  button.Text:SetText(text)
  if ( smallFont ) then
    button.Text:SetFontObject("GameFontHighlightSmall")
  end
  button.var = var
  button.tooltipText = tooltipText
  button.dependsOn = dependsOn
  button.updateFunc = updateFunc
  button:SetPoint(point, x, y)
  button:SetChecked(ClassicPlatesDB[var])
  button:SetScript("OnClick", OptionCheckButton_OnClick)
  table.insert(OptionCheckButtonsControls, button)
end


function ClassicPlates:GetDefaultOptions()
  return ClassicPlatesDefaultOptions
end


function ClassicPlates:SetupOptionPanel(name)
  local title = InterfaceOptionsNamesPanel:CreateFontString(nil, "ARTWORK", "GameFontNormal")
  title:SetPoint("BOTTOMLEFT", 16, 130)
  title:SetText(name)
  for buttonName, button in pairs(OptionCheckButtons) do
    OptionCheckButton_Create(button.text, buttonName, button.var, button.toolTipText, button.point, button.x, button.y, button.smallFont, button.dependsOn, button.updateFunc)
  end
  for _, button in next, OptionCheckButtonsControls do
    OptionCheckButton_Update(button)
  end
end
