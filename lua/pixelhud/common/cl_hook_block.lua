
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

local blockedHooks = {}

function PIXEL.HUD.BlockHook(event, identifier)
    hook.Remove(event, identifier)

    if not blockedHooks[event] then
        blockedHooks[event] = {}
    end

    blockedHooks[event][identifier] = true
end

hook.Add("InitPostEntity", "PIXEL.HUD.RemoveBlockedHooks", function()
    for event, eventTable in pairs(blockedHooks) do
        for identifier, enabled in pairs(eventTable) do
            if not enabled then continue end
            hook.Remove(event, identifier)
        end
    end

    local oldAddHook = hook.Add
    function hook.Add(event, identifier, func)
        if blockedHooks[event] and blockedHooks[event][identifier] then return end

        oldAddHook(event, identifier, func)
    end
end)

PIXEL.HUD.BlockHook("StartChat", "StartChatIndicator")
PIXEL.HUD.BlockHook("FinishChat", "EndChatIndicator")
PIXEL.HUD.BlockHook("CreateClientsideRagdoll", "DarkRP_ChatIndicator")
PIXEL.HUD.BlockHook("PostPlayerDraw", "DarkRP_ChatIndicator")
PIXEL.HUD.BlockHook("player_disconnect", "DarkRP_ChatIndicator")