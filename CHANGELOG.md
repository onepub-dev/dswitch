# 7.2.0
- lint fixes and upgraded all packages.

# 7.0.0
- upgraded to dcli 4.x and dart 3.2 to fix the waitFor issue.

# 6.0.0-alpha.2
- removed the logic that force an install of the stable version of dart
  given we must already be running a dart version we don't need to install
  one and by not installing one we are not forcing a specific version on the
  user.
# 6.0.0-alpha.1
- moved to the alpha version of dcli 4.x

# 5.3.2
- upgraded dcli to fix a null check.

# 5.3.1
- upgraded to the latest version of dcli to correctly detect when we are running in docker.

# 5.3.0
- upgraded te latest version of dcli
- added permission to addtional exes.

# 5.2.1
- upgraded to archive 3.3.8 due to security issue.
# 5.2.0
- added toString to ExitExeption so we see the problem in unit tests.
- Added logic to add +x to the dart exe as I suspect that when we use ZipDecoder that it doesn't restore the execute flag.  This was seen when running dswitch under a docker that didn't have unzip installed.

# 5.1.0
- moved to pubspec_manager

# 5.0.2
- upgrade dependency versions

# 5.0.0
- upgraded for dart 3.x support.

# 4.7.5
- added support for dart 2.19.5 which modified the .pub_cache path for hosted libraries.

# 4.7.4
- incorrect architecture X86 returned when it should be x86
- Thanks to genesistms for the PR!

# 4.7.3
- corrected the archive paths for armv7 and armv8

# 4.7.2
- we now throw a OSError when we detect an unrecognized architecture.
- upgraded to latest version of system_info2 to take advantage of the new kernelArchitecture call.

# 4.7.0
- Fixed a bug on the RPI. It was selecting the wrong cpu architecture resulting
in x86 executables being downloaded.

# 4.6.0
- Add: new --force switch to the pin command to download/install the requested version withouth prompting the user.
- Add: a critical_test pre_hook to activate dswitch from source which is required before running unit tests.

# 4.5.2
- upgraded to scope 3.x
- experiements to pin a package version.

# 4.5.0
- switch the dswitch install path to /usr/local/bin as /usr/bin on macos is a readonly file system.

# 4.4.1
- Upgraded to latest settings_yaml to fix an async bug during saving of the .channel.yaml
The path .dswitch/channels/stable/.channel.yaml.bak does not exists.
#0      _Delete.delete (package:dcli_core/src/functions/delete.dart:22)
#1      delete (package:dcli_core/src/functions/delete.dart:15)
#2      SettingsYaml.save (package:settings_yaml/src/settings_yaml.dart:202)


# 4.4.0
- upgraded  to dcli 1.20.2 as 1.20.0 had issues running in a pure dart 2.12 environment.
- renamed isCurrentVersionInstalled to isLatestPubCacheVersionInstalled and added a flag to which controls whether a version installed from source is included. We do this so we can test dswitch from a global activation.
- relaxed the first run test to allow  us to run a copy of dswitch from a source version with a higher version no. than the version in pub-cache.
- the installer wasn't catching ExitExceptions. Added a try block and now output a nice message.
- unit test improvements.
- improved doco on releases.dart
- forced the cachedVersions to be sorted. Added logic to the channel.latest to reset the version if it gets buggered up, this is probably only an issue in testing but does no harm.
- Fixed the --verbose switch. It was print the word verbose and exiting.
- Removed all calls to exit so we can extend the unit tests to error conditions.

# 4.3.11
- upgraded lint_hard version.
- addec copyright notices.

# 4.3.10
- updated the doc paths to point at  onepub.dev .

# 4.3.9
- upgraded to scope 2.2.1
- Added a better message if the version selected to download doesn't exist.
- Added sorting of the versions to the list command.

# 4.3.7
- pinned the dcli and dcli_core versions as we need dswitch pinned to 2.12.

# 4.3.6
- updated the readme link to docs.
- removed redundant verbose option.
- Improved search path when running install in a test environment.

# 4.3.5
- applied lint_hard.
- updated dcli version

# 4.3.4
- Fix: the pin command when called without a version would exit if the version was already installed without pinning the version.
- updated dcli version

# 4.3.3
- We now install the latest stable build of dart as part of the install. 
- Fixed a permissions issue with settings.yaml as it was being set to being owned by root.

