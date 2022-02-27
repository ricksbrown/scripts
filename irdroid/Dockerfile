FROM ubuntu
RUN apt-get update
RUN apt-get upgrade -y
RUN apt-get install lirc curl vim -y

# DL remote which will be exposed as LG_AKB73715601
RUN curl https://sourceforge.net/p/lirc-remotes/code/ci/master/tree/remotes/lg/AKB73715601.lircd.conf?format=raw --output /etc/lirc/lircd.conf.d/AKB73715601.lircd.conf

# Update lirc_options.conf to contain 'driver = irtoy'
RUN sed -i 's/^\(driver\s*=\s*\).*$/\1irtoy/' /etc/lirc/lirc_options.conf
# Don't run lirc in Daemon mode - Docker needs to see a foreground task running.
RUN sed -i 's/^\(nodaemon\s*=\s*\).*$/\1True/' /etc/lirc/lirc_options.conf
CMD ["/usr/sbin/lircd"]
