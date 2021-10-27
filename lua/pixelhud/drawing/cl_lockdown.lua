
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

local colors = PIXEL.HUD.Colors.Lockdown

local lockdownEnabled
hook.Add("Think", "PIXEL.HUD.LockdownStatus", function()
    lockdownEnabled = GetGlobalBool("DarkRP_LockDown", false)
end)

local animProg = 0
local lerp = Lerp

PIXEL.RegisterFont("HUD.Lockdown", "Open Sans Bold", 31, 400)
PIXEL.RegisterFont("HUD.LockdownDescription", "Open Sans SemiBold", 19, 400)

hook.Add("HUDPaint", "PIXEL.HUD.LockdownStatus", function()
    animProg = lerp(FrameTime() * 10, animProg, lockdownEnabled and 1 or 0)

    if animProg < .001 then return end

    local yOffset = (PIXEL.HUD.BarEnabled and PIXEL.HUD.BarTop) and PIXEL.GetScaledConstant("HUD.BarHeight") or 0

    local pad = PIXEL.GetScaledConstant("HUD.Padding")

    local titleW, titleH = PIXEL.GetTextSize("LOCKDOWN IN PROGRESS", "HUD.Lockdown")
    local descW = PIXEL.GetTextSize("The mayor has initiated a lockdown,\nreturn to your home.", "HUD.LockdownDescription")

    PIXEL.DrawSimpleText("LOCKDOWN IN PROGRESS", "HUD.Lockdown", (titleW + pad) * animProg, yOffset + pad - PIXEL.Scale(6), colors.Title, TEXT_ALIGN_RIGHT)
    PIXEL.DrawText("The mayor has initiated a lockdown,\nplease return to your home.", "HUD.LockdownDescription", (descW + pad) * animProg - descW, yOffset + pad + titleH, colors.Message)
end)