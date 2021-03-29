# 3.2.3
added pub activation logic to pin and unpin so now whenever we switch versions we pre-compile dswitch.

# 3.2.2
Fixed a bug when checking if a symlink exists.
Added command to pre-compile dswitch after switching so that it is functional against the new version of dart.

# 3.2.1
Added configue for running all unit tests.
Fixed bugs caused by having to revert to dcli 0.35

# 3.2.0
Reverted to dcli 0.35.0 as this is the last version that support dart 2.6.0

# 3.1.0
reverted nnbd migration. dswitch by nature needs to run under older version of dart (we support from 2.6) so we can not move to nnbd.
Minor grammar fixes.

# 3.0.0
Migrated to nnbd.

# 2.0.1
Add channel validation for the `use` cmd so that it provides a coherent warning if the users enters a non-existing channel.

# 2.0.0
Breaking change to the cli interface.

Changed the switch command to use. This bring is inline with fvm and feels less verbose then dswitch switch.

Instead of:
dswitch switch beta

use:

dswitch use beta
# 1.1.2
upgraded to latest version of dcli.
released 1.1.1

# 1.1.1
upgrade was checking the latest downloaded version not the currentVersion. You may have downloaded the latest version but not switched to it. We now check against the currentVersion and make certain we always switch to the latests.
Now prints dswitch version no. on start.
changed the minimum dart version back to 2.6 so we can switch to older versions of dart.

# 1.1.0
Change the minimum dart version to 2.6.0 so we can switch back to older versions of dart.
# 1.0.0
Fixed a bug in the pin and unpin commands. If the channel being pinned/unpined is the active channel then we need to also recreate the active link.

# 0.9.7
Added hook to automate creation of git hub release
Fixed incorrect error message.

# 0.9.6
Fixed permissions on the post release hook.

# 0.9.5
Added post release hook to automatically create a binary release.

# 0.9.4
Added support for arm and x32 architectures.


# 0.9.3
A number of fixes for Windows  to resolve failing unit tests.
Fix for isPrivilgedUser under windows cmd.exe


# 0.9.2
Fixed the bug where dswich would take something like 10 seconds to such down after any operation that fetch http data.

# 0.9.1
Improved first run messages.

# 0.9.0
fixed bug on first run if .dswitch directory didn' exist.
fixed stack overflow on windows.

# 0.3.0
Updated to dcli 0.39.1 which includes fixes for windows privileges and dev mode.

# 0.2.0
On windows we now require the user to be running in development mode so we can create symlinks.



# 0.1.0
Fixed bug where zip not being unpacked on windows/macosx.
now force administrator rights on windows. as needed to create links.

# 0.0.3
Added examples.
updated to latest dependencies.

# 0.0.2
first release
progress message now working correctly. cleanup of the status messags.
removed completerex.
The progress now updates on the same line.
Update README.md
