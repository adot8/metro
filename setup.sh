#!/bin/bash
#check if ran as root
check_root(){
	if [ "$EUID" -ne 0 ]
  then 
  	echo
  	echo -e "\e[31m[!]\e[0m Please run as root"
  	echo
  exit 0
fi

}


setup() {
	echo -e "\e[34m[+]\e[0m  Updating repositories" 
	sleep 1
	echo
	sudo apt-get update
	sleep 1
	echo
	echo -e "\e[34m[+]\e[0m  Installing dhcpig and bettercap" 
	sleep 1
	echo
	sudo apt install dhcpig bettercap bettercap-caplets
	sleep 1
	echo
 	chmod +x metro.sh
	echo -e "\e[32m[+]\e[0m  Done!" 
	exit 0
}

check_root
setup
