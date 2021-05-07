# iPhoneOS Membrane

This is an implementation of a native-code HatSploit membrane for iPhoneOS, designed for portability, embeddability, and low resource utilization.

## Building it

**Requirements:** `macOS` with installed `XCode` >= 7.3, `Theos` with SDK 13.0.

First you need to compile main membrane handler. After this you should build membrane dynamic library located in `dylib/`. Dynamic library should be installed on target device to provide command interface and full system control for membrane handler.

## Features

* **`shell`** - Execute system command.
* **`dial`** - Make a call from device.
* **`openurl`** - Open URL on device.
* **`openapp`** - Open device application.
* **`battery`** - Show device battery level.
* **`say`** - Say message on device.
* **`getvol`** - Show device volume level.
* **`setvol`** - Set device volume level.
* **`alert`** - Show alert on device.
* **`lock`** - Lock device.
* **`wake`** - Wake up device.
* **`mute`** - Mute device sounds.
* **`unmute`** - Unmute device sounds.
* **`dhome`** - Double home button tap.
* **`home`** - Home button tap.
* **`location`** - Control device location services.
* **`state`** - Check device state.
* **`player`** - Control device media player.

## Acknowledgments

* https://iphonedevwiki.net
    * https://iphonedevwiki.net/index.php/Theos
    * https://iphonedevwiki.net/index.php/Logos
* https://developer.apple.com/documentation
    * https://developer.apple.com/documentation/technologies?language=objc
