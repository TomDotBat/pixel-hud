
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

local statsCvar = CreateClientConVar("pixel_statistics_enabled", "0", true, false, "Should statistics about the server and etc show in the corner of your screen?", 0, 1)

local function enableStatsDrawing()
    local round = math.Round
    local stats = {
        ["FPS"] = function()
            return round(1 / FrameTime())
        end,
        ["Tickrate"] = function()
            return round(1 / engine.ServerFrameTime())
        end,
        ["Prop Count"] = function(localPly)
            return localPly:GetCount("props") .. "/" .. localPly:GetNW2Int("PIXEL.Restrict.PropLimit", 0)
        end,
        ["Ping"] = function(localPly)
            return localPly:Ping()
        end,
        ["Player Count"] = function(localPly)
            return player.GetCount() .. "/" .. game.MaxPlayers()
        end,
        ["Session Time"] = function(localPly)
            return PIXEL.FormatTime(localPly.GetUTimeSessionTime and localPly:GetUTimeSessionTime() or 0)
        end
    }

    PIXEL.RegisterFont("HUD.Statistics", "Open Sans SemiBold", 21)

    local localPly
    hook.Add("HUDPaint", "PIXEL.HUD.DrawStats", function()
        if not IsValid(localPly) then localPly = LocalPlayer() end

        local textX = PIXEL.Scale(20)
        local textY = (PIXEL.HUD.BarEnabled and PIXEL.HUD.BarTop) and (PIXEL.GetScaledConstant("HUD.BarHeight") + textX) or textX
        textX = ScrW() - textX

        for stat, getter in pairs(stats) do
            local _, h = PIXEL.DrawSimpleText(stat .. ": " .. getter(localPly), "HUD.Statistics", textX, textY, PIXEL.Colors.PrimaryText, TEXT_ALIGN_RIGHT)
            textY = textY + h
        end
    end)
end

if statsCvar:GetBool() then
    enableStatsDrawing()
end

cvars.AddChangeCallback("pixel_statistics_enabled", function(_, _, val)
    if tonumber(val) == 1 then enableStatsDrawing()
    else hook.Remove("HUDPaint", "PIXEL.HUD.DrawStats") end
end)