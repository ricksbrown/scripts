# pip3 install pulsectl
import pyttsx3
import pulsectl

# Call this to get a 'say' function which reuses underlying engine instance
def get_sayer():
	engine = pyttsx3.init()
	pulse = pulsectl.Pulse()

	def say(msg):
		print(msg)
		if not is_running(pulse):
			engine.say(msg)
			engine.runAndWait()
	return say

def is_running(pulse):
	sinks = pulse.sink_list()
	return any(sink.state == 'running' for sink in sinks)
