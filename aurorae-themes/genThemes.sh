#!/usr/bin/env bash

function outputTheme {
    # takes in icons, decoration + ????, and metadata.desktop
    iconDir="$1"
    decoDir="$2"
    #rc and metadata.desktop
    metaDir="$3"
    outputDir="output/$metaDir"

    mkdir $outputDir

    cp -a src/$iconDir/* "$outputDir"
    cp -a src/$decoDir/* "$outputDir"
    cp -a $metaDir/* "$outputDir"

    #print out the name and plugin
    sed -n -e "/^\[Desktop Entry\]/,/^\[.*\]/ s|^\(Name[ \t]*=[ \t]*.*$\)|\1|p" "$outputDir/metadata.desktop"
    sed -n -e "/^\[Desktop Entry\]/,/^\[.*\]/ s|^\(X-KDE-PluginInfo-Name[ \t]*=[ \t]*.*$\)|\1|p" "$outputDir/metadata.desktop"
}

function outputBlurTheme {
    # duplicates opaque theme and renames everything to be blur
    #this is possible because they usually overlap in everything except
    # metadata, rc???, and decoration
    baseDir="output/$1"
    #grab rc name from original so we can rename it
    #i'm sure there will never be a case where there will be more than one
    baseRCFileName="$(basename $baseDir/*rc)"
    dirName="output/$2"
    themeName="$3"
    pluginName="$4"
    decorationDir="$5"

    #duplicate existing theme
    cp -a $baseDir $dirName
    #copy over the specified blurred asset
    cp -a "$decorationDir/blur/decoration.svg" "$dirName"
    #sorry for the random $2 after all these variables
    mv "$dirName/$baseRCFileName" "$dirName/$2rc"
    #set plugin name
    sed -i -e "/^\[Desktop Entry\]/,/^\[.*\]/ s|^\(X-KDE-PluginInfo-Name[ \t]*=[ \t]*\).*$|\1$pluginName|" "$dirName/metadata.desktop"
    #set theme name
    sed -i -e "/^\[Desktop Entry\]/,/^\[.*\]/ s|^\(Name[ \t]*=[ \t]*\).*$|\1$themeName|" "$dirName/metadata.desktop"

    #print out the name and plugin
    sed -n -e "/^\[Desktop Entry\]/,/^\[.*\]/ s|^\(Name[ \t]*=[ \t]*.*$\)|\1|p" "$dirName/metadata.desktop"
    sed -n -e "/^\[Desktop Entry\]/,/^\[.*\]/ s|^\(X-KDE-PluginInfo-Name[ \t]*=[ \t]*.*$\)|\1|p" "$dirName/metadata.desktop"
}

function addShaderIcons {
    dirName="output/$1"
    iconDir="$2"
    cp -a $iconDir/icons/* $dirName
}

rm -r "output/WillowDark" "output/WillowDarkAlt" "output/WillowDarkBlur" "output/WillowDarkBlurAlt"
rm -r "output/WillowLight" "output/WillowLightAlt" "output/WillowLightBlur" "output/WillowLightBlurAlt"
rm -r "output/WillowLightly"
rm -r "output/WillowLightShader" "output/WillowDarkShader"

mkdir -p "output"

#generate standard version with rounded right close button
outputTheme "dark/icons" "dark/opaque" "WillowDark"
outputBlurTheme "WillowDark" "WillowDarkBlur" "Willow Dark Blur" "willow-dark-blur-aurorae" "src/dark"

outputTheme "light/icons" "light/opaque" "WillowLight"
outputBlurTheme "WillowLight" "WillowLightBlur" "Willow Light Blur" "willow-light-blur-aurorae" "src/light"

#generate the better alt version
outputTheme "dark/icons-alt" "dark/opaque" "WillowDarkAlt"
outputBlurTheme "WillowDarkAlt" "WillowDarkBlurAlt" "Willow Dark Blur Alt" "willow-dark-blur-alt-aurorae" "src/dark"

outputTheme "light/icons-alt" "light/opaque" "WillowLightAlt"
outputBlurTheme "WillowLightAlt" "WillowLightBlurAlt" "Willow Light Blur Alt" "willow-light-blur-alt-aurorae" "src/light"

#generate Lightly version
outputTheme "light/icons" "lightly/blur" "WillowLightly"

#generate shader versions
outputBlurTheme "WillowDark" "WillowDarkShader" "Willow Dark (Shaders)" "willow-dark-aurorae-shaders" "src/dark-shader"
addShaderIcons "WillowDarkShader" "src/dark-shader"

outputBlurTheme "WillowLight" "WillowLightShader" "Willow Light (Shaders)" "willow-light-aurorae-shaders" "src/light-shader"
addShaderIcons "WillowLightShader" "src/light-shader"

echo "done"
exit

