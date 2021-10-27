
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

local colors = PIXEL.HUD.Colors.Alerts

net.Receive("PIXEL.HUD.Alert", function()
    PIXEL.HUD.Alert(net.ReadString(), net.ReadString(), net.ReadUInt(16))
end)

function PIXEL.HUD.Alert(title, body, time)
    if not (PIXEL.HUD and PIXEL.HUD.Panel and PIXEL.HUD.Panel.Elements and PIXEL.HUD.Panel.Elements.Alerts) then return end
    if not IsValid(PIXEL.HUD.Panel.Elements.Alerts) then return end
    PIXEL.HUD.Panel.Elements.Alerts:QueueAlert(title, body, time)
end

local lockdownEnabled = false

hook.Add("Think", "PIXEL.HUD.LockdownCheck", function()
    if lockdownEnabled == GetGlobalBool("DarkRP_LockDown") then return end
    lockdownEnabled = not lockdownEnabled

    if lockdownEnabled then
        PIXEL.HUD.Alert("Lockdown", "The mayor has initiated a lockdown,\nplease return to your home.")
        return
    end

    PIXEL.HUD.Alert("Lockdown Over", "The mayor has ended the lockdown.")
end)

local PANEL = {}

AccessorFunc(PANEL, "sTitle", "Title", FORCE_STRING)
AccessorFunc(PANEL, "sBody", "Body", FORCE_STRING)

PIXEL.RegisterFont("HUD.AlertHeader", "Open Sans Bold", 24)
PIXEL.RegisterFont("HUD.AlertMessage", "Open Sans SemiBold", 20, 400)

function PANEL:Init()
    self:SetTitle("UNWANTED")
    self:SetBody("ply:Nick() ..  is no longer wanted!\nRevoked by:  .. actor:Nick()")

    self:SetVisible(false)

    self.Alerts = {}
end

function PANEL:QueueAlert(title, body, time)
    table.insert(self.Alerts, {
        title = string.upper(title),
        body = PIXEL.WrapText(body, self:GetWide() - PIXEL.Scale(20), "HUD.AlertMessage"),
        time = time or 5,
    })

    if #self.Alerts > 1 then return end
    self:PlayAlert(1)
end

function PANEL:PlayAlert(id)
    local alert = self.Alerts[id]
    if not alert then return end
    if self.PlayingAlert then return end

    self:SetTitle(alert.title)
    self:SetBody(alert.body)

    self.PlayingAlert = true
    self:SetTall(self:GetPrefferedSize())
    self:SetVisible(true)

    local preferredX = self:GetPos()
    self:MoveTo(preferredX, PIXEL.GetScaledConstant("HUD.Padding") + ((PIXEL.HUD.BarEnabled and PIXEL.HUD.BarTop) and PIXEL.GetScaledConstant("HUD.BarHeight") or 0), .2, 0, -1, function()
        if not IsValid(self) then return end

        timer.Simple(alert.time, function()
            if not IsValid(self) then return end

            self:MoveTo(preferredX, -self:GetTall(), .2, 0, -1, function()
                if not IsValid(self) then return end

                self:SetVisible(false)
                table.remove(self.Alerts, 1)
                self.PlayingAlert = false

                self:PlayAlert(1)
            end)
        end)
    end)
end

function PANEL:GetPrefferedSize()
    return PIXEL.Scale(30) + PIXEL.Scale(20) + select(2, PIXEL.GetTextSize(self:GetBody(), "HUD.AlertMessage"))
end

function PANEL:PlaceElement(w, h)
    local selfW = PIXEL.Scale(350)
    self:SetSize(selfW, self:GetPrefferedSize())
    self:SetPos(w / 2 - selfW / 2, select(2, self:GetPos()))

    if self.Placed then return end
    self.Placed = true

    self:SetPos(w / 2 - selfW / 2, -self:GetTall())
end

function PANEL:Paint(w, h)
    PIXEL.DrawRoundedBox(PIXEL.Scale(3), 0, 0, w, h, colors.Background)

    local headerH = PIXEL.Scale(30)
    PIXEL.DrawRoundedBoxEx(PIXEL.Scale(3), 0, 0, w, headerH, colors.Header, true, true)

    local center = w / 2
    PIXEL.DrawSimpleText(self:GetTitle(), "HUD.AlertHeader",  center, headerH / 2, colors.Title, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    PIXEL.DrawText(self:GetBody(), "HUD.AlertMessage", center, headerH + PIXEL.Scale(10), colors.Body, TEXT_ALIGN_CENTER)
end

vgui.Register("PIXEL.HUD.Alerts", PANEL, "Panel")