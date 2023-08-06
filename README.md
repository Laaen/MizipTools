# MizipTools

Android App written in Kotlin made to fiddle with MiZip NFC tags.

#### /!\ This app only works with MiZip keys /!\

Features :

- Read tag dump / create template
- Dump tag data
- Write a new tag
- Recharge a tag
- Change a tag's UID
- Reset a tag

## How to install
Two options : 
- You can either clone this repo, and build the app with Android Studio
- Or, you can download the .apk file in "Release", and install it manually

## Quick guide

### Introduction
Start the app, put the tag on the back of your phone, and you're good to go

The tag's info should be displayed.

In case of the tag being repeatedly detected and disconnected, it is likely that you have some "exotic" access bits, if it is the case, feel free to send me your tag's dump so I can work on this issue.

### Read tag dump
Use the drop-down menu to select which dump file you want to read, then hit "Read" button, the dump's contents should be displayed

You can make a template (More on templates at the end of this Readme) out of the selected dump by touching the "Make template" button

### Dump Tag
It will read your Mizip tag's UID, generate all keys, and read all sectors, a dump should be saved in the Android/data/com.laen.miziptools/files/[UID].txt

If the app crashes when dumping, it's either you don't have a MiZip tag or some issue occured when writing the file (unlikely).

If it doesn't work, and you are sure your tag is a MiZip tag, feel free to submit an issue :)

### Write new tag /!\ You need a changeable block 0 tag to use this feature /!\
Pretty straightforward, it will write content in your tag.

- UID : You can choose the UID, you can put X to have a random value
- Money : The amount you want 
- Unique Key : To write a new tag, you need to have all of its keys (A AND B) to have the same value (this can be easily done with the "Reset tag" functionnality).
- Dump File : A template dump which will be modified with the new chosen UID, money and keys and written to the key

If it doesn't work, the most common issue is that your A and B keys are not the same

### Recharge Tag
Easy, put amount of money you want (up to 655.3), tap recharge, and you're done ;)

### Change UID /!\ You need a changeable block 0 tag to use this feature /!\
UID : You can choose the UID, you can put X to have a random value

### Reset Tag /!\ You need a changeable block 0 tag to use this feature /!\
Be careful this action will erase *everything* on your tag. It could even erase all sectors 1-4 data even if you're not using a changeable block 0 tag.

It will write a predefined dump in your tag all data will be erased, and all A and B keys will be changed to "FFFFFFFFFFFF"

## Templates
The key idea of this app is to allow the user to clone a MiZip tag in such a manner that it won't be detected.

To do this, you can make use of templates.

Templates are genuine tag dumps, but with some parts which are automatically modified by the "Create new tag" function (UID + BCC, money and Keys).

The modified parts are marked as X'es in the dump, these X'es are automatically added by the "Make template" button from the "Read dump" menu

The best way to use them is to dump a bunch of different keys (maybe 3 or 4), compare the dumps, find which parts of them are different (these parts could be used to identify you), modify them with random values, and then use this template to write new keys.

You can put "Y"es in the template where you want the "Write new tag function" to write a random value (You have to do it by yourself by editing the dump)

## Final words
Unfortunately for you most of the code's comments and var/fun names are in French. If you have any questions and/or suggestions feel free to message me :)

Please note, this repo is for educational purposes only, I don't encourage the use of this application in any illicit way.




