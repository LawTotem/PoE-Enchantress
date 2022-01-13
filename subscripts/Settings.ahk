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

tooltip, Loading Enchantress [Settings]

; You need to set the variable SettingsPath before including
; Interaction should be through the function addSetting() and getSetting()

; You should not interact with these variables
global settings_num := 0
global settings_keys := []
global settings_sections := []
global settings_description := []

; Add a setting to the current list
; sec: section heading
; key: the key
; def: default value
; desc: description of the setting
addNewSetting(sec, key, def, desc)
{
    settings_keys.Push(key)
    settings_sections.Push(sec)
    settings_description.Push(desc)
    settings_num += 1

    IniRead, this_value, %SettingsPath%, %sec%, %key%
    if (this_value == "ERROR" or this_value == "")
    {
        IniWrite, %def%, %SettingsPath%, %sec%, %key%
        sleep, 250
    }
    return
}

getSetting(sec, key)
{
    IniRead, this_value, %SettingsPath%, %sec%, %key%
    return this_value
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

saveOption(sect, set_name)
{
    GuiControlGet, TmpName,, _%sect%_%set_name%, value
    IniWrite, %TmpName%, %SettingsPath%, %sect%, %set_name%
    return
}

; Creates and shows the Settings GUI
settingsGUI()
{
    Gui, SettingsUI:new,, PoE-Enchantress Settings

    offset = 5
    current_sect = ""
    Gui, font, s10
        Loop % settings_num
        {
            offset := addOption(settings_sections[A_Index], settings_keys[A_Index]
                                ,offset, settings_description[A_Index])
        }

    Gui, font, s20
        Gui, add, text, x350 y%offset% gSettingsSave, Save
        offset += 60
    
    Gui, SettingsUI:Show, w800 h%offset%
}

goto SettingsEnd

SettingsSave:
    if (settings_num == 0)
        Return
    Loop % settings_num
    {
        saveOption(settings_sections[A_Index], settings_keys[A_index])
    }
    Gui, SettingsUI:Destroy
    Return

SettingsUIGuiEscape:
SettingsUIGuiClose:
    Gui, SettingsUI:Destroy
    Return

SettingsEnd: