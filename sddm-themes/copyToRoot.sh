#!/usr/bin/env bash

sudo rm -r /usr/share/sddm/themes/willow-light

sudo cp -a willow-light /usr/share/sddm/themes/

sudo rm -r /usr/share/sddm/themes/willow-dark

sudo cp -a willow-dark /usr/share/sddm/themes/

exit
