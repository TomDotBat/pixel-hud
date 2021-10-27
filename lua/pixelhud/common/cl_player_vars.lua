
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

local localPly = LocalPlayer()

hook.Add("DarkRPVarChanged", "PIXEL.DarkRPVarChanged", function(ply, key, _, value)
    if not IsValid(localPly) then return end
    if ply ~= localPly then return end
    if localPly:Name() ~= ply:Name() then return end

    hook.Run("PIXEL.HUD.UpdatePlayerVars", key, value)
end)

local currentVals = {}

local function checkChanges(name, getter)
    local newVal = getter(localPly)

    if not currentVals[name] then
        currentVals[name] = newVal
        hook.Run("PIXEL.HUD.UpdatePlayerVars", name, newVal)
        return
    end

    if newVal == currentVals[name] then return end

    hook.Run("PIXEL.HUD.UpdatePlayerVars", name, newVal, currentVals[name])
    currentVals[name] = newVal
end

local showingAmmo = false
local curClip = 0
local curReserve = 0

local function checkWeaponStats()
    local curWeapon = localPly:GetActiveWeapon()

    if not IsValid(curWeapon) then
        if not showingAmmo then return end
        hook.Run("PIXEL.HUD.UpdatePlayerVars", "showammo", false)
        showingAmmo = false
        return
    end

    local clip = curWeapon:Clip1()
    local reserve = localPly:GetAmmoCount(curWeapon:GetPrimaryAmmoType())

    if curClip ~= clip then
        hook.Run("PIXEL.HUD.UpdatePlayerVars", "ammoclip", clip)
        curClip = clip
    end

    if curReserve ~= reserve then
        hook.Run("PIXEL.HUD.UpdatePlayerVars", "ammoreserve", reserve)
        curReserve = reserve
    end

    if clip < 0 or reserve < 0 then
        if not showingAmmo then return end
        hook.Run("PIXEL.HUD.UpdatePlayerVars", "showammo", false)
        showingAmmo = false
        return
    end

    if showingAmmo then return end
    hook.Run("PIXEL.HUD.UpdatePlayerVars", "showammo", true)
    showingAmmo = true
end

hook.Add("PIXEL.HUD.FinishedBuilding", "PIXEL.WaitToCheckStats", function()
    currentVals = {}
    showingAmmo = false
    curClip = 0
    curReserve = 0

    hook.Add("Think", "PIXEL.CheckPlayerStatChanges", function()
        if not IsValid(localPly) then localPly = LocalPlayer() end

        checkChanges("health", localPly.Health)
        checkChanges("armor", localPly.Armor)

        checkChanges("time", localPly.GetUTimeTotalTime)

        checkWeaponStats()
    end)
end)