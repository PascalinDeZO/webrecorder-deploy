#!/bin/bash

if [$SUDO_USER];
then
	CURR_USER = $SUDO_USER
else
	CURR_USER = $(whoami)
fi


VERSION = $(sudo -u $CURR_USER ansible --version)


if [$? -ne 0];
then
	echo "Package ansible is not installed. Installing ..."
	apt-get update
	apt-get install software-properties-common
	apt-add-repository ppa:ansible/ansible
	apt-get update
	apt-get install ansible
fi

echo "Enabling httpd_can_network_connect ..."
sudo -u $CURR_USER setsebool -P httpd_can_network_connect on

NGINX = $(ansible-galaxy list | sudo -u $CURR_USER grep nginx)

if [$? -ne 0];
then
	"Installing roles from Galaxy ..."
	ansible-galaxy install -r requirements.yml
	chown -R $CURR_USER
fi

sudo -u ansible-playbook -i inventory.ini playbook.yml --extra_vars $1
