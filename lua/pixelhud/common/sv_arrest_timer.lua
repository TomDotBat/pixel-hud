
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

hook.Add("playerArrested", "PIXEL.HUD.SendArrestTime", function(criminal, time, actor)
    net.Start("PIXEL.HUD.SendArrestTime")
     net.WriteUInt(time, 32)
    net.Send(criminal)
end)

util.AddNetworkString("PIXEL.HUD.SendArrestTime")