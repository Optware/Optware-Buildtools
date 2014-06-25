#!/bin/bash

export OPTWARE_TARGET="nslu2"

#TARGETS="ddwrt ds101 nslu2 ds101 ds101g syno-x07 openwrt-brcm24 sheevaplug wdtv slugos6be syno1142ppc824x "
i=$1
svn co http://svn.nslu2-linux.org/svnroot/optware/trunk ~/optware/default

#for i in $TARGETS
#do
{
   export OPTWARE_TARGET=$i
   [ -d ~/optware/builddir/$i ] || mkdir -p ~/optware/builddir/$i
   [ ! -h ~/optware/builddir/$i/downloads ] && rm -fR ~/optware/builddir/$i/downloads && ln -s ~/optware/downloads ~/optware/builddir/$i/downloads
   cd ~/optware/builddir/$i
   for j in make platforms scripts sources Makefile AUTHORS README
   do
      [ ! -h ~/optware/builddir/$i/$j ] && ln -s ~/optware/default/$j ~/optware/builddir/$i/$j
   done
   #svn co https://svn.nslu2-linux.org/svnroot/optware/trunk ~/optware/$i
   make $2
   make $2-ipk
   make $2-check
} &> ~/optware/make_$i.log
#done

