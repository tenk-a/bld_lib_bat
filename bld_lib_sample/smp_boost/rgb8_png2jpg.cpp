#include <iostream>
#include <boost/gil/gil_all.hpp>
#include <boost/gil/extension/io/png_io.hpp>
#include <boost/gil/extension/io/jpeg_io.hpp>
using namespace std;
using namespace boost;

int main(int argc, char* argv[])
{
	if (argc < 2) {
		printf("rgb8_png2jpg input.png output.jpg\n");
		return 0;
	}

	// pngファイル読み込み
	gil::rgb8_image_t src;
	gil::png_read_image(argv[1], src);

	// pngファイル書き込み
	gil::jpeg_write_view(argv[2], gil::view(src) );
	return 0;
}
