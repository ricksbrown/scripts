# IRDROID

Running on Ubuntu, I must have broken the lirc installation on the bare metal. Here I describe how I got this working in a Docker container (it wasn't as easy as you would think).

1. Build the [Dockerfile](Dockerfile):
   `docker build -t ricksbrown/linlirc .`
2. Run it on HTPC:
   `docker run -d -t --privileged --restart=unless-stopped  --name lircnix ricksbrown/linlirc`
3. Use it:
   `docker exec lircnix irsend SEND_ONCE LG_AKB73715601 KEY_VOLUMEDOWN`

## Control from iPhone

This lets you do "Hey Siri TV Power" or push a shortcut button on the phone desktop.

0. Use the inbuilt Shortcuts app (make sure script shortcuts are enabled in the settings)
1. New shortcut
2. Add action `Run script over SSH`
3. Fill in all the SSH details (host, authentication etc)
4. Add the script, simply: `docker exec lircnix irsend SEND_ONCE LG_AKB73715601 KEY_POWER`
   
   For changing the volume, repeat it a few times: 
   ```bash
   docker exec lircnix irsend SEND_ONCE LG_AKB73715601 KEY_VOLUMEDOWN KEY_VOLUMEDOWN KEY_VOLUMEDOWN KEY_VOLUMEDOWN KEY_VOLUMEDOWN
   ```

### Pro Tip

Using the iOS Shortcuts app and `playerctl` it is possible to play/pause stop HTPC playback from iOS too.

On the HTPC: `sudo apt install playerctl`

In the Shortcuts app, ass a SSH shortcut like above but use this script: `playerctl play-pause`

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

## Notes

Careful what other dongles are plugged in to USB. I had a Realtek RTL2832U dongle plugged in which caused me issues for days.

Also, I have tried a CEC injector instead of IR - CEC is a load of rubbish, lots of issues.
