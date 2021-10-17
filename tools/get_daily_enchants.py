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
from urllib.parse import quote
import time
import random

# You need to get your own api key
# You have to open poe.ninja with the browsers developer tools
# Look for the api fetches and grab the key from there
# Should look like
# https://poe.ninja/api/data/API_KEY_HERE/getbuildoverview?overview=expedition&type=exp&language=en
# I couldn't find a cookie that had it
key = 'API_KEY_HERE';

general_url = 'https://poe.ninja/api/data/' + key + '/getbuildoverview?overview=daily&type=mix&language=en';
general_req = urllib.request.Request(general_url, headers={'User-Agent': 'Mozilla/5.0'});
general_page = urllib.request.urlopen(general_req).read()
general_json = json.loads(general_page)
time.sleep(0.2)

# Helm Item Class 2,3
# Helm Item Slot 1,1

# Frame Type 2 (elder?)
# TypeName = Bone Helm
# BaseType = Bone Helm

# Frame Type 3 unique?
# Frame Type 2 

outfile = open('raw_enchants.txt','w')

all_select = list(zip(general_json['accounts'], general_json['names']));

sub_select = all_select[0:100]
for account_name in all_select :
    p_url = 'https://poe.ninja/api/data/' + key + '/GetCharacter?account=' + quote(account_name[0].encode('utf-8')) + '&name=' + quote(account_name[1].encode('utf-8')) + '&overview=daily&type=mix&language=en';
    p_req = urllib.request.Request(p_url, headers={'User-Agent': 'Mozilla/5.0'});
    p_page = urllib.request.urlopen(p_req).read();
    p_json = json.loads(p_page)
    try :
        helm_index = [ii['itemSlot'] == 1 for ii in p_json['items']].index(True);
    except :
        helm_index = -1;
    if helm_index >= 0 :
        helm = p_json['items'][helm_index]['itemData'];
        name = helm['name'];
        base = helm['baseType'];
        ilvl = str(helm['ilvl']);
        try :
            enchant = helm['enchantMods'][0];
        except :
            enchant = 'None'
        is_unique = str(helm['frameType'] == 3);
        try :
            influences = helm['influences']
            is_elder = str(influences['elder'])
            is_shaper = str(influences['shaper'])
        except :
            is_elder = str(False);
            is_shaper = str(False);
        if enchant != 'None' :
            outfile.write(":".join([account_name[0], account_name[1], name, base, ilvl, enchant, is_unique, is_elder, is_shaper]))
            outfile.write("\n");
    time.sleep(0.2 + random.randint(0,50)/100);

outfile.close()
