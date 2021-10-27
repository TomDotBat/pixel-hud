
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

sam.command.new("cancelnlr")
:SetCategory("DarkRP")
:Help("Cancels a player's NLR timer.")
:SetPermission("cancelnlr", "admin")

:AddArg("player")

:OnExecute(function(caller, targets)
    for i = 1, #targets do
        targets[i]:SendLua([[timer.Remove("PIXEL.HUD.NLRTimer")
hook.Remove("HUDPaint", "PIXEL.HUD.NLRTimer")]])
    end

    sam.player.send_message(nil, "{A} cancelled the NLR timer for {T}.", {
        A = caller, T = targets
    })
end)
:End()