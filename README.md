# MizipTools

Android App written in Kotlin made to fiddle with MiZip NFC tags.

#### /!\ This app only works with MiZip keys /!\

Features :

- Dump tag data
- Write a new tag
- Recharge a tag
- Change a tag's UID
- Reset a tag

## Quick guide

#### Introduction
Put your MiZip key on the back of your phone, the app should start.

Don't start the app manually, it won't work (I'll maybe fiddle with it to allow manual starting)


#### Dump Tag
-It will read your Mizip tag's UID, generate all keys, and read all sectors, a dump should be saved in the Android/data/com.laen.miziptools/files/[UID].txt

-If the app crashes when dumping, it's either you don't have a MiZip tag, some issue occured when writing the file (unlikely), or there are some subtilities on how they generate key and this app is worthless D:

-If it doesn't work, and you are sure your tag is a MiZip tag, feel free to submit an issue :)


#### Write new tag /!\ You need a changeable block 0 tag to use this feature /!\
Pretty straightforward, it will write content in your tag.

-UID : You can choose the UID, you can put X to have a random char

-Money : The amount you want 

-Unique Key : To write a new tag, you need to have all of its keys (A AND B) to have the same value (this can be easily done with the "Reset tag" functionnality).

-Dump File : A template dump which will be modified with the new chosen UID, money and keys and written to the key (An example one is given in this repo ("DUMP.txt")

The best thing to do is to dump your tag content, put "X"es at the same location as in the "DUMP.txt" file, and boom, you're done ;)

If it doesn't work, the most common issue is that your A and B keys are not the same


#### Recharge Tag
Easy put amount of money you want, tap recharge, and you're done ;)

If the app crashes when recharging, it' likely to be the same reasons as for the "Dump tag"


#### Change UID /!\ You need a changeable block 0 tag to use this feature /!\
UID : You can choose the UID, you can put X to have a random char


#### Reset Tag /!\ You need a changeable block 0 tag to use this feature /!\
Be careful this action will erase *everything* on your tag. It could even erase all sectors 1-4 data even if you're not using a changeable block 0 tag.

Pretty simple : It will write a predefined dump in your tag all data will be erased, and all A and B keys will be changed to "FFFFFFFFFFFF"


## Final words
This app is stil quite unstable, if you remove/add a new tag while it is open, it il very likely to crash.

Moreover, when asked informations (UID, money, Key), please follow the guide. 

If for example you enter an UID which is too small, it could brick your tag (I'll very likely start to implement stuff to prevent that soon)

Unfortunately for you most of the code's comments and var/fun names are in French. If you have any questions and/or suggestions feel free to message me :)

Please note, this repo is for educational purposes only, I don't encourage the use of this application in any illicit way.




