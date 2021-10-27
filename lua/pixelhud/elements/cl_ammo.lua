
--[[
    PIXEL HUD
    Copyright (C) 2021 Tom O'Sullivan (Tom.bat)
    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License.
    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.
    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <https://www.gnu.org/licenses/>.
]]

local colors = PIXEL.HUD.Colors.Ammo

local PANEL = {}

PIXEL.RegisterFont("HUD.AmmoHeader", "Open Sans Bold", 22)
PIXEL.RegisterFont("HUD.AmmoCount", "Open Sans SemiBold", 40, 400)

function PANEL:Init()
    self.ShouldShow = false
    self.HasLicense = LocalPlayer():getDarkRPVar("HasGunlicense")
    self.AmmoCount = 0
    self.AmmoReserve = 0

    hook.Add("PIXEL.HUD.UpdatePlayerVars", self, self.UpdateStatistic)
end

function PANEL:UpdateStatistic(key, value)
    if key == "showammo" then self.ShouldShow = value return end
    if key == "HasGunlicense" then self.HasLicense = value return true end
    if key == "ammoclip" then self.AmmoCount = value return end
    if key ~= "ammoreserve" then return end
    self.AmmoReserve = value
end

function PANEL:PlaceElement(w, h)
    local pad = PIXEL.GetScaledConstant("HUD.Padding")

    local selfW, selfH = PIXEL.Scale(160), PIXEL.Scale(82)
    self:SetPos(w - pad - selfW, h - pad - ((PIXEL.HUD.BarEnabled and not PIXEL.HUD.BarTop) and PIXEL.GetScaledConstant("HUD.BarHeight") or 0) - selfH)
    self:SetSize(selfW, selfH)
end

function PANEL:Paint(w, h)
    if not self.ShouldShow then return end

    PIXEL.DrawRoundedBox(PIXEL.Scale(4), 0, 0, w, h, colors.Background)

    local headerH = PIXEL.Scale(30)
    PIXEL.DrawRoundedBoxEx(PIXEL.Scale(4), 0, 0, w, headerH, colors.Header, true, true)

    PIXEL.DrawSimpleText("Ammo" .. (self.HasLicense and " - Licensed" or ""), "HUD.AmmoHeader", w / 2, headerH / 2, colors.Title, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    PIXEL.DrawSimpleText(self.AmmoCount .. "/" .. self.AmmoReserve, "HUD.AmmoCount", w / 2, headerH + (h - headerH) / 2, colors.Body, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
end

vgui.Register("PIXEL.HUD.Ammo", PANEL, "Panel")