# 4.3.2
Fixed a bug in the first run install logic that assumed the .dswitch directory exists.

# 4.3.1
upgraded to dcli 1.13.3
# 4.3.0
upgraded to dcli 1.13.2

# 4.2.11
- Fixed bug under linux where the version no. was being written to /root/settings.yaml rather than HOME/settings.yaml. The result was the the linux version always thought an upgrade was required.
- Log the contents of the settings file after it is written in attempt to find why its not being udpated on linux.
- Added additional logging when updating settings file.

# 4.2.10
- released purely created to test the upgrade process.

# 4.2.9
Increased logging of version details to help diagnose install problems.

# 4.2.8
- upgraded to dcli 1.9.3
- Fixed bug where we tried to access local pubspec.yaml when installed.

# 4.2.7
 - and one more go. DCli had a bug in getPrimaryVersion as it was treating pre-release versions as releases.
# 4.2.6
* Another go at fixing the version detection when determing if an install is required.
 This bug was a result of a bug in dcli not processing pre-release version nos correctly which has now been fixe.

# 4.2.5
* fixed the logic that detcts that the active version has been installed under windows. Previously it continously reported that dswitch_install needed to be run.
* Improved errors when invalid argument passed on cli.
* Fixed a bug in dswitch disable when it tried to delete the linked directory rather than the symlink.

# 4.2.4
Improved the error message when an invalid switch is passed. No longer dumps a stack trace.

# 4.2.3
- upgraded dcli version for improved logging

# 4.2.2
- Added startup logic to ensure that the correct version of dswitch is running after a new pub global activate. Previoulsy the existing compiled version would continue to run. We now check the version no. matches  Updated the logic that finds a version to deal with dcli change to findPrimaryVersion which now returns null rather than throwing StateError if dswitch isn't in pub cache. This is mainly for dev environment.

# 4.2.1
- An attempt at fixing the logic that detects when dswitch_install needs to be run after a pub global activate is run to obtain a newer version.

# 4.1.0
- Fixes for running on Windows.
  The install process now correctly compiles and installs the dswitch exes on windows.
- Uses dcli 1.6.0 which fixes detection of admin writes when running under powershell.
- Added doctor command to help with diagnosing problems.

# 4.0.7

# 4.0.6
Corrected the dswitch use example.

# 4.0.5
updated homepage.

# 4.0.4

- Revised the install so that it installs into an existing OS path as overwriting the version in pub-cache was causing future pub gets to fail. 
  The error was: Failed to decode data using encoding 'utf-8', path = '~/.pub-cache/bin/dswitch'
- Added new commands to enable/disable dswitch so user can revert to the os installed dart.
- Moved the check for a compiled dscript to individual commands, so we can allow some useful commands to still run.
- Handled an exception when a symlink target doesn't exist.
- Added windows test to see if path had been updated in registry to tell the user to restart rather than telling them to add the path when it was allready in the reg.
- upgraded to dcli 1.5.3

# 4.0.3
Fixed failed release.


# 4.0.2
Fixes to the install option as compiles were failing.

# 4.0.0
- We now require that dswitch is compiled.
This gets around the issue of not being compatible with different versions of dart.
It has also allowed us to upgrade dswitch to nnbd and the latest dart version.

- Added dswitch_install as an exe which compiles dswitch.
- nndb migration.
- Added check that windows users are in development mode 

# 3.3.0
Added subcommand to delete a version of the sdk from a channel.
Added logic to delete the sdk zip file after we have expanded it.
Fixed a bug in the select options when the no. of menu items was less than the limit of 20.

# 3.2.7
grabed a copy of the fetch function from the latest version of dcli. As we have to support pre-nnbd version of dart we can't use the latest dcli. Older version of dcli contained a bug in the fetch command where in it wasn't shutting down the httpclient with the result that a dswitch command that preformed a fetch would take some 20seconds to shutdown. This patch fixes that issue.
moved pedantic from dev to dep as we are using unawaited.

# 3.2.6
removed the pub global activate calls as these  problems these were designed to resolve were just an artifact of my test environment.

# 3.2.5
formatting.

# 3.2.4
Cleaned up the pre-compile logic so it is activated at the command level so it only happens once.

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
