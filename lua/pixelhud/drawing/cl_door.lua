
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

local colors = PIXEL.HUD.Colors.Door

local localPly

PIXEL.RegisterFont("HUD.Door", "Open Sans SemiBold", 21, 400)

timer.Simple(1, function()
    local meta = FindMetaTable("Entity")
    function meta:drawOwnableInfo()
        if localPly:InVehicle() and not localPly:GetAllowWeaponsInVehicle() then return end

        local blocked = self:getKeysNonOwnable()
        local superadmin = localPly:IsSuperAdmin()
        local doorTeams = self:getKeysDoorTeams()
        local doorGroup = self:getKeysDoorGroup()
        local playerOwned = self:isKeysOwned() or next(self:getKeysCoOwners() or {}) ~= nil
        local owned = playerOwned or doorGroup or doorTeams

        local doorInfo = {}

        local title = self:getKeysTitle()
        if title then table.insert(doorInfo, title) end

        if owned then
            table.insert(doorInfo, DarkRP.getPhrase("keys_owned_by"))
        end

        if playerOwned then
            if self:isKeysOwned() then table.insert(doorInfo, self:getDoorOwner():Nick()) end
            for k in pairs(self:getKeysCoOwners() or {}) do
                local ent = Player(k)
                if not IsValid(ent) or not ent:IsPlayer() then continue end
                table.insert(doorInfo, ent:Nick())
            end

            local allowedCoOwn = self:getKeysAllowedToOwn()
            if allowedCoOwn and not fn.Null(allowedCoOwn) then
                table.insert(doorInfo, DarkRP.getPhrase("keys_other_allowed"))

                for k in pairs(allowedCoOwn) do
                    local ent = Player(k)
                    if not IsValid(ent) or not ent:IsPlayer() then continue end
                    table.insert(doorInfo, ent:Nick())
                end
            end
        elseif doorGroup then
            table.insert(doorInfo, doorGroup)
        elseif doorTeams then
            for k, v in pairs(doorTeams) do
                if not v or not RPExtraTeams[k] then continue end

                table.insert(doorInfo, RPExtraTeams[k].name)
            end
        elseif blocked and superadmin then
            table.insert(doorInfo, DarkRP.getPhrase("keys_allow_ownership"))
        elseif not blocked then
            table.insert(doorInfo, DarkRP.getPhrase("keys_unowned"))
            if superadmin then
                table.insert(doorInfo, DarkRP.getPhrase("keys_disallow_ownership"))
            end
        end

        if self:IsVehicle() then
            local driver = self:GetDriver()
            if driver:IsPlayer() then
                table.insert(doorInfo, DarkRP.getPhrase("driver", driver:Nick()))
            end
        end

        local x, y = ScrW() * .5, ScrH() * .5
        local text = table.concat(doorInfo, "\n")

        for i = 1, PIXEL.Scale(1) do
            PIXEL.DrawText(text, "HUD.Door", x, y + i, color_black, TEXT_ALIGN_CENTER)
        end

        PIXEL.DrawText(text, "HUD.Door", x, y, (blocked or owned) and colors.Owned or colors.Unowned, TEXT_ALIGN_CENTER)
    end
end)

hook.Add("HUDPaint", "PIXEL.HUD.DoorInfo", function()
    if not localPly then localPly = LocalPlayer() end

    local ent = localPly:GetEyeTrace().Entity
    if not (IsValid(ent) and ent:isKeysOwnable() and ent:GetPos():DistToSqr(localPly:GetPos()) < 40000) then return end
    ent:drawOwnableInfo()
end)