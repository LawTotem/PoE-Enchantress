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
#include <codecvt>

#include<tensorflow/c/c_api.h>

#include "json.h"

#define DLLEXPORT __declspec(dllexport)

// Get the version index for the library
extern "C" DLLEXPORT int GetSnipVersion();

// Get the TensorFlow version
extern "C" DLLEXPORT void GetTFVersion(WCHAR *rvalue);

// Test TensorFlow
extern "C" DLLEXPORT void TestTF(WCHAR *rvalue);

// Setup TensorFlow Graph for OCR
// return: A pointer to the session.
extern "C" DLLEXPORT void* SetupTF(void);


// Function to snip a section of the screen and save it to file
// int x: x coordinate of the snip
// int y: y coordinate of the snip
// int w: width of the snip
// int h: height of the snip
// WCHAR file_name: the file name to save the snip in
extern "C" DLLEXPORT void SnipAndSave(int x, int y, int w, int h, const WCHAR *file_name);

extern "C" DLLEXPORT void SnipAndOCR(void* heist_ocr_r, int x, int y, int w, int h, const WCHAR *file_name, WCHAR *rvalue);

// Function to parse a bunch of JSON and transform it to a ':' separated list
// of item:price because AHK is not great at parsing JSON.
// wchar target_items:
// wchar poe_ninja_sgems:
// wchar poe_ninja_weaps:
// wchar poe_ninja_armor:
// wchar poe_ninja_umaps:
// wchar poe_ninja_jewel:
// wchar poe_ninja_rings:
// wchar poe_ninja_flask:
// wchar poe_ninja_bases:
// wchar file_name: the name of the file to save the summarized pricing
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

// Function to parse the MTX specials
// wchar json_specials: The server response from the api call
//                      https://www.pathofexile.com/api/shop/microtransactions/special
// wchar file_name: The file to write the simplified special too
extern "C" DLLEXPORT int SimplifySpecial(const WCHAR *json_specials,
                                         const WCHAR *file_name);

// These are used to return strings to AHK
const int STR_SIZE = 2000; // Max size for the string to return
std::wstring return_value(L""); // Global for translating things into wstrings

/******************************************************************************/
std::string shortString(const std::wstring &lstring)
{
   std::string rvalue(lstring.begin(), lstring.end());
   return rvalue;
}

/******************************************************************************/
int GetSnipVersion(void)
{
   return 1;
}

/******************************************************************************/
void GetTFVersion(WCHAR *rvalue)
{
   std::string temp(TF_Version());
   return_value = std::wstring_convert<std::codecvt_utf8<wchar_t> >().from_bytes(temp);
   wcsncpy(rvalue, return_value.c_str(), STR_SIZE);
}

/******************************************************************************/
int SimplifySpecial(const WCHAR *json_specials, const WCHAR *file_name)
{
   JSONValue *specials = JSON::Parse(json_specials);
   JSONObject root;
   JSONArray array;

   int rvalue = 0;

   if (specials == NULL)
   {
      rvalue = -3;
      goto cleanup_specials;
   }

   if (!specials->IsObject())
   {
      rvalue = -2;
      goto cleanup_specials;
   }

   root = specials->AsObject();
   if (root.find(L"entries") == root.end())
   {
      rvalue = -1;
      goto cleanup_specials;
   }
   array = root[L"entries"]->AsArray();
   {
      std::ofstream output;
      output.open(file_name);
      bool first_element = true;
      for (unsigned int i = 0; i < array.size(); ++i)
      {
         if (!array[i]->IsObject())
         {
            continue;
         }
         JSONObject this_element = array[i]->AsObject();
         if (this_element.find(L"microtransaction") == this_element.end())
         {
            continue;
         }
         if (!this_element[L"microtransaction"]->IsObject())
         {
            continue;
         }
         JSONObject micro_trans = this_element[L"microtransaction"]->AsObject();
         if (this_element.find(L"cost") == this_element.end())
         {
            continue;
         }
         if (micro_trans.find(L"cost") == micro_trans.end())
         {
            continue;
         }
         if (!this_element[L"cost"]->IsNumber())
         {
            continue;
         }
         if (!micro_trans[L"cost"]->IsNumber())
         {
            continue;
         }
         if (this_element.find(L"imageUrl") == this_element.end())
         {
            continue;
         }
         if (micro_trans.find(L"name") == micro_trans.end())
         {
            continue;
         }
         int discount = 100.0 * (1.0 - this_element[L"cost"]->AsNumber() / micro_trans[L"cost"]->AsNumber());

         if (!first_element)
         {
            output << std::endl;
         }
         first_element = false;
         output << shortString(micro_trans[L"name"]->AsString());
         output << "!";
         output << discount;
         output << "!";
         output << shortString(this_element[L"imageUrl"]->AsString());
      }
      output.close();
   }

cleanup_specials:
   delete specials;
   return rvalue;
}

/******************************************************************************/
void NoOp(void *data, size_t a, void* b)
{
}

