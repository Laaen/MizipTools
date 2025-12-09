# MizipTools

Android App written in Flutter made to fiddle with MiZip NFC tags.  
⚠️ This app only works with MiZip tags ⚠️

Features :
- ✅ Dump tag data
- ✅ Write dump to tag
- ✅ Change tag's balance
- ✅ Change tag's UID
- ✅ Read tag dump

This is a rewrite of the Kotlin version, some features are missing such as "Reset tag" and the whole template system  
They may or may not be included in future versions

## How to install
⚠️ **If you're upgrading from the Kotclin version backup your dumps, they will be erased when installing this version**  ⚠️  

Two options :
- Download the .apk file in "Release", and install it manually on your phone.
- Clone this repo, install Flutter on your machine (https://docs.flutter.dev/install), and build with ``flutter build apk``

## How to use
⚠️ **Using this app can brick your NFC tag if not used correctly** ⚠️  
I strongly advise you to **NOT USE IT ON YOUR ORIGINAL TAG**, instead, you should buy a cheap tag from Aliexpress or somewhere else (preferably a CUID one)  

### Dump the tag
It's the first thing you should do, it will create a dump file you can use to restore your tag if something bad happens  
Go [here](https://github.com/Laaen/MizipTools/wiki/Dump-Tag), to learn how to do it

### Change tag's balance
This feature is mostly safe, if something goes wrong, you can restore your tag's dump    
[link](https://github.com/Laaen/MizipTools/wiki/Change-Balance)

### Restore dump
⚠️ If something goes wrong during the restoration, your tag can be left in a corrupted state, go [here](https://github.com/Laaen/MizipTools/wiki/Potential-fixes-for-broken-tags) to see possible solutions ⚠️  
[link](https://github.com/Laaen/MizipTools/wiki/Restore-Dump)

### Change UID
⚠️ **Using this feature on a non CUID tag is strongly not advised, it will not work, and will very likely brick your tag** ⚠️  
⚠️ If something goes wrong during the uid change, your tag can be left in a corrupted state, go [here](https://github.com/Laaen/MizipTools/wiki/Potential-fixes-for-broken-tags) to see possible solutions ⚠️  
[link](https://github.com/Laaen/MizipTools/wiki/Change-UID)