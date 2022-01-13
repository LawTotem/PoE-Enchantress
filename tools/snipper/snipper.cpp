/*******************************************************************************
*    PoE-Enchantress a pricing tool for things which cannot be copied
*    Copyright (C) 2021 LawTotem#8511
*
*    This program is free software: you can redistribute it and/or modify
*    it under the terms of the GNU General Public License as published by
*    the Free Software Foundation, either version 3 of the License, or
*    (at your option) any later version.

*    This program is distributed in the hope that it will be useful,
*    but WITHOUT ANY WARRANTY; without even the implied warranty of
*    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
*    GNU General Public License for more details.

*    You should have received a copy of the GNU General Public License
*    along with this program.  If not, see <https://www.gnu.org/licenses/>.
*******************************************************************************/

//#import "snipper.h"

#include <windows.h>
#include <wingdi.h>
#include <gdiplus.h>
#include <gdiplusheaders.h>
#include <gdiplusimaging.h>
#include <gdiplusimagecodec.h>
#include <iostream>
#include <vector>
#include <list>
#include <fstream>

#include "json.h"

#define DLLEXPORT __declspec(dllexport)

// Function to snip a section of the screen and save it to file
// int x: x coordinate of the snip
// int y: y coordinate of the snip
// int w: width of the snip
// int h: height of the snip
// WCHAR file_name: the file name to save the snip in
extern "C" DLLEXPORT void SnipAndSave(int x, int y, int w, int h, const WCHAR *file_name);

extern "C" DLLEXPORT void TestFunc(WCHAR *value);

// JSON Based functions because AHK is not good at it

extern "C" DLLEXPORT int UpdatePrices(const WCHAR *target_items,
                                      const WCHAR *poe_ninja_sgems,
                                      const WCHAR *poe_ninja_weaps,
                                      const WCHAR *poe_ninja_armor,
                                      const WCHAR *poe_ninja_umaps,
                                      const WCHAR *poe_ninja_jewel,
                                      const WCHAR *poe_ninja_rings,
                                      const WCHAR *poe_ninja_flask,
                                      const WCHAR *poe_ninja_bases,
                                      const WCHAR *file_name);

extern "C" DLLEXPORT void CompareInventory(const WCHAR *inv1, const WCHAR *inv2, WCHAR *rvalue);


/******************************************************************************/
std::string shortString(const std::wstring &lstring)
{
   std::string rvalue(lstring.begin(), lstring.end());
   return rvalue;
}


