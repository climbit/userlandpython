#!/bin/sh


myhelp() {
   echo userlandpython PATH VERSION
   echo
   echo PATH: The path to the install directory
   echo VERSION: the python version to install
   echo
   echo Check available versions: https://www.python.org/ftp/python/
}

########################
# Check input
########################
# throw help if necessary
if [ -z $1 ]
then
   myhelp
   exit
fi

if [ -z $2 ]
then
   myhelp
   exit
fi


########################
# configuration
########################
# set general parameters
curdir=$(pwd)
path=$1
pyversion=$2
zlibversion=$3

# set zlib parameters
zlibprefix="zlib-"
zlibpostfix="-install"
zlibextension=".tar.gz"
zlibpack=$path/$zlibprefix$zlibversion$zlibextension
zlibunpack=$path/$zlibprefix$zlibversion
zlibinstall=$path/$zlibprefix$zlibversion$zlibpostfix
zliburl=https://www.zlib.net/fossils/zlib-$zlibversion$zlibextension

# set python parameters
pyprefix="Python-"
pyextension=".tgz"
pypack=$path/$pyprefix$pyversion$pyextension
pyunpack=$path/$pyprefix$pyversion
pyinstall=$path/$pyversion
pyurl=https://www.python.org/ftp/python/$pyversion/$pyprefix$pyversion$pyextension


# change directory
cd $path

# check if already installed




########################
# Install zlib
########################
# download
wget -O $zlibpack $zliburl

# unpack
tar --gzip -C $path -xf $zlibpack

# install
mkdir $zlibinstall
cd $zlibunpack
./configure --prefix=$zlibinstall | tee $zlibunpack.log
make -j4 | tee -a $zlibunpack.log && make -j4 install | tee -a $zlibunpack.log


cd $path
########################
# Install python
########################
# download
wget -O $pypack $pyurl

# unpack
tar --gzip -C $path -xf $pypack

# install
mkdir $pyinstall
cd $pyunpack
./configure --enable-optimizations --prefix=$pyinstall --includedir=$zlibinstall/include --libdir=$zlibinstall/lib | tee $pyunpack.log
make -j4 | tee -a $pyunpack.log && make -j4 install | tee -a $pyunpack.log

# clean
cd $curdir
rm -r $pypack $pyunpack $zlibpack $zlibunpack $zlibinstall
