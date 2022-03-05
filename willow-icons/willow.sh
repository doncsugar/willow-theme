#!/usr/bin/env bash

#load in desired directories of icon resolutions e.g. 16, 22, 32, 64
mapfile -t ICON_DIRECTORIES < "global-configs/directoryList.txt"

#load in list of undesired icons e.g. prevent theme from inheriting Papirus
mapfile -t BANNED_ICONS < "global-configs/removeList.txt"

# used in folder assembly code
FOLDER_ASSET_DIR="icon-pipeline/places/special-folder-assets"

#names of the folders that iconpack will go into
readonly ICONPACK_FOLDER_LIGHT="willow-icons-light"
readonly ICONPACK_FOLDER_DARK="willow-icons-dark"
readonly ICONPACK_FOLDER_SPECTRUM_LIGHT="willow-icons-spectrum-light"
readonly ICONPACK_FOLDER_SPECTRUM_DARK="willow-icons-spectrum-dark"

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
    #needed a for loop because sed would overwrite links
    for file in "${1}"/{16,22,24,32}/actions/*.svg; do
        if [[ ! -L $file ]]; then
            sed -i "s/#363636/#dedede/g" "$file"
        fi
    done
#     sed -i "s/#363636/#dedede/g" "${1}"/{16,22,24,32}/actions/*.svg
    #commented out until further notice since 16px icons will be full color
    #sed -i "s/#363636/#dedede/g" "${1}"/{16,22,24}/{places,devices}/*.svg
    for file in "${1}"/symbolic/{actions,apps,categories,devices,emblems,emotes,mimetypes,places,status}/*.svg; do
        if [[ ! -L $file ]]; then
            sed -i "s/#363636/#dedede/g" "$file"
        fi
    done
#     sed -i "s/#363636/#dedede/g" "${1}"/symbolic/{actions,apps,categories,devices,emblems,emotes,mimetypes,places,status}/*.svg
}

function lightBlueToDarkBlue {
    #changes dark's bright blue to light's dark blue
    #needed a for loop because sed would overwrite links
    for file in "${1}"/{16,22,24,32}/actions/*.svg; do
        if [[ ! -L $file ]]; then
            sed -i "s/#3daee9/#0078d4/g" "$file"
        fi
    done
    #does places need to be included here?
    for file in "${1}"/{16,22,24,32}/apps/*.svg; do
        if [[ ! -L $file ]]; then
            sed -i "s/#3daee9/#0078d4/g" "$file"
        fi
    done

    for file in "${1}"/symbolic/{actions,apps,categories,devices,emblems,emotes,mimetypes,places,status}/*.svg; do
        if [[ ! -L $file ]]; then
            sed -i "s/#3daee9/#0078d4/g" "$file"
        fi
    done
}

function setToActiveTextColor {

    TARGET_DIR="$1"
    COLOR_TO_REPLACE="$2"
    REPLACEMENT_COLOR="$3"

    for file in $(find "$TARGET_DIR" -type f -print); do
        if [[ ! -L $file ]]; then
            sed -i "s/$COLOR_TO_REPLACE/$REPLACEMENT_COLOR/g" "$file"
        fi
#         echo "$file"
    done

}

function themeColor {
    #sets the colors for the theme's index.theme name
    sed -i "s/%COLOR%/${2//-/ }/g" "${1}/index.theme"
    sed -i "s/%INHERITCOLOR%/${3//-/ }/g" "${1}/index.theme"
}

function linkDefaultFolderColor {
# links the folders to a specific default color
# e.g. if you wanted the 'regular' folder to be blue
# you would link it by passing in a color from the
# color list and it would generate the base set of
# icons by linking it to an existing color
# e.g. folder.svg would be linked to folder-blue.svg
    TARGET_DIR="$1"
    CHOSEN_COLOR="$2"
    #turned into a global variable
#     FOLDER_ASSET_DIR="icon-pipeline/places/special-folder-assets"
    CUSTOM_DIR="$FOLDER_ASSET_DIR/system-color-resolutions"
    GENERIC_DIR="$FOLDER_ASSET_DIR/resolutions"

    mapfile -t ICON_COLORS < "global-configs/colorList.txt"

    for color in ${ICON_COLORS[@]}; do
        color="${color%=*}"
        #"
        if [[ "$color" == "$CHOSEN_COLOR" ]]; then
            #no special directory handling is required
            #so we can just use the custom prefix
            if [[ "$color" == "KDE_HIGHLIGHT" ]]; then
                color="custom"
                echo "$color"
            fi
#             exit
            echo "color exists, beginning linking"

            for type in "$FOLDER_ASSET_DIR"/overlays/*; do
                for scale in {16,22,32,48,64}; do
                    TYPE_TARGET="$(basename $type)"
                    #starting with ? means it needs special handling
                    if [[ ${TYPE_TARGET:0:1} == "?" ]]; then
                        #this is the default folder
                        if [[ ${TYPE_TARGET:1} == "" ]]; then

                            (cd "$TARGET_DIR/$scale/places/"
                            ln --symbolic --force "folder-$color.svg" "folder.svg")
                            #establish links found in its folder
                            if [[ -f "$type/links" ]]; then
                                mapfile -t LINKS < "$type/links"
                                for link in "${LINKS[@]}"; do
                                    (cd "$TARGET_DIR/$scale/places/"
                                    ln --symbolic --force "folder.svg" "$link.svg")
                                done
                            fi
                        #this is the user prefixed links
                        elif [[ ${TYPE_TARGET:1} == "home" ]]; then

                            (cd "$TARGET_DIR/$scale/places/"
                            ln --symbolic --force "user-$color-home.svg" "user-home.svg")

                            #may be some redundancy with this and generic folder
                            if [[ -f "$type/links" ]]; then
                                mapfile -t LINKS < "$type/links"
                                for link in "${LINKS[@]}"; do
                                    (cd "$TARGET_DIR/$scale/places/"
                                    ln --symbolic --force "user-home.svg" "$link.svg")
                                done
                            fi
                        fi

                        #this is the end of handling the special cases
                        #other cases such as folder-open need to be added
                    else
                        #need special handling for 16px
                        #check if overlay of desired type and scale is present
                        if [[ -f "$type/$scale.svg" ]]; then
                            #check if the highlight inheriting assets need to be used
                            (cd "$TARGET_DIR/$scale/places/"
                            ln --symbolic --force "folder-$color-$(basename $type).svg" "folder-$(basename $type).svg")
                        else
                            #warn that a scale is missing
                            echo "$type/$scale could not be linked"
                        fi
                    fi
                done
            done
            #break loop since it was found
            break 1
        fi
    done
}

function placesPipeline {
    TARGET_DIR=$1
    #turned into  a global variable
#     FOLDER_ASSET_DIR="icon-pipeline/places/folders/testRun/folder-prefix"
    CUSTOM_DIR="$FOLDER_ASSET_DIR/system-color-resolutions"
    GENERIC_DIR="$FOLDER_ASSET_DIR/resolutions"

    #consider standardizing usage of a global area to configuration files
    mapfile -t ICON_COLORS < "global-configs/colorList.txt"
    for color in ${ICON_COLORS[@]}; do
        COLOR_NAME="${color%=*}"
        #"
        COLOR_HEX="${color##*=}"
        #"

        for type in "$FOLDER_ASSET_DIR"/overlays/*; do
            for scale in {16,22,32,48,64}; do
                TYPE_TARGET="$(basename $type)"
                #starting with ? means it needs special handling
                #e.g. the default folder does not receive an overlay
                if [[ ${TYPE_TARGET:0:1} == "?" ]]; then
                    #remove "?" hint at the start of the name
                    TYPE_TARGET="${TYPE_TARGET:1}"
                    #check if file exists, ignore if it's the default folder
                    # or if the scale is 16 since there is no official style for them
                    if [[ -f "$type/$scale.svg" || "$TYPE_TARGET" == "" || "$scale" == "16" ]]; then
                        #this is the default folder
                        if [[ "$TYPE_TARGET" == "" ]]; then
                            COLOR_SUFFIX="-$COLOR_NAME"
                            if [[ "$COLOR_SUFFIX" == "-" ]]; then
                                COLOR_SUFFIX=""
                            fi
                            #check if a special directory doesn't need to be used
                            if [[ "$COLOR_NAME" != "KDE_HIGHLIGHT" ]]; then
                                sed -e "s|ffb004|$COLOR_HEX|" "$GENERIC_DIR/folder/$scale.svg" > "$TARGET_DIR/$scale/places/folder$COLOR_SUFFIX.svg"
                            else
                                cp "$CUSTOM_DIR/folder/$scale.svg" "$TARGET_DIR/$scale/places/folder-custom.svg"
                            fi
                        #this is the home folder, papirus has a user prefix (user-red-home)
                        elif [[ "$TYPE_TARGET" == "home" ]]; then
                            OVERLAY=$(printf %q "$(sed -n '2p' "$type/$scale.svg")")
                            if [[ "$COLOR_NAME" != "KDE_HIGHLIGHT" ]]; then
                                sed -e "s|</svg>|${OVERLAY}\n</svg>|g" -e "s|ffb004|$COLOR_HEX|" "$GENERIC_DIR/folder/$scale.svg" > "$TARGET_DIR/$scale/places/user-$COLOR_NAME-home.svg"
                            else
                                sed -e "s|</svg>|${OVERLAY}\n</svg>|g" "$CUSTOM_DIR/folder/$scale.svg" > "$TARGET_DIR/$scale/places/user-custom-home.svg"
                            fi
                        fi
                    fi
                    #this is the end of handling the current special cases
                    #other cases such as folder-open need to be added
                else
                    #need special handling for 16px
                    #check if overlay of desired type and scale is present
                    if [[ -f "$type/$scale.svg" ]]; then
                        OVERLAY=$(printf %q "$(sed -n '2p' "$type/$scale.svg")")
                        #check if the highlight inheriting assets need to be used
                        if [[ "$COLOR_NAME" != "KDE_HIGHLIGHT" ]]; then
                            #target line in svg is: fill="#ffb004"
                            #apply overlay + replace willow color with specified
                            #then deposit in correct directory in theme
                            #also prefix it with the proper name e.g. folder-red-locked.svg
                            sed -e "s|</svg>|${OVERLAY}\n</svg>|g" -e "s|ffb004|$COLOR_HEX|" "$GENERIC_DIR/folder/$scale.svg" > "$TARGET_DIR/$scale/places/folder-$COLOR_NAME-$(basename $type).svg"
                        else
                            #use highlight inheriting assets for overlay
                            sed -e "s|</svg>|${OVERLAY}\n</svg>|g" "$CUSTOM_DIR/folder/$scale.svg" > "$TARGET_DIR/$scale/places/folder-custom-$(basename $type).svg"
                        fi
                    else
                        #warn that a scale is missing
                        echo "$type/$scale could not be made"
                    fi
                fi
            done
        done
    done
}

function import {
    #requires a subset of Icon Items generated by iconRipper
    TARGET_DIR=$1
    TARGET_DIR=${TARGET_DIR%/}
    #the directory of the icons to import
    IMPORT_DIR=$2
    IMPORT_DIR=${IMPORT_DIR%/}
    #the group the icons belong to e.g. apps, devices, places
    ICON_GROUP=$3

    for icon in $IMPORT_DIR/*; do
        ICON_NAME="$(<"$icon/name")"
        mapfile -t LINKS < "$icon/links"
        for scale in {16,22,32,48,64}; do
            cp $icon"/icons/$scale.svg" "$TARGET_DIR/$scale/$ICON_GROUP"
            mv "$TARGET_DIR/$scale/$ICON_GROUP/$scale.svg" "$TARGET_DIR/$scale/$ICON_GROUP/$ICON_NAME.svg"
            for icon_link in "${LINKS[@]}"; do
            #.svg not appended to link name because it's already
            #a part of imported icons
                (cd "$TARGET_DIR/$scale/$ICON_GROUP"
                ln --symbolic --force "$ICON_NAME.svg" "$icon_link")
            done
        done
    done
}

function pipeline {
    #moves and renames icons for use in a theme
    #iconpack folder you want to deposit in. Requires scales (e.g. 16, 22, 32, 64) to be in pack's root rather than concept groups
    TARGET_DIR=$1

    for group in icon-pipeline/{apps,devices,places}; do
        echo OUTER LOOP
        echo $group
        #includes the directories in the index.theme file if present
        if [[ -f "$group/directory-list" ]]; then
            DIRECTORIES="$(<$group"/directory-list")"
            CURRENT_DIRECTORIES=$(sed -n "/^Directories=/p" "$TARGET_DIR/index.theme")
            CURRENT_DIRECTORIES="$CURRENT_DIRECTORIES,$DIRECTORIES"
            sed  -i "s|Directories=.*|$CURRENT_DIRECTORIES|" "$TARGET_DIR/index.theme"
        fi
        #includes the scales in the index.theme file if present
        if [[ -f "$group/scale-declarations" ]]; then
            SCALE_DECLARATIONS="$(<$group"/scale-declarations")"
            echo "" >> "$TARGET_DIR/index.theme"
            echo "$SCALE_DECLARATIONS" >> "$TARGET_DIR/index.theme"
        fi

        for icon_set in $group/*/; do
        echo MIDDLE LOOP
        echo $icon_set
        ICON_GROUP="$(<$group"/targetDirectory.txt")"
        if [[ -f "$icon_set/name" ]]; then
            ICON_NAME="$(<$icon_set"/name")"
            ICON_DIR_NAME="${icon_set%/}"
            #"
            mapfile -t LINKS < "$ICON_DIR_NAME/links"
            echo "${LINKS[@]}"
    #         echo "copy icons if exists: $ICON_NAME"
    #         echo "this is the directory: $ICON_DIR_NAME"
                for scale in {16,22,32,48,64}; do
                    echo INNER LOOP
                    if [[ ! -d "$TARGET_DIR/$scale/$ICON_GROUP/" ]]; then
                        mkdir "$TARGET_DIR/$scale/$ICON_GROUP/"
                    fi

                    if [[ -f "$ICON_DIR_NAME/icons/$scale.svg" ]]; then
                        cp -a "$ICON_DIR_NAME/icons/$scale.svg" "$TARGET_DIR/$scale/$ICON_GROUP/$ICON_NAME.svg"
                        if [[ -f "$ICON_DIR_NAME/links" ]]; then
                            for link in "${LINKS[@]}"; do
                                (cd "$TARGET_DIR/$scale/$ICON_GROUP/"
                                ln --symbolic --force "$ICON_NAME.svg" "$link.svg")
                            done
                        fi
                    else
                        echo "Scale for $scale of $ICON_NAME does not exist."
                    fi
                done
        fi
        done
    done
    #places may need its own loop
}

