### 2.0.2
- Check if NFC is enabled on launch
- Displays a message if NFC is disabled or not supported
- Bumped Kotlin + Gradle version
- Migrated Kotlin plugin
- Fixed checksum check
- Added message in case of invalid checksum of the balance

### 2.0.1
- Fixed UI overflow for some widgets
- Added warning message in case of trying to write a dump or change the uid on a non CUID tag
- Added error messages if reading and/or writing to a tag with incorrect keys
- Added error messages if reading and/or writing to a disconnected tag
- Reorganized tests
- Added logging
- Fixed issue with tag ping on some phone models
- Updated dependencies
- Added UID display for MifareClassic tag
- Updated flutter version
- Updated dependencies versions

### 2.0.0
- Rewrite in Flutter
- Removed confusing functionalities ("Reset tag" and the whole templating system)
- Fixed the code which changes the balance (it now targets only the 3 useful bytes instead of the whole block + it now takes into account the two first bytes of block 10)
- Added an "Auto-repair" function which can repair the tag in case of connection loss during a "Write from dump" or "Change UID"
