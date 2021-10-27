
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

local colors = PIXEL.HUD.Colors.VoiceChat

local PANEL = {}

PIXEL.RegisterFont("HUD.VoiceChatName", "Open Sans SemiBold", 20, 400)

function PANEL:SetPlayer(ply)
    self.Player = ply
    self.Avatar = vgui.Create("PIXEL.HUD.Avatar", self)
end

function PANEL:PerformLayout(w, h)
    if not IsValid(self.Player) then return end

    local pad = PIXEL.Scale(4)
    self:DockPadding(pad, pad, pad, pad)

    local avatarSize = h - pad * 2
    self.Avatar:Dock(LEFT)
    self.Avatar:SetWide(avatarSize)

    self.Avatar:SetPlayer(self.Player, avatarSize)
    self.Avatar:SetRounding(PIXEL.Scale(3))
end

function PANEL:Paint(w, h)
    if not IsValid(self.Player) then
        self:GetParent():RemovePlayer(self.Player)
        return
    end

    PIXEL.DrawRoundedBox(PIXEL.Scale(4), 0, 0, w, h, PIXEL.LerpColor(self.Player:VoiceVolume() * 255, colors.Background, colors.TalkingBackground))
    PIXEL.DrawSimpleText(PIXEL.EllipsesText(self.Player:Name(), w - h - PIXEL.Scale(8), "HUD.VoiceChatName"), "HUD.VoiceChatName", h + PIXEL.Scale(4), h / 2, colors.Name, nil, TEXT_ALIGN_CENTER)
end

vgui.Register("PIXEL.HUD.VoiceChatPlayer", PANEL, "Panel")

PANEL = {}

function PANEL:Init()
    self.LocalPlayer = LocalPlayer()
    self.Players = {}

    hook.Add("PlayerStartVoice", self, self.AddPlayer)
    hook.Add("PlayerEndVoice", self, self.RemovePlayer)
end

function PANEL:AddPlayer(ply)
    --if ply == self.LocalPlayer then return end

    if IsValid(self.Players[ply]) then
        if self.Players[ply].Fading then
            self.Players[ply].Fading = false
            self.Players[ply]:AlphaTo(255, .1, 0)
        end
        return
    end

    local pnl = vgui.Create("PIXEL.HUD.VoiceChatPlayer", self)

    pnl:SetPlayer(ply)
    pnl:SetAlpha(0)
    pnl:AlphaTo(255, .1, 0)

    self.Players[ply] = pnl
end

function PANEL:RemovePlayer(ply)
    if not IsValid(self.Players[ply]) then return end

    self.Players[ply].Fading = true
    self.Players[ply]:AlphaTo(0, .1, 0, function(anim, pnl)
        if not pnl.Fading then return end
        pnl:Remove()
        self.Players[ply] = nil
    end)
end

function PANEL:PlaceElement(w, h)
    local selfW, selfH = PIXEL.Scale(220), PIXEL.Scale(600)

    self:SetSize(selfW, selfH)
    self:SetPos(w - PIXEL.GetScaledConstant("HUD.Padding") - selfW, h - selfH - PIXEL.Scale(320))
end

function PANEL:PerformLayout(w, h)
    local playerH = PIXEL.Scale(40)
    local spacing = PIXEL.Scale(6)
    for k,v in pairs(self.Players) do
        v:Dock(BOTTOM)
        v:DockMargin(0, spacing, 0, 0)
        v:SetTall(playerH)
    end
end

vgui.Register("PIXEL.HUD.VoiceChat", PANEL, "Panel")

hook.Add("InitPostEntity", "PIXEL.HUD.RemoveOldVoicePanel", function()
    timer.Simple(1, function()
        timer.Remove("VoiceClean")
        if not IsValid(g_VoicePanelList) then return end
        g_VoicePanelList:Remove()
    end)
end)

PIXEL.HUD.BlockHook("InitPostEntity", "CreateVoiceVGUI")