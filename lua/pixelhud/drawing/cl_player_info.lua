
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

local boxEnabled = CreateClientConVar("pixel_hud_box_enabled", "0", true, false, "Should the box HUD be shown?", 0, 1)

local localPly
local name, teamName = "", ""
local health, armor, money = 0, 0, 0
local maxHealth, maxArmor = 100, 100
local wanted
local hideArmor

local max = math.max
local lerp = Lerp
local ft = FrameTime
local getTeamName = team.GetName
local function updateStats(ply)
    name = ply:Name()
    teamName = getTeamName(ply:Team())

    local animSpeed = ft() * 3
    health = max(lerp(animSpeed, health, ply:Health()), 0)
    armor = lerp(animSpeed, armor, ply:Armor())
    money = lerp(animSpeed, money, ply:getDarkRPVar("money"))

    maxHealth = max(maxHealth, health)
    maxArmor = max(maxArmor, armor)

    wanted = ply:getDarkRPVar("wanted")

    if armor < 1 then hideArmor = true
    else hideArmor = false end
end

gameevent.Listen("player_spawn")
hook.Add("player_spawn", "PIXEL.ResetPlayerInfoStats", function(data)
    if not IsValid(localPly) then return end
    if data.userid ~= localPly:UserID() then return end
    maxHealth = 100
    maxArmor = 100
end)

PIXEL.RegisterFont("HUD.PlayerInfo", "Open Sans SemiBold", 22, 500)
PIXEL.RegisterFont("HUD.Wanted", "Open Sans Bold", 22, 500)

PIXEL.RegisterScaledConstant("HUD.ContentPadding", 12)
PIXEL.RegisterScaledConstant("HUD.PlayerInfo.MinWidth", 290)
PIXEL.RegisterScaledConstant("HUD.PlayerInfo.RowHeight", 24)
PIXEL.RegisterScaledConstant("HUD.PlayerInfo.BarHeight", 10)
PIXEL.RegisterScaledConstant("HUD.PlayerInfo.WantedSpacing", 6)
PIXEL.RegisterScaledConstant("HUD.PlayerInfo.SirenSize", 24)

local getScaledConstant = PIXEL.GetScaledConstant
local backgroundCol = PIXEL.Colors.Header
local primaryCol = PIXEL.Colors.PrimaryText
local healthCol = PIXEL.Colors.Negative
local armorCol = PIXEL.Colors.Primary
local healthBgCol = PIXEL.OffsetColor(healthCol, -45)
local armorBgCol = PIXEL.OffsetColor(armorCol, -45)
local contentOverflow = 0
local contentPad
local barHeight

local rows = {}

rows[1] = function(x, y, w, h, centerY, baseW)
    PIXEL.DrawImgur(x, y, h, h, "9dOCGhN", primaryCol)

    local nameOffset = h + contentPad
    local nameW = PIXEL.DrawSimpleText(name, "HUD.PlayerInfo", x + nameOffset, centerY, primaryCol, nil, TEXT_ALIGN_CENTER)

    contentOverflow = (nameOffset + nameW) - baseW
end

local round = math.Round
rows[2] = function(x, y, w, h, centerY, baseW)
    PIXEL.DrawImgur(x, y, h, h, "wcd8zwk", primaryCol)
    local teamX = x + h + contentPad
    local teamW = PIXEL.DrawSimpleText(teamName, "HUD.PlayerInfo", teamX, centerY, primaryCol, nil, TEXT_ALIGN_CENTER)

    local moneyX = teamX + teamW + contentPad
    PIXEL.DrawImgur(moneyX, y, h, h, "1PGuA4X", primaryCol)

    moneyX = moneyX + h + contentPad
    local moneyW = PIXEL.DrawSimpleText(PIXEL.FormatMoney(round(money)), "HUD.PlayerInfo", moneyX, centerY, primaryCol, nil, TEXT_ALIGN_CENTER)

    contentOverflow = max((moneyX + moneyW - x) - baseW, contentOverflow)
