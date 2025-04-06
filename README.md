# shell-script/tree/get-big.LITTLE
## GET big.LITTLE
Get `big core` and `LITTLE core` amount and frequency (MHz) on Android device using [Android Debug Bridge (ADB)](https://wikipedia.org/wiki/Android_Debug_Bridge)
---
## How to Use
1. Clone this repository branch or download `get_bigLITTLE.sh` files in repository
2. Enable [Developer Options](https://www.google.com/search?q=How+to+Enable+Developer+Options)
3. There are two ways to use `USB Debugging` and `Wireless Debugging`.

### USB Debugging
1. [Enable and Connect USB Debugging](https://www.google.com/search?q=How+to+enable+and+connect+USB+Debugging+to+PC)
2. Run the `get_bigLITTLE.sh` shell script
``` sh
adb shell sh "/path/to/file/get_bigLITTLE.sh"
```

### Wireless Debugging
1. [Enable Wireless Debugging](https://www.google.com/search?q=How+to+Enable+Wireless+Debugging)
2. [Connect Wireless Debugging](https://www.google.com/search?q=How+to+Connect+Wireless+Debugging) or Using [Brevent App](https://play.google.com/store/apps/details?id=me.piebridge.brevent) ([HELP!](https://www.google.com/search?q=How+To+Connect+Brevent)), [Termux (GitHub or F-Droid Recommended)](https://github.com/termux/termux-app) + [Shizuku](https://github.com/RikkaApps/Shizuku) ([HELP!](https://www.google.com/search?q=How+To+Connect+Shizuku+To+Termux)), etc.
3. Run the `get_bigLITTLE.sh` shell script
``` sh
adb shell sh "/path/to/file/get_bigLITTLE.sh"
```
or (if you use Brevent, etc.)
``` sh
sh "/path/to/file/get_bigLITTLE.sh"
```
---