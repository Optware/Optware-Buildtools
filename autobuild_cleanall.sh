#!/bin/bash
#--------------------------------------
# Script to clean one package (or all packages) for optware
# Initially updates the svn from trunk
# 
# by Sebastian Ulmer
#
#--------------------------------------
#  Initially: 
#    Change the 'optware_folder' to point to a directory name you want to have. 
#    Directory will be created. If changed from default, it needs to be changed in all scripts
#  Usage: 
#   ./autoclean_all.sh    -> attempts to remove all file for all plattforms
#--------------------------------------
export OPTWARE_TARGET="nslu2"

# Folder for optware
optware_folder="optware"

#TARGETS="ddwrt ds101 nslu2 ds101 ds101g syno-x07 openwrt-brcm24 sheevaplug wdtv slugos6be syno1142ppc824x "
#ls platforms/ | grep packages | sed -e 's/packages-//' | sed -e 's/.mk//'

#first get reference platform for platform list
i="default"
export OPTWARE_TARGET=$i
[ -d ~/$optware_folder/$i ] || mkdir -p ~/$optware_folder/$i
[ ! -h ~/$optware_folder/$i/downloads ] && rm -fR ~/$optware_folder/$i/downloads && ln -s ~/$optware_folder/downloads ~/$optware_folder/$i/downloads
cd ~/$optware_folder/$i

git clone https://github.com/Optware/Optware ~/$optware_folder/$i

TARGETS=`ls ~/$optware_folder/default/platforms/ | grep packages | sed -e 's/packages-//' | sed -e 's/.mk//'`


for i in $TARGETS
do
{
   echo "cleaning ... ~/$optware_folder/$i "
   [ -d ~/$optware_folder/builddir/$i ]&& echo "cleaning ... ~/$optware_folder/$i " && rm -rf ~/$optware_folder/builddir/$i
   [ -e ~/$optware_folder/make_$i.log ] && rm ~/$optware_folder/make_$i.log
}
done


