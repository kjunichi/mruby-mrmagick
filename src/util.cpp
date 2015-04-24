#include <Magick++.h> 
#include <iostream> 
using namespace std; 
using namespace Magick;

extern "C" void myputs() {
	cout <<"Hello, mruby!"<<endl;
}

extern "C" void scale(const char *srcPath,const char *destPath, const char *ratio) {
	InitializeMagick("./mruby");
	Image image;
	image.read(srcPath);
	// calc geom.
	image.scale(ratio);
	image.write(destPath);
}
