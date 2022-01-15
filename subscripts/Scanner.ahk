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

global LastCaptureFile := ""

; Perform a screen grab and then run through Capture2Text to convert to text

grabScreen(whitelist) {
    Gui, PriceUI:Hide

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
    }

    FileRead, raw_text_capture, %tempPath%
    
    return raw_text_capture
}

CaptureAreaWin(x, y, w, h) {
    FormatTime, dtg,, yyyy_MM_dd_HH_mm_ss
    global LastCaptureFile
    LastCaptureFile := "snap_" dtg ".png"
    DllCall("snipper\SnipAndSave","Int",x,"Int",y
            ,"Int",w,"Int",h,"Str",LastCaptureFile)
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

global SelectAreaEscapePressed := false

goto ScannerEnd

SelectAreaEscape:
    SelectAreaEscapePressed := true
Return

ScannerEnd:
