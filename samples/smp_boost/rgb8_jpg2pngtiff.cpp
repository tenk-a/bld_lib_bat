#include <iostream>
#include <boost/gil/gil_all.hpp>
#include <boost/gil/extension/io/png_io.hpp>
#include <boost/gil/extension/io/jpeg_io.hpp>
#include <boost/gil/extension/io/tiff_io.hpp>
using namespace std;
using namespace boost;

int main(int argc, char* argv[])
{
	if (argc < 3) {
		printf("rgb8_jpg2pngtiff input.jpg output.png output.tif\n");
		return 0;
	}

	gil::rgb8_image_t src;
	gil::jpeg_read_image(argv[1], src);

	gil::png_write_view(argv[2], gil::view(src) );
	gil::tiff_write_view(argv[3], gil::view(src) );
	return 0;
}
