# htpc mqtt listener

Allows control of the HTPC via MQTT messages.
Since just about anything can send an MQTT message this is pretty darn powerful.

The primary use case is needing to control the HTPC from inside a docker container.

## Installation

Obviously NodeJS and NPM must be installed.
Also this assumes an MQTT broker is installed (I am using Mosquitto right now).

```bash
# Get the code
cd /home/htpc/projects
git clone git@github.com:ricksbrown/scripts.git

# Install the dependencies
cd scripts/htpc-mqtt
npm install

# Make it executable
sudo chmod +x htpcmqtt.js

# Wire it up as a service
sudo vi /etc/systemd/system/htpc-mqtt.service
```

Make this the content (make sure the `ExecStart`, `User`, `Group` and `WorkingDirectory` are correct):

```
[Unit]
Description=HtpcMqtt

[Service]
ExecStart=/home/htpc/projects/scripts/htpc-mqtt/htpcmqtt.js
Restart=always
User=htpc
Group=htpc
Environment=PATH=/usr/bin:/usr/local/bin
Environment=NODE_ENV=production
WorkingDirectory=/home/htpc

[Install]
WantedBy=multi-user.target
```

Then it can be started with systemd:

```bash
sudo systemctl start htpc-mqtt
```

Enable auto-start on boot:

```bash
sudo systemctl enable htpc-mqtt
```

View output:

```bash
journalctl -u htpc-mqtt
```

## Home Assistant

### Automatically restart the soundbar

Add this to `automations.yaml` in Home Assistant (well you can add it thru the GUI http://127.0.0.1:8123/config/automation/dashboard):


```yaml
alias: Turn Soundbar back on
description: If the soundbar has gone to sleep while the TV is on, turn it back on
trigger:
  - platform: state
    entity_id: media_player.lg_webos_tv_lf6300
    attribute: sound_output
    to: tv_speaker
    from: external_speaker
condition: []
action:
  - service: notify.lg_webos_tv_lf6300
    data:
      message: The soundbar turned off - will restart...
  - delay:
      hours: 0
      minutes: 0
      seconds: 11
      milliseconds: 0
  - service: mqtt.publish
    data:
      topic: /htpc
      payload: soundbar_power
mode: single

```
