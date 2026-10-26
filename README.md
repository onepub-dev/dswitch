DSwitch is a cli tool that allows you to rapidly switch between channels and versions of Dart.

If you are a flutter user then you are better off using FVM as FVM changes the version of Dart embedded in Flutter.

DSwitch is intended to help manage a standalone version of Dart if you are doing things like building CLI applications.

For those interested, DSwitch is written in Dart using the [DCli](https://pub.dev/packages/dcli) api library.

DSwitch can switch between Dart Channels (stable, beta, dev) as well as versions within those channels.

## Upgrading to 8.0.0

DSwitch 8.0.0 requires Dart 3.13 or later. SDKs downloaded by older DSwitch
versions remain on disk, but DSwitch 8.0.0 only treats a version as cached after
it has completed the new verified installation process. Reinstall a version with
`dswitch <channel> install <version>` before switching to it. You can remove an
old cached directory with `dswitch <channel> delete <version>`.

Switching between Dart channels is as easy as:

```
dswitch use beta
```

Full documentation is on [GitBook](https://dswitch.onepub.dev/).


# Unit tests

Use the critical_test package to run unit tests as we use a ct pre_hook to
activate dswitch from source to run the tests.
