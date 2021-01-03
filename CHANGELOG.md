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
