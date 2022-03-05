 #!/usr/bin/env bash

Help() {
    echo
    echo "Copies names of links from a theme to a file called links"
    echo
    echo "Syntax: linkNames [ICON NAME]... [TARGET DIRECTORY]..."
    echo "e.g. ./linkinator system-settings.svg /usr/share/icons/breeze/apps/48/"
    echo
}

Help

# should this be name + extension or just name?
NAME="$1"
# gets basename and extension
PURE_NAME=${NAME##*/}
# gets place to look for file links
TARGET_DIR="$2"
# location of "links" is hard-coded until further notice
FILE="links"
# FILE="$3"
# location of file in the target icons
TARGET_FILE="${TARGET_DIR%/}/$NAME"

echo "The name of the file is: "$PURE_NAME
echo "The place where the file is: "$TARGET_DIR
echo "The place the links are going is: "$FILE
echo
# clear current links in working directory
rm $FILE

for icon in $(find -L "$TARGET_DIR" -samefile "$TARGET_FILE"); do
    FOUND_ICON=${icon##*/}
    if [[ "$PURE_NAME" == "$FOUND_ICON" ]]; then
        echo "Same file found, not adding to links"
    else
        ICON_NAME="${icon##*/}"
        echo "${ICON_NAME%.*}" >> $FILE
        echo "Added to the links: ${ICON_NAME%.*}"
    fi
done

echo
echo "List of links is done"
