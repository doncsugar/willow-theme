# Icons
Willow aims for full folder compatibilty with Papirus. There are about 30 unique icons in total. To be pixel perfect, Willow needs one for each scale (e.g. 16, 22, 32, 48, 64).
## Contributing TL;DR
The easiest thing you can do is make overlays for folders. See the [locked](icon-pipeline/places/special-folder-assets/overlays/locked) icon scales to see the format. Just take bare folder icons from [generic-folder](icon-pipeline/places/generic-folder/icons) and draw the shapes over them. Run `willow.sh` to build the iconpack. Don't worry too much about formatting the SVGs properly, I will clean them up before adding them.
## Contributing (instructions are untested)
You should have Inkscape installed.

Install Cuttlefish through Discover or install the SDK

`sudo apt install plasma-sdk`

Clone the repository and sub-modules with

`git clone https://github.com/doncsugar/willow-theme.git --recursive`

Run the `directoryKeeper` script in the folder `willow-icons` with the `remove` parameter.

`./directoryKeeper.sh remove`

Nagivate to the icons

`willow-icons/icon-pipeline/`

Apps contains application icons (e.g. Dolphin, System Settings). Places contains folder icons. This guide is for making folders.

### Making a folder icon

Navigate to overlays

`places/special-folder-assets/overlays/`

The structure for icons is just a folder with overlays for scales 22, 32, 48, and 64. Look inside `locked` for an example.

To make an icon, you can open Dolphin. In your Places panel (on the left by default)you might see plain folders. That means that it does not have an icon yet. For example, right click the `Network` item (should be under Remote) and select `Edit...` to open the edit window. Click the icon thumbnail and it will show you the real name of the icon. The Network folder uses the `folder-network` icon.

To make the icon for it, make a new folder called `network` in `places/special-folder-assets/overlays/`.

Copy the bases from `places/special-folder-assets/resolutions/folder/` into your new `network` folder. 

Draw your icons over the folder bases. If the following is too difficult, you can just commit them.

To complete the icons for generation, make sure they are a single `path` element. You can use Path > Union to combine them. Delete the folder base. There should only be one element in your `.svg`. Finally, save it as an optimized svg. You can compare yours with the files in `locked` with a text editor. You should have a scale for 22px, 32px, 48px, and 64px, saved as `.svg`. e.g. `32.svg`.

I do not recommend running `willow.sh` if you have a mechanical hard drive, as it is a very wasteful script and may take a long time.

To generate the icon packs, run the script at `willow-theme/willow-icons/willow.sh`. It may take a while to create them and will output a lot of meaningless* text.

You can copy the newly made icon packs (or link them) to your icons folder in

`~/.local/share/icons`

Apply the updated icon pack in System Settings. Open the Cuttlefish application to view the icons. Search for the folder icon we just made to make sure everything is working properly: `folder-network`.

Click on it to show each scale of the icon. You should be able to see the overlays you made over folders.

# Notes
\* The meaningless text occasionally refers to missing icons