/******************************************************************************/
int UpdatePrices(const WCHAR *target_items,
                 const WCHAR *json_sgems,
                 const WCHAR *json_weaps,
                 const WCHAR *json_armor,
                 const WCHAR *json_umaps,
                 const WCHAR *json_jewel,
                 const WCHAR *json_rings,
                 const WCHAR *json_flask,
                 const WCHAR *json_bases,
                 const WCHAR *file_name)
{
   JSONValue *items = JSON::Parse(target_items);
   JSONValue *all_sgems = JSON::Parse(json_sgems);
   JSONValue *all_weaps = JSON::Parse(json_weaps);
   JSONValue *all_armor = JSON::Parse(json_armor);
   JSONValue *all_umaps = JSON::Parse(json_umaps);
   JSONValue *all_jewel = JSON::Parse(json_jewel);
   JSONValue *all_rings = JSON::Parse(json_rings);
   JSONValue *all_flask = JSON::Parse(json_flask);
   JSONValue *all_bases = JSON::Parse(json_bases);
   int rvalue = 0;

   std::list<std::wstring> heist_uniques;
   std::list<std::wstring> heist_bases;
   
   JSONObject root;
   JSONArray array;
   
   using note_price = std::pair<std::wstring, double>;
   std::map<std::wstring, note_price> prices;

   using price_line = std::pair<std::wstring, note_price>;
   std::list<price_line> value_list;
   if (items == NULL)
   {
      rvalue = -3;
      goto cleanup_update_prices;
   }

   if (items == NULL ||
       all_sgems == NULL ||
       all_weaps == NULL ||
       all_armor == NULL ||
       all_umaps == NULL ||
       all_jewel == NULL ||
       all_rings == NULL ||
       all_flask == NULL ||
       all_bases == NULL)
   {
      rvalue = -1;
      goto cleanup_update_prices;
   }
   if (!items->IsObject() ||
       !all_sgems->IsObject() ||
       !all_weaps->IsObject() ||
       !all_armor->IsObject() ||
       !all_umaps->IsObject() ||
       !all_jewel->IsObject() ||
       !all_rings->IsObject() ||
       !all_flask->IsObject() ||
       !all_bases->IsObject())
   {

      rvalue = -2;
      goto cleanup_update_prices;
   }

   root = items->AsObject();
   array = root[L"Heist Specific Uniques"]->AsArray();
   for (unsigned int i = 0; i < array.size(); ++i)
   {
      heist_uniques.push_back(array[i]->AsString());
   }
   array = root[L"Heist Exclusive Bases"]->AsArray();
   for (unsigned int i = 0; i < array.size(); ++i)
   {
      heist_bases.push_back(array[i]->AsString());
   }

   // Start with the Skill GEMS
   root = all_sgems->AsObject();
   array = root[L"lines"]->AsArray();
   for (unsigned int i = 0; i < array.size(); ++i)
   {
      if (!array[i]->IsObject())
      {
         continue;
      }
      JSONObject this_item = array[i]->AsObject();
      int lvl = -1;
      int qual = -1;
      if (this_item.find(L"gemLevel") != this_item.end())
      {
         lvl = round(this_item[L"gemLevel"]->AsNumber());
      }
      if (this_item.find(L"gemQuality") != this_item.end())
      {
         qual = round(this_item[L"gemQuality"]->AsNumber());
      }
      bool is_corrupt = false;
      if (this_item.find(L"corrupted") != this_item.end())
      {
         is_corrupt = this_item[L"corrupted"]->AsBool();
      }
      if (lvl > 20 || is_corrupt)
      {
         continue;
      }
      std::wstring key = this_item[L"name"]->AsString();
      double price = this_item[L"chaosValue"]->AsNumber();
      if (key.find(L"Anomalous") == 0 ||
            key.find(L"Phantasmal") == 0 ||
            key.find(L"Divergent") == 0)
      {
         if (lvl == 16 && qual < 20)
         {
            prices[key] = note_price(L"",price);
         }
         else if (prices.find(key) == prices.end())
         {
            prices[key] = note_price(L"~",price);
         }
         
      }
   }

   // Work through the weapons
   root = all_weaps->AsObject();
   array = root[L"lines"]->AsArray();
   for (unsigned int i = 0; i < array.size(); ++i)
   {
      if (!array[i]->IsObject())
      {
         continue;
      }
      JSONObject this_item = array[i]->AsObject();
      int links = 0;
      if (this_item.find(L"links") != this_item.end())
      {
         links = round(this_item[L"links"]->AsNumber());
      }
      std::wstring key = this_item[L"name"]->AsString();
      double price = this_item[L"chaosValue"]->AsNumber();
      if (key.find(L"Replica") == 0 ||
          std::find(heist_uniques.begin(),heist_uniques.end(),key) != 
            heist_uniques.end())
      {
         if (links == 0)
         {
            prices[key] = note_price(L"", price);
         }
         else if(prices.find(key) == prices.end())
         {
            std::wstring note = L"[" + std::to_wstring(links) + L"l]";
            prices[key] = note_price(note, price);
         }
      }
   }

   // Work through the armors
   root = all_armor->AsObject();
   array = root[L"lines"]->AsArray();
   for (unsigned int i = 0; i < array.size(); ++i)
   {
      if (!array[i]->IsObject())
      {
         continue;
      }
      JSONObject this_item = array[i]->AsObject();
      int links = 0;
      if (this_item.find(L"links") != this_item.end())
      {
         links = round(this_item[L"links"]->AsNumber());
      }
      std::wstring key = this_item[L"name"]->AsString();
      double price = this_item[L"chaosValue"]->AsNumber();
      if (key.find(L"Replica") == 0 ||
          std::find(heist_uniques.begin(),heist_uniques.end(),key) != 
            heist_uniques.end())
      {
         if (links == 0)
         {
            prices[key] = note_price(L"", price);
         }
         else if(prices.find(key) == prices.end())
         {
            std::wstring note = L"[" + std::to_wstring(links) + L"l]";
            prices[key] = note_price(note, price);
         }
      }
   }

   // Work through the unique maps
   root = all_umaps->AsObject();
   array = root[L"lines"]->AsArray();
   for (unsigned int i = 0; i < array.size(); ++i)
   {
      if (!array[i]->IsObject())
      {
         continue;
      }
      JSONObject this_item = array[i]->AsObject();
      std::wstring key = this_item[L"name"]->AsString();
      double price = this_item[L"chaosValue"]->AsNumber();
      if (key.find(L"Replica") == 0 ||
          std::find(heist_uniques.begin(),heist_uniques.end(),key) != 
            heist_uniques.end())
      {
         prices[key] = note_price(L"", price);
      }
   }

   // Work through the jewelry
   root = all_jewel->AsObject();
   array = root[L"lines"]->AsArray();
   for (unsigned int i = 0; i < array.size(); ++i)
   {
      if (!array[i]->IsObject())
      {
         continue;
      }
      JSONObject this_item = array[i]->AsObject();
      std::wstring key = this_item[L"name"]->AsString();
      double price = this_item[L"chaosValue"]->AsNumber();
      if (key.find(L"Replica") == 0 ||
          std::find(heist_uniques.begin(),heist_uniques.end(),key) != 
            heist_uniques.end())
      {
         prices[key] = note_price(L"", price);
      }
   }

   // Work through the unique rings
   root = all_rings->AsObject();
   array = root[L"lines"]->AsArray();
   for (unsigned int i = 0; i < array.size(); ++i)
   {
      if (!array[i]->IsObject())
      {
         continue;
      }
      JSONObject this_item = array[i]->AsObject();
      std::wstring key = this_item[L"name"]->AsString();
      double price = this_item[L"chaosValue"]->AsNumber();
      if (key.find(L"Replica") == 0 ||
          std::find(heist_uniques.begin(),heist_uniques.end(),key) != 
            heist_uniques.end())
      {
         prices[key] = note_price(L"", price);
      }
   }

   // Work through the flask
   root = all_flask->AsObject();
   array = root[L"lines"]->AsArray();
   for (unsigned int i = 0; i < array.size(); ++i)
   {
      if (!array[i]->IsObject())
      {
         continue;
      }
      JSONObject this_item = array[i]->AsObject();
      std::wstring key = this_item[L"name"]->AsString();
      double price = this_item[L"chaosValue"]->AsNumber();
      if (key.find(L"Replica") == 0 ||
          std::find(heist_uniques.begin(),heist_uniques.end(),key) != 
            heist_uniques.end())
      {
         prices[key] = note_price(L"", price);
      }
   }

   // Lets start building up the file
   for (auto idx = prices.begin(); idx != prices.end(); ++idx)
   {
      value_list.push_back(price_line(idx->first,idx->second));
   }

   // Work through the bases because we care about ilvl we add all the bases
   // as we find them.
   root = all_bases->AsObject();
   array = root[L"lines"]->AsArray();
   for (unsigned int i = 0; i < array.size(); ++i)
   {
      if (!array[i]->IsObject())
      {
         continue;
      }
      JSONObject this_item = array[i]->AsObject();
      std::wstring key = this_item[L"name"]->AsString();
      std::wstring variant = L"None";
      if (this_item.find(L"variant") != this_item.end())
      {
         variant = this_item[L"variant"]->AsString();
      }
      if (variant.find(L"None") != 0)
      {
         continue;
      }
      if (this_item[L"listingCount"]->AsNumber() < 30)
      {
         continue;
      }
      double price = this_item[L"chaosValue"]->AsNumber();
      int ilvl = round(this_item[L"levelRequired"]->AsNumber());
      if (std::find(heist_bases.begin(),heist_bases.end(),key) != 
            heist_bases.end())
      {
         if (price > 5.1 || ilvl >= 86)
         {
            std::wstring note = L"ilvl" + std::to_wstring(ilvl) + L" ";
            value_list.push_back(price_line(key,note_price(note, price)));
         }
      }
   }

   {
      std::ofstream output;
      output.open(file_name);
      bool first_element = true;
      for (auto idx = value_list.begin(); idx != value_list.end(); ++idx)
      {
         if (!first_element)
         {
            output << std::endl;
         }
         first_element = false;
         int int_c = floor(idx->second.second);
         int dec_c = floor((idx->second.second - int_c)*10);
         output << shortString(idx->first) << ":"
                << shortString(idx->second.first)
                << std::to_string(int_c) << "." << std::to_string(dec_c) << "c";
      }
      output.close();
   }

cleanup_update_prices:
   delete items;
   delete all_sgems;
   delete all_weaps;
   delete all_armor;
   delete all_umaps;
   delete all_jewel;
   delete all_rings;
   delete all_flask;
   delete all_bases;
   return rvalue;
}