function totalCompletion {
    ICON_SET="$1"
    ICONS_TO_COMPARE="$2"

    ICONS_MADE="$(find -L  $ICON_SET -type f | grep "" -c)"
    TOTAL_ICONS="$(find -L  $ICONS_TO_COMPARE -type f | grep "" -c)"

    PERCENT_COMPLETION=$(bc <<< "scale=2; 100 * $ICONS_MADE / $TOTAL_ICONS")"%"

    echo "$ICONS_MADE"
    echo "$TOTAL_ICONS"
    echo "$PERCENT_COMPLETION"
}

function testPack {
    clearPack $ICONPACK_FOLDER_LIGHT
    actionsCopy $ICONPACK_FOLDER_LIGHT
    linksCopy $ICONPACK_FOLDER_LIGHT
    removeBanned $ICONPACK_FOLDER_LIGHT
    willowCopy $ICONPACK_FOLDER_LIGHT
    pipeline $ICONPACK_FOLDER_LIGHT
    import "$ICONPACK_FOLDER_LIGHT" "icon-pipeline/apps/papirus-imports/" "apps"
    placesPipeline $ICONPACK_FOLDER_LIGHT
    linkDefaultFolderColor $ICONPACK_FOLDER_LIGHT "WILLOW"
    themeColor $ICONPACK_FOLDER_LIGHT "Light" "Light"
    exit
}

# testPack

#make Willow Light
clearPack $ICONPACK_FOLDER_LIGHT
actionsCopy $ICONPACK_FOLDER_LIGHT
linksCopy $ICONPACK_FOLDER_LIGHT
removeBanned $ICONPACK_FOLDER_LIGHT
willowCopy $ICONPACK_FOLDER_LIGHT
pipeline $ICONPACK_FOLDER_LIGHT
import "$ICONPACK_FOLDER_LIGHT" "icon-pipeline/apps/papirus-imports/" "apps"
placesPipeline $ICONPACK_FOLDER_LIGHT
linkDefaultFolderColor $ICONPACK_FOLDER_LIGHT "WILLOW"
# uncomment this line when ActiveText color applies to plasma themes
# setToActiveTextColor $ICONPACK_FOLDER_LIGHT "ColorScheme-Highlight" "ColorScheme-ActiveText"

#make Willow Dark
clearPack $ICONPACK_FOLDER_DARK

#lazily copy over light
cp -a $ICONPACK_FOLDER_LIGHT/* $ICONPACK_FOLDER_DARK
lightToDark $ICONPACK_FOLDER_DARK

#set light blue to dark blue even though I said willow won't support gnome
lightBlueToDarkBlue $ICONPACK_FOLDER_LIGHT

#make spectrum variants
clearPack $ICONPACK_FOLDER_SPECTRUM_LIGHT
#directory structure does not allow easy linking of categories to preserve space. May do a rework to Breeze's organization in future.
#as a result, this release will be over 10MB
cp -a $ICONPACK_FOLDER_LIGHT/* $ICONPACK_FOLDER_SPECTRUM_LIGHT
linkDefaultFolderColor $ICONPACK_FOLDER_SPECTRUM_LIGHT "KDE_HIGHLIGHT"

clearPack $ICONPACK_FOLDER_SPECTRUM_DARK
#lazily copy over light to dark
cp -a $ICONPACK_FOLDER_DARK/* $ICONPACK_FOLDER_SPECTRUM_DARK
linkDefaultFolderColor $ICONPACK_FOLDER_SPECTRUM_DARK "KDE_HIGHLIGHT"

#name the themes their appropriate colors
themeColor $ICONPACK_FOLDER_LIGHT "Light" "Light"
themeColor $ICONPACK_FOLDER_DARK "Dark" "Dark"
themeColor $ICONPACK_FOLDER_SPECTRUM_LIGHT "Spectrum Light" "Light"
themeColor $ICONPACK_FOLDER_SPECTRUM_DARK "Spectrum Dark" "Dark"

echo ""
echo done
exit
