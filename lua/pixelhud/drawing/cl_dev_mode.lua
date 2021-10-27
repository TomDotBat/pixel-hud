
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

if not PIXEL_DEV_MODE then return end

PIXEL.RegisterFont("HUD.DevMode", "Open Sans Bold", 40)

local colors = PIXEL.HUD.Colors.DevMode

hook.Add("HUDPaint", "PIXEL.HUD.DevMode", function()
    PIXEL.DrawSimpleText("DEVELOPMENT MODE", "HUD.DevMode", ScrW() * .5, ScrH() - PIXEL.Scale(10), colors.Text, TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM)
end)