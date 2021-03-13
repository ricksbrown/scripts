import time
import gi
gi.require_version('Notify', '0.7')
from gi.repository import Notify

Notify.init('Nag')

def show(msg):
	print(msg)
	notification = Notify.Notification.new(msg)
	notification.show()
	time.sleep(10)
	notification.close()

def show_all(msgs):
	show('\r\n'.join(msgs))
