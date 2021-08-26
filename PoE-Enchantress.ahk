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


global version := "0.1.0"

global x_start := 0
global y_start := 0
global x_end := 0
global y_end := 0

global FirstRun

global PID := DllCall("Kernel32\GetCurrentProcessId")

EnvGet, dir, USERPROFILE
global RoamingDir := dir . "\AppData\Roaming\POE-Enchantress"

if (!FileExist(RoamingDir)) {
    FileCreateDir, %RoamingDir%
}

global SettingsPath := RoamingDir . "\settings.ini"
global TempPath := RoamingDir . "\temp.txt"

tooltip, Loading Enchantress [Initializing Settings]

IniRead, FirstRun, %SettingsPath%, General, FirstRun
while (FirstRun == "ERROR" or FirstRun == "") {
    IniWrite, 1, %SettingsPath%, General, FirstRun
    sleep, 250
    IniRead, FirstRun, %SettingsPath%, General, FirstRun
}

IniRead, GuiKey, %SettingsPath%, General, GuiKey
while (GuiKey == "ERROR" or GuiKey == "") {
    IniWrite, ^+y, %SettingsPath%, General, GuiKey
    sleep, 250
    IniRead, GuiKey, %SettingsPath%, General, GuiKey
}

hotkey, %GuiKey%, OpenGui

IniRead, sc, %SettingsPath%, Other, scale
if (sc == "ERROR") {
    iniWrite, 1, %SettingsPath%, Other, scale
}

IniRead tempMon, %SettingsPath%, Other, monitor
if (tempMon == "ERROR") {
    iniWrite, 1, %SettingsPath%, Other, monitor
}

IniRead, EnchantScanKey, %SettingsPath%, General, EnchantScanKey
while (EnchantScanKey == "ERROR" or EnchantScanKey == "") {
    IniWrite, ^y, %SettingsPath%, General, EnchantScanKey
    sleep, 250
    IniRead, EnchantScanKey, %SettingsPath%, General, EnchantScanKey
}

hotkey, %EnchantScanKey%, ScanEnchant

IniRead, HeistScanKey, %SettingsPath%, General, HeistScanKey
while (HeistScanKey == "ERROR" or HeistScanKey == "") {
    IniWrite, ^u, %SettingsPath%, General, HeistScanKey
    sleep, 250
    IniRead, HeistScanKey, %SettingsPath%, General, HeistScanKey
}

hotkey, %HeistScanKey%, ScanHeist

IniRead, GeneralEnchantTxt, %SettingsPath%, User, GeneralEnchantTxt
while (GeneralEnchantTxt == "ERROR") {
    IniWrite, "general_enchants.txt", %SettingsPath%, User, GeneralEnchantTxt
    sleep, 250
    IniRead, GeneralEnchantTxt, %SettingsPath%, User, GeneralEnchantTxt
}

IniRead, ServiceEnchantTxt, %SettingsPath%, User, ServiceEnchantTxt
while (ServiceEnchantTxt == "ERROR") {
    IniWrite, "services.txt", %SettingsPath%, User, ServiceEnchantTxt
    sleep, 250
    IniRead, ServiceEnchantTxt, %SettingsPath%, User, ServiceEnchantTxt
}

IniRead, HeistPriceTxt, %SettingsPath%, User, HeistPriceTxt
while (HeistPriceTxt == "ERROR") {
    IniWrite, "heists.txt", %SettingsPath%, User, HeistPriceTxt
    sleep, 250
    IniRead, HeistPriceTxt, User, HeistPriceTxt
}

tooltip, Loading Enchantress [Enchant List]

tooltip, Loading Enchantress [Personal Lists]

;menu, Tray, Icon, resources\ScalesOfJustice.png
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

if (FirstRun == 1) {
    goto help
}

Return
Return

OpenGui:
    Gui, EnchantressUI:Show, w650 h585
Return

ScanEnchant:
    _wasVisible := IsGuiVisible("EnchantressUI")
    if (grabScreen("ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789`'+`%")) {
        Gui, EnchantressUI:Show, w650 h585
        enchantSort()
    } else {
        if (_wasVisible) {
            Gui, EnchantressUI:Show, w650 h585
        }
    }
Return

ScanHeist:
    _wasVisible := IsGuiVisible("EnchantressUI")
    if (grabScreen("ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz`'-")) {
        GUI, EnchantressUI:Show, w650 h585
        heistSort()
    } else {
        if (_wasVisible) {
            Gui, EnchantressUI:Show, w650 h585
        }
    }
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
    ;Gui add, picture, x10 y10, resources\ScalesOfJustice_icon.png
        Gui add, text, x60 y20 w50, Enchantress v%version%

        Gui add, text, x10 y60 vValue, Captured String
        Gui add, edit, x10 y80 vCaptureS r5 w500
        Gui add, text, x10 y180 gReprossEnchant vReprossEnchant, Repross Enchants
        Gui add, text, x300 y180 gReprossHeist vReprocessHeist, Repross Heist Price

        loop, 20 {
            rowo := 90+5*20+20*A_Index
            gui, add, text, x10 y%rowo% w500 venchant_%A_Index%,
        } 
    Gui, font

}

