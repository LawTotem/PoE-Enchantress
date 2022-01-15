;    PoE-Enchantress a pricing tool for things which cannot be copied
;    Copyright (C) 2021 LawTotem#8511

;    This program is free software: you can redistribute it and/or modify
;    it under the terms of the GNU General Public License as published by
;    the Free Software Foundation, either version 3 of the License, or
;    (at your option) any later version.

;    This program is distributed in the hope that it will be useful,
;    but WITHOUT ANY WARRANTY; without even the implied warranty of
;    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;    GNU General Public License for more details.

;    You should have received a copy of the GNU General Public License
;    along with this program.  If not, see <https://www.gnu.org/licenses/>.
#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
#SingleInstance Force
SetBatchLines -1
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

global PID := DllCall("Kernel32\GetCurrentProcessId")

global version = "0.0"
FileRead, version, version.txt
global show_update := false

EnvGet, dir, USERPROFILE
global RoamingDir := dir . "\AppData\Roaming\POE-Enchantress"

if (!FileExist(RoamingDir)) {
    FileCreateDir, %RoamingDir%
}

global SettingsPath := RoamingDir . "\settings.ini"

#Include, subscripts/Settings.ahk

global CurrentLeague := "Scourge"
global TempPath := RoamingDir . "\temp.txt"

tooltip, Loading Enchantress [Initializing Settings]

addNewSetting("General", "League", "Scourge", "Current League")
addNewSetting("General", "FirstRun", 1, "Show First Run Help")
addNewSetting("General", "HeistScanKey", ^u, "Key Sequence to Grab Screen for Heist")
addNewSetting("General", "GuiKey", ^+y, "Key Sequency to show Main GUI")
addNewSetting("User", "HeistPriceTxt", "auto", "Heist Prices File (auto to use poe.ninja)")
addNewSetting("User", "HeistRemappingTxt", "heist_remapping.txt", "Heist Text Remapping File")
addNewSetting("User", "SnapshotScreen", 0, "Save a Snapshot when Grabbing Screen")
addNewSetting("Other", "scale", 1, "Monitor Scale Factor")
addNewSetting("Other", "monitor", 1, "Which Monitor to use when Grabbing")

#Include, subscripts/Scanner.ahk

#Include, subscripts/ScanAndPrice.ahk

GuiKey := getSetting("General","GuiKey")
hotkey, %GuiKey%, OpenGui

HeistScanKey := getSetting("General", "HeistScanKey")
hotkey, %HeistScanKey%, ScanHeist


#Include, subscripts/NinjaPricing.ahk

if (FileExist("resources\ScalesOfJustice.png"))
{
    menu, Tray, Icon, resources\ScalesOfJustice.png
}
Menu, Tray, NoStandard
Menu, Tray, Add, Enchantress, OpenGui
Menu, Tray, Default, Enchantress
Menu, Tray, Standard

tooltip, Loading [Building GUI]

sleep, 250
newGUI()
tooltip, Ready
sleep, 250
Tooltip
Gui, EnchantressUI:Show, w650 h585

global last_version_grab := 0
global last_heist_grab := 0
global last_enchant_grab := 0

if (getSetting("General","FirstRun") == 1) {
    goto help
}

if (checkUpdate())
{
    global show_update := true
    MsgBox A new version of the tool is available, check https://github.com/LawTotem/PoE-Enchantress/releases
}

Return
Return

OpenGui:
    Gui, EnchantressUI:Show, w650 h585
Return

EntrantressUIGuiEscape:
EnchantressUIGuiClose:
    Gui, EnchantressUI:Hide
Return

newGUI() {
    global
    Gui, EnchantressUI:New,, PoE-Enchantress v%version%
    Gui, Color, 0x192020, 0x251e16
    Gui, Font, s11 ce7b477

; === TITLE, ICON ===
    if (FileExist("resources\ScalesOfJustice.png"))
    {
        Gui add, picture, x5 y5 w50 h50 gHelp, resources\ScalesOfJustice.png
    }
    Gui, add, text, x65 y20 w100 vversiontext, PoE-Enchantress v%version%
    Gui, add, picture, x520 y10 w120 h40 gSettings, resources\settings.png

}

Settings:
    settingsGUI()
Return

help:
    Gui Help:new,, PoE-Enchantress Help

    Gui, font, s14
        Gui, add, text, x5 y5, See https://github.com/LawTotem/PoE-Enchantress#readme
        Gui, add, text, x5 y75, Credits`/License
    Gui, font

    Gui, font, s10
        Gui, add, text, x15 y1000, This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License`r`nas published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.`r`n`r`nThis program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty`r`nof MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.`r`n`r`nYou should have received a copy of the GNU General Public License along with this program.`r`nIf not, see <https://www.gnu.org/licenses/>.`r`nCopyright (C) 2021 LawTotem#8511

    Gui, Help:Show, w800 h610

    if (checkFiles())
    {
        IniWrite, 0, %SettingsPath%, General, FirstRun
    }
Return


HelpGuiClose:
    Gui, Help:Destroy
;    Gui, EnchantressUI:Destroy
Return



IsGuiVisible(guiName) {
    Gui, %guiName%: +HwndguiHwnd
    return DllCall("User32\IsWindowVisible", "Ptr", guiHwnd)
}

checkFiles() {
    if (!FileExist("Capture2Text")) {
        if (FileExist("Capture2Text.exe")) {
            msgbox, Looks like you put PoE-Enchantress into the Capture2Text folder`r`nThis is wrong`r`nTake the file out of this folder
            ExitApp
        } else {
            msgbox, Capture2Text folder is missing, did you download the tool?
            ExitApp
        }
    }

    if (!FileExist(SettingsPath)) {
        msgbox, PoE-Enchantress is in a write protected place on your PC.`r`nIt needs to be able to write some files to the directory.
        ExitApp
    }
    return true
}

monitorInfo(num) {
   SysGet, Mon2, monitor, %num%
  
   x := Mon2Left
   y := Mon2Top
   height := abs(Mon2Top-Mon2Bottom)
   width := abs(Mon2Left-Mon2Right)

   return [x,y,height,width]
}

CheckError(name, code) {
    if (code == 0) {
    } else if (code == -1) {
        msgbox, %name% Bad Parameter (-1)
    } else if (code == -2) {
        msgbox, %name% Return Type is invalid (-2)
    } else if (code == -3) {
        msgbox, %name% DLL could not be found (-3)
    } else if (code == -4) {
        msgbox, %name% Function could not be found (-4)
    }
}

checkUpdate() {
    global last_version_grab
    Delta := %A_Now%
    EnvSub Delta, %last_version_grab%, hours
    if (last_version_grab = 0 or Delta > 1)
    {
        whr := ComObjCreate("WinHttp.WinHttpRequest.5.1")
        whr.Open("Get","https://raw.githubusercontent.com/LawTotem/PoE-Enchantress/dev/version.txt", true)
        whr.Send()
        whr.WaitForResponse()
        online_version := whr.ResponseText()
        last_version_grab = %A_Now%
        if (online_version > version)
        {
            return true
        }
    }
    return false
}
;    if (checkUpdate())
;    {
;        global show_update
;        if (!show_update)
;        {
;            MsgBox A new version of the tool is available, check https://github.com/LawTotem/PoE-Enchantress/releases
;            show_update := true
;        }
;
;        GuiControl, Text, versiontext, PoE-Enchantress v%version% Update
;    }