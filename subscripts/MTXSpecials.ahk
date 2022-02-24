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

tooltip, Loading Enchantress [MTX Specials]


global last_mtx_grab := 0
global current_show := 1


global mtx_names := []
global mtx_images := []
global mtx_discounts := []
global num_mtx_items := 0

pullMTXSpecials()
{
    grab := ComObjCreate("WinHttp.WinHttpRequest.5.1")
    grab.Open("Get","https://www.pathofexile.com/api/shop/microtransactions/specials")
    grab.SetRequestHeader("User-Agent","Mozilla/5.0")
    grab.Send()
    grab.WaitForResponse()
    if (grab.responseText == "")
    {
        MsgBox, Bad request %this_type%
    }
    return grab.responseText
}

MTXGrab()
{
    global last_mtx_grab
    Delta := %A_Now%
    EnvSub Delta, %last_mtx_grab%, hours
    if (last_mtx_grab == 0 or Delta > 1)
    {
        last_mtx_grab := %A_Now%

        tooltip, Enchantress [Fetching MTX]

        global mtx_grab
        mtx_grab := pullMTXSpecials()
        i := DllCall("snipper\SimplifySpecial"
                        ,"Str",mtx_grab
                        ,"Str","specials.txt")
        CheckError("Snipper\SimplifySpecial", ErrorLevel)
        FileRead, SalesFile, specials.txt
        global mtx_names := []
        global mtx_images := []
        global mtx_discounts := []
        global num_mtx_items := 0
        if (StrLen(SalesFile) > 0)
        {
            loop, parse, SalesFile, `n, `r
            {
                saleLine := % A_LoopField
                salearray := StrSplit(saleLine, "!")
                num_mtx_items := num_mtx_items + 1
                mtx_names.Push(salearray[1])
                mtx_discounts.Push(salearray[2])
                ii := "" . salearray[3]
                UrlDownloadToFile, %ii%, sale.png
                mtx_images.Push(LoadPicture("sale.png"))
            }
        }
    }
}

newMTXGUI()
{
    global
    Gui, MTXUI:New,, PoE-Enchantress MTX Sales

    Gui, Color, 0x192020, 0x251e16
    Gui, Font, s11 ce7b477
    local offset := 5

    Gui, add, text, x10 y5 vSale1Name w150, Sale Item
    Gui, add, picture, x5 y25 w150 h150 vSale1Image, % sale.png
    Gui, add, text, x10 y180 vSale1Discount w150, X Percent Off

    Gui, add, text, x165 y5 vSale2Name w150, Sale Item
    Gui, add, picture, x160 y25 w150 h150 vSale2Image, sale.png
    Gui, add, text, x165 y180 vSale2Discount w150, X Percent Off

    Gui, add, text, x320 y5 vSale3Name w150, Sale Item
    Gui, add, picture, x315 y25 w150 h150 vSale3Image, sale.png
    Gui, add, text, x320 y180 vSale3Discount w150, X Percent Off

    MTXGrab()
    UpdateShow()
    

    SetTimer, UpdateMTXShow, 5000
    SetTimer, UpdateMTXList, 180000

    Gui, MTXUI:-SysMenu
    Gui, MTXUI:Show
}

newMTXGUI()

UpdateShow()
{
    global current_show
    global mtx_images
    global mtx_names
    global mtx_discounts
    global num_mtx_items
    if (num_mtx_items > 0)
    {
        if (current_show > num_mtx_items)
        {
            current_show = 1
        }
        this_show := current_show
        nn := "" . mtx_names[this_show]
        GuiControl, MTXUI:, Sale1Name, %nn%
        ii := % "HBITMAP:*" mtx_images[this_show]
        GuiControl, MTXUI:, Sale1Image, *w150 *h-1 %ii%
        dd := mtx_discounts[this_show] . " Percent Off"
        GuiControl, MTXUI:, Sale1Discount, %dd%
        this_show := this_show + 1
        if (this_show > num_mtx_items)
        {
            this_show = 1
        }
        nn := "" . mtx_names[this_show]
        GuiControl, MTXUI:, Sale2Name, %nn%
        ii := % "HBITMAP:*" mtx_images[this_show]
        GuiControl, MTXUI:, Sale2Image, *w150 *h-1 %ii%
        dd := mtx_discounts[this_show] . " Percent Off"
        GuiControl, MTXUI:, Sale2Discount, %dd%
        this_show := this_show + 1
        if (this_show > num_mtx_items)
        {
            this_show = 1
        }
        nn := "" . mtx_names[this_show]
        GuiControl, MTXUI:, Sale3Name, %nn%
        ii := % "HBITMAP:*" mtx_images[this_show]
        GuiControl, MTXUI:, Sale3Image, *w150 *h-1 %ii%
        dd := mtx_discounts[this_show] . " Percent Off"
        GuiControl, MTXUI:, Sale3Discount, %dd%
        current_show := current_show + 1
    }
}

goto MTXSpecialsEnd

MTXUIGuiEscape:
MTXUIGuiClose:
    Gui, MTXUI:Hide
Return

UpdateMTXShow:
    UpdateShow()
Return

UpdateMTXList:
    MTXGrab()
Return

MTXSpecialsEnd: