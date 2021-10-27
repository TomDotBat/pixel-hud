
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

local PANEL = {}

function PANEL:Init()
    self:SetSize(ScrW(), ScrH())
    self:SetPos(0, 0)
    self:ParentToHUD()

    PIXEL.HUD.Build(self)
end

function PANEL:OnScreenSizeChanged()
    self:SetSize(ScrW(), ScrH())
    self:SetPos(0, 0)
end

function PANEL:PerformLayout(w, h)
    if not self.Elements then return end

    for k,v in pairs(self.Elements) do
        if not v.PlaceElement then continue end
        v:PlaceElement(w, h)
    end

    hook.Run("PIXEL.HUD.FinishedBuilding")
end

vgui.Register("PIXEL.HUD.Container", PANEL, "Panel")

hook.Add("InitPostEntity", "PIXEL.HUD.BuildWhenReady", function()
    timer.Simple(.1, function()
        PIXEL.HUD.Panel = vgui.Create("PIXEL.HUD.Container")
    end)
end)

if not IsValid(LocalPlayer()) then return end

if IsValid(PIXEL.HUD.Panel) then
    PIXEL.HUD.Panel:Remove()
end

PIXEL.HUD.Panel = vgui.Create("PIXEL.HUD.Container")