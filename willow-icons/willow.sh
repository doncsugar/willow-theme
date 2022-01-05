#!/usr/bin/env bash

#load in desired directories of icon resolutions e.g. 16, 22, 32, 64
mapfile -t ICON_DIRECTORIES < "directoryList.txt"

#load in list of undesired icons e.g. prevent theme from inheriting Papirus
mapfile -t BANNED_ICONS < "removeList.txt"

#names of the folders that iconpack will go into
readonly ICONPACK_FOLDER_LIGHT="willow-icons-light"
readonly ICONPACK_FOLDER_DARK="willow-icons-dark"

#names of target directories e.g. Fluent's source and Willow's
readonly FLUENT_TARGET="Fluent-icon-theme"
readonly WILLOW_SOURCE="willow-src"

function clearPack {
    #deletes entire icon pack
    rm --recursive -- "$1"
    mkdir "$1"
}

function actionsCopy {
    #copies each selected actions/ directory from Fluent
    for directory in "${ICON_DIRECTORIES[@]}"; do
        mkdir $1/$directory/
        cp -a $FLUENT_TARGET/src/$directory/actions $1/$directory/
    done
}

function linksCopy {
    #copies the links for the selected directories from Fluent
    for directory in "${ICON_DIRECTORIES[@]}"; do
        cp -a $FLUENT_TARGET/links/$directory/actions $1/$directory/
    done
}

function removeBanned {
    #removes icons that inhibit inheriting from Papirus
    for directory in "${ICON_DIRECTORIES[@]}"; do
        for icon in "${BANNED_ICONS[@]}"; do
            rm -f $1/$directory/actions/$icon
        done
    done
}

function willowCopy {
    #copies over willow's icons
    for files in $WILLOW_SOURCE/* ; do
        cp -a "$files" $1
    done
}

function lightToDark {
    #inverts colors of svgs from dark (363636 to dedede)
    sed -i "s/#363636/#dedede/g" "${1}"/{16,22,24,32}/actions/*.svg
    #commented out until further notice since 16px icons will be full color
    #sed -i "s/#363636/#dedede/g" "${1}"/{16,22,24}/{places,devices}/*.svg
    sed -i "s/#363636/#dedede/g" "${1}"/symbolic/{actions,apps,categories,devices,emblems,emotes,mimetypes,places,status}/*.svg
}

function themeColor {
    #sets the colors for the theme's index.theme name
    sed -i "s/%COLOR%/${2//-/ }/g" "${1}/index.theme"
}

#make Willow Light
clearPack $ICONPACK_FOLDER_LIGHT
actionsCopy $ICONPACK_FOLDER_LIGHT
linksCopy $ICONPACK_FOLDER_LIGHT
removeBanned $ICONPACK_FOLDER_LIGHT
willowCopy $ICONPACK_FOLDER_LIGHT

#make Willow Dark
clearPack $ICONPACK_FOLDER_DARK

#lazily copy over light
cp -a $ICONPACK_FOLDER_LIGHT/* $ICONPACK_FOLDER_DARK
lightToDark $ICONPACK_FOLDER_DARK

#name the themes their appropriate colors
themeColor $ICONPACK_FOLDER_LIGHT "Light"
themeColor $ICONPACK_FOLDER_DARK "Dark"

echo done
exit