/******************************************************************************/
char MaxLikeChar(float *region)
{
   char mapping[31] = "eABCDEFGHIJKLMNOPQRSTUVWXYZ-' ";
   int midx = 0;
   float mvalue = 0.0;
   for (int i = 0; i < 30; ++i)
   {
      if (region[i] > mvalue)
      {
         mvalue = region[i];
         midx = i;
      }
   }
   return mapping[midx];
}

/******************************************************************************/
std::wstring ToMaxString(float *result)
{
   std::string rstring;
   rstring.resize(121);
   for (int i = 0; i < 121; ++i)
   {
      rstring[i] = MaxLikeChar(&result[30*i]);
   }
   return std::wstring_convert<std::codecvt_utf8<wchar_t> >().from_bytes(rstring);
}

/******************************************************************************/
std::wstring CTCString(const std::wstring &input)
{
   std::wstring rstring;
   WCHAR lastchar = ' ';
   for (int k = 0; k < input.length(); ++k)
   {
      if (input[k] != lastchar)
      {
         lastchar = input[k];
         if (input[k] != ' ')
         {
            rstring.push_back(input[k]);
         }
      }
   }
   return rstring;
}

struct HeistTFOCR {
   TF_Graph* graph;
   TF_Status* status;
   TF_Session* session;
   TF_Output* input;
   TF_Output* output;

   int n_i_dim;
   int64_t *i_dims;
   int n_i_data;

   float *input_data;

};

/******************************************************************************/
void* SetupTF()
{
   HeistTFOCR *rvalue = new HeistTFOCR;

   rvalue->graph = TF_NewGraph();
   rvalue->status = TF_NewStatus();

   TF_SessionOptions* session_ops = TF_NewSessionOptions();
   TF_Buffer* run_ops = NULL;

   const std::string model = "heist_ocr.tf";
   const char* tags = "serve";

   int ntags = 1;

   rvalue->session = TF_LoadSessionFromSavedModel(session_ops, run_ops, model.c_str(), &tags, ntags, rvalue->graph, NULL, rvalue->status);
   TF_DeleteSessionOptions(session_ops);

   if (TF_GetCode(rvalue->status) != TF_OK)
   {
      TF_DeleteGraph(rvalue->graph);
      TF_DeleteSession(rvalue->session, rvalue->status);
      TF_DeleteSessionOptions(session_ops);
      TF_DeleteStatus(rvalue->status);
      delete rvalue;
      rvalue = NULL;
   }
   else
   {

      rvalue->input = new TF_Output[1];
      rvalue->input[0] = {TF_GraphOperationByName(rvalue->graph, "serving_default_input_image"), 0};
      rvalue->output = new TF_Output[1];
      rvalue->output[0] = {TF_GraphOperationByName(rvalue->graph, "StatefulPartitionedCall"), 0};

      if (rvalue->input[0].oper == NULL || rvalue->output[0].oper == NULL)
      {
         delete[] rvalue->input;
         delete[] rvalue->output;
         TF_DeleteGraph(rvalue->graph);
         TF_DeleteSession(rvalue->session, rvalue->status);
         TF_DeleteSessionOptions(session_ops);
         TF_DeleteStatus(rvalue->status);
         delete rvalue;
         rvalue = NULL;
      }
      else
      {
         rvalue->n_i_dim = 4;
         rvalue->i_dims = new int64_t[rvalue->n_i_dim];
         rvalue->i_dims[0] = 1;
         rvalue->i_dims[1] = 50;
         rvalue->i_dims[2] = 1000;
         rvalue->i_dims[3] = 1;
         rvalue->n_i_data = 1 * 50 * 1000 * 1;
         rvalue->input_data = new float[rvalue->n_i_data];
      }

   }
   return (void*)rvalue;
}

/******************************************************************************/
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

/******************************************************************************/
void ScaleAndGray(Gdiplus::Bitmap *image, float *output, int w, int h)
{
   if (image != NULL && output != NULL)
   {
      Gdiplus::Color clr;
      int width = image->GetWidth();
      int height = image->GetHeight();
      float scale = (static_cast<float>(h) - 1.) / static_cast<float>(height);
      int new_width = std::ceil(static_cast<float>(width) * scale);
      new_width = min(new_width, w);

      for (int y = 0; y < h; ++y)
      {
         for (int x = 0; x < new_width; ++x)
         {
            float xo = static_cast<float>(x) / scale;
            float yo = static_cast<float>(y) / scale;

            int x1 = std::floor(xo);
            int x2 = x1 + 1;
            int y1 = std::floor(yo);
            int y2 = y1 + 1;
            x1 = max(0, x1);
            x2 = min(width - 1, x2);
            y1 = max(0, y1);
            y2 = min(height - 1, y2);

            image->GetPixel(x1, y1, &clr);
            float q_11 = clr.GetRed() * 0.2989 + clr.GetGreen() * 0.5870 + clr.GetBlue() * 0.1140;
            image->GetPixel(x1, y2, &clr);
            float q_12 = clr.GetRed() * 0.2989 + clr.GetGreen() * 0.5870 + clr.GetBlue() * 0.1140;
            image->GetPixel(x2, y1, &clr);      
            float q_21 = clr.GetRed() * 0.2989 + clr.GetGreen() * 0.5870 + clr.GetBlue() * 0.1140;
            image->GetPixel(x2, y2, &clr);
            float q_22 = clr.GetRed() * 0.2989 + clr.GetGreen() * 0.5870 + clr.GetBlue() * 0.1140;

            float x1f = static_cast<float>(x1);
            float x2f = static_cast<float>(x2);
            float y1f = static_cast<float>(y1);
            float y2f = static_cast<float>(y2);
            float bl = (x2f - xo) * (y2f - yo) * q_11 +
                        (xo - x1f) * (y2f - yo) * q_21 +
                        (x2f - xo) * (yo - y1f) * q_12 +
                        (xo - x1f) * (yo - y1f) * q_22;
            output[y * 1000 + x] = bl;
         }
      }
   }
}

