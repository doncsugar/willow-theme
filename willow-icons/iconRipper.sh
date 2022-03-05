#!/usr/bin/env bash

Help() {
    echo
    echo "Takes a set of icons from Papirus, used for fixing inheritance problems"
    echo
    echo "Run inside the import folder with your set of Icon Items and it will import all scales, name it, and list links"
    echo
    echo "This script must be edited manually to function"
    echo
}

# Help

# e.g. /home/user/.local/share/icons/Papirus
TARGET_ICON_PACK="$1"
TARGET_ICON_PACK=${TARGET_ICON_PACK%/}
# e.g. places, apps, devices
ICON_GROUP="apps"

# assumes that largest directories are scales
# breeze has it inverted with groups being largest
for icon in */; do
    NAME=$(basename $icon/icons/*)
    NAME=${NAME%.*}
    #writes the name of the original icon
    echo $NAME > $icon/name
#     rm $icon/links
    touch $icon/links
    #copies scales
    for icon_scale in $TARGET_ICON_PACK/{16x16,22x22,32x32,48x48,64x64}/$ICON_GROUP/$NAME.svg; do
        SCALE=${icon_scale%x*}
        SCALE=${SCALE##*/}
        echo $SCALE
        cp -f $icon_scale $icon"icons/"
        mv $icon"icons/$NAME.svg" $icon"icons/$SCALE.svg"
    done
    #writes links to file
    for dir in $TARGET_ICON_PACK/64x64/$ICON_GROUP; do
        find -L "$dir" -samefile "$dir/$NAME.svg" -exec basename {} >> $icon/links \;
    done

done

exit
