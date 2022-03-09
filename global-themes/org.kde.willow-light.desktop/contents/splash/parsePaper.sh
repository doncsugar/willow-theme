#!/usr/bin/env bash

# pwd > /home/user/.local/share/plasma/look-and-feel/org.kde.willow.desktop/contents/splash/new.txt

THEME_FOLDER="org.kde.willow-light.desktop"

PLASMA=".config/plasma-org.kde.plasma.desktop-appletsrc"

# PLASMA="/home/user/.config/plasma-org.kde.plasma.desktop-appletsrc"

WALLPAPER_SECTION="$(sed -e '1,/\[Containments\]\[[0-9]*\]\[Wallpaper\]\[org.kde.color\]/ d' $PLASMA)"

COLOR_SECTION="$(sed -e '1,/\[Containments\]\[[0-9]*\]\[Wallpaper\]\[org.kde.color\]/ d' $PLASMA)"
#
# echo "$WALLPAPER_SECTION"
# echo "$COLOR_SECTION"

#it's not really broken up by lines, now is it
for x in $WALLPAPER_SECTION; do
    if [[ $x == *Image* ]]; then
        WALLPAPER=$(printf '%s\n' "$x")
        WALLPAPER=${WALLPAPER#*=}
        WALLPAPER=${WALLPAPER#file://}
        echo "$WALLPAPER"
        break
    fi
done

for x in $COLOR_SECTION; do
    if [[ $x == *Color* ]]; then
        COLOR=$(printf '%s\n' "$x")
        COLOR=${COLOR#*=}
        COLOR="$COLOR,255"
        echo "$COLOR"
        break
    fi
done


(cd ".local/share/plasma/look-and-feel/$THEME_FOLDER/contents/splash/";
echo "$(rm "wallpaper")";
ln -s "$WALLPAPER" "wallpaper")