/******************************************************************************/
void SnipAndOCR(void* heist_ocr_r, int x, int y, int w, int h, const WCHAR *file_name, WCHAR *rvalue)
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

   if (heist_ocr_r == NULL)
   {
      std::wstring tmp = L"NULL";
      wcsncpy(rvalue, tmp.c_str(), STR_SIZE);
   }
   else
   {
      HeistTFOCR *heist_ocr = (HeistTFOCR*)heist_ocr_r;
      for (int i = 0; i < heist_ocr->n_i_data; ++i)
      {
         heist_ocr->input_data[i] = 1.0;
      }
      ScaleAndGray(img, heist_ocr->input_data, heist_ocr->i_dims[2], heist_ocr->i_dims[1]);

  
      TF_Tensor *image_tensor = TF_NewTensor(TF_FLOAT, heist_ocr->i_dims, heist_ocr->n_i_dim, heist_ocr->input_data, heist_ocr->n_i_data * sizeof(float), &NoOp, 0);

      if (image_tensor == NULL)
      {
         std::wstring tmp = L"ERROR: Allocating TF_NewTensor";
         wcsncpy(rvalue, tmp.c_str(), STR_SIZE);
      }
   
      TF_Tensor** input_values = new TF_Tensor*[1];
      TF_Tensor** output_values = new TF_Tensor*[1];
      input_values[0] = image_tensor;
      
      TF_SessionRun(heist_ocr->session,
                    NULL,
                    heist_ocr->input,
                    &image_tensor,
                    1,
                    heist_ocr->output,
                    output_values,
                    1,
                    NULL,
                    0,
                    NULL,
                    heist_ocr->status);
      
      if (TF_GetCode(heist_ocr->status) != TF_OK)
      {
         std::string message = TF_Message(heist_ocr->status);
         std::wstring tmp = L"SessionRun not ok" + std::wstring_convert<std::codecvt_utf8<wchar_t> >().from_bytes(message);
         wcsncpy(rvalue, tmp.c_str(), STR_SIZE);
      }
      else
      {
         float* result = (float*)TF_TensorData(output_values[0]);
         std::wstring tmp = CTCString(ToMaxString(result));
         wcsncpy(rvalue, tmp.c_str(), STR_SIZE);
      }
   }

   delete img;

   SelectObject(hdc_dest, hdc_old);

   DeleteDC(hdc_dest);
   ReleaseDC(NULL, hdc);
   
   DeleteObject(hbitmap);
   Gdiplus::GdiplusShutdown(gdiplusToken);
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
            std::wstring infl = L"-";
            if (this_item.find(L"influences") != this_item.end())
            {
               JSONObject influences = this_item[L"influences"]->AsObject();
               if (influences.find(L"hunter") != influences.end())
               {
                  infl += L"hunter ";
               }
               if (influences.find(L"elder") != influences.end())
               {
                  infl += L"elder ";
               }
               if (influences.find(L"warlord") != influences.end())
               {
                  infl += L"warlord ";
               }
               if (influences.find(L"shaper") != influences.end())
               {
                  infl += L"shaper ";
               }
               if (influences.find(L"redeemer") != influences.end())
               {
                  infl += L"redeemer ";
               }
               if (influences.find(L"crusader") != influences.end())
               {
                  infl += L"crusader ";
               }
            }
            infl = infl.substr(0, infl.size() - 1);
            std::wstring ench = L"-";
            if (this_item.find(L"enchantMods") != this_item.end())
            {
               JSONArray all_enchants = this_item[L"enchantMods"]->AsArray();
               for (unsigned int j = 0; j < all_enchants.size(); ++j)
               {
                  std::wstring enchant = all_enchants[j]->AsString();
                  if (enchant.find(L"Players in Area are") == 0)
                  {
                     ench += L"Deli[" + enchant.substr(20, 2) + L"] ";
                  }
                  if (enchant.find(L"Area contains a Blight Encounter") == 0)
                  {
                     ench += L"Blighted ";
                  }
               }
            }
            ench = ench.substr(0, ench.size() - 1);
            std::wstring key = type + infl + ench + L":" + ilvl;
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

/******************************************************************************/
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

/******************************************************************************/
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