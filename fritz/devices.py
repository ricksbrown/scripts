
################################################################################
# Lists all hosts connected to router including their names and IP addresses
#
# Requires:
# 	pip3 install fritzconnection
#################################################################################
import os
from fritzconnection.lib.fritzhosts import FritzHosts

USER = os.getenv('FRITZ_USERNAME')
PASSWORD = os.environ.get('FRITZ_PASSWORD')
IP_ADDR = os.environ.get('FRITZ_IP_ADDRESS')

fh = FritzHosts(address=IP_ADDR, password=IP_ADDR, user=USER)

hosts = fh.get_hosts_info()
for index, host in enumerate(hosts, start=1):
	status = 'active' if host['status'] else  '-'
	ip = host['ip'] if host['ip'] else '-'
	mac = host['mac'] if host['mac'] else '-'
	hn = host['name']
	print(f'{index:>3}: {ip:<16} {hn:<32}  {mac:<17}   {status}')
