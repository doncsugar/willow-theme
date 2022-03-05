#!/usr/bin/env bash
function help {
    echo ""
    echo "Use this script to add .gitkeep to empty directories and remove them when generating the icon set"
    echo ""
    echo "Syntax: ./directoryKeeper.sh [CHOICE]"
    echo ""
    echo "Options are keep or remove"
    echo ""
}
CHOICE="$1"

if [[ $CHOICE == "keep" ]]; then
    find "willow-src" -type d -empty -not -path "./.git/*" -exec touch {}/.gitkeep \;
    find "icon-pipeline" -type d -empty -not -path "./.git/*" -exec touch {}/.gitkeep \;
elif [[ $CHOICE == "remove" ]]; then
    find "willow-src" -name ".gitkeep" -delete
    find "icon-pipeline" -name ".gitkeep" -delete
else
    echo "Incorrect input"
fi

exit
