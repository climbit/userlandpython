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
zliburl=https://www.zlib.net/fossils/zlib-$zlibversion$zlibextension

# set python parameters
pyprefix="Python-"
pyextension=".tgz"
pypack=$path/$pyprefix$pyversion$pyextension
pyunpack=$path/$pyprefix$pyversion
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
mkdir $zlibprefix$zlibversion$zlib$zlibpostfix
cd $zlibprefix$zlibversion
./configure --prefix=$path/$zlibprefix$zlibversion$zlibpostfix | tee $path/$zlibprefix$zlibversion.log
make -j4 | tee -a $path/$zlibprefix$zlibversion.log && make -j4 install | tee -a $path/$zlibprefix$zlibversion.log


cd $path
########################
# Install python
########################
# download
wget -O $pypack $pyurl

# unpack
tar --gzip -C $path -xf $pypack

# install
mkdir $pyversion
cd $pyprefix$pyversion
./configure --enable-optimizations --prefix=$path/$pyversion --includedir=/home/daniel/Downloads/mytest/zlib-1.2.11-install/include/ --libdir=/home/daniel/Downloads/mytest/zlib-1.2.11-install/lib/ | tee $path/$pyprefix$pyversion.log
make -j4 | tee -a $path/$pyprefix$pyversion.log && make -j4 install | tee -a $path/$pyprefix$pyversion.log

# clean
cd $curdir
rm -r $pypack $pyunpack $zlibpack $zlibunpack
