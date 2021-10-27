
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

local colors = PIXEL.HUD.Colors.ChatListeners

local receivers
local playerCount = 0
local currentChatText = {}
local receiverConfigs = {}
local currentConfig = {text = "", hearFunc = function() end}
local localPly

PIXEL.RegisterFont("HUD.ChatListener", "Open Sans SemiBold", 18)

local function drawChatReceivers()
    if not receivers then return end

    local _, fontH = PIXEL.GetTextSize("W", "HUD.ChatListener")
    fontH = fontH + PIXEL.Scale(7)

    local x, y = chat.GetChatBoxPos()
    x = x + PIXEL.Scale(3)
    y = y - fontH

    local receiversCount = playerCount
    if receiversCount == 0 then
        PIXEL.DrawRoundedTextBox(
            DarkRP.getPhrase("hear_noone", currentConfig.text), "HUD.ChatListener", x, y, nil, colors.Negative,
            PIXEL.Scale(4), PIXEL.Scale(3), colors.Background
        )
        return
    elseif receiversCount >= player.GetCount() - 2 then
        PIXEL.DrawRoundedTextBox(
             DarkRP.getPhrase("hear_everyone"), "HUD.ChatListener", x, y, nil, colors.Positive,
            PIXEL.Scale(4), PIXEL.Scale(3), colors.Background
        )
        return
    end

    PIXEL.DrawRoundedTextBox(
        DarkRP.getPhrase("hear_certain_persons", currentConfig.text), "HUD.ChatListener", x, y - (receiversCount * fontH), nil, colors.Positive,
        PIXEL.Scale(4), PIXEL.Scale(3), colors.Background
    )

    for i = 1, receiversCount, 1 do
        if not IsValid(receivers[i]) then
            receivers[i] = receivers[#receivers]
            receivers[#receivers] = nil
            continue
        end

        PIXEL.DrawRoundedTextBox(
            receivers[i]:Nick(), "HUD.ChatListener", x, y - (i - 1) * fontH, nil, colors.PlayerName,
            PIXEL.Scale(4), PIXEL.Scale(3), colors.Background
        )
    end
end

local playerGetAll = player.GetAll
local function chatGetRecipients()
    if not currentConfig then return end

    receivers = {}
    playerCount = 0

    for _, ply in ipairs(playerGetAll()) do
        if not IsValid(ply) or ply == localPly or ply:GetNoDraw() then continue end
        if hook.Run("chatHideRecipient", ply) then continue end

        local val = currentConfig.hearFunc(ply, currentChatText)

        if val == nil then
            receivers = nil
            return
        elseif val == true then
            table.insert(receivers, ply)
            playerCount = playerCount + 1
        end
    end
end

hook.Add("StartChat", "PIXEL.HUD.StartVoiceReceiverFind", function()
    local shouldDraw = hook.Call("HUDShouldDraw", GAMEMODE, "DarkRP_ChatReceivers")
    if shouldDraw == false then return end

    currentConfig = receiverConfigs[""]
    hook.Add("Think", "PIXEL.HUD.ChatReceiverThink", chatGetRecipients)
    hook.Add("HUDPaint", "PIXEL.HUD.DrawChatReceivers", drawChatReceivers)
end)

hook.Add("FinishChat", "PIXEL.HUD.StopVoiceReceiverFind", function()
    hook.Remove("Think", "PIXEL.HUD.ChatReceiverThink")
    hook.Remove("HUDPaint", "PIXEL.HUD.DrawChatReceivers")
end)

hook.Add("ChatTextChanged", "PIXEL.HUD.FindChatReceivers", function(text)
    local split = string.Explode(' ', text)
    local prefix = string.lower(split[1])

    currentChatText = split
    currentConfig = receiverConfigs[prefix] or receiverConfigs[""]
end)

local function createReceivers()
    function DarkRP.addChatReceiver(prefix, text, hearFunc)
        receiverConfigs[prefix] = {
            text = text,
            hearFunc = hearFunc
        }
    end

    function DarkRP.removeChatReceiver(prefix)
        receiverConfigs[prefix] = nil
    end

    DarkRP.addChatReceiver("", DarkRP.getPhrase("talk"), function(ply)
        if GAMEMODE.Config.alltalk then return nil end

        return localPly:GetPos():DistToSqr(ply:GetPos()) <
            GAMEMODE.Config.talkDistance * GAMEMODE.Config.talkDistance
    end)

    DarkRP.addChatReceiver("/ooc", DarkRP.getPhrase("speak_in_ooc"), function(ply) return true end)
    DarkRP.addChatReceiver("//", DarkRP.getPhrase("speak_in_ooc"), function(ply) return true end)
    DarkRP.addChatReceiver("/a", DarkRP.getPhrase("speak_in_ooc"), function(ply) return true end)
    DarkRP.addChatReceiver("/w", DarkRP.getPhrase("whisper"), function(ply) return localPly:GetPos():DistToSqr(ply:GetPos()) < GAMEMODE.Config.whisperDistance * GAMEMODE.Config.whisperDistance end)
    DarkRP.addChatReceiver("/y", DarkRP.getPhrase("yell"), function(ply) return localPly:GetPos():DistToSqr(ply:GetPos()) < GAMEMODE.Config.yellDistance * GAMEMODE.Config.yellDistance end)
    DarkRP.addChatReceiver("/me", DarkRP.getPhrase("perform_your_action"), function(ply) return localPly:GetPos():DistToSqr(ply:GetPos()) < GAMEMODE.Config.meDistance * GAMEMODE.Config.meDistance end)
    DarkRP.addChatReceiver("/g", DarkRP.getPhrase("talk_to_your_group"), function(ply)
        for _, func in pairs(GAMEMODE.DarkRPGroupChats) do
            if func(localPly) and func(ply) then
                return true
            end
        end
        return false
    end)

    DarkRP.addChatReceiver("/pm", "PM", function(ply, text)
        if not isstring(text[2]) then return false end
        text[2] = string.lower(tostring(text[2]))

        return string.find(string.lower(ply:Nick()), text[2], 1, true) ~= nil or
            string.find(string.lower(ply:SteamName()), text[2], 1, true) ~= nil or
            string.lower(ply:SteamID()) == text[2]
    end)

    local voiceDistance = GAMEMODE.Config.voiceDistance * GAMEMODE.Config.voiceDistance
    DarkRP.addChatReceiver("speak", DarkRP.getPhrase("speak"), function(ply)
        if not localPly.DRPIsTalking then return nil end
        if localPly:GetPos():DistToSqr(ply:GetPos()) > voiceDistance then return false end

        return not GAMEMODE.Config.dynamicvoice or ply:isInRoom()
    end)
end

hook.Add("PlayerStartVoice", "PIXEL.HUD.StartVoiceReceiverFind", function(ply)
    if ply ~= localPly then return end

    local shouldDraw = hook.Run("HUDShouldDraw", "DarkRP_ChatReceivers")
    if shouldDraw == false then return end

    currentConfig = receiverConfigs["speak"]
    hook.Add("Think", "PIXEL.HUD.ChatReceiverThink", chatGetRecipients)
    hook.Add("HUDPaint", "PIXEL.HUD.DrawChatReceivers", drawChatReceivers)
end)

hook.Add("PlayerEndVoice", "PIXEL.HUD.StopVoiceReceiverFind", function(ply)
    if ply ~= localPly then return end

    hook.Remove("Think", "PIXEL.HUD.ChatReceiverThink")
    hook.Remove("HUDPaint", "PIXEL.HUD.DrawChatReceivers")
end)

if IsValid(LocalPlayer()) then
    localPly = LocalPlayer()
    createReceivers()
end

hook.Add("InitPostEntity", "PIXEL.HUD.LoadChatListeners", function()
    localPly = LocalPlayer()

    timer.Simple(.1, createReceivers)
end)

PIXEL.HUD.BlockHook("StartChat", "DarkRP_StartFindChatReceivers")
PIXEL.HUD.BlockHook("FinishChat", "DarkRP_StopFindChatReceivers")
PIXEL.HUD.BlockHook("ChatTextChanged", "DarkRP_FindChatRecipients")
PIXEL.HUD.BlockHook("loadCustomDarkRPItems", "loadChatListeners")
PIXEL.HUD.BlockHook("PlayerStartVoice", "DarkRP_VoiceChatReceiverFinder")
PIXEL.HUD.BlockHook("Think", "DarkRP_chatRecipients")
PIXEL.HUD.BlockHook("HUDPaint", "DarkRP_DrawChatReceivers")
PIXEL.HUD.BlockHook("PlayerEndVoice", "DarkRP_VoiceChatReceiverFinder")