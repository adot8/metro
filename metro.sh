#!/bin/bash
# Automated PoC script displaying a variety of attacks for an SIEM to detect

dhcpsrv=""
dfg=""
target=""
$4

#Help function
help() {
	echo
	echo "Usage: sudo ./metro.sh [-h] [-g] [-d] [-t] <interface>"
	echo
	echo "-h			Display help message"
	echo "-g 		    default gateway"
	echo "-d 			dhcp server"
	echo "-t			target"
	echo
	echo "ex: sudo 6ix -t 192.168.1.129 -d WRENCH.local -i eth0"
	exit 0
	exit 0
}

#Cleanup function
cleanup() {
	echo
	echo " [+] Stopping mitm6"
	kill $mitm6_pid 2>/dev/null
	sleep 3
	echo " [+] Stopping ntlmrelayx"
	kill $ntlm_pid 2>/dev/null
	sleep 1
	exit 0
}

menu() {
	echo
	echo "MEETTRROOOOOOOOO!!!!!"
	echo
	echo "[01] Ping of Death"
	echo "[02] SSH bruteforce"
	echo "[03] DHCP Starvation"
	echo "[04] MITM Arp Poisioning"
	echo "[05] Ping Sweep"
	echo "[06] Exit"
	echo 
	read -p "> " option
	echo $option	
}

pod() {
	echo
}

#CTRL-C force cleanup
trap cleanup SIGINT


# Require options
if [ $# -eq 0 ]
then
	echo
    echo "[*] Missing options!"
    echo "[*] Run ./metro -h for help"
    echo ""
    exit 0
fi
	
# Get the options
while getopts "hg:d:t:" option; do
   case $option in
      h) # display Help
         help
         exit;;
	  g) # default gateway
	  	dfg=$OPTARG;;
	  d) # dhcp server
	  	dhcpsrv=$OPTARG;;
	  t) # target for dos
	  	target=$OPTARG;;
	  \?) # Invalid option
	  	 echo
         echo "[*] Invalid option"
         exit;;
   esac
done
menu
