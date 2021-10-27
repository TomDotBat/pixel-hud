
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

local colors = PIXEL.HUD.Colors.ArrestTimer

local PANEL = {}

PIXEL.RegisterFont("HUD.ArrestHeader", "Open Sans Bold", 24)
PIXEL.RegisterFont("HUD.ArrestMessage", "Open Sans SemiBold", 22, 400)

function PANEL:Init()
    self.ShouldShow = false
    self.Message = "You will be released in 0 seconds."

    net.Receive("PIXEL.HUD.SendArrestTime", function()
        if not IsValid(self) then return end

        local timeLeft = net.ReadUInt(32)
        local ply = LocalPlayer()

        self.ShouldShow = true
        self.Message = string.format("You will be released in %u seconds.", timeLeft)

        timer.Create("PIXEL.HUD.ArrestTimer", 1, timeLeft - 1, function()
            if not IsValid(self) then return end
            if not ply:getDarkRPVar("Arrested") then
                self.ShouldShow = false
                timer.Remove("PIXEL.HUD.ArrestTimer")
                return
            end

            timeLeft = timeLeft - 1
            self.ShouldShow = timeLeft > 1
            self.Message = string.format("You will be released in %u seconds.", timeLeft)
        end)
    end)
end

function PANEL:PlaceElement(w, h)
    local selfW, selfH = PIXEL.Scale(350), PIXEL.Scale(70)

    self:SetSize(selfW, selfH)
    self:SetPos(w / 2 - selfW / 2, h - PIXEL.GetScaledConstant("HUD.Padding") - ((PIXEL.HUD.BarEnabled and not PIXEL.HUD.BarTop) and PIXEL.GetScaledConstant("HUD.BarHeight") or 0) - selfH)
end

function PANEL:Paint(w, h)
    if not self.ShouldShow then return end

    PIXEL.DrawRoundedBox(PIXEL.Scale(4), 0, 0, w, h, colors.Background)

    local headerH = PIXEL.Scale(30)
    PIXEL.DrawRoundedBoxEx(PIXEL.Scale(4), 0, 0, w, headerH, colors.Header, true, true)

    PIXEL.DrawSimpleText("ARRESTED", "HUD.ArrestHeader", w / 2, headerH / 2, colors.Title, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    PIXEL.DrawSimpleText(self.Message, "HUD.ArrestMessage", w / 2, headerH + (h - headerH) / 2, colors.Message, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
end

vgui.Register("PIXEL.HUD.Arrested", PANEL, "Panel")