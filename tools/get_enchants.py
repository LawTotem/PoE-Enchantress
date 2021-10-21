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
import datetime

# You can copy the contents of the raw_enchants###_##.txt into google sheets
# Then select the column the data got put in and use the menu Data->'Split text to columns'
# A small box will apear in the bottom left, select custom divider and enter the colon character ':'

# You need to get your own api key
# You have to open poe.ninja with the browsers developer tools
# Look for the api fetches and grab the key from there
# Should look like
# https://poe.ninja/api/data/API_KEY_HERE/getbuildoverview?overview=expedition&type=exp&language=en
# I couldn't find a cookie that had it
# In Chrome
# three little dots ->more tools->developer tools 
# or maybe Ctrl+Shift+ I 
# then the network tab
# click the getbuildoverview request when selecting "builds" on the site
# should give you a request URL

# According to @Skid they rotate daily bot may not be invalid.
key = 'b1ead41788cede02ff8f49656c736490';

# I recommend daily but you can use the league name to pull the top Exp characters.
league = 'daily';

if league == 'daily' :
    s_type = 'mix';
else :
    s_type = 'exp';


general_url = 'https://poe.ninja/api/data/' + key + '/getbuildoverview?overview=' + league + '&type=' + s_type + '&language=en';
general_req = urllib.request.Request(general_url, headers={'User-Agent': 'Mozilla/5.0'});
general_page = urllib.request.urlopen(general_req).read()
general_json = json.loads(general_page)
time.sleep(0.2)

now_time = datetime.datetime.now();
outfile = open('raw_enchants' + now_time.strftime("%j_%H") + '.txt','w')

all_select = list(zip(general_json['accounts'], general_json['names']));

# We save account and character in case we need to look them up later
# Helm Name is in case we mess up unique identification
# Helm Base and ilvl is so we can get some idea as to what is important
# Is Unique just flags if the helm is a unique helm
# Is Elder - this influence cannot be added later and may be needed
# Is Shaper - this influence cannot be added later and may be needed
# Time - In case you are joining multiple files togather you can take the most recent version of a duplicate character
outfile.write(":".join(["Account","Character","Helm Name","Helm Base","Helm ilvl","Enchant","Is Unique","Is Elder","Is Shaper","Time"]))
outfile.write("\n");

time_str = now_time.strftime("%j.%H");

sub_select = all_select[0:10]
# When testing the script consider substituting sub_select for all_select
for account_name in all_select :
    try :
        p_url = 'https://poe.ninja/api/data/' + key + '/GetCharacter?account=' + quote(account_name[0].encode('utf-8')) + '&name=' + quote(account_name[1].encode('utf-8')) + '&overview=' + league + '&type=' + s_type + '&language=en';
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
                outfile.write(":".join([account_name[0], account_name[1], name, base, ilvl, enchant, is_unique, is_elder, is_shaper, time_str]))
                outfile.write("\n");
    except :
        print('Could not fetch data for:' + account_name[0] + ' -- ' + account_name[1]);
    time.sleep(0.2 + random.randint(0,50)/100);

outfile.close()
