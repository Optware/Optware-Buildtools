#!/bin/bash


#first get reference platform for platform list, atuall platform refer to this
i="default"
export OPTWARE_TARGET=$i
[ -d ~/optware/$i ] || mkdir -p ~/optware/$i
[ -d ~/optware/downloads ] || mkdir -p ~/optware/downloads
[ ! -h ~/optware/$i/downloads ] && rm -fR ~/optware/$i/downloads && ln -s ~/optware/downloads ~/optware/$i/downloads
cd ~/optware/$i
svn co http://svn.nslu2-linux.org/svnroot/optware/trunk ~/optware/$i

# download some sources fron nslu server as auto download fails
[ -e ~/optware/downloads/binutils-2.17.50.0.8.tar.bz2 ] || wget -O ~/optware/downloads/binutils-2.17.50.0.8.tar.bz2 http://ftp.osuosl.org/pub/nslu2/sources/binutils-2.17.50.0.8.tar.bz2
[ -e ~/optware/downloads/binutils-2.15.94.0.2.tar.bz2 ] || wget -O ~/optware/downloads/binutils-2.15.94.0.2.tar.bz2 http://ftp.osuosl.org/pub/nslu2/sources/binutils-2.15.94.0.2.tar.bz2
[ -e ~/optware/downloads/gdb-6.5.tar.bz2 ] || wget -O ~/optware/downloads/gdb-6.5.tar.bz2 http://ftp.osuosl.org/pub/nslu2/sources/gdb-6.5.tar.bz2
[ -e ~/optware/downloads/binutils-2.17.tar.bz2 ] ||  wget -O ~/optware/downloads/binutils-2.17.tar.bz2 http://ftp.osuosl.org/pub/nslu2/sources/binutils-2.17.tar.bz2
#missing source for dns323, conversion to tar.bz2 needed
[ -e ~/optware/downloads/binutils-2.14.90.0.7.tar.bz2 ] ||wget -O ~/optware/downloads/binutils-2.14.90.0.7.tar.gz ftp://ftp.kernel.org/pub/linux/devel/binutils/binutils-2.14.90.0.7.tar.gz && cd ~/optware/downloads/ && gunzip binutils-2.14.90.0.7.tar.gz && bzip2 binutils-2.14.90.0.7.tar
[ -e ~/optware/downloads/gcc-3.4.5.tar.bz2 ] || wget -O ~/optware/downloads/gcc-3.4.5.tar.bz2 http://ftp.osuosl.org/pub/nslu2/sources/gcc-3.4.5.tar.bz2
[ -e ~/optware/downloads/pxaregs-1.14.tar.bz ] || wget -O ~/optware/downloads/pxaregs-1.14.tar.bz http://ftp.osuosl.org/pub/nslu2/sources/pxaregs-1.14.tar.bz

#get target list, overwrite for individual target
TARGETS=`ls ~/optware/default/platforms/ | grep packages | sed -e 's/packages-//' | sed -e 's/.mk//'`

#build package for every target
for i in $TARGETS
do
{
   export OPTWARE_TARGET=$i
   [ -d ~/optware/builddir/$i ] || mkdir -p ~/optware/builddir/$i
   # symlink the download dir, so that sources are only downloaded once
   [ ! -h ~/optware/builddir/$i/downloads ] && rm -fR ~/optware/builddir/$i/downloads && ln -s ~/optware/downloads ~/optware/builddir/$i/downloads
   cd ~/optware/builddir/$i
   cp ~/optware/default ~/optware/builddir/$i
   # make symlinks to refecence checkout dir, symlinks save space
   for j in make platforms scripts sources Makefile AUTHORS README
   do
      [ ! -h ~/optware/builddir/$i/$j ] && ln -s ~/optware/default/$j ~/optware/builddir/$i/$j
   done
   # some targets have problems with autobuilding directories
   # so trigger manually
   [ -d ~/optware/builddir/$i/builds ] ||  make directories
   #build packacke, ipk and check ipk
   make $1
   make $1-ipk
   make $1-check
} &> ~/optware/make_$i.log
done


