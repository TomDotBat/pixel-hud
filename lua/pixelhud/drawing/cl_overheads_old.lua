
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

local overheadsEnabled = CreateClientConVar("pixel_hud_old_overheads_enabled", "0", true, false, "Should the old overheads be shown?", 0, 1)

function PIXEL.HUD.SetupOldOverheadDrawing()
	local colors = PIXEL.HUD.Colors.Overheads

	PIXEL.RegisterFontUnscaled("HUD.Overheads.Name", "Open Sans Bold", 50)
	PIXEL.RegisterFontUnscaled("HUD.Overheads.Job", "Open Sans SemiBold", 44)
	PIXEL.RegisterFontUnscaled("HUD.Overheads.License", "Open Sans SemiBold", 32)
	PIXEL.RegisterFontUnscaled("HUD.Overheads.Typing", "Open Sans Bold", 180)

	local renderPlayers = {}

	local ply
	local playergetall = player.GetAll
	local ipairs = ipairs
	local teamGetColor = team.GetColor

	hook.Add("Tick", "PIXEL.HUD.GetOldOverheads", function()
		if not overheadsEnabled:GetBool() then
			hook.Remove("Tick", "PIXEL.HUD.GetOldOverheads")
			return
		end

		if not IsValid(ply) then ply = LocalPlayer() end
		if not IsValid(ply) then return end

		renderPlayers = {}

		local plypos = ply:GetPos()
		for k,v in ipairs(playergetall()) do
			if v == ply then continue end
			if plypos:DistToSqr(v:GetPos()) < 90000 or v:IsSpeaking() then
				table.insert(renderPlayers, v)
			end
		end
	end)

	hook.Add("PostDrawTranslucentRenderables", "PIXEL.HUD.DrawOldOverheads", function()
		if not overheadsEnabled:GetBool() then
			hook.Remove("PostDrawTranslucentRenderables", "PIXEL.HUD.DrawOldOverheads")
			return
		end

		if not IsValid(ply) then ply = LocalPlayer() end
		if not IsValid(ply) then return end

		local previousClip = DisableClipping(true)

		local plyInVehicle = ply:InVehicle()
		local eyeAngs = ply:EyeAngles()

		for k,v in ipairs(renderPlayers) do
			if not IsValid(v) then continue end
			if v:Health() < 1 then continue end
			if v:GetColor().a < 100 or v:GetNoDraw() then continue end

			local name = v:Name()
			local jobname = v:getDarkRPVar("job") or "ERROR"

			local nameTextWidth = PIXEL.GetTextSize(name, "HUD.Overheads.Name") + 44
			local jobTextWidth = PIXEL.GetTextSize(jobname, "HUD.Overheads.Job") + 44

			local boxW = math.max(nameTextWidth, jobTextWidth) + 40
			local boxPos = -(boxW * .5)

			local eyeId = v:LookupAttachment("eyes")
			local offset = Vector(-3, 0, 85)
			local ang  = v:EyeAngles()
			local pos

			if not eyeId then
				pos = v:GetPos() + offset + ang:Up()
			else
				local eyes = v:GetAttachment(eyeId)
				if not eyes then
					pos = v:GetPos() + offset + ang:Up()
				else
					offset = Vector(0, 0, 19)
					pos = eyes.Pos + offset
				end
			end

			cam.Start3D2D(pos, plyInVehicle and Angle(0, ply:GetVehicle():GetAngles().y + eyeAngs.y - 90, 90) or Angle(0, eyeAngs.y - 90, 90), 0.1)
				draw.RoundedBox(6, boxPos, 0, boxW, 100, colors.Background)
				draw.RoundedBoxEx(6, boxPos, 0, boxW, 50, colors.Header, true, true)

				if v:IsSpeaking() then
					PIXEL.DrawImgur(boxPos + boxW * .5 - 64, -140, 128, 128, "5xdPg17", color_white)
				elseif v:IsTyping() then
					PIXEL.DrawImgur(boxPos + boxW * .5 - 64, -140, 128, 128, "KKVTATT", color_white)
				end

				local npw = PIXEL.GetTextSize(name, "HUD.Overheads.Name") + 52

				local isWanted = v:getDarkRPVar("wanted")
				PIXEL.DrawImgur(boxPos + boxW * .5 - npw * .5, 8, 36, 36, isWanted and "cxOssG3" or "6lHN1nU", color_white)
				PIXEL.DrawText(name, "HUD.Overheads.Name", boxPos + boxW * .5 + npw * .5, 1, isWanted and colors.Negative or color_white, TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP)

				local jpw = PIXEL.GetTextSize(jobname, "HUD.Overheads.Job") + 52

				PIXEL.DrawImgur(boxPos + boxW * .5 - jpw * .5, 57, 36, 36, "WRF0KWw", color_white)

				PIXEL.DrawText(jobname, "HUD.Overheads.Job", boxPos + boxW * .5 + jpw * .5, 55, teamGetColor(v:Team()), TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM)

				if v:getDarkRPVar("HasGunlicense") then
					PIXEL.DrawText("Licensed", "HUD.Overheads.License", boxPos + boxW * .5, 100, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM)
				end
			cam.End3D2D()
		end

		DisableClipping(previousClip)
	end)
end

PIXEL.HUD.SetupOldOverheadDrawing()
cvars.AddChangeCallback("pixel_hud_old_overheads_enabled", function(_, _, val)
	if val == "0" then return end
	PIXEL.HUD.SetupOldOverheadDrawing()
end)