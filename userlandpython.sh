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
    #pyversion=3.7.5
    pyversion=3.7.2
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
    #bisonversion=3.4.2
    bisonversion=3.3.2
fi

if [ -z $glibcversion ]
then
    #glibcversion=2.30
    glibcversion=2.29
fi

########################
# configuration
########################
# change directory
curdir=$(pwd)
cd $path

# check if already installed



for libname in "zlib" "gawk" "bison" "glibc"
do
    echo
    echo
    echo
    echo "##################################"
    echo "# Build $libname"
    echo "##################################"
    echo
    echo
    echo
    
    # go to base path
    cd $path

    # set lib parameters
    if [ $libname = "zlib" ]
    then
        libversion=$zlibversion
    elif [ $libname = "gawk" ]
    then
        libversion=$gawkversion
    elif [ $libname = "bison" ]
    then
        libversion=$bisonversion
    elif  [ $libname = "glibc" ]
    then
        libversion=$glibcversion
    fi
    libprefix="$libname-"
    libpostfix="-build"
    libextension=".tar.gz"
    libpack=$path/$libprefix$libversion$libextension
    libunpack=$path/$libprefix$libversion
    libbuild=$path/$libprefix$libversion$libpostfix
    if [ $libname = "zlib" ]
    then
        liburl=https://www.$libname.net/fossils/$libprefix$libversion$libextension
    elif [ $libname = "gawk" ] || [ $libname = "bison" ] || [ $libname = "glibc" ]
    then
        liburl=https://ftp.gnu.org/gnu/$libname/$libprefix$libversion$libextension
    fi

    # download
    wget -O $libpack $liburl

    # unpack
    tar --gzip -C $path -xf $libpack

    # build
    if [ $libname = "zlib" ] || [ $libname = "gawk" ] || [ $libname = "bison" ]
    then
        export CFLAGS="-O3"
        export LDFLAGS=
        export LIBS=
    elif [ $libname = "glibc" ]
    then
        export CFLAGS="-O3 -I$path/build/include"
        export LDFLAGS="-L$path/build/lib"
        export LIBS=
    fi
    mkdir $libbuild
    cd $libbuild
    #if [ $libname = "zlib" ]
    #then
    #    $libunpack/configure --prefix=$libbuild --eprefix=$path/build | tee $libunpack.log
    #else
    #    $libunpack/configure --prefix=$libbuild --exec-prefix=$path/build | tee $libunpack.log
    #fi
    $libunpack/configure --prefix=$path/build | tee $libunpack.log
    make -j4 | tee -a $libunpack.log && make -j4 install | tee -a $libunpack.log
    
    if [ $libname = "gawk" ] || [ $libname = "bison" ]
    then
        #export PATH=$libbuild/bin:$PATH
        export PATH=$path/build/bin:$PATH
    fi
    echo $PATH
    
    
    
    echo
    echo
    echo
    echo "##################################"
    echo "# Finished $libname"
    echo "##################################"
    echo
    echo
    echo
done


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

# build
#mkdir $pybuild
cd $pyunpack
export CFLAGS="-Wl,--rpath=$path/build/lib,--dynamic-linker=$path/build/lib/ld-linux-x86-64.so.2 -I$path/build/include"
export LDFLAGS="-L$path/build/lib"
#export LDFLAGS="--rpath=$path/build/lib --dynamic-linker=$path/build/lib/ld-linux-x86-64.so.2 -L$path/build/lib"
export LIBS="-lz"
#./configure --enable-optimizations --prefix=$pybuild \
#    --includedir=$path/zlib-$zlibversion-build/include \
#    --libdir=$path/zlib-$zlibversion-build/lib | tee $pyunpack.log
./configure --prefix=$pybuild \
    --includedir=$path/build/include \
    --libdir=$path/build/lib | tee $pyunpack.log
make -j4 | tee -a $pyunpack.log && make -j4 install | tee -a $pyunpack.log

# clean
cd $curdir
#rm -r $pypack $pyunpack $zlibpack $zlibunpack $zlibbuild
echo "sh userlandpython.sh -p /home/daniel/Downloads/mytest"

