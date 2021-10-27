
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

hook.Add("PostGamemodeLoaded", "PIXEL.HUD.OverrideVotingUsermessages", function()
    usermessage.Hook("DoVote", function(msg)
        local text, id, time = msg:ReadString(), tostring(msg:ReadShort()), msg:ReadFloat()

        if not IsValid(PIXEL.HUD.VoteContainer) then return end
        PIXEL.HUD.VoteContainer:AddVote(id, text, time)
    end)

    usermessage.Hook("KillVoteVGUI", function(msg)
        local id = tostring(msg:ReadShort())

        if not IsValid(PIXEL.HUD.VoteContainer) then return end
        if not IsValid(PIXEL.HUD.VoteContainer.Votes[id]) then return end

        PIXEL.HUD.VoteContainer.Votes[id]:Remove()
        PIXEL.HUD.VoteContainer.Votes[id] = nil
    end)

    usermessage.Hook("DoQuestion", function(msg)
        local text, id, time = msg:ReadString(), msg:ReadString(), msg:ReadFloat()

        if not IsValid(PIXEL.HUD.VoteContainer) then return end
        PIXEL.HUD.VoteContainer:AddQuestion(id, text, time)
    end)

    usermessage.Hook("KillQuestionVGUI", function(msg)
        local id = msg:ReadString()

        if not IsValid(PIXEL.HUD.VoteContainer) then return end
        if not IsValid(PIXEL.HUD.VoteContainer.Votes[id]) then return end

        PIXEL.HUD.VoteContainer.Votes[id]:Remove()
        PIXEL.HUD.VoteContainer.Votes[id] = nil
    end)
end)