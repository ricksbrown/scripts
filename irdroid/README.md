# IRDROID

Running on Ubuntu, I must have broken the lirc installation on the bare metal. Here I describe how I got this working in a Docker container (it wasn't as easy as you would think).

1. Build the [Dockerfile](Dockerfile):
   `docker build -t ricksbrown/linlirc .`
2. Run it on HTPC:
   `docker run -d -t --privileged --restart=unless-stopped  --name lircnix ricksbrown/linlirc`
3. Use it:
   `docker exec lircnix irsend SEND_ONCE LG_AKB73715601 KEY_VOLUMEDOWN`

## Registering Keyboard Shortcuts

### Using xbindkeys

```bash
sudo apt install xbindkeys xbindkeys-config
xbindkeys-config
```

Here is an example of my initial [~/.xbindkeysrc](xbindkeysrc)

### Using Desktop Settings

Well this way seems to stop working after the TV has been off for a while.

~~After that, set custom keyboard shortcuts in Ubuntu through the desktop settings.
Give it whatever name and shortcut, the `Command` can be passed to sh as a string, like so:~~

`sh -c "docker exec lircnix irsend SEND_ONCE LG_AKB73715601 KEY_POWER"`
