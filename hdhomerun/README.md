# HDHOMERUN

## WATCHING AWAY FROM HOME

Assumptions:

* HDHomeRun device running on remote network
* Linux machine running on remote network with NordVPN Meshnet connection
* NordVPN Meshnet set up on local machine

1. Start Meshnet on local machine and find the remote machine's meshnet hostname.
2. On the local machine, run the following, using the hostname you found above:

```bash
ssh remote-hostname.nord -L 5004:hdhomerun.local:5004 -L 65001:hdhomerun.local:80
```

3. Now you should be able to watch TV by opening the following URL in VLC: http://localhost:65001/lineup.m3u
