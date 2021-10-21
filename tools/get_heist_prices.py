#    PoE-Enchantress a pricing tool for things which cannot be copied
#    Copyright (C) 2021 LawTotem#8511

#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.

#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.

#    You should have received a copy of the GNU General Public License
#    along with this program.  If not, see <https://www.gnu.org/licenses/>.

import json
import urllib.request
import time

league = "Expedition"

# We are going to get all the prices from poe.ninja - don't abuse this.
sgems_req = urllib.request.Request("https://poe.ninja/api/data/itemoverview?league=" + league + "&type=SkillGem&language=en",headers={'User-Agent': 'Mozilla/5.0'})
weaps_req = urllib.request.Request("https://poe.ninja/api/data/itemoverview?league=" + league + "Expedition&type=UniqueWeapon&language=en",headers={'User-Agent': 'Mozilla/5.0'})
armor_req = urllib.request.Request("https://poe.ninja/api/data/itemoverview?league=" + league + "&type=UniqueArmour&language=en",headers={'User-Agent': 'Mozilla/5.0'})
umaps_req = urllib.request.Request("https://poe.ninja/api/data/itemoverview?league=" + league + "&type=UniqueMap&language=en",headers={'User-Agent': 'Mozilla/5.0'})
jewel_req = urllib.request.Request("https://poe.ninja/api/data/itemoverview?league=" + league + "&type=UniqueJewel&language=en",headers={'User-Agent': 'Mozilla/5.0'})
rings_req = urllib.request.Request("https://poe.ninja/api/data/itemoverview?league=" + league + "&type=UniqueAccessory&language=en",headers={'User-Agent': 'Mozilla/5.0'})
flask_req = urllib.request.Request("https://poe.ninja/api/data/itemoverview?league=" + league + "&type=UniqueFlask&language=en",headers={'User-Agent': 'Mozilla/5.0'})
bases_req = urllib.request.Request("https://poe.ninja/api/data/itemoverview?league=" + league + "&type=BaseType&language=en",headers={'User-Agent': 'Mozilla/5.0'})

sgems_page = urllib.request.urlopen(sgems_req).read()
all_sgems = json.loads(sgems_page)
time.sleep(0.2)

weaps_page = urllib.request.urlopen(weaps_req).read()
all_weaps = json.loads(weaps_page)
time.sleep(0.2)

armor_page = urllib.request.urlopen(armor_req).read()
all_armor = json.loads(armor_page)
time.sleep(0.2)

umaps_page = urllib.request.urlopen(umaps_req).read()
all_umaps = json.loads(umaps_page)
time.sleep(0.2)

jewel_page = urllib.request.urlopen(jewel_req).read()
all_jewel = json.loads(jewel_page)
time.sleep(0.2)

rings_page = urllib.request.urlopen(rings_req).read()
all_rings = json.loads(rings_page)
time.sleep(0.2)

flask_page = urllib.request.urlopen(flask_req).read()
all_flask = json.loads(flask_page)
time.sleep(0.2)

bases_page = urllib.request.urlopen(bases_req).read()
all_bases = json.loads(bases_page)
time.sleep(0.2)

# We are going to open the output
outfile = open('heists.txt','w')

# Pull in the price of skill gems
# First try and find 16,16 gems
priced_gems = set()
newline = ''
for gem in all_sgems['lines'] :
    try : 
        lvl = int(gem['gemLevel'])
    except :
        lvl = -1
    try : 
        qual = int(gem['gemQuality'])
    except :
        qual = -1
    title = gem['name']
    if lvl == 16 and qual < 20 and (not title in priced_gems):
        if (title.startswith('Anomalous') or title.startswith('Phantasmal') or title.startswith('Divergent')) :
            outfile.write(newline + title + ',' + str(gem['chaosValue']) + 'c')
            newline = '\n'
            priced_gems.add(title)
# If we cant find the qual 16 than just pull what ever
for gem in all_sgems['lines'] :
    try : 
        lvl = int(gem['gemLevel'])
    except :
        lvl = -1
    try : 
        qual = int(gem['gemQuality'])
    except :
        qual = 16
    title = gem['name']
    if lvl < 20 and qual < 20 and (not title in priced_gems):
        if (title.startswith('Anomalous') or title.startswith('Phantasmal') or title.startswith('Divergent')) :
            outfile.write(newline + title + ':~' + str(gem['chaosValue']) +'c')
            priced_gems.add(title)

# Pull in the Weapons
for weap in all_weaps['lines'] :
    title = weap['name']
    try :
        links = weap['links']
    except :
        links = 0
    if title.startswith('Replica') and links == 0 :
        outfile.write(newline + title + "," + str(weap['chaosValue']) + 'c')

# Pull in Armors
for armor in all_armor['lines'] :
    title = armor['name']
    try :
        links = armor['links']
    except :
        links = 0
    if title.startswith('Replica') and links == 0 :
        outfile.write(newline + title + "," + str(armor['chaosValue']) + 'c')

# Pull in Rings/Amulets
for jewerly in all_rings['lines'] :
    title = jewerly['name']
    if title.startswith('Replica') :
        outfile.write(newline + title + "," + str(jewerly['chaosValue']) + 'c')

# Pull in Maps
for umap in all_umaps['lines'] :
    title = umap['name']
    if title.startswith('Replica') :
        outfile.write(newline + title + "," + str(umap['chaosValue']) + 'c')

# Pull in Maps
for jewel in all_jewel['lines'] :
    title = jewel['name']
    if title.startswith('Replica') :
        outfile.write(newline + title + "," + str(jewel['chaosValue']) + 'c')

# Pull in Maps
for flask in all_flask['lines'] :
    title = flask['name']
    if title.startswith('Replica') :
        outfile.write(newline + title + "," + str(flask['chaosValue']) + 'c')

heist_bases = {
    'Psychotic Axe',
    'Apex Cleaver',
    'Solarine Bow',
    'Void Fangs',
    'Pneumatic Dagger',
    'Infernal Blade',
    'Boom Mace',
    'Alternating Sceptre',
    'Impact Force Propagator',
    'Battery Staff',
    'Eventuality Rod',
    'Anarchic Spirit Blade',
    'Banishing Blade',
    'Accumulator Wand',
    'Heat-attuned Tower Shield',
    'Cold-attuned Buckler',
    'Transfer-attuned Sprirt Shield',
    'Micro-Distillery Belt',
    'Mechalarm Belt',
    'Simplex Amulet',
    'Astrolabe Amulet',
    'Cogwork Ring',
    'Geodesic Ring'
}

# Pull in the Heist bases
for base in all_bases['lines'] :
    title = base['name']
    try :
        variant = base['variant']
    except :
        variant = 'None'
    if title in heist_bases and variant == 'None' :
            if base['chaosValue'] > 5.1 or base['levelRequired'] >= 86 :
                outfile.write(newline + title + "," + "ilvl" + str(base['levelRequired']) + " " + str(base['chaosValue']) + "c")

outfile.close()
