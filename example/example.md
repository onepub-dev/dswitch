# install a channel

```bash
dswitch stable install
dswitch beta install
dswitch dev install
```

# switch between channels

```
dswitch switch beta
```

You will need to restart your terminal.


# upgrade a channel to the latest version

```bash
dswitch stable upgrade
```

# list locally cached versions

```
dswitch beta list
```

# list version available for download

```
dswitch beta list --archive
```

# install a specific version

```
dswitch stable install 2.8.1
```

# install a specif version from a menu of available versions

```
dswitch dev install --select
```

# pin a channel to a specific version

```
dswitch beta pin 2.8.1
```

# unpin a channel

```
dswitch beta unpin
```

# get the status of a channel

```
dswitch dev status
```

# get the status of all channels

```
dswitch status
```



