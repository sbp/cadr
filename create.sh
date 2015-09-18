#!/bin/bash
# Create CADR

pushd $(dirname $0) > /dev/null
SCRIPT=$(pwd)/$(basename $0)
popd > /dev/null

echo Setting bash strict mode...
set -euo pipefail

echo Create a cadr directory and work in there
mkdir cadr
cd cadr

echo Cloning @joshuaeckroth/cadr
git clone https://github.com/joshuaeckroth/cadr .

echo Cleaning up the project
rm .gitignore
rm -rf .git/
rm -rf chaos/
mv usim/ src/

# We only need this for the cadr_*.bin files
echo Cloning @stevej/cadr_macos_port
git clone https://github.com/stevej/cadr_macos_port
cp cadr_macos_port/cadr_*.bin ./
tar -cf cadr.bin.tar cadr_*.bin
rm cadr_*.bin
rm -rf cadr_macos_port/

echo Working in ./src/
cd src/

echo Creating a Makefile.patch
cat > Makefile.patch <<EOF
--- a/Makefile	1970-01-01 00:00:00.000000000 +0000
+++ b/Makefile	2015-09-01 00:00:00.000000000 +0000
@@ -21,8 +21,8 @@
 DISPLAY = SDL
 #DISPLAY = X11
 
-#KEYBOARD = OLD
-KEYBOARD = NEW
+KEYBOARD = OLD
+#KEYBOARD = NEW
 
 #----------- code ------------
EOF

echo Applying the Makefile patch
patch -p1 < Makefile.patch

echo Working in ./
cd ..

echo Getting the disk image
wget http://www.unlambda.com/download/cadr/disks/disk-with-state.tgz
tar -zxvf disk-with-state.tgz
rm disk-with-state.tgz
rm usim.state
xz disk.img

echo Creating project information
echo 'all: ;' > Makefile
echo -e '\txz -d disk.img.xz' >> Makefile
echo -e '\ttar -xvf cadr.bin.tar' >> Makefile
echo -e '\tcd src && make' >> Makefile
echo -e '\tmv src/usim cadr' >> Makefile
cp $SCRIPT create.sh

cat > README.md <<EOF
# CADR Lisp Machine Simulator

This is a fork of the CADR simulator, originally [by Brad Parker][1] and as
modified [by Joshua Eckroth][2]. This fork contains the .img and .bin files
which are missing from Eckroth's version, and fixes a bug on OS X. The origin
of this project is documented in \`create.sh\`.

The simulator requires SDL and xz to build.

To make it go, run \`make\` followed by \`./cadr\`.

[1]: http://www.unlambda.com/cadr/
[2]: https://github.com/joshuaeckroth/cadr
EOF

git init
git add -A
git commit -m 'Created by create.sh'
