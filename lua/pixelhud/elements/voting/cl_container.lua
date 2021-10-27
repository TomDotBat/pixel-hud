
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

local PANEL = {}

function PANEL:Init()
    self.Votes = {}
    self:SetMouseInputEnabled(true)
    self:SetZPos(32000)
end

function PANEL:AddVote(id, text, time)
    LocalPlayer():EmitSound("Town.d1_town_02_elevbell1", 100, 100)
    if time <= 0 then time = 100 end

    if self.Votes[id] and IsValid(self.Votes[id]) then
        self.Votes[id]:Remove()
    end

    local vote = vgui.Create("PIXEL.HUD.Vote", self)
    vote:SetVote(id, text, time)

    vote.OnRemove = function()
        self.Votes[id] = nil
    end

    self.Votes[id] = vote
end

function PANEL:AddQuestion(id, text, time)
    LocalPlayer():EmitSound("Town.d1_town_02_elevbell1", 100, 100)
    if time <= 0 then time = 100 end

    if self.Votes[id] and IsValid(self.Votes[id]) then
        self.Votes[id]:Remove()
    end

    local question = vgui.Create("PIXEL.HUD.Vote", self)
    question:SetQuestion(id, text, time)

    question.OnRemove = function()
        self.Votes[id] = nil
    end

    self.Votes[id] = question
end

function PANEL:PerformLayout(w, h)
    for k,v in SortedPairsByMemberValue(self.Votes, "FinishTime") do
        v:Dock(LEFT)
        v:DockMargin(0, 0, PIXEL.Scale(10), 0)
        v:SetWide(h)
    end
end

function PANEL:PlaceElement(w, h)
    local pad = PIXEL.GetScaledConstant("HUD.Padding")
    local selfH = PIXEL.Scale(160)
    PIXEL.HUD.VoteContainer:SetSize(w - pad * 2, selfH)
    PIXEL.HUD.VoteContainer:SetPos(pad, h * .4 - selfH * .5)
end

function PANEL:OnScreenSizeChanged()
    self:PlaceElement(ScrW(), ScrH())
end

vgui.Register("PIXEL.HUD.VoteContainer", PANEL, "EditablePanel")
