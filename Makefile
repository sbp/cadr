all: ;
	xz -d disk.img.xz
	tar -xvf cadr.bin.tar
	cd src && make
	mv src/usim cadr
