/**
 *  @file   get_pixman_version.cpp
 *  @author Masashi Kitamura (tenka@6809.net)
 *  @date   2019-02-17
 *  @license boost software license version 1.0
 */
#include <stdio.h>
#include <stdlib.h>

static int startsWith(char const* l, char const* r, char const** nextp) {
	size_t rlen = strlen(r);
	if (strncmp(l, r, rlen) == 0) {
		*nextp = l + rlen;
		return 1;
	}
	return 0;
}

int main(int argc, char* argv[])
{
	char* fname;
    char buf[ 0x10000 ];
    FILE* fp;
    char* p;
    size_t n;

    if (argc <= 1) {
        fprintf(stderr,"usage> get_pixman_version pixman/configure.ac\n");
        return 1;
	}
	fname = argv[1];
    fp = fopen(fname, "rt");
    if (!fp) {
		fprintf(stderr, "File open error : %s\n", fname);
        return 0;
    }
    p = NULL;
    while (fgets(buf, sizeof buf, fp) != NULL) {
		if (startsWith(buf, "m4_define([pixman_major],", &p)) {
			long n = strtol(p,NULL,10);
			printf("set PIXMAN_VERSION_MAJOR=%ld\n", n);
		}
		if (startsWith(buf, "m4_define([pixman_minor],", &p)) {
			long n = strtol(p,NULL,10);
			printf("set PIXMAN_VERSION_MINOR=%ld\n", n);
		}
		if (startsWith(buf, "m4_define([pixman_micro],", &p)) {
			long n = strtol(p,NULL,10);
			printf("set PIXMAN_VERSION_MICRO=%ld\n", n);
		}
	}
	fclose(fp);
    return 0;
}
