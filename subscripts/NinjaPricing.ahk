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

tooltip, Loading Enchantress [NinjaPrice]

; Main functionality is in setting these variables
; Call ninjaGrab(league) to update, it will return true if prices were updated
global ninja_sgems := "" ; skill gems
global ninja_weaps := "" ; unique weapons
global ninja_armor := "" ; unique armors
global ninja_umaps := "" ; unique maps
global ninja_jewel := "" ; unique jewels
global ninja_rings := "" ; unique rings/amulets
global ninja_flask := "" ; unique flasks
global ninja_bases := "" ; crafting bases
global ninja_corbs := "" ; currency orbs
global ninja_frags := "" ; map fragments
global ninja_cards := "" ; divination cards
global ninja_boils := "" ; blight oils
global ninja_incub := "" ; incubators
global ninja_scarb := "" ; scarabs
global ninja_dorbs := "" ; delirium orbs
global ninja_wmaps := "" ; white maps
global ninja_essen := "" ; essences
global ninja_reson := "" ; reasonators
global ninja_fossl := "" ; fossils

; Internal variable used to track when the last prices were grabbed
global last_ninja_grab := 0

addNewSetting("User", "NinjaOnStart", 1, "Fetch PoE.Ninja Prices on Start")
if (getSetting("User", "NinjaOnStart"))
{
    ninjaGrab(getSetting("General", "League"))
}

; Pulls an individual pricing
pullNinjaItems(league, this_type)
{
    grab := ComObjCreate("WinHttp.WinHttpRequest.5.1")
    grab.Open("Get","https://poe.ninja/api/data/itemoverview?league=" league "&type=" this_type "&language=en")
    grab.SetRequestHeader("User-Agent","Mozilla/5.0")
    grab.Send()
    grab.WaitForResponse()
    if (grab.responseText == "")
    {
        MsgBox, Bad request %this_type%
    }
    return grab.responseText
}

pullNinjaCurrency(league, this_type)
{
    grab := ComObjCreate("WinHttp.WinHttpRequest.5.1")
    grab.Open("Get","https://poe.ninja/api/data/currencyoverview?league=" league "&type=" this_type "&language=en")
    grab.SetRequestHeader("User-Agent","Mozilla/5.0")
    grab.Send()
    grab.WaitForResponse()
    if (grab.responseText == "")
    {
        MsgBox, Bad request %this_type%
    }
    return grab.responseText
}

; This function will update the global once an hour when requested.
ninjaGrab(league)
{
    global last_ninja_grab
    Delta := %A_Now%
    EnvSub Delta, %last_ninja_grab%, hours
    if (last_ninja_grab = 0 or Delta > 1)
    {
        last_ninja_grab := %A_Now%

        global ninja_sgems
        ninja_sgems := pullNinjaItems(league, "SkillGem")
        global ninja_weaps
        ninja_weaps := pullNinjaItems(league, "UniqueWeapon")
        global ninja_armor
        ninja_armor := pullNinjaItems(league, "UniqueArmour")
        global ninja_umaps
        ninja_umaps := pullNinjaItems(league, "UniqueMap")
        global ninja_jewel
        ninja_jewel := pullNinjaItems(league, "UniqueJewel")
        global ninja_rings
        ninja_rings := pullNinjaItems(league, "UniqueAccessory")
        global ninja_flask
        ninja_flask := pullNinjaItems(league, "UniqueFlask")
        global ninja_bases
        ninja_bases := pullNinjaItems(league, "BaseType")
        global ninja_corbs
        ninja_corbs := pullNinjaCurrency(league, "Currency")
        global ninja_frags
        ninja_frags := pullNinjaCurrency(league, "Fragment")
        global ninja_boils
        ninja_boils := pullNinjaItems(league, "Oil")
        global ninja_incub
        ninja_incub := pullNinjaItems(league, "Incubator")
        global ninja_scarb
        ninja_scarb := pullNinjaItems(league, "Scarab")
        global ninja_dorbs
        ninja_dorbs := pullNinjaItems(league, "DeliriumOrb")
        global ninja_wmaps
        ninja_wmaps := pullNinjaItems(league, "Map")
        global ninja_essen
        ninja_essen := pullNinjaItems(league, "Essence")
        global ninja_reson
        ninja_reson := pullNinjaItems(league, "Resonator")
        global ninja_fossl
        ninja_fossl := pullNinjaItems(league, "Fossil")
        return true
    }
    return false
}