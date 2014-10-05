#!/bin/bash
#--------------------------------------
# Script to build one package (or all packages) for optware
# Initially updates the local Git repro from GitHub 
#
# by Sebastian Ulmer
#
#--------------------------------------
#  Initially: 
#    Change the 'optware_folder' to point to a directory name you want to have. 
#    Directory will be created. If changed from default, it needs to be changed in all scripts
#  Usage: 
#   ./autobuild_all.sh all   -> attempts to build all packages for all platforms
#   ./autobuild_all.sh samba -> attempts to build the samba package for all platforms
#--------------------------------------

# Folder for optware
optware_folder="optware/optware"

#first get reference platform for platform list, actual platforms refer to this
i="default"
export OPTWARE_TARGET=$i
# if local git repro folder already exists, assume optware repo is there and update
# else clone the optware repro locally
if [ -d ~/$optware_folder/$i ]; then
   cd ~/$optware_folder/$i && git pull
else
 git clone https://github.com/Optware/Optware ~/$optware_folder/$i
fi
# local folders n onot need to be created, git will do this for you
#[ -d ~/$optware_folder/$i ] || mkdir -p ~/$optware_folder/$i
# create folder to store downloaded files
[ -d ~/$optware_folder/downloads ] || mkdir -p ~/$optware_folder/downloads
# delete any individual download folders if not a symlink
# symlink plattform individual folders to main download folders to save storage
[ ! -h ~/$optware_folder/$i/downloads ] && rm -fR ~/$optware_folder/$i/downloads && ln -s ~/$optware_folder/downloads ~/$optware_folder/$i/downloads
cd ~/$optware_folder/$i


# download some sources fron nslu server as auto download fails
[ -e ~/$optware_folder/downloads/binutils-2.17.50.0.8.tar.bz2 ] || wget -O ~/$optware_folder/downloads/binutils-2.17.50.0.8.tar.bz2 http://ftp.osuosl.org/pub/nslu2/sources/binutils-2.17.50.0.8.tar.bz2
[ -e ~/$optware_folder/downloads/binutils-2.15.94.0.2.tar.bz2 ] || wget -O ~/$optware_folder/downloads/binutils-2.15.94.0.2.tar.bz2 http://ftp.osuosl.org/pub/nslu2/sources/binutils-2.15.94.0.2.tar.bz2
[ -e ~/$optware_folder/downloads/gdb-6.5.tar.bz2 ] || wget -O ~/$optware_folder/downloads/gdb-6.5.tar.bz2 http://ftp.osuosl.org/pub/nslu2/sources/gdb-6.5.tar.bz2
[ -e ~/$optware_folder/downloads/binutils-2.17.tar.bz2 ] ||  wget -O ~/$optware_folder/downloads/binutils-2.17.tar.bz2 http://ftp.osuosl.org/pub/nslu2/sources/binutils-2.17.tar.bz2
#missing source for dns323, conversion to tar.bz2 needed
[ -e ~/$optware_folder/downloads/binutils-2.14.90.0.7.tar.bz2 ] ||wget -O ~/$optware_folder/downloads/binutils-2.14.90.0.7.tar.gz ftp://ftp.kernel.org/pub/linux/devel/binutils/binutils-2.14.90.0.7.tar.gz && cd ~/$optware_folder/downloads/ && gunzip binutils-2.14.90.0.7.tar.gz && bzip2 binutils-2.14.90.0.7.tar
[ -e ~/$optware_folder/downloads/gcc-3.4.5.tar.bz2 ] || wget -O ~/$optware_folder/downloads/gcc-3.4.5.tar.bz2 http://ftp.osuosl.org/pub/nslu2/sources/gcc-3.4.5.tar.bz2
[ -e ~/$optware_folder/downloads/pxaregs-1.14.tar.bz ] || wget -O ~/$optware_folder/downloads/pxaregs-1.14.tar.bz http://ftp.osuosl.org/pub/nslu2/sources/pxaregs-1.14.tar.bz

#get target list, overwrite for individual target
TARGETS=`ls ~/$optware_folder/default/platforms/ | grep packages | sed -e 's/packages-//' | sed -e 's/.mk//'`

#build package for every target
for i in $TARGETS
do
{
   export OPTWARE_TARGET=$i
   [ -d ~/$optware_folder/builddir/$i ] || mkdir -p ~/$optware_folder/builddir/$i
   # symlink the download dir, so that sources are only downloaded once
   [ ! -h ~/$optware_folder/builddir/$i/downloads ] && rm -fR ~/$optware_folder/builddir/$i/downloads && ln -s ~/$optware_folder/downloads ~/$optware_folder/builddir/$i/downloads
   cd ~/$optware_folder/builddir/$i
   cp ~/$optware_folder/default ~/$optware_folder/builddir/$i
   # make symlinks to refecence checkout dir, symlinks save space
   for j in make platforms scripts sources Makefile AUTHORS README
   do
      [ ! -h ~/$optware_folder/builddir/$i/$j ] && ln -s ~/$optware_folder/default/$j ~/$optware_folder/builddir/$i/$j
   done
   # some targets have problems with autobuilding directories
   # so trigger manually
   [ -d ~/$optware_folder/builddir/$i/builds ] ||  make directories
   #build packacke, ipk and check ipk
   make $1
   make $1-ipk
   make $1-check
} &> ~/$optware_folder/make_$i.log
done



