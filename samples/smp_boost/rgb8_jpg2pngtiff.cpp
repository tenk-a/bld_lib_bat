#include <fstream>
#include <iostream>
#include <boost/gil/gil_all.hpp>
#if 1
#include <boost/gil/extension/io/png.hpp>
#include <boost/gil/extension/io/jpeg.hpp>
#include <boost/gil/extension/io/tiff.hpp>
using namespace std;
using namespace boost;

void jpeg_read_image(char const* fname, gil::rgb8_image_t& image)
{
	std::ifstream stream(fname, std::ios::binary);
	boost::gil::image_read_settings<boost::gil::jpeg_tag> read_settings;
	boost::gil::read_image(stream, image, read_settings);
}

void png_write_image(char const* fname, gil::rgb8_image_t& image)
{
	std::ofstream stream(fname, std::ios::binary);
	gil::write_view(stream, gil::const_view(image),gil::png_tag() );
}

void tiff_write_image(char const* fname, gil::rgb8_image_t& image)
{
	std::ofstream stream(fname, std::ios::binary);
	gil::write_view(stream, gil::const_view(image),gil::tiff_tag() );
}

int main(int argc, char* argv[])
{
	if (argc < 3) {
		printf("rgb8_jpg2pngtiff input.jpg output.png output.tif\n");
		return 0;
	}

	gil::rgb8_image_t img;
	jpeg_read_image(argv[1], img);
	png_write_image(argv[2], img );
	tiff_write_image(argv[3], img );

	return 0;
}

#else
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
#endif
