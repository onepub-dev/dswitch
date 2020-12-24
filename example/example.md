# channels
DSwitch support three Dart channels

* stable
* beta
* dev

# install a channel

```bash
dswitch stable install
  Installing stable (2.12.0) ...
  Fetching: 100 %
  Expanding release...
  Expansion complete.
  Install of stable channel complete

```

# switch between channels

```
dswitch switch beta
  Downloading latest version (2.12.0-133.2.beta) for beta
  Fetching: 100 %
  Expanding release...
  Expansion complete.
  Switched to beta (2.12.0-133.2.beta)
 
  You need to restart your terminal session.
```

You will need to restart your terminal.


# upgrade a channel to the latest version

```bash
dswitch stable upgrade
  Downloading 2.10.4...
  Fetching: 100 %
  Expanding release...
  Expansion complete.
  Upgrade of channel stable to 2.10.4 complete

```

# list locally cached versions

```
dswitch beta list
  The following versions for the beta are cached locally:
  2.12.0-133.2.beta

```

# list versions available for download

```
dswitch beta list --archive
  The following versions for the beta are available to download:
  2.12.0-133.2.beta
  2.12.0-133.1.beta
  2.12.0-29.10.beta
  2.12.0-29.7.beta
  2.11.0-213.5.beta
 ... 

```

# install a specific version

```
dswitch stable install 2.8.1
  You need to add dswitch to your path.
  Prepend the following path to your PATH environment variable.
  /home/bsutton/.dswitch/active
  Installing stable version 2.8.1...
  Fetching: 100 %
  Expanding release...
  Expansion complete.
  Install of stable channel complete
```

# install a specific version from a menu of available versions

```
dswitch dev install --select
    1) 2.12.0-133.0.dev
    2) 2.12.0-114.0.dev
    3) 2.12.0-110.0.dev
    4) 2.12.0-96.0.dev
    5) 2.12.0-79.0.dev
    6) 2.12.0-69.0.dev
    7) 2.12.0-51.0.dev
    8) 2.12.0-33.0.dev
    9) 2.12.0-29.0.dev
   10) 2.12.0-13.0.dev
   11) 2.12.0-0.0.dev
   12) 2.11.0-266.0.dev
   13) 2.11.0-240.0.dev
   14) 2.11.0-218.0.dev
   15) 2.11.0-213.0.dev
   16) 2.11.0-190.0.dev
   17) 2.11.0-189.0.dev
   18) 2.11.0-180.0.dev
   19) 2.11.0-176.0.dev
   20) 2.11.0-161.0.dev
  Select Version to install: 1
  Fetching: 100 %
  Expanding release...
  Expansion complete.
  Install of dev channel complete
```

# pin a channel to a specific version

```
dswitch stable pin 2.8.1
  Channel stable is now pinned to 2.8.1
```

# unpin a channel

```
dswitch stable unpin
  Channel stable is now on 2.10.4
```

# get the status of a channel

```
dswitch stable status
  Status for channel stable:
  Current Version: 2.10.4
  Is Pinned: false
  Lastest cached Version: 2.10.4
  Available for download: 2.10.4
```

# get the status of all channels

```
dswitch status
  The active channel is beta on 2.12.0-133.2.beta
  
  Status for channel stable:
  Current Version: 2.10.4
  Is Pinned: false
  Lastest cached Version: 2.10.4
  Available for download: 2.10.4
  
  Status for channel beta:
  Current Version: 2.12.0-133.2.beta
  Is Pinned: false
  Lastest cached Version: 2.12.0-133.2.beta
  Available for download: 2.12.0-133.2.beta
  
  Status for channel dev:
  Current Version: 2.12.0-133.0.dev
  Is Pinned: false
  Lastest cached Version: 2.12.0-133.0.dev
  Available for download: 2.12.0-133.0.dev
```



