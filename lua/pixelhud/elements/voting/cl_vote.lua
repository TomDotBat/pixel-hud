
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

local colors = PIXEL.HUD.Colors.Vote

local PANEL = {}

PIXEL.RegisterFont("HUD.VoteTitle", "Open Sans Bold", 23)
PIXEL.RegisterFont("HUD.VoteMessage", "Open Sans SemiBold", 18)

function PANEL:Init()
    self.YesBtn = vgui.Create("PIXEL.TextButton", self)
    self.YesBtn:SetText("Yes")

    self.NoBtn = vgui.Create("PIXEL.TextButton", self)
    self.NoBtn:SetText("No")
end

function PANEL:SetVote(id, text, time)
    self.Id = id
    self.Title = "Vote"
    self.Text = text
    self.StartTime = CurTime()
    self.FinishTime = self.StartTime + time

    timer.Create("PIXEL.HUD.VoteTimer:" .. id, time, 0, function()
        if not IsValid(self) then return end
        self:Remove()
    end)

    self.YesBtn.DoClick = function()
        LocalPlayer():ConCommand("vote " .. id .. " yea\n")
        self:Remove()
    end

    self.NoBtn.DoClick = function()
        LocalPlayer():ConCommand("vote " .. id .. " nay\n")
        self:Remove()
    end
end

function PANEL:SetQuestion(id, text, time)
    self.Id = id
    self.Title = "Question"
    self.Text = text
    self.StartTime = CurTime()
    self.FinishTime = self.StartTime + time

    timer.Create("PIXEL.HUD.VoteTimer:" .. id, time, 0, function()
        if not IsValid(self) then return end
        self:Remove()
    end)

    self.YesBtn.DoClick = function()
        LocalPlayer():ConCommand("ans " .. id .. " 1\n")
        self:Remove()
    end

    self.NoBtn.DoClick = function()
        LocalPlayer():ConCommand("ans " .. id .. " 2\n")
        self:Remove()
    end
end

function PANEL:PerformLayout(w, h)
    local btnW, btnH = PIXEL.Scale(64), PIXEL.Scale(25)

    self.YesBtn:SetSize(btnW, btnH)
    self.NoBtn:SetSize(btnW, btnH)

    local btnPad = PIXEL.Scale(10)
    local btnY = h - PIXEL.Scale(10) - btnH

    self.YesBtn:SetPos(btnPad, btnY)
    self.NoBtn:SetPos(w - btnPad - btnW, btnY)
end

local whiteTexture = surface.GetTextureID("vgui/white")

function PANEL:Paint(w, h)
    if w == 64 then return end

    PIXEL.DrawRoundedBox(PIXEL.Scale(4), 0, 0, w, h, colors.Background)

    local headerH = PIXEL.Scale(28)
    PIXEL.DrawRoundedBoxEx(PIXEL.Scale(4), 0, 0, w, headerH, colors.Header, true, true)

    PIXEL.DrawSimpleText(self.Title, "HUD.VoteTitle", w / 2, headerH / 2, colors.Title, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

    PIXEL.DrawText(PIXEL.WrapText(self.Text, w - PIXEL.Scale(20), "HUD.VoteMessage"), "HUD.VoteMessage", w / 2, headerH + PIXEL.Scale(16), colors.Message, TEXT_ALIGN_CENTER)

    local prog = (self.FinishTime + 6 - CurTime()) / (self.FinishTime - self.StartTime)
    if prog > 1 or prog < 0 then return end

    local circleRad = headerH * .3
    if not self.ProgBackgroundPoly then
        self.ProgBackgroundPoly = PIXEL.PrecacheArc(w - PIXEL.Scale(14), headerH / 2, circleRad, circleRad, 90, 450, 3)
    end

    surface.SetTexture(whiteTexture)
    surface.SetDrawColor(colors.TimerBackground.r, colors.TimerBackground.g, colors.TimerBackground.b, colors.TimerBackground.a)
    PIXEL.DrawArc(self.ProgBackgroundPoly)

    PIXEL.DrawUncachedArc(w - PIXEL.Scale(14), headerH / 2, circleRad, circleRad, 90, 440 * prog, 3, colors.Timer)
end

vgui.Register("PIXEL.HUD.Vote", PANEL, "Panel")