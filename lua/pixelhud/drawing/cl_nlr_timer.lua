
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

local NLR_TIME = 300

local colors = PIXEL.HUD.Colors.NLR

gameevent.Listen("entity_killed")
hook.Add("entity_killed", "PIXEL.HUD.NLRTimer", function(data)
    local localPly = LocalPlayer()
    if not IsValid(localPly) then return end
    if not (data.entindex_killed and data.entindex_killed == localPly:EntIndex()) then return end

    local finishTime = CurTime() + NLR_TIME

    PIXEL.RegisterFont("HUD.NLRTitle", "Open Sans Bold", 42)
    PIXEL.RegisterFont("HUD.NLRDescription", "Open Sans Bold", 24)

    local centerX = ScrW() * .5

    local titleCol = colors.Title
    local descriptionCol = colors.Description
    local textAlignCenter = TEXT_ALIGN_CENTER

    hook.Add("HUDPaint", "PIXEL.HUD.NLRTimer", function()
        local titleX = PIXEL.Scale(localPly:IsInSpawn() and 160 or 80)
        local _, titleH = PIXEL.DrawSimpleText("NEW LIFE RULE", "HUD.NLRTitle", centerX, titleX, titleCol, textAlignCenter)
        PIXEL.DrawSimpleText("You must not return to your death location for another " .. math.Round(finishTime - CurTime()) .. " seconds.", "HUD.NLRDescription", centerX, titleX + titleH, descriptionCol, textAlignCenter)
    end)

    timer.Create("PIXEL.HUD.NLRTimer", NLR_TIME, 1, function()
        hook.Remove("HUDPaint", "PIXEL.HUD.NLRTimer")
    end)
end)