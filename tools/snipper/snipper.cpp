//#import "snipper.h"

#include <windows.h>
#include <wingdi.h>
#include <gdiplus.h>
#include <gdiplusheaders.h>
#include <gdiplusimaging.h>
#include <gdiplusimagecodec.h>
#include <iostream>


#define DLLEXPORT __declspec(dllexport)

extern "C" DLLEXPORT void snipAndSave(int x, int y, int w, int h, const WCHAR *file_name);

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

void main()
{
    std::cout << "testing" << std::endl;
}