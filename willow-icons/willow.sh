#!/usr/bin/env bash



readonly ICONPACK_FOLDER_LIGHT="willow-icons-light"
readonly ICONPACK_FOLDER_DARK="willow-icons-dark"

readonly FLUENT_TARGET="src"

readonly WILLOW_SOURCE="willow-src"

#set target folder to light first
ICONPACK_FOLDER="$ICONPACK_FOLDER_LIGHT"
ICONPACK_COLOR="Light"

#make willow light by copying over everything
#copy over blank theme file
#copy that to a willow dark
#change name of willow light, change papirus dependency to be light
#change name of willow dark, change papirus dependency to be dark

function generateTarget {

#clean and make iconpack from scratch
rm -r "$ICONPACK_FOLDER"
mkdir "$ICONPACK_FOLDER"

#transfer svgs to new iconpack
while read DIRECTORY
do
    mkdir $ICONPACK_FOLDER/$DIRECTORY/
    cp -ar src/$DIRECTORY/actions $ICONPACK_FOLDER/$DIRECTORY/
done < directoryList.txt

#transfer links for identical icons to new iconpack
while read DIRECTORY
do
    cp -ar links/$DIRECTORY/actions $ICONPACK_FOLDER/$DIRECTORY/
done < directoryList.txt

#remove problematic icons so Papirus can be inherited properly
while read DIRECTORY
do
    while read ICON
    do
        rm $ICONPACK_FOLDER/$DIRECTORY/actions/$ICON
    done < removeList.txt
done < directoryList.txt

#copy over willow's icons to new pack
while read DIRECTORY
do
    cp -ar $WILLOW_SOURCE/* $ICONPACK_FOLDER
done < directoryList.txt

#copy over willow's theme file to inherit Papirus
cp -ar $WILLOW_SOURCE/index.theme $ICONPACK_FOLDER

}

generateTarget

#clean and make iconpack from scratch
rm -r "$ICONPACK_FOLDER_DARK"
mkdir "$ICONPACK_FOLDER_DARK"
cp -ar "$ICONPACK_FOLDER"/* "$ICONPACK_FOLDER_DARK"

#Update theme color name and papirus dependency suffix for light version
sed -i "s/%COLOR%/${ICONPACK_COLOR//-/ }/g"                                         "${ICONPACK_FOLDER_LIGHT}/index.theme"


#Switch dark to be target folder
ICONPACK_FOLDER=$ICONPACK_FOLDER_DARK
ICONPACK_COLOR="Dark"
#Update dark versions colors in theme
sed -i "s/%COLOR%/${ICONPACK_COLOR//-/ }/g"                                         "${ICONPACK_FOLDER_DARK}/index.theme"
# generateTarget

#Update dark versions icons in theme
sed -i "s/#363636/#dedede/g" "${ICONPACK_FOLDER}"/{16,22,24,32}/actions/*.svg
sed -i "s/#363636/#dedede/g" "${ICONPACK_FOLDER}"/{16,22,24}/{places,devices}/*.svg
sed -i "s/#363636/#dedede/g" "${ICONPACK_FOLDER}"/symbolic/{actions,apps,categories,devices,emblems,emotes,mimetypes,places,status}/*.svg


exit

#clean and make iconpack from scratch
rm -r $ICONPACK_FOLDER
mkdir $ICONPACK_FOLDER

#transfer svgs to new iconpack
while read DIRECTORY
do
    mkdir $ICONPACK_FOLDER/$DIRECTORY/
    cp -ar src/$DIRECTORY/actions $ICONPACK_FOLDER/$DIRECTORY/
done < directoryList.txt

#transfer links for identical icons to new iconpack
while read DIRECTORY
do
    cp -ar links/$DIRECTORY/actions $ICONPACK_FOLDER/$DIRECTORY/
done < directoryList.txt

#remove problematic icons so Papirus can be inherited properly
while read DIRECTORY
do
    while read ICON
    do
        rm $ICONPACK_FOLDER/$DIRECTORY/actions/$ICON
    done < removeList.txt
done < directoryList.txt

#copy over willow's icons to new pack
while read DIRECTORY
do
    cp -ar $WILLOW_SOURCE/* $ICONPACK_FOLDER
done < directoryList.txt

#copy over willow's theme file to inherit Papirus
cp -ar $WILLOW_SOURCE/index.theme $ICONPACK_FOLDER

# cp -ar links/* willow-icons
#
# cp -r 22/* willow-icons/22/actions
#
# cp -r 22-optional-thin-arrows/* willow-icons/22/actions
#
# cp index.theme willow-icons
