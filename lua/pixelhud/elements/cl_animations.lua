
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

local menuOpen = false

local PANEL = {}

PIXEL.RegisterFont("HUD.AnimMenuButton", "Open Sans SemiBold", 19)

function PANEL:Init()
    if menuOpen then self:Remove() end
    menuOpen = true

    self:SetSize(PIXEL.Scale(140), 0)
    self:MakePopup()
    self:ParentToHUD()

    self:SetTitle("Animations")

    self.Buttons = {}
    local anims = {
        [ACT_GMOD_GESTURE_BOW] = DarkRP.getPhrase("bow"),
        [ACT_GMOD_TAUNT_MUSCLE] = DarkRP.getPhrase("sexy_dance"),
        [ACT_GMOD_GESTURE_BECON] = DarkRP.getPhrase("follow_me"),
        [ACT_GMOD_TAUNT_LAUGH] = DarkRP.getPhrase("laugh"),
        [ACT_GMOD_TAUNT_PERSISTENCE] = DarkRP.getPhrase("lion_pose"),
        [ACT_GMOD_GESTURE_DISAGREE] = DarkRP.getPhrase("nonverbal_no"),
        [ACT_GMOD_GESTURE_AGREE] = DarkRP.getPhrase("thumbs_up"),
        [ACT_GMOD_GESTURE_WAVE] = DarkRP.getPhrase("wave"),
        [ACT_GMOD_TAUNT_DANCE] = DarkRP.getPhrase("dance")
    }

    for k,v in pairs(anims) do
        self:AddButton(v, k)
    end
end

function PANEL:AddButton(name, cmd)
    local btn = vgui.Create("PIXEL.TextButton", self)

    btn:SetText(name)
    btn:SetFont("HUD.AnimMenuButton")

    btn.DoClick = function(s)
        RunConsoleCommand("_DarkRP_DoAnimation", cmd)
        self:Close()
        menuOpen = false
    end

    table.insert(self.Buttons, btn)
end

function PANEL:OnRemove()
    menuOpen = false
end

function PANEL:LayoutContent(w, h)
    local btnH = PIXEL.Scale(40)
    local btnPad = PIXEL.Scale(6)

    for k,v in ipairs(self.Buttons) do
        v:SetTall(btnH)
        v:Dock(TOP)
        v:DockMargin(0, k > 1 and btnPad or 0, 0, 0)
    end

    self:SizeToChildren(false, true)
    self:CenterHorizontal(.6)
    self:CenterVertical()
end

vgui.Register("PIXEL.HUD.AnimationMenu", PANEL, "PIXEL.Frame")

timer.Simple(1, function()
    concommand.Add("_DarkRP_AnimationMenu", function()
        if menuOpen then return end
        vgui.Create("PIXEL.HUD.AnimationMenu")
    end)
end)