/*
	Script to control pump from Shelly 1 Plus based on float switch state.
	The reason I did not use basic timers was the fear that the float switch may not have dropped into the "off" position
	when the timer ends, meaning the pump would not come back on.

	I also could have programmed this using a "Scene" but that relies on a cloud connection and I want to be able to rely on the pump.

	I have the Shelly configured to: '"Detached" switch mode'.
	Ensure the script is "Enabled".
*/
let CONFIG = {
	operateSecs: 30,  // how many additional seconds to operate after the float switch turns "off"
	inputId: 0,
	switchId: 0
};

let timer = 0;

function eventHandler(event, user_data) {
	if (typeof event.info.event !== "undefined") {
		if (event.info.id === CONFIG.inputId) {
			
			// for(let prop in event.info) {
			// 	print('prop', prop, event.info[prop]);
			// }

			if (event.info.event === "toggle") {
				if (timer) {
					Timer.clear(timer);  // Clear any previous timed actions
					timer = 0;
				}
				
				if (event.info.state) {
					setOutputState(event.info.state);
				} else {
					turnOffDelayed();
				}
			}
		}
	}
}

function setOutputState(state) {
	print("Setting switch state:", state);
	Shelly.call("Switch.Set", {"id": CONFIG.switchId, "on": state});
}

function turnOffDelayed() {
	print("Setting timer to turn switch off");
	timer = Timer.set(CONFIG.operateSecs * 1000, false, function() {
		setOutputState(false);
	}, null);
}

function isInputOn() {
	let status = Shelly.getComponentStatus("input:" + JSON.stringify(CONFIG.inputId));
	return status.state;
}


Shelly.call("Switch.SetConfig", {
	id: CONFIG.switchId,
	config: {
		in_mode: "detached",
	},
});

Shelly.addEventHandler(eventHandler);

if (isInputOn()) {
	setOutputState(true);  // You might need to get pumping right away!
} else {
	print("Script started - input is off");
}
