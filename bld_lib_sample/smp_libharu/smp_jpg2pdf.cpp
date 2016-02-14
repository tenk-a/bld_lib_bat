/**
 *	@file	smp_jpg2pdf.cpp
 *	@brief	jpg to pdf
 *	@author	tenka@6809.net
 */
#include <stdio.h>
#include <stdlib.h>
#include <setjmp.h>
#include <vector>
#include <string>
#include <hpdf.h>

#ifdef HPDF_DLL
#define CALLBACK_DECL  __stdcall
#else
#define CALLBACK_DECL
#endif

class Jpg2Pdf {
public:
	bool run(std::vector<std::string> const& jpgfiles, char const* outname) {
	    HPDF_Doc  	pdf = HPDF_New (&Jpg2Pdf::errorHandlerForHaru, NULL);
	    if (!pdf) {
	        printf ("error: cannot create PdfDoc object\n");
	        return false;
	    }
	    if (setjmp(s_jmp_buf_env)) {
	        HPDF_Free (pdf);
	        return false;
	    }
	    HPDF_SetCompressionMode (pdf, HPDF_COMP_ALL);
		for (size_t i = 0; i < jpgfiles.size(); ++i)
			addJpgPage(pdf, jpgfiles[i].c_str());
	    HPDF_SaveToFile (pdf, outname);
	    HPDF_Free (pdf);
	    return 0;
	}

private:
	bool addJpgPage(HPDF_Doc pdf, char const* jpgname) {
	    HPDF_Page 	page = HPDF_AddPage (pdf);
		if (!page)
			return false;
	    HPDF_Image	image	= HPDF_LoadJpegImageFromFile (pdf, jpgname);
		if (!image) {
			printf("load error %s\n", jpgname);
			return false;
		}
		HPDF_REAL img_w = HPDF_REAL(HPDF_Image_GetWidth(image));
		HPDF_REAL img_h = HPDF_REAL(HPDF_Image_GetHeight(image));
	    HPDF_Page_SetWidth (page, img_w);
	    HPDF_Page_SetHeight(page, img_h);
	    HPDF_Page_DrawImage (page, image, 0, 0, img_w, img_h);
		return true;
	}

	static void CALLBACK_DECL errorHandlerForHaru(HPDF_STATUS   error_no, HPDF_STATUS   detail_no, void *user_data) {
	    printf ("ERROR: error_no=%04X, detail_no=%u\n", (HPDF_UINT)error_no, (HPDF_UINT)detail_no);
	    longjmp(s_jmp_buf_env, 1);
	}

private:
	static jmp_buf s_jmp_buf_env;
};

jmp_buf 	Jpg2Pdf::s_jmp_buf_env;

static int usage() {
	printf("jpg2pdf -oOUTPUT.pdf jpgfile(s)...\n");
	return 1;
}

int main (int argc, char *argv[]) {
	if (argc < 1)
		return usage();
	std::vector<std::string> jpgfiles;
	std::string outname;
	jpgfiles.reserve(1000);
	for (int i = 1; i < argc; ++i) {
		char* p = argv[i];
		if (*p == '-') {
			switch (*++p) {
			case 'o':
				if (*++p)
					outname = p;
				break;
			default:
				return usage();
			}
		} else {
			jpgfiles.push_back(p);
		}
	}
	if (jpgfiles.empty())
		return 0;
	if (outname.empty())
		outname = "a.pdf";
	Jpg2Pdf	jpg2pdf;
	return jpg2pdf.run(jpgfiles, outname.c_str()) == false;
}
