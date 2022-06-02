#!/usr/bin/env node
/*
	This is a MQTT subscriber which listens for messages and executes the appropriate commands.

	An example problem this solves: with Home Assistant running in a Docker container, how can we
	run commands on the host system, for example executing LIRC commands?

	Using MQTT allows anything to control the HTPC.
*/
const mqtt = require('mqtt');
const { exec } = require('child_process');
const mqttHost = '127.0.0.1';
const mqttPort = '1883';
const clientId = 'htpc_commander';
const topic = '/htpc';

// command prefeixes used to start with "docker exec lircnix "
const tvCommandPrefix = 'irsend SEND_ONCE LG_AKB73715601';
const soundbarCommandPrefix = 'irsend SEND_ONCE soundbar';

const commandMap = {
	'tv_voldown': `${tvCommandPrefix} KEY_VOLUMEDOWN`,
	'tv_volup': `${tvCommandPrefix} KEY_VOLUMEUP`,
	'tv_power': `${tvCommandPrefix} KEY_POWER`,
	'tv_mute': `${tvCommandPrefix} KEY_MUTE`,
	'soundbar_power': `${soundbarCommandPrefix} POWER`,
	'soundbar_volup': `${soundbarCommandPrefix} VOLUME_UP`,
	'soundbar_voldown': `${soundbarCommandPrefix} VOLUME_DOWN`,
	'soundbar_wooferup': `${soundbarCommandPrefix} WOOFER_UP`,
	'soundbar_wooferdown': `${soundbarCommandPrefix} WOOFER_DOWN`,
	'soundbar_woofermute': `${soundbarCommandPrefix} WOOFER_MUTE`,
	'soundbar_btpair': `${soundbarCommandPrefix} BT_PAIR`,
	'soundbar_source': `${soundbarCommandPrefix} SOURCE`,
	'soundbar_wakeup': `${soundbarCommandPrefix} WAKEUP`,
	'soundbar_control': `${soundbarCommandPrefix} SOUND_CTRL`
};

const connectUrl = `mqtt://${mqttHost}:${mqttPort}`;

const client = mqtt.connect(connectUrl, {
	clientId,
	clean: true,
	connectTimeout: 4000,
	reconnectPeriod: 1000
});


client.on('connect', () => {
	console.log('Connected');
	client.subscribe([topic], () => {
		console.log(`Subscribe to topic '${topic}'`);
	});
});

client.on('message', (topic, data) => {
	const payload = data.toString();
	console.log('Received Message:', topic, payload);
	const cmd = commandMap[payload];
	if (cmd && commandMap.hasOwnProperty(payload) ) {
		exec(cmd, (err, stdout, stderr) => {
			if (err) {
				console.error(err)
			} else {
				console.log(`stdout: ${stdout}`);
				console.log(`stderr: ${stderr}`);
			}
		});
	}
});
