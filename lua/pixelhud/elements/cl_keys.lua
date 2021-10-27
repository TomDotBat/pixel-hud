
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

local buttons = {
    {
        name = function(entType) return "Sell " .. entType end,
        canSee = function(ply, door, hasSetDoorOwnerAccess, hasDoorSettingsAccess)
            return door:isKeysOwnedBy(ply)
        end,
        autoClose = true,
        onClick = function(ply, door, frame)
            RunConsoleCommand("darkrp", "toggleown")
        end
    },
    {
        name = "Add Owner",
        canSee = function(ply, door, hasSetDoorOwnerAccess, hasDoorSettingsAccess)
            return door:isKeysOwnedBy(ply)
        end,
        onClick = function(ply, door, frame)
            CloseDermaMenus()
            local playerList = vgui.Create("PIXEL.Menu")

            playerList.found = false

            for _, v in pairs(DarkRP.nickSortedPlayers()) do
                if not door:isKeysOwnedBy(v) and not door:isKeysAllowedToOwn(v) then
                    local steamID = v:SteamID()
                    playerList.found = true
                    playerList:AddOption(v:Nick(), function() RunConsoleCommand("darkrp", "ao", steamID) end)
                end
            end

            if not playerList.found then
                playerList:AddOption(DarkRP.getPhrase("noone_available"), function() end)
            end

            playerList:Open()
        end
    },
    {
        name = "Remove Owner",
        canSee = function(ply, door, hasSetDoorOwnerAccess, hasDoorSettingsAccess)
            return door:isKeysOwnedBy(ply)
        end,
        onClick = function(ply, door, frame)
            CloseDermaMenus()
            local playerList = vgui.Create("PIXEL.Menu")

            for _, v in pairs(DarkRP.nickSortedPlayers()) do
                if (door:isKeysOwnedBy(v) and not door:isMasterOwner(v)) or door:isKeysAllowedToOwn(v) then
                    local steamID = v:SteamID()
                    playerList.found = true
                    playerList:AddOption(v:Nick(), function() RunConsoleCommand("darkrp", "ro", steamID) end)
                end
            end

            if not playerList.found then
                playerList:AddOption(DarkRP.getPhrase("noone_available"), function() end)
            end

            playerList:Open()

            if not door:isMasterOwner(LocalPlayer()) then
                RemoveOwner:SetDisabled(true)
            end
        end
    },
    {
        name = function(entType, door) return door:getKeysNonOwnable() and "Allow Ownership" or "Disallow Ownership" end,
        canSee = function(ply, door, hasSetDoorOwnerAccess, hasDoorSettingsAccess)
            return hasDoorSettingsAccess
        end,
        autoClose = true,
        onClick = function(ply, door, frame)
            RunConsoleCommand("darkrp", "toggleownable")
        end
    },
    {
        name = function(entType) return "Set " .. entType .. " Title" end,
        canSee = function(ply, door, hasSetDoorOwnerAccess, hasDoorSettingsAccess)
            return hasDoorSettingsAccess and (door:isKeysOwned() or door:getKeysNonOwnable() or door:getKeysDoorGroup()) or door:isKeysOwnedBy(ply)
        end,
        onClick = function(ply, door, frame)
            Derma_StringRequest("Set title", "Set the title of what you're looking at:", "", function(text)
                RunConsoleCommand("darkrp", "title", text)
                if IsValid(frame) then frame:Close() end
            end,
            function() end, DarkRP.getPhrase("ok"), DarkRP.getPhrase("cancel"))
        end
    },
    {
        name = function(entType) return "Buy " .. entType end,
        canSee = function(ply, door, hasSetDoorOwnerAccess, hasDoorSettingsAccess)
            return not door:isKeysOwned() and not door:getKeysNonOwnable() and not door:getKeysDoorGroup() and not door:getKeysDoorTeams() or not door:isKeysOwnedBy(ply) and door:isKeysAllowedToOwn(ply)
        end,
        autoClose = true,
        onClick = function(ply, door, frame)
            RunConsoleCommand("darkrp", "toggleown")
        end
    },
    {
        name = "Edit Door Group",
        canSee = function(ply, door, hasSetDoorOwnerAccess, hasDoorSettingsAccess)
            return hasDoorSettingsAccess
        end,
        onClick = function(ply, door, frame)
            CloseDermaMenus()
            local dropdown = vgui.Create("PIXEL.Menu")

            local groups = dropdown:AddSubMenu("Door Groups")
            local teams = dropdown:AddSubMenu("Jobs")
            local add = teams:AddSubMenu("Add")
            local remove = teams:AddSubMenu("Remove")

            dropdown:AddOption("None", function()
                RunConsoleCommand("darkrp", "togglegroupownable")
                if IsValid(frame) then frame:Close() end
            end)

            for k in pairs(RPExtraTeamDoors) do
                groups:AddOption(k, function()
                    RunConsoleCommand("darkrp", "togglegroupownable", k)
                    if IsValid(frame) then frame:Close() end
                end)
            end

            local doorTeams = door:getKeysDoorTeams()
            for k, v in pairs(RPExtraTeams) do
                local which = (not doorTeams or not doorTeams[k]) and add or remove
                which:AddOption(v.name, function()
                    RunConsoleCommand("darkrp", "toggleteamownable", k)
                    if IsValid(frame) then frame:Close() end
                end)
            end

            dropdown:Open()
        end
    }
}

