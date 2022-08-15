
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

function PANEL:Init()
    self.Elements = {}

    self.Player = LocalPlayer()

    local avatarElem = self:AddElement(nil, "rpname")
    avatarElem.Avatar = vgui.Create("PIXEL.HUD.Avatar", avatarElem)

    function avatarElem:PerformLayout(w, h)
        local avatarPad = PIXEL.Scale(7)
        local avatarSize = h - avatarPad * 2

        self.Avatar:SetPos(avatarPad, avatarPad)
        self.Avatar:SetSize(avatarSize, avatarSize)

        self.Avatar:SetPlayer(LocalPlayer(), avatarSize)
        self.Avatar:SetRounding(PIXEL.Scale(2))
    end

    avatarElem:SetText(self.Player:getDarkRPVar("rpname"))

    local comma, max, round = string.Comma, math.max, math.Round
    local function numberFormatter(val)
        return comma(max(round(val), 0))
    end

    local healthElem = self:AddElement("QT11zrH", "health", nil, numberFormatter, true)
    healthElem:SetText(self.Player:Health()):SetIconColor(colors.Health)
    healthElem.CurValue = 0
    healthElem.TargetValue = self.Player:Health()

    local armorElem = self:AddElement("k3pNdW1", "armor", nil, numberFormatter, true)
    armorElem:SetText(self.Player:Armor()):SetIconColor(colors.Armor)
    armorElem.CurValue = 0
    armorElem.TargetValue = self.Player:Armor()

    self:AddElement("WRF0KWw", "job"):SetText(self.Player:getDarkRPVar("job"))

    local moneyElem = self:AddElement("0IpCrnN", "money", nil, PIXEL.FormatMoney, true)
    moneyElem:SetText("$0"):SetIconColor(colors.Money)
    moneyElem.CurValue = 0
    moneyElem.TargetValue = self.Player:getDarkRPVar("money")

    local timeElem = self:AddElement("fyibNtJ", "time", nil, PIXEL.FormatTime)
    timeElem:SetText("0m 0s")
end

function PANEL:AddElement(imgurID, var, dock, formatter, lerp)
    local element = vgui.Create("PIXEL.HUD.BarElement", self)

    element:Dock(dock or LEFT)
    if imgurID then element:SetImgurID(imgurID) end
    element:SetSubscribedVar(var)
    element.Formatter = formatter

    if lerp then
        element.CurValue = 0
        element.TargetValue = 0

        function element.Think()
            element.CurValue = Lerp(FrameTime() * 8, element.CurValue, element.TargetValue)
            element:SetText(formatter and formatter(element.CurValue) or element.CurValue)
        end
    end

    table.insert(self.Elements, element)
    return element
end

function PANEL:PerformLayout(w, h)
    local elemPad = PIXEL.Scale(6)

    for k,v in ipairs(self.Elements) do
        v:DockMargin(0, 0, elemPad, 0)
        v:SizeElement()
    end
end

PIXEL.RegisterScaledConstant("HUD.BarHeight", 40)
function PANEL:PlaceElement(w, h)
    local height = PIXEL.GetScaledConstant("HUD.BarHeight")
    self:SetSize(w, height)
    self:SetPos(0, PIXEL.HUD.BarTop and 0 or ScrH() - math.floor(height))
end

local colorAlpha = ColorAlpha
function PANEL:Paint(w, h)
    surface.SetDrawColor(colors.Background)
    surface.DrawRect(0, 0, w, h)

    local nameW = PIXEL.DrawSimpleText(PIXEL.HUD.ServerName, "HUD.BarElement", w - PIXEL.Scale(7), h / 2, color_white, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)

    if self.Player:getDarkRPVar("wanted") then
        PIXEL.DrawSimpleText("Wanted", "HUD.BarElement", w - PIXEL.Scale(19) - nameW, h / 2, colorAlpha(colors.Wanted, math.sin(CurTime() * 4) * 100 + 155), TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
    end
end

vgui.Register("PIXEL.HUD.Bar", PANEL, "Panel")
