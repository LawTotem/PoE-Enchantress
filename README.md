# PoE-Enchantress
The Poe-Enchantress tool help in pricing elements of Path of Exile (PoE) which you cannot simply copy to the clipboard. It uses an Optical Character Recognition (OCR) tool to convert selected portions of the screen to text. This text, either names of items or enchants, are looked up in user configurable files to price them.

You can find the latest release on the releases page <https://github.com/LawTotem/PoE-Enchantress/releases>.
The releases include an executable version of the autohotkey script and come in a more convenient zip file.

You will need the tool <code>Capture2Text</code> to perform the ORC. This will need to be downloaded separately and the folder <code>Capture2Text</code> should be moved into the folder with the PoE-Enchantress script.

PoE-Enchantress does not use any external sites/tools to perform Heist item pricing.
To start you can copy the example <code>heists.txt</code> to the root folder for heist prices.
You will probably have to manually configure <code>general_enchants.txt</code> and <code>services.txt</code> because I'm no good at that stuff.
To practice you can snapshot any text which has the name of the item/enchant to see what the tool will do or manually hand type it into the GUI's captured text box and press the desired Reprocess button.

## Setup

1. Download the latest release <https://github.com/LawTotem/PoE-Enchantress/releases>
2. Unzip the tool into a directory
3. Download Capture2Text <https://sourceforge.net/projects/capture2text/files/Capture2Text/>
4. Extract the Capture2Text folder into the folder with Enchantress
5. Start up Enchantress
6. Open the menu with either Ctrl-Shift+Y or select **Enchantress** line from the tray icon
7. Open the settings menu by clicking the *Settings* button in the top right
8. Set the Heist prices, either copy heists.txt from `examples` folder or use a pastebin https://pastebin.com/raw/Z5udVRZS
9. Set the General Enchants, either copy `general_enchants.txt` or use the pastebin https://pastebin.com/raw/Za0fgKzg
10. Create a services.txt, either blank or enter your current services
11. In Lab use Ctrl-Y to highlight the font options
12. In Heist use Ctrl-U to highlight the heist items
13. ... Profit

# Features

## Feature Requests
There is a discussions page on the github page, <https://github.com/LawTotem/PoE-Enchantress/discussions>, or you can find me, LawTotem, on discord.

## Heist Pricing
To price heist items press the heist hotkey, default Ctrl-u, and select a relatively tight selection of the screen which includes the name of the unique, jewel, or heist base. The tool will then attempt to provide you with a price for the item based on the contents of the <code>HeistPriceTxt</code>, defaults to <code>heists.txt</code>.
The file follows the format "heists item name":"price", when the item is matched a line "item name" --price-- "price" will appear on one of the lines below the captured text.


## Enchant Pricing
To price enchants press the enchant hotkey, default Ctrl-y, and select a relatively tight selection of the screen which includes just the enchants (not the lvl or boot/belt/helm icons). The tool will check to see if you have any services out on the enchants by checking <code>ServiceEnchantTxt</code>, default <code>services.txt</code>, and then check to see if any of the enchants are valuable enough to enchant on a base <code>GeneralEnchantTxt</code>, default </code>general_enchants.txt</code>. Not unlike <code>heists.txt</code> the examples are really not sufficient.


## OCR Remapping
Because the OCR can make mistakes in its CRing the tool by default always compares strings with no white space, so "h e l l o" and "hello" are the same, and no capitalization, "HeLlO" and "hello" are the same.

In addition, two remapping files <code>HeistRemappingTxt</code> and <code>EnchantRemappingTxt</code> are provided. They have been generated to provide short strings which should be mostly unique to actual things that you are looking for. When these files are provided the associated scanned text will be searched for the short strings and replaced with the complete ones. This can result in the order of enchants being shuffled or lost and some heist gems being duplicated, Anomalous Withering Step going to Anomalous Wither and Anomalous Withering Step __BUT__ the anything that survives will be exactly correct. If something is missing you can manually type in the full text and click associated reprocesses buttons. If you hate this you can change the file name in settings to a non-existant file and the feature will not be used.

There are a couple of gems whose names are a subset of another gem so the tool will always miss-map them.
 - Arc (Arcmage, Arcane Surge, Arctic Armour, Arcane Cloak, Arcanist Brand)
 - Barrage (Barrage Support)
 - Wither (Withering Step)

# Settings

## General
### FirstRun
A flag which indicates if the help menu should appear on next start. Initially set to '1' but once the tool has been started it is set to '0' to indicate the menu should no longer be shown.
### GuiKey
The key sequence to bring up the GUI, defaults to Ctl-Shift-y.
### EnchantScanKey
The key sequence to start an Enchant screen grab, defaults to Ctrl-y.
### HeistScanKey
The key sequence to start a Heist screen grab, defaults to Ctrl-u
## User
### HeistPriceTxt
The file to use when pricing items from a Heist scan.
Can also be a url that starts with http which will be fetched every hour on use, for example https://pastebin.com/raw/Z5udVRZS
### ServiceEnchantTxt
The file to use when alerting to enchant services, always appears before general enchants.
### GeneralEnchantTxt
The file to use when giving general enchant recommendations.
The format is "string to look for":"string to show". See <code>examples/general_enchants.txt</code> for an example.
Can also be a url that starts with http which will be fetched every hour on use, for example https://pastebin.com/raw/Za0fgKzg
### HeistRemappingTxt
This file provides the string remapping for Heist, see the ORC remapping feature.

### EnchantRemappingTxt
This file provides the string remapping for Enchants, see the OCR remapping feature.

### SnapshotScreen
You'll have to compile the snapper.cpp file yourself into a dll and put that into the same folder as the script to use this but when enabled it will save a time stamped snapshot every time you use the tool. Used in development to provide reference images.

### SaveEnchant
This option will save the scanned enchants to a date stamped text file if you want to keep statistics on what you have seen.
If anything goes wrong with the scan, missed enchant or something, you can type in the correct enchant and press the reprocess enchant and it will save the file again, overwriting the file until you perform another screen grab.

## Other
### scale
Untested but maybe corrects for some monitor scaling.

### monitor
Untested but maybe allows for monitor selection.

# Lab Enchants
Originally the tool had some capabilities for handling labratory enchants because they fell in the same category of requiring OCR.
As of 0.5.0 these features have been removed; I (LawTotem) don't run lab so these features were mostly a curiosity and the tool bnorick/labbie is simply superior.

# Change List

## 0.5.0
 - Removing Lab Enchant Features
 - Added PoE Ninja Price Fetching
 - Interal code cleanup

## 0.4.0
 - Added genearl enchants from http like pastebin.
 - Added ability to dump raw capture to text. In the case where the remapping failed it should help.
 - Added update detection. The tool will now check gitlab to see if there is an update and display a message to user.
 - Added heist pricing from http like pastebin.

## 0.3.0
 - Added an enchant scraper, still requires hand data analysis to create general_enchants.txt.
 - Added league variables to tools.
 - Corrected seperator in heist price scraper.
 - Readme grammer/spelling.
 - Added support for saving text version of enchant grabs.

## 0.2.0
 - Added settings menu, available from main GUI
 - Added more complete Heist prices
 - Added example Lab services and base enchant files
 - Update GUI
 - Added OCR string fixing
