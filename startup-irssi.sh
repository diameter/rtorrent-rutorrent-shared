#!/usr/bin/env sh
# Some of this was copied from http://pulsedmedia.com/remote/autodl.txt

# For new installs, we need to wait and ensure that the user gets created.
sleep 5

# Set up .autodl dir, and allow for configs to be saved.
if [ ! -h /home/rtorrent/.autodl ]
then
	echo "Linking autodl config directory to /downloads/.autodl."
	if [ ! -d /downloads/.autodl ]
	then
		echo "Did not find /downloads/.autodl existed. Creating it."
		mkdir /downloads/.autodl
		chown rtorrent:rtorrent /downloads/.autodl
	fi
	ln -s /downloads/.autodl /home/rtorrent/.autodl
else
	echo "Do not need to relink the autodl config directory."
fi

if [ -f /downloads/.autodl/autodl.cfg ]
then
	echo "Found an existing autodl configs. Will not reinitialize."
	irssi_port=$(grep gui-server-port /downloads/.autodl/autodl2.cfg | awk '{print $3}')
	irssi_pass=$(grep gui-server-password /downloads/.autodl/autodl2.cfg | awk '{print $3}')
else
	echo "Need to set up a new autodl install."

	irssi_pass=$(perl -le 'print map {(a..z,A..Z,0..9)[rand 62] } 0..pop' 15)
	irssi_port=$((RANDOM%64025+1024))
	
	echo "Creating necessary configuration files ... "
	touch /downloads/.autodl/autodl.cfg
	cat >/downloads/.autodl/autodl2.cfg<<ADC
[options]
gui-server-port = ${irssi_port}
gui-server-password = ${irssi_pass}
ADC
	chown -R rtorrent:rtorrent /downloads/.autodl
fi



# Set up .irssi scripts.
if [ ! -d /home/rtorrent/.irssi ]
then
	echo "Creating necessary directory structure for irssi and downloading files ... "
	mkdir -p /home/rtorrent/.irssi/scripts/autorun && cd /home/rtorrent/.irssi/scripts || (echo "mkdir failed ... " && exit 1)
	curl -sL http://git.io/vlcND | grep -Po '(?<="browser_download_url": ")(.*-v[\d.]+.zip)' | xargs wget --quiet -O autodl-irssi.zip
	unzip -o autodl-irssi.zip >/dev/null 2>&1
	rm autodl-irssi.zip
	cp autodl-irssi.pl autorun/
	chown -R rtorrent:rtorrent /home/rtorrent/.irssi
else
	echo "Found irssi scripts are installed. Skipping install."
fi



# Install the web plugin.
if [ ! -d /var/www/rutorrent/plugins/autodl-irssi ]	
then
	echo "Installing web plugin portion."
	# Web plugin setup.
	cd /var/www/rutorrent/plugins/
	git clone https://github.com/autodl-community/autodl-rutorrent.git autodl-irssi > /dev/null 2>&1
	cd autodl-irssi
	cp _conf.php conf.php
	sed -i "s/autodlPort = 0;/autodlPort = ${irssi_port};/" conf.php
	sed -i "s/autodlPassword = \"\";/autodlPassword = \"${irssi_pass}\";/" conf.php
else
	echo "Found web plugin portion is already installed."
fi

echo "Starting up irssi."
su --login --command="TERM=xterm irssi" rtorrent

