# htpc mqtt listener

Allowed me to do this in Home Assistant:

```yaml
alias: Turn Soundbar back on
description: If the soundbar has gone to sleep while the TV is on, turn it back on
trigger:
  - platform: state
    entity_id: media_player.lg_webos_smart_tv
    attribute: sound_output
    to: tv_speaker
    from: external_speaker
condition: []
action:
  - service: notify.lg_webos_smart_tv
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
