
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

local overheadsEnabled = CreateClientConVar("pixel_hud_overheads_enabled", "1", true, false, "Should overheads be shown?", 0, 1)

function PIXEL.HUD.SetupOverheadDrawing()
    local colors = PIXEL.HUD.Colors.Overheads

    local stats = {
        { --Name
            imgurId = "6lHN1nU",
            color = function(ply) return (ply:IsUserGroup("vip") or ply:IsUserGroup("vip+")) and PIXEL.GetRainbowColor() or colors.Name end,
            getter = function(ply) return ply:Name() end
        },
        { --Job
            imgurId = "CqIwC9T",
            color = function(ply) return team.GetColor(ply:Team()) end,
            getter = function(ply) return team.GetName(ply:Team()) end
        },
        { --Gang
            imgurId = "sMh3imc",
            color = colors.Gang,
            getter = function(ply)
                if ply:GetGangID() <= 0 then return "N/A" end

                local gangInfo = BRS_PLYGANGINFO and BRS_PLYGANGINFO[ply:SteamID()] or false
                if not (gangInfo and gangInfo.Name) then
                    BRICKS_SERVER.Func.RequestPlyGangInfo(ply:SteamID())
                    return "N/A"
                end

                return gangInfo.Name or "N/A"
            end,
            shouldShow = function(ply) return ply:HasGang() end
        },
        { --Health
            imgurId = "TsGKspF",
            color = colors.Health,
            getter = function(ply) return ply:Health() end
        },
        { --Armour
            imgurId = "J6xcGtm",
            color = colors.Armor,
            getter = function(ply) return ply:Armor() end,
            shouldShow = function(ply) return ply:Armor() > 0 end
        },
        { --Gun License
            imgurId = "mv33zwQ",
            color = colors.License,
            getter = function(ply) return "Licensed" end,
            shouldShow = function(ply) return ply:getDarkRPVar("HasGunlicense") end
        },
        { --Wanted
            imgurId = "cxOssG3",
            color = function(ply) return colors.Wanted end,
            getter = function(ply) return "Wanted" end,
            shouldShow = function(ply) return ply:getDarkRPVar("wanted") end
        }
    }

    PIXEL.RegisterFontUnscaled("HUD.OverheadText", "Open Sans SemiBold", 120)

    local localPly
    local min = math.min
    local remap = math.Remap
    local meta = FindMetaTable("Player")

    function meta:DrawPlayerStats()
        local alpha = min(remap(localPly:GetPos():DistToSqr(self:GetPos()), 90000, 160000, 1, 0), 1)

        local eyeAngs = localPly:EyeAngles()
        local pos = self:LocalToWorld(self:OBBCenter())
        local ang = localPly:InVehicle() and Angle(0, localPly:GetVehicle():GetAngles().y + eyeAngs.y - 90, 90) or Angle(0, eyeAngs.y - 90, 90)

        pos = pos + ang:Right() * -28
        pos = pos + ang:Forward() * 15

        if alpha < 0.02 then return pos, ang, alpha end

        surface.SetAlphaMultiplier(alpha)

        cam.Start3D2D(pos, ang, .03)
            local yOff = 0
            for _, stat in ipairs(stats) do
                if stat.shouldShow and not stat.shouldShow(self) then continue end

                PIXEL.DrawImgur(0, yOff, 120, 120, stat.imgurId, color_white)
                PIXEL.DrawSimpleText(stat.getter(self), "HUD.OverheadText", 160, yOff + 60, isfunction(stat.color) and stat.color(self) or stat.color, nil, TEXT_ALIGN_CENTER)
                yOff = yOff + 150
            end
        cam.End3D2D()

        surface.SetAlphaMultiplier(1)

        return pos, ang, alpha
    end

    local headOffset = Vector(0, 0, 13)
    local fallbackOffset = Vector(-3, 0, 85)

    function meta:DrawPlayerComms(pos, ang, alpha)
        local speaking = self:IsSpeaking()
        if not (speaking or self:IsTyping()) then return end

        surface.SetAlphaMultiplier(alpha)

        local eyeId = self:LookupAttachment("eyes")
        if eyeId then
            local eyes = self:GetAttachment(eyeId)
            if eyes then
                pos = eyes.Pos + headOffset
            else
                pos = self:GetPos() + fallbackOffset + ang:Up()
            end
        else
            pos = self:GetPos() + fallbackOffset + ang:Up()
        end

        local oldClip = DisableClipping(true)

        cam.Start3D2D(pos, ang, 0.04)
            PIXEL.DrawImgur(-120, -120, 240, 240, speaking and "5xdPg17" or "KKVTATT", color_white)
        cam.End3D2D()

        DisableClipping(oldClip)
        surface.SetAlphaMultiplier(1)
    end

    local playerGetAll = player.GetAll

    hook.Add("PostDrawTranslucentRenderables", "PIXEL.HUD.DrawOverheads", function(depth, skybox)
        if not overheadsEnabled:GetBool() then
            hook.Remove("PostDrawTranslucentRenderables", "PIXEL.HUD.DrawOverheads")
            return
        end

        if not localPly then localPly = LocalPlayer() end
        if skybox then return end

        for _, ply in ipairs(playerGetAll()) do
            if ply == localPly then continue end
            if ply:IsDormant() then continue end
            if ply:Health() < 1 or ply:GetColor().a < 100 or ply:GetNoDraw() then continue end
            if ply:GetNW2Bool("PIXEL.AdminMode", false) then continue end

            ply:DrawPlayerComms(ply:DrawPlayerStats())
        end
    end)
end

PIXEL.HUD.SetupOverheadDrawing()
cvars.AddChangeCallback("pixel_hud_overheads_enabled", function(_, _, val)
    if val == "0" then return end
    PIXEL.HUD.SetupOverheadDrawing()
end)