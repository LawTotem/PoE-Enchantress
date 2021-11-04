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

def simplifyName(name) :
    return name.lower().replace(' ','').rstrip();

def reducedMapping(min_list, bk=6, min_length=3) :
    set_of_names = set(min_list);
    sn_mapping = [];
    for fnname in min_list :
        name = simplifyName(fnname);
        shortest = "";
        abandoned_dist = bk;
        abandoned = "";
        other_names = set_of_names.difference({fnname});
        simp_other_names = [simplifyName(on) for on in other_names];
        for k in range(min_length,min([bk+1,len(name)])) :
            short_names = [name[i:(i+k)] for i in range(len(name) - k + 1)];
            goodness = [sum([sn in on for on in simp_other_names]) for sn in short_names];
            mg = min(goodness);
            best_name = goodness.index(min(goodness));
            if mg == 0 :
                if shortest == "" :
                    shortest = short_names[best_name];
                    k = bk+1;
            if mg < abandoned_dist :
                abandoned = short_names[best_name];
        if shortest == "" :
            print("Warning: " + fnname);
            sn_mapping.append(abandoned + ":" + fnname);
        else :
            sn_mapping.append(shortest + ":" + fnname);
    return sn_mapping

if __name__ == "__main__":
    ff = open('./heists.txt','r');
    all_heists = ff.readlines();
    lines = [ll.rsplit(':')[0] for ll in all_heists]
    lines = list(set(lines));
    reduced_heists = reducedMapping(lines,20);
    ff.close();
    ff = open('./heist_remapping.txt','w');
    ff.write("\n".join(reduced_heists));
    ff.close();

    ff = open('./all_enchants.txt','r');
    all_enchants = ff.readlines();
    reduced_enchants = reducedMapping(all_enchants, 20, min_length=5);
    ff.close();
    ff = open('./enchant_remapping.txt','w');
    ff.writelines(reduced_enchants);
    ff.close();