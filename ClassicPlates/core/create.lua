--[[

    create.lua

    Contains functions to create a nameplate and it's elements.

--]]
local CreateFrame, CastBar_Create = CreateFrame, CastBar_Create


local function HealthBar_Create(self)
  self.HealthBar = CreateFrame("StatusBar", nil, self)
  self.HealthBar:SetFrameLevel(1)
  self.HealthBar:SetSize(105, 11)
  self.HealthBar:SetStatusBarTexture("Interface/TargetingFrame/UI-TargetingFrame-BarFill")
  self.HealthBar:SetPoint("BOTTOMLEFT", self, "BOTTOMLEFT", 5, 4.8)
  self.NameText = self:CreateFontString(nil, "OVERLAY", NAMEPLATE_FONT)
  self.NameText:SetShadowOffset(1.56, -1.56)
  self.NameText:SetJustifyH("CENTER")
  self.NameText:SetPoint("BOTTOM", self, "CENTER", 0, 0)
  self.RaidTargetIcon = self:CreateTexture(nil, "ARTWORK", nil, 0)
  self.RaidTargetIcon:SetTexture("Interface/TargetingFrame/UI-RaidTargetingIcons")
  self.RaidTargetIcon:SetSize(31, 31)
  self.RaidTargetIcon:SetPoint("RIGHT", self, "LEFT", 0, 0)
  self.RaidTargetIcon:Hide()
  self.Border = self:CreateTexture(nil, "ARTWORK", nil, 1)
  self.Border:SetTexture("Interface/Tooltips/Nameplate-Border")
  self.Border:SetTexCoord(0, 0, 0, 1, 0.53125, 0, 0.53125, 1)
  self.Border:SetSize(140.9, 39)
  self.Border:SetPoint("TOPLEFT", self, "TOPLEFT", 0, 0)
  self.LevelText = self:CreateFontString(nil, "OVERLAY", NAMEPLATE_FONT)
  self.LevelText:SetShadowOffset(1.56, -1.56)
  self.LevelText:SetJustifyH("CENTER")
  self.LevelText:SetPoint("CENTER", self.Border, "BOTTOMRIGHT", -16.4, 11.5)
  self.HighLevelIcon = self:CreateTexture(nil, "ARTWORK", nil, 3)
  self.HighLevelIcon:SetTexture("Interface/TargetingFrame/UI-TargetingFrame-Skull")
  self.HighLevelIcon:SetSize(15, 15)
  self.HighLevelIcon:SetPoint("CENTER", self.Border, "BOTTOMRIGHT", -16.4, 11)
  self.HighLevelIcon:Hide()
  self.EliteIcon = self:CreateTexture(nil, "ARTWORK", nil, 0)
  self.EliteIcon:SetTexture("Interface/Tooltips/EliteNameplateIcon")
  self.EliteIcon:SetTexCoord(0, 0, 0, 0.84375, 0.578125, 0, 0.578125, 0.84375)
  self.EliteIcon:SetSize(46, 33.6)
  self.EliteIcon:SetPoint("CENTER", self.Border, "BOTTOMRIGHT", -12, 10)
  self.EliteIcon:Hide()
  self.AggroWarning = self:CreateTexture(nil, "BACKGROUND")
  self.AggroWarning:SetTexture("Interface/TargetingFrame/UI-TargetingFrame-Flash", 1.0)
  self.AggroWarning:SetTexCoord(0.0, 0.555, 0.53, 0.6)
  self.AggroWarning:SetSize(155, 43)
  self.AggroWarning:SetPoint("BOTTOMLEFT", self.Border, "BOTTOMLEFT", -8.4, -14.4)
  self.AggroWarning:SetVertexColor(1.0, 0.0, 0.0, 1.0)
  self.AggroWarning:Hide()
end


function ClassicPlates:NewNamePlate(baseFrame)
  local frame = CreateFrame("Frame", "Classic"..baseFrame:GetName(), baseFrame)
  frame:SetPoint("CENTER", baseFrame, "BOTTOM", 0, 30)
  frame:SetFrameStrata("BACKGROUND")
  frame:SetSize(140, 39)
  frame:Hide()
  frame.unit = nil
  frame.elapsed = 0
  frame.lastCombatAction = 0
  frame.isMouseOver = false
  frame.inCombat = false
  self:SetUpdateFuncs(frame)

  HealthBar_Create(frame)
  CastBar_Create(frame)
  return frame
end
