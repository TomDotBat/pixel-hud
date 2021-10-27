
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

local colors = PIXEL.HUD.Colors.FPP

local weaponClassTouchTypes = {
    ["weapon_physgun"] = "Physgun",
    ["weapon_physcannon"] = "Gravgun",
    ["gmod_tool"] = "Toolgun",
}

local function filterEntityTable(t)
    local filtered = {}

    for i, ent in ipairs(t) do
        if (not ent:IsWeapon()) and (not ent:IsPlayer()) then table.insert(filtered, ent) end
    end

    return filtered
end

PIXEL.RegisterFont("HUD.FPPOwner", "Open Sans SemiBold", 16)

--local nameOverrides = {
--    ["world"] = "World",
--    ["blocked"] = "Blocked",
--    ["constraint"] = "Constraint",
--    ["disconnected"] = "Disconnected"
--}

local localPly
local findAlongRay = ents.FindAlongRay
hook.Add("HUDPaint", "PIXEL.HUD.FPP", function()
    if not gProtect then return end
    if not localPly then localPly = LocalPlayer() end

    local eyePos = localPly:EyePos()
    local LAEnt2 = findAlongRay(eyePos, eyePos + EyeAngles():Forward() * 16384)

    local LAEnt = filterEntityTable(LAEnt2)[1]
    if not IsValid(LAEnt) then return end

    local eyeTrace = localPly:GetEyeTrace()
    if eyeTrace.HitPos:DistToSqr(eyeTrace.StartPos) < LAEnt:NearestPoint(eyeTrace.StartPos):DistToSqr(eyeTrace.StartPos) then return end

    --local weapon = localPly:GetActiveWeapon()
    --local class = weapon:IsValid() and weapon:GetClass() or ""

    --local touchType = weaponClassTouchTypes[class] or "EntityDamage"

    --local reason = FPP.entGetTouchReason(LAEnt, touchType)
    --if not reason then return end

    --local originalOwner = LAEnt:GetNW2String("FPP_OriginalOwner")
    --originalOwner = originalOwner ~= "" and (" (previous owner: %s)"):format(originalOwner) or ""
    --reason = reason .. originalOwner

    if !LAEnt or !IsValid(LAEnt) then return end

    local info = gProtect.GetOwner(LAEnt)
    if !info then
        local result = LAEnt:GetNWString("gPOwner", "")
        info = (string.find(result, "STEAM") and "Disconnected") or "World"
    end

    if isstring(info) then
        local translation = slib.getLang("gprotect", gProtect.config.SelectedLanguage, string.lower(info))
        if !translation then return end
        info = translation
        local cachedPly = gProtect.CachedPlayers[LAEnt:GetNWString("gPOwner", "")]

        if cachedPly then
            info = info .. " (" .. cachedPly .. ")"
        end
    end

    local reason = !isstring(info) and info:Nick() or info

    local textH = select(2, PIXEL.GetTextSize(reason, "HUD.FPPOwner"))

    PIXEL.DrawRoundedTextBox(
        reason, "HUD.FPPOwner", PIXEL.Scale(4), ScrH() / 2 - textH / 2, nil, gProtect.HandlePermissions(localPly, LAEnt) and colors.Positive or colors.Negative,
        PIXEL.Scale(4), PIXEL.Scale(3), colors.Background
    )
end)