help:
    Gui Help:new,, PoE-Enchantress Help

    Gui, font, s14
        Gui, add, text, x5 y5, Setup
        Gui, add, text, x5 y75, Heist Prices
        Gui, add, text, x5 y165, Enchant Prices
        Gui, add, text, x5 y255, Usage
        Gui, add, text, x5 y375, Credits`/License
    Gui, font


    IniRead, ServiceEnchantTxt, %SettingsPath%, User, ServiceEnchantTxt
    IniRead, GeneralEnchantTxt, %SettingsPath%, User, GeneralEnchantTxt
    IniRead, HeistPriceTxt, %SettingsPath%, User, HeistPriceTxt
    Gui, font, s10
        Gui, add, text, x15 y30, PoE-Enchantress uses the tool 'Capture2Text' to translate enchant/item names to text. This tool must be downloaded`r`nseperately and is available at http://capture2text.sourceforge.net/. Once downloaded the 'Capture2Text' folder should be moved`r`ninto the folder containing the PoE-Enchantress autohotkey script.
        Gui, add, text, x15 y100, PoE-Enchantress does not use any external sites/tools to perform Heist item pricing. It uses a comma separated file 'heists.txt'`r`nwhich should be formatted as 'item name', 'price/comment'. The item name will be matched without capitalization and without spaces`r`n(because Capture2Text messes them up quite frequently). Original author uses a python script to download and parse`r`nskill gem and item overviews from 'poe.ninja'.
        Gui, add, text, x15 y190, Just like for the Heist item pricing, we use comma separated files to help with enchant pricing. The format is`r`n'enchant subtext', 'comment to show'. Make the enchant subtext as minimal as possible, the longer it the greater the chance`r`nthe enchantment will be missed because it was miss parsed. Two files are used 'services.txt' is checked first, it is intended for`r`nany lab services you are running, and 'general_enchants.txt' is checked second, it is intended for base item enchanting.
        Gui, add, text, x15 y280, Use either of the scan hotkeys to capture a region of the screen containing only the name of the item or list of enchants you want`r`nto price. After you press the hotkey you will be able to select a region by pressing and holding the left mouse key.`r`nYou may edit the captured text and click either of the reprocess texts, there is no feedback but it does reprocess.`r`nDefault hotkeys to open the UI = Ctrl + Shift + Y`r`nHotkey to Capture Enchants = Ctrl + Y`r`nHotkey to Capture Heist = Ctrl + U
        Gui, add, text, x15 y400, This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License`r`nas published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.`r`n`r`nThis program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty`r`nof MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.`r`n`r`nYou should have received a copy of the GNU General Public License along with this program.`r`nIf not, see <https://www.gnu.org/licenses/>.`r`nCopyright (C) 2021 LawTotem#8511

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

ReprossEnchant:
    enchantSort()
Return

ReprossHeist:
    heistSort()
Return

grabScreen(whitelist) {
    Gui, EnchantressUI:Hide

    coordTemp := SelectArea()
    x_start := coordTemp[1]
    y_start := coordTemp[3]
    x_end := coordTemp[2]
    y_end := coordTemp[4]

    ;WinActivate, Path of Exile
    sleep, 500

    Tooltip, Please Wait
    command = Capture2Text/Capture2Text.exe -s `"%x_start% %y_start% %x_end% %y_end%`" -o `"%TempPath%`" -l English --trim-capture --whitelist `"%whitelist%`"
    RunWait, %command%

    sleep, 1000
    WinActivate, ahk_pid %PID%

    Tooltip

    if (!FileExist(TempPath)) {
        MsgBox, - Unable to create temp.txt
        return false
    }

    FileRead, CaptureString, %tempPath%
    
    GuiControl,, CaptureS, %CaptureString%
    return true
}

enchantSort() {
    GuiControlGet, EnchantString,, CaptureS, value
    loop, 20
    {
        GuiControl,, enchant_%A_Index%,
    }
    current_row := 1
    IniRead, ServiceEnchantTxt, %SettingsPath%, User, ServiceEnchantTxt
    if (FileExist(ServiceEnchantTxt))
    {
        FileRead, ServiceFile, %ServiceEnchantTxt%
        loop, parse, ServiceFile, `n, `r
        {
            enchantLine := % A_LoopField
            enchantarray := StrSplit(enchantLine, ",")
            if (InStr(StrReplace(EnchantString, " "), StrReplace(enchantarray[1], " "), false))
            {
                if (current_row <= 20)
                {
                    GuiControl,, enchant_%current_row%, % enchantarray[2]
                }
                current_row := current_row + 1
            }
        }
    } else {
        GuiControl,, enchant_%current_row%, No Service File
        current_row := current_row + 1
    }
    IniRead, GeneralEnchantTxt, %SettingsPath%, User, GeneralEnchantTxt
    if (FileExist(GeneralEnchantTxt))
    {
        FileRead, GeneralFile, %GeneralEnchantTxt%
        loop, parse, GeneralFile, `n, `r
        {
            enchantLine := % A_LoopField
            enchantarray := StrSplit(enchantLine, ",")
            if (InStr(StrReplace(EnchantString," "), StrReplace(enchantarray[1], " "), false))
            {
                if (current_row <= 20)
                {
                    GuiControl,, enchant_%current_row%, % enchantarray[2]
                }
                current_row := current_row + 1
            }
        }
    } else {
        GuiControl,, enchant_%current_row%, No General Enchant File
        current_row := current_row + 1
    }
    if (current_row > 20)
    {
        msgbox, To many enchant entries (some may have been lost).
    }
    return true
}

heistSort() {
    GuiControlGet, HeistString,, CaptureS, value
    loop, 20
    {
        GuiControl,, enchant_%A_Index%,
    }

    IniRead, HeistPriceTxt, %SettingsPath%, User, HeistPriceTxt
    current_row := 1    
    if (FileExist(HeistPriceTxt))
    {
        FileRead, HeistFile, %HeistPriceTxt%
        loop, parse, HeistFile, `n, `r
        {
            heistLine := % A_LoopField
            heistarray := StrSplit(heistLine, ",")
            if (InStr(StrReplace(HeistString, " "), StrReplace(heistarray[1], " "), false))
            {
                if (current_row <= 20)
                {
                    GuiControl,, enchant_%current_row%, % heistarray[1] " ==Price== " heistarray[2]
                }
                current_row := current_row + 1
            }
        }

    }
    else
    {
        GuiControl,, enchant_1, No Heist Prices Found
    }
    if (current_row > 20)
    {
        msgbox, To many heist price entries (some may have been lost) (this shouldnt happen).
    }
    return true
}

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

global SelectAreaEscapePressed := false
SelectAreaEscape:
    SelectAreaEscapePressed := true
Return

SelectArea() {
    iniRead tempMon, %SettingsPath%, Other, monitor
    iniRead, scale, %SettingsPath%, Other, scale
    cover := monitorInfo(tempMon)
    coverX := cover[1]
    coverY := cover[2]
    coverH := cover[3] / scale
    coverW := cover[4] / scale
    Gui, Select:New
    Gui, Color, 141414
    Gui, +LastFound +ToolWindow -Caption +AlwaysOnTop
    WinSet, Transparent, 120
    Gui, Select:Show, x%coverX% y%coverY% h%coverH% w%coverW%, "AutoHotkeySnapshotApp"

    ; Waiting for the initial keypress
    isLButtonDown := false
    SelectAreaEscapePressed := false
    Hotkey, Escape, SelectAreaEscape, On
    while (!isLButtonDown and !SelectAreaEscapedPressed) {
        KeyWait, LButton, D T0.1
        isLButtonDown := (ErrorLevel == 0)
    }

    ; Starting the rectangle draw
    areaRect := []
    if (!SelectAreaEscapePressed) {
        CoordMode, Mouse, Screen
        MouseGetPos, MX, MY
        CoordMode, Mouse, Relative
        MouseGetPos, rMX, rMY
        CoordMode, Mouse, Screen

        c := "Blue"
        t := "40"
        g := "99"
        m := "s"

        Gui %g%: Destroy
        Gui %g%: +AlwaysOnTop -Caption +Border +ToolWindow +LastFound
        WinSet, Transparent, %t%
        Gui %g%: Color, %c%

        ; Draw the window accounting for top left to bottom right or bottom right to top left
        while (GetKeyState("LButton") and !SelectAreaEscapePressed) {
            sleep, 10
            MouseGetPos, MXend, MYend
            w := abs((MX / scale) - (MXend / scale))
            h := abs((MY / scale) - (MYend / scale))
            X := (MX < MXend) ? MX : MXend
            Y := (MY < MYend) ? MY : MYend
            Gui %g%: Show, x%X% y%Y% w%w% h%h% NA
        }

        Gui %g%: Destroy

        if (!SelectAreaEscapePressed) {
            MouseGetPos, MXend, MYend
            if (MX > MXend) {
                temp := MX
                MX := MXend
                MXend := temp
            }
            if (MY > MYend) {
                temp := MY
                MY := MYend
                MYend := temp
            }
            areaRect := [MX, MXend, MY, MYend]
        }
    }

    Hotkey, Escape, SelectAreaEscape, Off

    Gui, Select:Destroy
    Gui, EnchantressUI:Default
    return areaRect
}