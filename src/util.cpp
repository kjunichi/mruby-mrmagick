#include <Magick++.h>
#include <iostream>
using namespace std;
using namespace Magick;

static bool gMagickInitFlg=false;

void myInitializeMagick() {
	if(!gMagickInitFlg) {
		InitializeMagick("./mruby");
		gMagickInitFlg=true;
	}
}

extern "C" void myputs() {
	cout <<"Hello, mruby!"<<endl;
}

extern "C" void scale(const char *srcPath,const char *destPath, const char *ratio) {
	myInitializeMagick();
	Image image;
	image.read(srcPath);
	// calc geom.
	image.scale(ratio);
	image.write(destPath);
}

extern "C" void blur(const char *srcPath,const char *destPath,
	const double radius, const double sigma) {
	myInitializeMagick();
	Image image;
	image.read(srcPath);
	// calc geom.
	cout<<radius<<","<<sigma<<endl;
	image.blur(radius, sigma);
	image.write(destPath);
}
