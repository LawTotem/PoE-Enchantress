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


global version := "0.4.0"
global show_update := false

global current_league := "Scourge"

global PID := DllCall("Kernel32\GetCurrentProcessId")

EnvGet, dir, USERPROFILE
global RoamingDir := dir . "\AppData\Roaming\POE-Enchantress"

if (!FileExist(RoamingDir)) {
    FileCreateDir, %RoamingDir%
}

global SettingsPath := RoamingDir . "\settings.ini"
global TempPath := RoamingDir . "\temp.txt"
global RawTextCapture := ""
global RawCaptureTime := ""

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

IniRead, HeistScanKey, %SettingsPath%, General, HeistScanKey
while (HeistScanKey == "ERROR" or HeistScanKey == "") {
    IniWrite, ^u, %SettingsPath%, General, HeistScanKey
    sleep, 250
    IniRead, HeistScanKey, %SettingsPath%, General, HeistScanKey
}

hotkey, %HeistScanKey%, ScanHeist

IniRead, HeistPriceTxt, %SettingsPath%, User, HeistPriceTxt
while (HeistPriceTxt == "ERROR") {
    IniWrite, "auto", %SettingsPath%, User, HeistPriceTxt
    sleep, 250
    IniRead, HeistPriceTxt, %SettingsPath% User, HeistPriceTxt
}

IniRead, SnapshotScreen, %SettingsPath%, User, SnapshotScreen
while (SnapshotScreen == "ERROR") {
    IniWrite, 0, %SettingsPath%, User, SnapshotScreen
    sleep, 250
    IniRead, SnapshotScreen, %SettingsPath%, User, SnapshotScreen
}

IniRead, HeistRemappingTxt, %SettingsPath%, User, HeistRemappingTxt
while (HeistRemappingTxt == "ERROR") {
    IniWrite, "heist_remapping.txt", %SettingsPath%, User, HeistRemappingTxt
    sleep, 250
    IniRead, HeistRemappingTxt, %SettingsPath%, User, HeistRemappingTxt
}


tooltip, Loading Enchantress [Enchant List]

#Include, subscripts/NinjaPricing.ahk

tooltip, Loading Enchantress [Personal Lists]
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

global last_version_grab := 0
global last_heist_grab := 0
global last_enchant_grab := 0

if (FirstRun == 1) {
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

ScanHeist:
    _wasVisible := IsGuiVisible("EnchantressUI")
    if (grabScreen("ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz`'-")) {
        IniRead, HeistRemappingTxt, %SettingsPath%, User, HeistRemappingTxt
        if (FileExist(HeistRemappingTxt))
        {
            RemapScan(HeistRemappingTxt)
        }
        GUI, EnchantressUI:Show, w650 h585
        heistSort()
    } else {
        if (_wasVisible) {
            Gui, EnchantressUI:Show, w650 h585
        }
    }
Return

RemapScan(filename) {
    GuiControlGet, CaptureString,, CaptureS, value
    new_capture := ""
    FileRead, RemappingFile, %filename%
    loop, parse, RemappingFile, `n, `r
    {
        remapLine := % A_LoopField
        remaparray := StrSplit(remapLine, ":")
        if (InStr(cleanString(CaptureString), cleanString(remaparray[1]), false))
        {
            if new_capture
            {
                new_capture := new_capture "`n"
            }
            new_capture := new_capture remaparray[2]
        }
    }
    if new_capture
    {
        GuiControl,, CaptureS, %new_capture%
    }
}

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
        Gui add, picture, x5 y5 w50 h50 gHelp , resources\ScalesOfJustice.png
    }
    Gui, add, text, x65 y20 w100 vversiontext, PoE-Enchantress v%version%
    Gui, add, picture, x520 y10 w120 h40 gSettings, resources\settings.png

    Gui, add, text, x10 y60 vValue, Captured String
    Gui, add, edit, x10 y80 vCaptureS r5 w600
    Gui, add, picture, x240 y180 gDumpRaw, resources\dumpraw.png
    Gui, add, picture, x490 y180 gReprossHeist, resources\heist.png

    loop, 15 {
        rowo := 210+20*A_Index
        gui, add, text, x5 y%rowo%, _
        gui, add, text, x10 y%rowo% w500 venchant_%A_Index%,
    } 
    Gui, font

}

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

ReprossHeist:
    IniRead, HeistRemappingTxt, %SettingsPath%, User, HeistRemappingTxt
    if (FileExist(HeistRemappingTxt))
    {
        RemapScan(HeistRemappingTxt)
    }
    heistSort()
Return

DumpRaw:
    GuiControl,, CaptureS, %RawTextCapture%
Return

Settings:
    Gui Settings:new,, PoE-Enchantress Settings

    Gui, font, s14
        Gui, add, text, x5 y5, General Settings
    Gui, font

    offset = 5
    Gui, font, s14
        Gui, add, text, x5 y%offset%, General Settings
        offset := offset + 25
    Gui, font
    
    Gui, font, s10
        offset := addOption("General", "FirstRun", offset, "Show First Run Help")
        offset := addOption("General", "GuiKey", offset, "Key Sequence to show GUI")
        offset := addOption("General", "HeistScanKey", offset, "Grab Heist Item Key Sequence")
    Gui, font

    Gui, font, s14
        Gui, add, text, x5 y%offset%, User Settings
        offset := offset + 25
    Gui, font
    Gui, font, s10
        offset := addOption("User", "HeistPriceTxt", offset, "Heist Price File")
        offset := addOption("User", "HeistRemappingTxt", offset, "Heist Text Remapping File")
        offset := addOption("User", "SnapshotScreen", offset, "Save a snapshot when OCRing screen")
    Gui, font

    Gui, font, s14
        Gui, add, text, x5 y%offset%, Other Settings
        offset := offset + 25
    Gui, font
    Gui, font, s10
        offset := addOption("Other", "scale", offset, "Monitor Scale")
        offset := addOption("Other", "monitor", offset, "Select Monitor")
    Gui, font

    Gui, font, s20
        Gui, add, text, x350 y550 gSaveSettings, Save

    Gui, Settings:Show, w800 h610