const int STR_SIZE = 500;
std::wstring return_value(L"");

std::map<std::wstring,int> cleanInventory(const WCHAR* inventory_json)
{
   std::map<std::wstring,int> inv_map;
   JSONValue *value = JSON::Parse(inventory_json);

   if (value == NULL)
   {
      return inv_map;
   }
   else
   {
      if (!value->IsObject())
      {
         delete value;
         return inv_map;
      }
      JSONObject root = value->AsObject();
      JSONArray array = root[L"items"]->AsArray();
      for (unsigned int i = 0; i < array.size(); ++i)
      {
         if (!array[i]->IsObject())
         {
            continue;
         }
         JSONObject this_item = array[i]->AsObject();
         if (this_item.find(L"inventoryId") == this_item.end() ||
             this_item.find(L"typeLine") == this_item.end())
         {
            continue;
         }
         if (this_item[L"inventoryId"]->AsString().compare(L"MainInventory") == 0)
         {
            std::wstring type = this_item[L"typeLine"]->AsString();
            int stack_size = 1;
            if (this_item.find(L"stackSize") != this_item.end())
            {
               stack_size = this_item[L"stackSize"]->AsNumber();
            }
            std::wstring ilvl = L"0";
            if (this_item.find(L"ilvl") != this_item.end())
            {
               int int_lvl = this_item[L"ilvl"]->AsNumber();
               ilvl = std::to_wstring(int_lvl);
            }
            std::wstring key = type + L":" + ilvl;
            if (inv_map.find(key) != inv_map.end())
            {
               inv_map[key] += stack_size;
            }
            else
            {
               inv_map[key] = stack_size;
            }
         }
      }
      delete value;
      return inv_map;
   }
}

