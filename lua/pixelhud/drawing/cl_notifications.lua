
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

local colors = PIXEL.HUD.Colors.Notifications

local notifications = {}

local imgurIds = {
    [NOTIFY_CLEANUP] = "Yq4YGjB",
    [NOTIFY_ERROR] = "xIqudQF",
    [NOTIFY_GENERIC] = "65aXd5A",
    [NOTIFY_HINT] = "AVCemiF",
    [NOTIFY_UNDO] = "bcQs60r"
}

local function getYOff()
    return ScrH() - PIXEL.Scale(180)
end

function notification.AddLegacy(text, type, time)
    if string.find(text, "Lua problem") then return end --lol

    local notif = {
        text = text,
        type = type,
        dietime = CurTime() + time,
        x = ScrW(),
        y = getYOff()
    }

    notifications[#notifications + 1] = notif
end

function notification.AddProgress(id, text, frac) end
function notification.Kill(id) end

PIXEL.RegisterFont("HUD.Notification", "Open Sans SemiBold", 22)

PIXEL.RegisterScaledConstant("HUD.Notifications.Spacing", 10)

local lerp = Lerp
local getScaledConstant = PIXEL.GetScaledConstant
hook.Add("HUDPaint", "PIXEL.HUD.Notifications", function()
    local padding = getScaledConstant("HUD.Padding")
    local spacing = getScaledConstant("HUD.Notifications.Spacing")

    local scrw, scrh = ScrW(), ScrH()

    local offX = scrw - padding
    local offY = getYOff()

    local ft = FrameTime() * 10
    local time = CurTime()

    local nh = scrh * .038


    for k,v in ipairs(notifications) do
        local nw = nh + PIXEL.GetTextSize(v.text, "HUD.Notification") + scrw * .005
        local desiredx, desiredy = offX-nw, offY-((nh * k) + (spacing * (k - 1)))

        if time >= v.dietime then
            v.x = lerp(ft, v.x, scrw + nw * .1)

            if v.x > scrw then
                table.remove(notifications, k)
                continue
            end
        else
            v.x = lerp(ft, v.x, desiredx)
        end

        v.y = lerp(ft, v.y, desiredy)

        PIXEL.DrawRoundedBox(PIXEL.Scale(4), v.x, v.y, nw, nh, colors.Background)
        PIXEL.DrawSimpleText(v.text, "HUD.Notification", v.x + nw - scrw * .005, v.y + nh * .47, colors.Text, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)

        local iconOff = nh * .18
        local iconOffX = PIXEL.Scale(11)
        local iconSize = nh * .55
        PIXEL.DrawImgur(iconOffX + v.x, iconOff + v.y + nh * .05, iconSize, iconSize, imgurIds[v.type], colors.Icon)
    end
end)