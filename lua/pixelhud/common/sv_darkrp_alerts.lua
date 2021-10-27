
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

function PIXEL.HUD.SendAlert(title, body, time, ply)
    net.Start("PIXEL.HUD.Alert")
        net.WriteString(title)
        net.WriteString(body)
        net.WriteUInt(time or 5, 16)
    net.Send(ply)
end

function PIXEL.HUD.BroadcastAlert(title, body, time)
    net.Start("PIXEL.HUD.Alert")
        net.WriteString(title)
        net.WriteString(body)
        net.WriteUInt(time or 5, 16)
    net.Broadcast()
end

hook.Add("playerWanted", "PIXEL.HUD.NotifyWanted", function(ply, actor, reason)
    reason = reason or "None"

    if IsValid(actor) then
        PIXEL.HUD.BroadcastAlert(
            "WANTED",
            ply:Nick() .. " was made wanted by " .. actor:Nick() .. "!\nReason: " .. reason
        )
    else
        PIXEL.HUD.BroadcastAlert(
            "WANTED",
            ply:Nick() .. " was made wanted!\nReason: " .. reason
        )
    end
end)

hook.Add("playerUnWanted", "PIXEL.HUD.NotifyUnWanted", function(ply, actor)
    if IsValid(actor) then
        PIXEL.HUD.BroadcastAlert(
            "UNWANTED",
            ply:Nick() .. " is no longer wanted!\nRevoked by: " .. actor:Nick()
        )
    else
        PIXEL.HUD.BroadcastAlert(
            "UNWANTED",
            ply:Nick() .. " is no longer wanted!"
        )
    end
end)

hook.Add("playerWarranted", "PIXEL.HUD.NotifyWarranted", function(ply, warranter, reason)
    reason = reason or "None"

    PIXEL.HUD.BroadcastAlert(
        "WARRANT",
        "Search warrant approved for " .. ply:Nick() .. "!\nReason: " .. reason
    )
end)

hook.Add("playerUnWarranted", "PIXEL.HUD.NotifyUnWarranted", function(ply, actor)
    if IsValid(actor) then
        PIXEL.HUD.BroadcastAlert(
            "UNWARRANTED",
            actor:Nick() .. " revoked the warrant on " .. ply:Nick() .. "!"
        )
    else
        PIXEL.HUD.BroadcastAlert(
            "UNWARRANTED",
            "The warrant for " .. ply:Nick() .. " expired!"
        )
    end
end)

hook.Add("playerArrested", "PIXEL.HUD.NotifyArrested", function(ply, time, actor)
    if IsValid(actor) then
        PIXEL.HUD.BroadcastAlert(
            "ARRESTED",
            ply:Nick() .. " has been arrested by " .. actor:Nick() .. "!"
        )
    else
        PIXEL.HUD.BroadcastAlert(
            "ARRESTED",
            ply:Nick() .. " has been arrested!"
        )
    end
end)

hook.Add("playerUnArrested", "PIXEL.HUD.NotifyUnArrested", function(ply, time, actor)
    if IsValid(actor) then
        PIXEL.HUD.BroadcastAlert(
            "UNARRESTED",
            ply:Nick() .. " has been unarrested by " .. actor:Nick() .. "!"
        )
    else
        PIXEL.HUD.BroadcastAlert(
            "UNARRESTED",
            ply:Nick() .. " has been unarrested!"
        )
    end
end)

util.AddNetworkString("PIXEL.HUD.Alert")