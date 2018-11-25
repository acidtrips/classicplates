--[[

    ClassicPlatesDB.lua

    Contains functions that add options to blizzard's interface options panel

--]]

local ClassicPlates = ClassicPlates

local InterfaceOptionsNamesPanel = InterfaceOptionsNamesPanel
local _G, CreateFrame = _G, CreateFrame


local function CreateCheckButton(panel, label, name, tooltipText, point, x, y, useSmallFont, initFunc, onClickedFunc)
  local button = CreateFrame("CheckButton", "InterfaceOptions"..name.."Button", panel, "InterfaceOptionsCheckButtonTemplate")
  button.label = _G[button:GetName().."Text"]
  button.label:SetText(label)
  if ( useSmallFont ) then
    button.label:SetFontObject(GameFontHighlightSmall)
  end
  button.tooltipText = tooltipText
  button:SetPoint(point, x, y)
  button:HookScript("OnClick", onClickedFunc)
  if ( initFunc ) then
    initFunc(button)
  end
end


function ClassicPlates:GetDefaultOptions()
  return { showAggroWarnings = true, showClassColors = false, showCastBars = true, showCastBarsTargetOnly = false, showCastBarsSpellName = false, setupCVars = true }
end


function ClassicPlates:SetupOptionPanel(name)
  local title = InterfaceOptionsNamesPanel:CreateFontString(nil, "ARTWORK", "GameFontNormal")
  title:SetPoint("BOTTOMLEFT", 16, 130)
  title:SetText(name)

  CreateCheckButton(InterfaceOptionsNamesPanel, "Display Aggro Warnings",
    "ShowAggroWarning", "Turn this on to enable aggro warnings. "..
    "Displays a red glow around unit nameplates that you have aggro with.",
    "BOTTOMLEFT", 16, 95, false,
    function(self)
      self:SetChecked(ClassicPlatesDB.showAggroWarnings)
    end,
    function(self, ...)
      ClassicPlatesDB.showAggroWarnings = self:GetChecked()
      ClassicPlates:CallUpdateFunc("Update_Threat")
    end)

  CreateCheckButton(InterfaceOptionsNamesPanel, "Show CastBars",
    "ShowCastBars", "Turn this on to show cast bars on unit nameplates.",
    "BOTTOMLEFT", 16, 65, false,
    function(self)
      self:SetChecked(ClassicPlatesDB.showCastBars)
    end,
    function(self, ...)
      local button = {a = _G["InterfaceOptionsCurrentTargetOnlyButton"], b = _G["InterfaceOptionsShowSpellNamesButton"]}
      local value = self:GetChecked()
      if ( button.a and button.b ) then
        if ( not value ) then
          button.a.label:SetTextColor(0.50, 0.50, 0.50)
          button.a:Disable()
          button.b.label:SetTextColor(0.50, 0.50, 0.50)
          button.b:Disable()
        elseif ( value and not ClassicPlatesDB.showCastBars ) then
          button.a.label:SetTextColor(1.0, 1.0, 1.0)
          button.a:Enable()
          button.b.label:SetTextColor(1.0, 1.0, 1.0)
          button.b:Enable()
        end
      end
      ClassicPlatesDB.showCastBars = value
      ClassicPlates:CallUpdateFunc("Update_CastBar")
    end)

  CreateCheckButton(InterfaceOptionsNamesPanel, "Current Target Only",
    "CurrentTargetOnly", "Turn this on to show cast bars for your current target only.",
    "BOTTOMLEFT", 26, 44, true,
    function(self)
      local button = _G["InterfaceOptionsShowCastBarsButton"]
      if ( button and not button:GetChecked() ) then
        self.label:SetTextColor(0.50, 0.50, 0.50)
        self:Disable()
      end
      self:SetChecked(ClassicPlatesDB.showCastBarsTargetOnly)
    end,
    function(self, ...)
      ClassicPlatesDB.showCastBarsTargetOnly = self:GetChecked()
      ClassicPlates:CallUpdateFunc("Update_CastBar")
    end)

  CreateCheckButton(InterfaceOptionsNamesPanel, "Show Spell Names",
    "ShowSpellNames", "Turn this on to show spell names on cast bars.",
    "BOTTOMLEFT", 26, 23, true,
    function(self)
      local button = _G["InterfaceOptionsShowCastBarsButton"]
      if ( button and not button:GetChecked() ) then
        self.label:SetTextColor(0.50, 0.50, 0.50)
        self:Disable()
      end
      self:SetChecked(ClassicPlatesDB.showCastBarsSpellName)
    end,
    function(self, ...)
      ClassicPlatesDB.showCastBarsSpellName = self:GetChecked()
      ClassicPlates:CallUpdateFunc("Update_CastBar")
    end)

  CreateCheckButton(InterfaceOptionsNamesPanel, "Show Class Colors",
    "ShowClassColors", "Turn this on to show class colors on enemy player healthbars.",
    "BOTTOMRIGHT", -295,  95, false,
    function(self)
      self:SetChecked(ClassicPlatesDB.showClassColors)
    end,
    function(self, ...)
      ClassicPlatesDB.showClassColors = self:GetChecked()
      ClassicPlates:CallUpdateFunc("Update_HealthColor")
    end)
end
