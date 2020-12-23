DSwitch is a cli tool that allows you to rapidly switch between channels and versions of Dart.

If you are a flutter user then you are better of using FVM as FVM changes the version of dart embedded in Flutter.

DSwitch is intended to help manage a standalone version of Dart if you are doing things like building cli applications.

For those interested, DSwitch is written Dart using the DCli api library.

DSwitch can switch between dart channels as well as versions within those channels.

Switching between dart channels is as easy as:

```
dswitch switch beta
```

Full documenation is on [gitbooks](https://bsutton.gitbook.io/dswitch/).
