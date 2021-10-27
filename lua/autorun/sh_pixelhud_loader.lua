
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

PIXEL = PIXEL or {}
PIXEL.HUD = PIXEL.HUD or {}

local function loadDirectory(dir)
    local fil, fol = file.Find(dir .. "/*", "LUA")

    for k,v in ipairs(fil) do
        local dirs = dir .. "/" .. v

        if v:StartWith("cl_") then
            if SERVER then AddCSLuaFile(dirs)
            else include(dirs) end
        elseif v:StartWith("sh_") then
            AddCSLuaFile(dirs)
            include(dirs)
        else
            if SERVER then include(dirs) end
        end
    end

    for k,v in pairs(fol) do
        loadDirectory(dir .. "/" .. v)
    end
end

local function loadAddon()
    loadDirectory("pixelhud")
end

if PIXEL.UI then
    loadAddon()
    return
end

hook.Add("PIXEL.UI.FullyLoaded", "PIXEL.HUD.WaitForPIXELUI", loadAddon)