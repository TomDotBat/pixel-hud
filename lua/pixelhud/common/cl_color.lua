
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

PIXEL.HUD.Colors = {
    Bar = {
        Background = PIXEL.Colors.Background,
        Text = PIXEL.Colors.PrimaryText,
        Health = PIXEL.Colors.Negative,
        Armor = Color(43, 114, 166),
        Money = Color(66, 134, 50),
        Credits = Color(212, 175, 55),
        Wanted = PIXEL.Colors.Negative
    },
    Ammo = {
        Background = PIXEL.Colors.Background,
        Header = PIXEL.Colors.Header,
        Title = PIXEL.Colors.PrimaryText,
        Body = PIXEL.Colors.SecondaryText
    },
    Lockdown = {
        Title = Color(240, 74, 74),
        Message = PIXEL.Colors.PrimaryText
    },
    ArrestTimer = {
        Background = PIXEL.Colors.Background,
        Header = PIXEL.Colors.Header,
        Title = PIXEL.Colors.Negative,
        Message = PIXEL.Colors.SecondaryText
    },
    Alerts = {
        Background = PIXEL.Colors.Background,
        Header = PIXEL.Colors.Header,
        Title = PIXEL.Colors.PrimaryText,
        Body = PIXEL.Colors.SecondaryText
    },
    Notifications = {
        Background = PIXEL.Colors.Background,
        Icon = PIXEL.Colors.PrimaryText,
        Text = PIXEL.Colors.PrimaryText
    },
    Overheads = {
        Name = PIXEL.Colors.PrimaryText,
        Gang = Color(128, 49, 231),
        Health = PIXEL.Colors.Negative,
        Armor = Color(43, 114, 166),
        License = Color(44, 167, 78),
        Wanted = PIXEL.Colors.Negative,

        Background = PIXEL.Colors.Background, --Old
        Header = PIXEL.Colors.Header, --Old
        Negative = PIXEL.Colors.Negative --Old
    },
    Door = {
        Owned = PIXEL.Colors.PrimaryText,
        Unowned = Color(160, 30, 30)
    },
    ChatListeners = {
        Background = ColorAlpha(PIXEL.Colors.Background, 240),
        Positive = PIXEL.Colors.Positive,
        Negative = PIXEL.Colors.Negative,
        PlayerName = PIXEL.Colors.PrimaryText
    },
    VoiceChat = {
        Background = PIXEL.Colors.Background,
        TalkingBackground = PIXEL.Colors.Primary,
        Name = PIXEL.Colors.PrimaryText
    },
    FPP = {
        Background = ColorAlpha(PIXEL.Colors.Background, 240),
        Positive = PIXEL.Colors.Positive,
        Negative = PIXEL.Colors.Negative,
    },
    Vote = {
        Background = PIXEL.Colors.Background,
        Header = PIXEL.Colors.Header,
        Title = PIXEL.Colors.PrimaryText,
        Message = PIXEL.Colors.SecondaryText,
        Timer = PIXEL.Colors.Primary,
        TimerBackground = PIXEL.OffsetColor(PIXEL.Colors.Primary, -20)
    },
    AdminMode = {
        Text = ColorAlpha(PIXEL.Colors.PrimaryText, 20)
    },
    DevMode = {
        Text = ColorAlpha(PIXEL.Colors.PrimaryText, 20)
    },
    NLR = {
        Title = PIXEL.Colors.Negative,
        Description = PIXEL.Colors.PrimaryText
    }
}