#!/bin/sh


usage() {
   echo userlandpython -p PATH -y PYVERSION -z ZVERSION
   echo
   echo PATH: The path to the install directory
   echo PYVERSION: The python version to install
   echo ZVERSION: The zlib version to install
   echo
   echo "Check for available python versions: https://www.python.org/ftp/python"
   echo "Check for available glibc versions: https://ftp.gnu.org/gnu/glibc"
   echo "Check for available zlib versions: https://www.zlib.net/fossils"
}

################################################
# Check input and throw help if necessary
################################################
# parse input
while getopts p:y:z:c: inarg
do
    case $inarg in
        p)
            path=$OPTARG;;
        y)
            pyversion=$OPTARG;;
        z)
            zlibversion=$OPTARG;;
        c)
            glibcversion=$OPTARG;;
    esac
done

# handle mandatory arguments and
# set defaults if neccessary
if [ -z $path ]
then 
    usage
    exit
fi

if [ -z $pyversion ]
then
    pyversion=3.7.5
fi

if [ -z $zlibversion ]
then
    zlibversion=1.2.11
fi

if [ -z $gawkversion ]
then
    gawkversion=4.2.1
fi

if [ -z $bisonversion ]
then
    bisonversion=3.4
fi

if [ -z $glibcversion ]
then
    glibcversion=2.30
fi

########################
# configuration
########################
# change directory
curdir=$(pwd)
cd $path

# check if already installed




########################
# build zlib
########################
# go to base path
cd $path

# set zlib parameters
zlibprefix="zlib-"
zlibpostfix="-build"
zlibextension=".tar.gz"
zlibpack=$path/$zlibprefix$zlibversion$zlibextension
zlibunpack=$path/$zlibprefix$zlibversion
zlibbuild=$path/$zlibprefix$zlibversion$zlibpostfix
zliburl=https://www.zlib.net/fossils/zlib-$zlibversion$zlibextension

# download
wget -O $zlibpack $zliburl

# unpack
tar --gzip -C $path -xf $zlibpack

# build
#mkdir $zlibbuild
cd $zlibunpack
./configure --prefix=$zlibbuild | tee $zlibunpack.log
make -j4 | tee -a $zlibunpack.log && make -j4 install | tee -a $zlibunpack.log

########################
# build gawk
########################
# go to base path
cd $path

# set gawk parameters
gawkprefix="gawk-"
gawkpostfix="-build"
gawkextension=".tar.gz"
gawkpack=$path/$gawkprefix$gawkversion$gawkextension
gawkunpack=$path/$gawkprefix$gawkversion
gawkbuild=$path/$gawkprefix$gawkversion$gawkpostfix
gawkurl=https://ftp.gnu.org/gnu/gawk/$gawkprefix$gawkversion$gawkextension

# download
wget -O $gawkpack $gawkurl

# unpack
tar --gzip -C $path -xf $gawkpack

# build
mkdir $gawkbuild
cd $gawkbuild
export CFLAGS=
export LDFLAGS=
export LIBS=
$gawkunpack/configure --prefix=$gawkbuild | tee $gawkunpack.log
make -j4 | tee -a $gawkunpack.log && make -j4 install | tee -a $gawkunpack.log

export PATH=$gawkbuild/bin:$PATH


########################
# build bison
########################
# go to base path
cd $path

# set bison parameters
bisonprefix="bison-"
bisonpostfix="-build"
bisonextension=".tar.gz"
bisonpack=$path/$bisonprefix$bisonversion$bisonextension
bisonunpack=$path/$bisonprefix$bisonversion
bisonbuild=$path/$bisonprefix$bisonversion$bisonpostfix
bisonurl=https://ftp.gnu.org/gnu/bison/$bisonprefix$bisonversion$bisonextension

# download
wget -O $bisonpack $bisonurl

# unpack
tar --gzip -C $path -xf $bisonpack

# build
mkdir $bisonbuild
cd $bisonbuild
export CFLAGS=
export LDFLAGS=
export LIBS=
$bisonunpack/configure --prefix=$bisonbuild | tee $bisonunpack.log
make -j4 | tee -a $bisonunpack.log && make -j4 install | tee -a $bisonunpack.log



########################
# build glibc
########################
# go to base path
cd $path

# set glibc parameters
glibcprefix="glibc-"
glibcpostfix="-build"
glibcextension=".tar.gz"
glibcpack=$path/$glibcprefix$glibcversion$glibcextension
glibcunpack=$path/$glibcprefix$glibcversion
glibcbuild=$path/$glibcprefix$glibcversion$glibcpostfix
glibcurl=https://ftp.gnu.org/gnu/glibc/$glibcprefix$glibcversion$glibcextension

# download
wget -O $glibcpack $glibcurl

# unpack
tar --gzip -C $path -xf $glibcpack

# build
mkdir $glibcbuild
cd $glibcbuild
export CFLAGS=-I$bisonbuild/include
export LDFLAGS=-L$bisonbuild/lib
export LIBS=
$glibcunpack/configure --prefix=$glibcbuild | tee $glibcunpack.log
make -j4 | tee -a $glibcunpack.log && make -j4 install | tee -a $glibcunpack.log


echo 'sh userlandpython.sh -p /home/daniel/Downloads/mytest'
exit

########################
# build python
########################
# go to base path
cd $path

# set python parameters
pyprefix="Python-"
pyextension=".tgz"
pypack=$path/$pyprefix$pyversion$pyextension
pyunpack=$path/$pyprefix$pyversion
pybuild=$path/$pyversion
pyurl=https://www.python.org/ftp/python/$pyversion/$pyprefix$pyversion$pyextension

# download
wget -O $pypack $pyurl

# unpack
tar --gzip -C $path -xf $pypack

# copy libs
#mkdir $pyunpack/Include/zlib
#cp -r $zlibbuild/include/* $pyunpack/Include/zlib
#mkdir $pyunpack/Lib/zlib
#cp -r $zlibbuild/lib/* $pyunpack/Lib/zlib

# build
mkdir $pybuild
cd $pyunpack
export CFLAGS=-I$zlibbuild/include
export LDFLAGS=-L$zlibbuild/lib
export LIBS=-lz
./configure --enable-optimizations --prefix=$pybuild --includedir=$zlibbuild/include --libdir=$zlibbuild/lib | tee $pyunpack.log
#./configure --enable-optimizations --prefix=$pybuild | tee $pyunpack.log
make -j4 | tee -a $pyunpack.log && make -j4 install | tee -a $pyunpack.log

# clean
cd $curdir
#rm -r $pypack $pyunpack $zlibpack $zlibunpack $zlibbuild
