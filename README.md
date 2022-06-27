DSwitch is a cli tool that allows you to rapidly switch between channels and versions of Dart.

If you are a flutter user then you are better off using FVM as FVM changes the version of Dart embedded in Flutter.

DSwitch is intended to help manage a standalone version of Dart if you are doing things like building CLI applications.

For those interested, DSwitch is written in Dart using the [DCli](https://pub.dev/packages/dcli) api library.

DSwitch can switch between Dart Channels (stable, beta, dev) as well as versions within those channels.

Switching between Dart channels is as easy as:

```
dswitch use beta
```

Full documenation is on [gitbooks](https://dswitch.onepub.dev/).