Return

SaveSettings:
    offset := 0
    saveOption("General", "FirstRun", offset, "Show First Run Help")
    saveOption("General", "GuiKey", offset, "Key Sequence to show GUI")
    saveOption("General", "HeistScanKey", offset, "Grab Heist Item Key Sequence")
    saveOption("User", "HeistPriceTxt", offset, "Heist Price File")
    saveOption("User", "HeistRemappingTxt", offset, "Heist Text Remapping File")
    saveOption("User", "SnapshotScreen", offset, "Save a snapshot when OCRing screen")
    saveOption("Other", "scale", offset, "Monitor Scale")
    saveOption("Other", "monitor", offset, "Select Monitor")
    Gui, Settings:Destroy
Return

SettingsGuiClose:
    Gui, Settings:Destroy
Return

getHeistPrices(heist_price_txt)
{
    if (SubStr(heist_price_txt,1,4) = "http")
    {
        global last_heist_grab
        Delta := %A_Now%
        EnvSub Delta, %last_heist_grab%, hours
        if (last_heist_grab = 0 or Delta > 1)
        {
            UrlDownloadToFile, %heist_price_txt%, local_heists.txt
            last_heist_grab = %A_Now%
        }
        FileRead, HeistFile, local_heists.txt
        return HeistFile
    }
    if (SubStr(heist_price_txt,1,4) = "auto")
    {
        if (ninjaGrab("Scourge"))
        {
            ftargets := FileOpen("heist_items.json","r")
            targets := ftargets.Read()
            global poe_sgems, poe_weaps
            global poe_armor, poe_umaps, poe_jewel
            global poe_rings, poe_flask, poe_bases
            i := DllCall("snipper\UpdatePrices"
                         ,"Str",targets,"Str",ninja_sgems,"Str",ninja_weaps
                         ,"Str",ninja_armor,"Str",ninja_umaps,"Str",ninja_jewel
                         ,"Str",ninja_rings,"Str",ninja_flask,"Str",ninja_bases
                         ,"Str","local_heists.txt")
            CheckError("Snipper\UpdatePrices", ErrorLevel)
        }
        FileRead, HeistFile, local_heists.txt
        return HeistFile
    }
    if (FileExist(heist_price_txt))
    {
        FileRead, HeistFile, %heist_price_txt%
        return HeistFile
    }
    return ""
}

addOption(sect, set_name, offset, title)
{
    global
    IniRead, TmpName, %SettingsPath%, %sect%, %set_name%
    Gui, add, text, x15 y%offset% w280 Right, %title%:
    Gui, add, edit, x300 y%offset% w400 v_%sect%_%set_name%, %TmpName%
    out := offset + 30
    return %out%
}

saveOption(sect, set_name, offset, title)
{
    GuiControlGet, TmpName,, _%sect%_%set_name%, value
    IniWrite, %TmpName%, %SettingsPath%, %sect%, %set_name%
}

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
    command = Capture2Text/Capture2Text.exe -s `"%x_start% %y_start% %x_end% %y_end%`" -o `"%TempPath%`" -l English --trim-capture -b --whitelist `"%whitelist%`"
    RunWait, %command%

    sleep, 1000
    WinActivate, ahk_pid %PID%

    Tooltip

    if (!FileExist(TempPath)) {
        MsgBox, - Unable to create temp.txt
        return false
    }

    global RawCaptureTime
    global RawTextCapture
    FileRead, RawTextCapture, %tempPath%
    FormatTime, RawCaptureTime,, yyyy_MM_dd_HH_mm_ss
    
    GuiControl,, CaptureS, %RawTextCapture%

    if (checkUpdate())
    {
        global show_update
        if (!show_update)
        {
            MsgBox A new version of the tool is available, check https://github.com/LawTotem/PoE-Enchantress/releases
            show_update := true
        }

        GuiControl, Text, versiontext, PoE-Enchantress v%version% Update
    }
    return true
}

cleanString(instring){
    output := StrReplace(instring, " ")
    output := StrReplace(output, "`r")
    output := StrReplace(output, "`n")
    return output
}

heistSort() {
    GuiControlGet, HeistString,, CaptureS, value
    loop, 20
    {
        GuiControl,, enchant_%A_Index%,
    }

    IniRead, HeistPriceTxt, %SettingsPath%, User, HeistPriceTxt
    current_row := 1
    HeistFile := getHeistPrices(HeistPriceTxt)
    if (StrLen(HeistFile) > 0)
    {
        loop, parse, HeistFile, `n, `r
        {
            heistLine := % A_LoopField
            heistarray := StrSplit(heistLine, ":")
            if (InStr(cleanString(HeistString), cleanString(heistarray[1]), false))
            {
                if (current_row <= 15)
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
    if (current_row > 15)
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

CaptureAreaWin(x, y, w, h) {
    FormatTime, dtg,, yyyy_MM_dd_HH_mm_ss
    file_name := "snap_" dtg ".png"
    DllCall("snipper\SnipAndSave","Int",x,"Int",y,"Int",w,"Int",h,"Str",file_name)
    CheckError("Snipper", ErrorLevel)
}

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
    IniRead, SnapshotScreen, %SettingsPath%, User, SnapshotScreen
    if  (SnapshotScreen) {
        CaptureAreaWin(MX,MY, MXend - MX, MYend - MY)
    }
    Gui, EnchantressUI:Default
    return areaRect
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