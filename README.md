# iPhoneOS Membrane

This is an implementation of a native-code HatSploit membrane for iPhoneOS, designed for portability, embeddability, and low resource utilization.

## Building it

**Requirements:** `macOS` with installed `XCode` >= 7.3, `Theos` with SDK 13.0.

First you need to compile main membrane handler. After this you should build membrane dynamic library located in `dylib/`. Dynamic library should be installed on target device to provide command interface and full system control for membrane handler.

## Acknowledgments

* https://iphonedevwiki.net
    * https://iphonedevwiki.net/index.php/Theos
    * https://iphonedevwiki.net/index.php/Logos
* https://developer.apple.com/documentation
    * https://developer.apple.com/documentation/technologies?language=objc
