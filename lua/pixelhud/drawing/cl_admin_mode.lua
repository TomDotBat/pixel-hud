
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

PIXEL.RegisterFont("HUD.AdminMode", "Open Sans Bold", 100)

local localPly
local colors = PIXEL.HUD.Colors.AdminMode

hook.Add("HUDPaint", "PIXEL.HUD.AdminMode", function()
    if not localPly then localPly = LocalPlayer() end
    if not localPly:GetNW2Bool("PIXEL.AdminMode", false) then return end

    PIXEL.DrawSimpleText("ADMIN MODE", "HUD.AdminMode", ScrW() * .5, ScrH() - PIXEL.GetScaledConstant("HUD.Padding"), colors.Text, TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM)
end)