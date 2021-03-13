from gi.repository import Notify

Notify.init('Nag')

def show(msg):
	Notify.Notification.new(msg).show()