void CompareInventory(const WCHAR *old_inv, const WCHAR *new_inv, WCHAR *rvalue)
{
   return_value = L"";
   auto oinv = cleanInventory(old_inv);
   auto ninv = cleanInventory(new_inv);
   for (auto idx = ninv.begin(); idx != ninv.end(); ++idx)
   {
      int stack_delta = 0;
      if (oinv.find(idx->first) != oinv.end())
      {
         stack_delta = idx->second - oinv[idx->first];
      }
      else
      {
         stack_delta = idx->second;
      }
      if (stack_delta > 0)
      {
         return_value += idx->first + L":" + std::to_wstring(stack_delta) + L"\n";
      }
   }
   wcsncpy(rvalue, return_value.c_str(), STR_SIZE);
}

int GetEncoderClsid(const WCHAR* format, CLSID* pClsid)
{
   UINT  num = 0;          // number of image encoders
   UINT  size = 0;         // size of the image encoder array in bytes

   Gdiplus::ImageCodecInfo* pImageCodecInfo = NULL;

   Gdiplus::GetImageEncodersSize(&num, &size);
   if(size == 0)
      return -1;  // Failure

   pImageCodecInfo = (Gdiplus::ImageCodecInfo*)(malloc(size));
   if(pImageCodecInfo == NULL)
      return -1;  // Failure

   Gdiplus::GetImageEncoders(num, size, pImageCodecInfo);

   for(UINT j = 0; j < num; ++j)
   {
      if( wcscmp(pImageCodecInfo[j].MimeType, format) == 0 )
      {
         *pClsid = pImageCodecInfo[j].Clsid;
         free(pImageCodecInfo);
         return j;  // Success
      }    
   }

   free(pImageCodecInfo);
   return -1;  // Failure
}

void SnipAndSave(int x, int y, int w, int h, const WCHAR *file_name)
{
    Gdiplus::GdiplusStartupInput gdiplusStartupInput;
    ULONG_PTR gdiplusToken;
    GdiplusStartup(&gdiplusToken, &gdiplusStartupInput, NULL);

    HDC hdc = GetDC(NULL);
    HDC hdc_dest = CreateCompatibleDC(hdc);

    HBITMAP hbitmap = CreateCompatibleBitmap(hdc, w, h);

    HGDIOBJ hdc_old = SelectObject(hdc_dest, hbitmap);

    BitBlt(hdc_dest, 0, 0, w, h, hdc, x, y, SRCCOPY);

    HPALETTE simple_palette = CreateHalftonePalette(hdc_dest);
    Gdiplus::Bitmap *img = Gdiplus::Bitmap::FromHBITMAP(hbitmap, simple_palette);
    CLSID pngClsid;
    GetEncoderClsid(L"image/png", &pngClsid);
    img->Save(file_name, &pngClsid);

    delete img;

    SelectObject(hdc_dest, hdc_old);

    DeleteDC(hdc_dest);
    ReleaseDC(NULL, hdc);
    
    DeleteObject(hbitmap);
    Gdiplus::GdiplusShutdown(gdiplusToken);
}

void TestFunc(WCHAR *out_val)
{
   std::wstring return_value = L"11";
   wcsncpy(out_val, return_value.c_str(), STR_SIZE);
   return;
}