local menuOpen = false

local PANEL = {}

PIXEL.RegisterFont("HUD.DoorMenuButton", "Open Sans SemiBold", 19)

function PANEL:Init()
    if menuOpen then self:Remove() return end
    menuOpen = true

    self:SetSize(PIXEL.Scale(160), 0)
    self:MakePopup()
    self:ParentToHUD()

    self.LocalPlayer = LocalPlayer()
    self.Buttons = {}
end

function PANEL:AddButton(name, func, autoClose)
    local btn = vgui.Create("PIXEL.TextButton", self)

    btn:SetText(name)
    btn:SetFont("HUD.DoorMenuButton")

    btn.DoClick = function(s)
        func(self.LocalPlayer, self.Door, self)

        if not autoClose then return end
        self:Close()
    end

    table.insert(self.Buttons, btn)
end

function PANEL:SetDoor(door, hasSetDoorOwnerAccess, hasDoorSettingsAccess)
    if not (IsValid(self) and IsValid(door)) then return end

    local entType = door:IsVehicle() and "Vehicle" or "Door"

    self.Door = door
    self:SetTitle(entType .. " Settings")

    for k,v in ipairs(buttons) do
        if v.canSee and not v.canSee(self.LocalPlayer, door, hasSetDoorOwnerAccess, hasDoorSettingsAccess) then continue end
        self:AddButton(isfunction(v.name) and v.name(entType, door) or v.name, v.onClick, v.autoClose)
    end

    if #self.Buttons <= 0 then
        self:Remove()
        menuOpen = false
        return
    end

    hook.Call("onKeysMenuOpened", nil, door, self)
end

function PANEL:OnClose()
    menuOpen = false
end

function PANEL:LayoutContent(w, h)
    local btnH = PIXEL.Scale(40)
    local btnPad = PIXEL.Scale(6)

    for k,v in ipairs(self.Buttons) do
        v:SetTall(btnH)
        v:Dock(TOP)
        v:DockMargin(0, k > 1 and btnPad or 0, 0, 0)
    end

    self:SizeToChildren(false, true)
    self:Center()
end

function PANEL:Think()
    if not IsValid(self.Door) then self:Close() return end

    local tr = self.LocalPlayer:GetEyeTrace()
    if self.Door ~= tr.Entity then self:Close() return end
end

vgui.Register("PIXEL.HUD.DoorMenu", PANEL, "PIXEL.Frame")

hook.Add("PostGamemodeLoaded", "PIXEL.HUD.OverrideKeysMenu", function()
    function DarkRP.openKeysMenu()
        local ply = LocalPlayer()
        CAMI.PlayerHasAccess(ply, "DarkRP_SetDoorOwner", function(hasSetDoorOwnerAccess)
            CAMI.PlayerHasAccess(ply, "DarkRP_ChangeDoorSettings", function(hasDoorSettingsAccess)
                if menuOpen then return end

                local frame = vgui.Create("PIXEL.HUD.DoorMenu")

                local tr = ply:GetEyeTrace()
                local ent = tr.Entity
                if not IsValid(ent) or not ent:isKeysOwnable() or tr.HitPos:DistToSqr(ply:EyePos()) > 40000 then return end

                frame:SetDoor(ent, hasSetDoorOwnerAccess, hasDoorSettingsAccess)
            end)
        end)
    end

    usermessage.Hook("KeysMenu", DarkRP.openKeysMenu)
end)