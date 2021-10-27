
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

local function rebuildHud()
    if IsValid(PIXEL.HUD.Panel) then
        PIXEL.HUD.Panel:Remove()
    end

    PIXEL.HUD.Panel = vgui.Create("PIXEL.HUD.Container")
end

local barTop = CreateClientConVar("pixel_hud_bar_top", "1", true, false, "Should the bar HUD be on the top or bottom of your screen?", 0, 1)
local barEnabled = CreateClientConVar("pixel_hud_bar_enabled", "1", true, false, "Should the bar HUD be shown?", 0, 1)

cvars.AddChangeCallback("pixel_hud_bar_top", rebuildHud)
cvars.AddChangeCallback("pixel_hud_bar_enabled", rebuildHud)

function PIXEL.HUD.Build(container)
    container.Elements = {}

    container.Elements.Ammo = vgui.Create("PIXEL.HUD.Ammo", container)
    container.Elements.Alerts = vgui.Create("PIXEL.HUD.Alerts", container)
    container.Elements.ArrestTimer = vgui.Create("PIXEL.HUD.Arrested", container)
    container.Elements.VoiceChat = vgui.Create("PIXEL.HUD.VoiceChat", container)

    PIXEL.HUD.BarEnabled = barEnabled:GetBool()
    if PIXEL.HUD.BarEnabled then
        PIXEL.HUD.BarTop = barTop:GetBool()
        container.Elements.Bar = vgui.Create("PIXEL.HUD.Bar", container)
    end

    if IsValid(PIXEL.HUD.VoteContainer) then
        PIXEL.HUD.VoteContainer:Remove()
    end

    PIXEL.HUD.VoteContainer = vgui.Create("PIXEL.HUD.VoteContainer")
    PIXEL.HUD.VoteContainer:PlaceElement(ScrW(), ScrH())

    hook.Run("PIXEL.HUD.FinishedBuilding")
end