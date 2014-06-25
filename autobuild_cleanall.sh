#!/bin/bash

export OPTWARE_TARGET="nslu2"

#TARGETS="ddwrt ds101 nslu2 ds101 ds101g syno-x07 openwrt-brcm24 sheevaplug wdtv slugos6be syno1142ppc824x "
#ls platforms/ | grep packages | sed -e 's/packages-//' | sed -e 's/.mk//'

#first get reference platform for platform list
i="default"
export OPTWARE_TARGET=$i
[ -d ~/optware/$i ] || mkdir -p ~/optware/$i
[ ! -h ~/optware/$i/downloads ] && rm -fR ~/optware/$i/downloads && ln -s ~/optware/downloads ~/optware/$i/downloads
cd ~/optware/$i
svn co https://svn.nslu2-linux.org/svnroot/optware/trunk ~/optware/$i

TARGETS=`ls ~/optware/default/platforms/ | grep packages | sed -e 's/packages-//' | sed -e 's/.mk//'`


for i in $TARGETS
do
{
   #echo "cleaning ... ~/optware/$i "
   [ -d ~/optware/builddir/$i ]&& echo "cleaning ... ~/optware/$i " && rm -rf ~/optware/builddir/$i
   [ -e ~/optware/make_$i.log ] && rm ~/optware/make_$i.log
}
done



