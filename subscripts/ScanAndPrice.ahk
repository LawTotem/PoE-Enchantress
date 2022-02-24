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

tooltip, Loading Enchantress [ScanTool]

global HeistCaptureS := ""
global HeistCaptureSH

newPriceGUI()
Gui, PriceUI:Show,

; Setup the Scan+Price UI
newPriceGUI()
{
    global
    Gui, PriceUI:New,, PoE-Enchantress Scan 'n Price

    Gui, Color, 0x192020, 0x251e16
    Gui, Font, s11 ce7b477
    local offset := 5
    local snap_screen := getSetting("User","SnapshotScreen")
    if (snap_screen)
    {
        ;Gui, add, text, x10 y%offset%, Captured Image
        ;offset += 20

        ;Gui, add, picture, x5 y%offset% w500 h100 vSnapImage, snap_2021_11_20_23_01_34.png
        ;offset += 105
    }

    Gui, add, text, x10 y%offset%, Captured Text
    Gui, add, picture, x480 y%offset% h25 w-1 gRepriceHeist, resources\heist.png
    offset += 30
    Gui, add, edit, x10 y%offset% vHeistCaptureS HwndHeistCaptureSH r3 w500,

    offset += 80
    loop, 5
    {
        Gui, add, text, x5 y%offset%, _
        Gui, add, text, x10 y%offset% w500 vheistprice_%A_Index%,
        offset += 20
    }
}

; Function to remove whitespace from strings. I found that the capture tool
; tended to place them inconsistently
cleanString(instring){
    output := StrReplace(instring, " ")
    output := StrReplace(output, "`r")
    output := StrReplace(output, "`n")
    return output
}


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
        league := getSetting("General", "League")
        if (ninjaGrab(league))
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


heistSort() {
    GuiControlGet, HeistString, PriceUI:, HeistCaptureS, value
    loop, 6
    {
        GuiControl, PriceUI:, heistprice_%A_Index%,
    }

    heist_price_file := getSetting("User", "HeistPriceTxt")
    current_row := 1
    HeistFile := getHeistPrices(heist_price_file)
    if (StrLen(HeistFile) > 0)
    {
        loop, parse, HeistFile, `n, `r
        {
            heistLine := % A_LoopField
            heistarray := StrSplit(heistLine, ":")
            if (InStr(cleanString(HeistString), cleanString(heistarray[1]), false))
            {
                if (current_row <= 6)
                {
                    GuiControl, PriceUI:, heistprice_%current_row%, % heistarray[1] " ==Price== " heistarray[2]
                }
                current_row += 1
            }
        }
    }
    else
    {
        GuiControl, PriceUI:, heistprice_1, No Heist Prices Found
    }
    if (current_row == 1)
    {
        GuiControl, PriceUI:, heistprice_%current_row%, No Item Found
    }
    if (current_row > 6)
    {
        msgbox, To many heist price entries (some may have been lost) (this shouldnt happen).
    }
    return true
}

; This takes the string that is currently in the capture box and attempts to
; map it to a known string
mapScan() {
    GuiControlGet, CaptureString, PriceUI:, HeistCaptureS, value
    new_capture := ""
    filename := getSetting("User", "HeistRemappingTxt")
    if (!FileExist(filename))
    {
        MsgBox, The remapping file "%filename%" was not found!
        return
    }
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
        GuiControl, PriceUI:, HeistCaptureS, %new_capture%
    }
}

; Grabs a portion of the screen, OCRs it and shows the price
heistScan()
{
    capture :=  grabScreen("ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz`'-")
    global HeistCaptureS
    GuiControl, PriceUI:, HeistCaptureS, %capture%
    mapScan()
    heistSort()
    snap_screen := getSetting("User","SnapshotScreen")
    if (snap_screen)
    {
        global LastCaptureFile
        global SnapImage
        GuiControl, PriceUI:, SnapImage, *h-1 %LastCaptureFile%
    }
    Gui, PriceUI:Show,
}

goto ScanAndPriceEnd

PriceUIGuiEscape:
PriceUIGuiClose:
    Gui, PriceUI:Hide
Return

RepriceHeist:
    mapScan()
    heistSort()
Return

ScanHeist:
    heistScan()
Return

ScanAndPriceEnd: