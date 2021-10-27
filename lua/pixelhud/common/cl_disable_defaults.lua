
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

local hiddenElements = {
    DarkRP_HUD = true,
    DarkRP_EntityDisplay = true,
    DarkRP_ZombieInfo = true,
    DarkRP_LocalPlayerHUD = true,
    DarkRP_Hungermod = true,
    DarkRP_Agenda = true,
    CHudHealth = true,
    CHudBattery = true,
    CHudDamageIndictator = true,
    CHudZoom = true,
    CHudAmmo = true,
    CHudSecondaryAmmo = true,
    CHudDeathNotice = true
}

hook.Add("HUDShouldDraw", "PIXEL.HUD.DisableDefaults", function(name)
    if hiddenElements[name] then return false end
end)

hook.Add("HUDDrawTargetID", "PIXEL.HUD.RemoveTargetID", function()
    return false
end)

usermessage.Hook("_Notify", function(msg) --From DarkRP hud/cl_hud.lua L360-371
    local txt = msg:ReadString()
    GAMEMODE:AddNotify(txt, msg:ReadShort(), msg:ReadLong())
    surface.PlaySound("buttons/lightswitch2.wav")

    MsgC(Color(255, 20, 20, 255), "[DarkRP] ", Color(200, 200, 200, 255), txt, "\n")
end)