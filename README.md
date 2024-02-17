## PSU AutoHotkey Assistant
This tool will enable better gameplay in Phantasy Star Universe by allowing the user to focus dealing damage and higher level gameplay while the assistant manages and maintains the desired state of the character for such things as photon charge or health.

Please note there are various caveats that may limit full functionality if prerequisites are not installed, configured, or the game's server differs from supported.

### Features
PC which stands for Photon Charge will maintain the Player's weapon charge above the specified percentage _(default 5-10%)_

TH a.k.a. Trimate Heal will ensure the player's health does not fall below provided percentage _(default 60-70%)_

JA for Just Attack will complete moveset combos at just the right time for full damage. __Requires PSU Floor Reader Addon!__

AS is Armor Swap, which will make use of player provided chat shortcuts to swap armor correctly resist an enemy's elemental type.

### Installation
Simply download the script and install [AutoHotkey Version 2](https://www.autohotkey.com/)
Then run the script as Administrator to allow it to interact with the game (_which also requires to be run as Administrator_)

### Dependencies
Just Attack combo completion requires the installation of PSU Floor Reader and use of the 'experimental' Just Attack feature.
* Installation Instructions: [https://psu-clementine.net/wiki/index.php/Floor_Reader](https://psu-clementine.net/wiki/index.php/Floor_Reader)
    * Addon Website: [https://sites.google.com/view/psufr](https://sites.google.com/view/psufr)

### Setup
Position the small tabs which are actually mini windows around to the respective ui element they should track. The settings gui part of this tool can be used to adjust various timings, thresholds, and reposition the small tabs around to get pixel perfect alignment. The idea here is to move these mini windows around to tell the assistant where it needs to look in order to get information like the player's current hp or photon charge. These tabs can be resized, increasing the size of detection, but for performance reasons should be as small as possible while still gathering the needed information.
* __PC__ is Photon Charge bar gauge
    * This is normally 1 pixel tall below the tab header and 100+ pixels wide. 
    * Make sure to resize to fully fit the length of the game's photon charge bar which is normally a medium light blue color.
    * Game's ui for photon charge is usually in the bottom right next to weapons
* __TH__ is Trimate Heal player health bar gauge
    * Also normally 1 pixel tall and much wider. _Don't make taller for perf reasons_
    * Must be just as long as the player's health bar and positioned until the status is visible in the assistant.
    * Game's ui normally puts the player health bar in the bottom left
* __JA__ is Just Attack completion timer _which 
    * *Requires the use of PSU Floor Reader addon
    * Move the PSU Floor Reader somewhere it will not interfere with reading and detecting other statuses such as the top left corner
    * Position the Just Attack tab over the PSU Floor Reader 'Pixel' which is normally red, but turns green during Just Attack timing
* __AS__ is Armor Swap enemy element type reader
    * Move tab over to where the enemy's name pops up, directly over the element type icon.
    * Game usually has enemy's name along with elemental type in the top left

__Once positioned properly you'll now visibly see the status tracked in the assistant's main gui via progress bar.__

Lastly, its recommended to hide each small tab window as to not inferfere with gameplay by pressing the Show/Hide PC|JA|TH|AS button visible in it's respective tab on the assistant settings ui. _Example: 'Hide TH', 'Hide PC'_

### Usage
Should be fairly straight-forward, depending on which features have been setup and configured properly you'll see the assistant attempt to heal by using a trimate via ingame chat shortcut command when the player's health dips below a provided percentage. The Key phrase for this is TH or Trimate Heal. When attacking with weapons, photon charge for the current weapon is used and when it dips below a threshold percentage a Photon Charge will be used. After encountering enemies of a new elemental type, the assistant will attempt to use the chat shortcut to swap to an armor that matches that type for max damage resist/decrease. By using the Just Attack timing feature on the PSU Floor Reader, the Assistant can time when to press to attack for bonus damage, which is normally quite difficult if your team consists of 'techers'.

### Caveats
#### Running the Assistant
Due to PSU normally requiring to be run as Admin or Administrator runtime privileges, the Assistant MUST ALSO BE RUN AS ADMINISTRATOR.

#### Just Attack Timing
Note: Just attack timing differs from moveset or 'PA' (photon art) so it may require fine tuning of the delay to get a higher correct Just Attack timing. For example 75ms delay might work for single saber PA's but not twin claws, ect.

Make sure to install PSU Floor reader listed under the Dependencies section to allow this feature, otherwise it WILL NOT work.

Due to AutoHotKey not supporting true multi-threading, operations related to pixel detection such as tracking player health percentage must remain as fast as possible for properly timing Just Attacks. If tracking a status such as health requires the program to search a large space on the screen which was increased through resizing its detection tab it may slow the assistant enough to miss proper timing to execute Just Attack.

#### Armor Swap, Photon Charge, Trimate Heal
These features make use of [Clementine Server Chat Commands](https://psu-clementine.net/wiki/index.php/Chat_Commands), which are a specially formed chat message is received by the server and interpreted to provide additional capabilities the original game may never have had. Because players can assign a keyboard shortcut to send a pre-package chat, one can press a couple buttons and swap armors without having to dig through menus. If the PSU client and/or server doesn't support these commands, this assistant will be HIGHLY LIMITED in it's capabilities.
