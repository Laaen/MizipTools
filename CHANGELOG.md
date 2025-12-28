### 2.0.0
- Rewrite in Flutter
- Removed confusing functionalities ("Reset tag" and the whole templating system)
- Fixed the code which changes the balance (it now targets only the 3 useful bytes instead of the whole block + it now takes into account the two first bytes of block 10)
- Added an "Auto-repair" function which can repair the tag in case of connection loss during a "Write from dump" or "Change UID"

### 2.0.1
- Fixed UI overflow for some widgets