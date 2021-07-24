# willow-theme
A Windows 11 style demo for KDE Plasma.

![Plasma desktop themed with Willow](willowLight.png)

## Set-up
Some of this may be automated in the future.

### Application Style
**Lightly** will be needed for the blurred variant of this theme. You can view it and its installation instructions here: https://github.com/Luwx/Lightly
* General
	* Set corner radius to 5 px
* Frames
	* Uncheck "Transparent Dolphin view"
* Transparency
	* Drag the "Sidebars" slider to "Opaque"

### Icons
This theme uses yeyushengfan258's Win11OS icon pack. You can download it in System Settings or manually install it from [here](https://www.pling.com/p/1546069/).

Icon packs are installed in your home directory at `~/.local/share/icons/`. Navigate to this folder and into the Win11OS folder. Go to `actions/22/` and copy the icons from this repository (located at `willow-icons/actions/22/`) into there. Reapply the icon pack and you should now have Willow's icons.

Optionally, if you want thin arrows, you can copy the arrows in `22-optional-thin-arrows` into `actions/22/` instead.

### Dolphin File Manager
Dolphin, like all KDE software, is quite customisable. You can edit the toolbar by right-clicking it (right-click the hamburger menu in the top-right) and selecting "Configure toolbars..." in the menu. In the configuration window there will be your current toolbar's tools in the right pane. To get the appearance in the screenshot, first remove the item named "Location Bar" from the right pane. The following is taken from the screenshot:

* Back
* Forward
* Up
* separator
* Icons
* Compact
* Details
* -- expanding spacer --
* Create New
* Cut
* Copy
* Paste
* Rename...
* Sort By
* Move to Trash
* -- expanding spacer --
* Split
* Search
* Filter

You can select these and change or hide the text it shows next to its icon.

I recommend the following only if you wish to sacrifice utility for aesthetics. Normally, the Location Bar will let you drag and drop files in any of its shown directories.

To get the look in the screenshot, open the hamburger menu and select "Configure Dolphin..." and then go to Startup > New windows > Check the "Make location bar editable" box.
