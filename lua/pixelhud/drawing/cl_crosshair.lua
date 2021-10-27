
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

local function setupCrosshairDrawing(imgurId, scale)
    if not imgurId or imgurId == "" or scale < 1 then
        hook.Remove("HUDShouldDraw", "PIXEL.HUD.OverrideCrosshair")
        hook.Remove("HUDPaint", "PIXEL.HUD.DrawCustomCrosshair")
        return
    end

    local localPly = LocalPlayer()
    if not IsValid(localPly) then
        hook.Add("PreRender", "PIXEL.HUD.CrosshairWaitForLocalPlayer", function()
            if not IsValid(LocalPlayer()) then return end

            hook.Remove("PreRender", "PIXEL.HUD.CrosshairWaitForLocalPlayer")
            setupCrosshairDrawing(
                GetConVar("pixel_hud_crosshair_imgur_id"):GetString(),
                GetConVar("pixel_hud_crosshair_size"):GetInt()
            )
        end)

        return
    end

    local overrideElem = "CHudCrosshair"
    local negative = false

    hook.Add("HUDShouldDraw", "PIXEL.HUD.OverrideCrosshair", function(elem, _, _, _, isCustom)
        if elem == overrideElem and not isCustom then return negative end
    end)

    local nothing = nil
    local positive = true
    local col = color_white
    local halfScale = scale * .5
    local drawImgur = PIXEL.DrawImgur
    local callHook = hook.Call
    local scrW, scrH = ScrW, ScrH
    local isValid = IsValid
    local getActiveWeapon = localPly.GetActiveWeapon
    local inVehicle = localPly.InVehicle
    local getAllowWeaponsInVehicle = localPly.GetAllowWeaponsInVehicle

    hook.Add("HUDPaint", "PIXEL.HUD.DrawCustomCrosshair", function()
        if callHook(overrideElem, nothing, nothing, nothing, positive) == nothing then
            do
                local wep = getActiveWeapon(localPly)
                if isValid(wep) and (wep.DrawCrosshair == negative or (wep.HUDShouldDraw and wep:HUDShouldDraw(overrideElem) == negative)) then
                    return
                end
            end

            if inVehicle(localPly) and not getAllowWeaponsInVehicle(localPly) then
                return
            end

            drawImgur(scrW() * .5 - halfScale, scrH() * .5 - halfScale, scale, scale, imgurId, col)
        end
    end)
end

CreateClientConVar("pixel_hud_crosshair_size", "25", true, false, "The size of your custom crosshair in pixels.")
CreateClientConVar("pixel_hud_crosshair_imgur_id", "", true, false, "The Imgur ID of your custom crosshair.", 0, ScrH())

local function cvarCallback()
    setupCrosshairDrawing(
        GetConVar("pixel_hud_crosshair_imgur_id"):GetString(),
        GetConVar("pixel_hud_crosshair_size"):GetInt()
    )
end
cvarCallback()

cvars.AddChangeCallback("pixel_hud_crosshair_size", cvarCallback, "pixel_hud_custom_crosshair_size")
cvars.AddChangeCallback("pixel_hud_crosshair_imgur_id", cvarCallback, "pixel_hud_custom_crosshair_imgur_id")