end

local function drawProgress(x, y, w, h, prog, bgCol, fgCol)
    y = y + (h - barHeight) * .5

    local rounding = PIXEL.Scale(2)
    PIXEL.DrawRoundedBox(rounding, x, y, w, barHeight, bgCol)
    PIXEL.DrawRoundedBox(rounding, x, y, w * prog, barHeight, fgCol)
end

rows[3] = function(x, y, w, h, centerY, baseW)
    PIXEL.DrawImgur(x, y, h, h, "HUc3yHx", primaryCol)

    local barOffset = h + contentPad
    drawProgress(x + barOffset, y, w - barOffset, h, health / maxHealth, healthBgCol, healthCol)
end

rows[4] = function(x, y, w, h, centerY, baseW)
    PIXEL.DrawImgur(x, y, h, h, "GwgAhqq", primaryCol)

    local barOffset = h + contentPad
    drawProgress(x + barOffset, y, w - barOffset, h, armor / maxArmor, armorBgCol, armorCol)
end

local animX = 0
local sin = math.sin
local curTime = UnPredictedCurTime
local callHook = hook.Call
hook.Add("HUDPaint", "PIXEL.HUD.DrawPlayerInfo", function()
    if not boxEnabled:GetBool() then return end

    if not IsValid(localPly) then localPly = LocalPlayer() end
    updateStats(localPly)

    local scrH = ScrH()

    local rowCount = hideArmor and (#rows - 1) or #rows
    local padding = getScaledConstant("HUD.Padding")
    contentPad = getScaledConstant("HUD.ContentPadding")
    barHeight = getScaledConstant("HUD.PlayerInfo.BarHeight")
    local rowHeight = getScaledConstant("HUD.PlayerInfo.RowHeight")
    local halfRowHeight = rowHeight * .5
    local width = getScaledConstant("HUD.PlayerInfo.MinWidth")
    local height = (contentPad + rowHeight) * rowCount + contentPad

    contentOverflow = max(contentOverflow, 0)

    local boxY = scrH - padding - height
    local rowX = padding + contentPad - animX
    local baseRowWidth = width - contentPad * 2
    local rowWidth = baseRowWidth + contentOverflow

    if callHook("PIXEL.ShouldDraw", nil, "PlayerInfo") == false then
        animX = lerp(ft() * 5, animX, padding * 2 + width + contentOverflow)
    else
        animX = lerp(ft() * 5, animX, 0)
    end

    PIXEL.DrawRoundedBox(PIXEL.Scale(6), padding - animX, boxY, width + contentOverflow, height, backgroundCol)

    local rowY = boxY + contentPad

    for i = 1, rowCount do
        rows[i](rowX, rowY, rowWidth, rowHeight, rowY + halfRowHeight, baseRowWidth)
        rowY = rowY + rowHeight + contentPad
    end

    if not wanted then return end

    local centerX = padding + width * .5 - animX
    local wantedY = boxY - getScaledConstant("HUD.PlayerInfo.WantedSpacing")
    local wantedW, wantedH = PIXEL.DrawSimpleText("WANTED", "HUD.Wanted", centerX, wantedY, primaryCol, TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM)

    local sirenSize = getScaledConstant("HUD.PlayerInfo.SirenSize")
    local sirenOffset = wantedW * .5 + sirenSize + contentPad
    wantedY = wantedY - wantedH * .5 - sirenSize * .5

    local time = curTime() * 5
    local sinTime = (sin(time) + 1) * .5
    for i = -1, 1, 2 do
        PIXEL.DrawImgur(centerX + sirenOffset * i, wantedY, sirenSize, sirenSize, "dIjQAWu", PIXEL.LerpColor(sinTime, healthCol, armorCol))
        sinTime = (sin(-time) + 1) * .5
        sirenOffset = sirenOffset - sirenSize
    end
end)