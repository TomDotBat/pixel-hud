
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

local colors = PIXEL.HUD.Colors.Bar

local PANEL = {}

PIXEL.RegisterFont("HUD.BarElement", "Open Sans SemiBold", 21)

AccessorFunc(PANEL, "sImgurID", "ImgurID", FORCE_STRING)
AccessorFunc(PANEL, "sSubscribedVar", "SubscribedVar", FORCE_STRING)
AccessorFunc(PANEL, "cIconColor", "IconColor")

function PANEL:Init()
    self.Text = ""

    self:SetIconColor(colors.Text)
    self:SizeElement()

    hook.Add("PIXEL.HUD.UpdatePlayerVars", self, self.UpdateStatistic)
end

function PANEL:UpdateStatistic(key, value)
    if key ~= self.sSubscribedVar then return end

    self.Text = self.Formatter and self.Formatter(value) or value
    self.TargetValue = value
    self:SizeElement(self.Formatter and self.Formatter(value) or value)

    return true
end

function PANEL:SetText(text)
    self.Text = text
    self:SizeElement()
    return self
end

function PANEL:SizeElement(overrideText)
    if (overrideText or self.Text) == "0" then self:SetWide(0) return end

    self:SetWide(self:GetTall() + PIXEL.GetTextSize(overrideText or self.Text, "HUD.BarElement") + PIXEL.Scale(8))
end

function PANEL:Paint(w, h)
    local iconPad = PIXEL.Scale(9)
    local iconSize = h - iconPad * 2

    local imgurId = self:GetImgurID()
    if imgurId then
        PIXEL.DrawImgur(iconPad, iconPad, iconSize, iconSize, imgurId, self:GetIconColor())
    end

    PIXEL.DrawSimpleText(self.Text, "HUD.BarElement", h, h / 2, colors.Text, nil, TEXT_ALIGN_CENTER)
end

vgui.Register("PIXEL.HUD.BarElement", PANEL, "Panel")