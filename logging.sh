#!/bin/bash

# The sleep command will stop the program,
# after that time is expired, the command will execute
# if the command finds that sshd has anything having
# to do with accepted or denied, it will notify the 
# user, using a pop up terminal.

# NOTE: In order to exit the program, you MUST use CTRL + C

red="\e[0;91m"
green="\e[0;92m"
yellow="\e[0;33m"
bold="\e[1m"
blue="\e[0;94m"
uline="\e[4m"
reset="\e[0m"

DIRECTORY=/etc/script_logs
echo -e "${green}[${red}*${green}]${reset} System is now being monitored. I will notify you, if I find any suspicious activity."
if [[ -d "$DIRECTORY" ]]; then
	echo ""
else
	echo ""
	echo -e "${green}[${red}*${green}]${reset} Directory not found. Creating directory /etc/script_logs"

	mkdir /etc/script_logs

	cp /var/log/auth.log /etc/script_logs/master_log.log
	cp /var/log/auth.log /etc/script_logs/recent_log.log

	echo -e "${green}[${red}*${green}]${reset} Directory Successfully Created! Two new files have been added!"
fi
while [ 1 ]
do
	sleep 5
	# If the auth outputs something, then we know someone got into
	# SSH. We can view it now.
	#echo -e "${bold}SSH Suspicious Activity:${reset}"
	
	#zenity --notification --text "System update necessary!"
	# auth.log is for Debain/Ubuntu
	if [[ "$(cat /proc/version)" = *"Debain"* ]] || [[ "$(cat /proc/version)" = *"Ubuntu"* ]]; then
		rm /etc/script_logs/recent_log.log
		cp /var/log/auth.log /etc/script_logs/recent_log.log
		sudo truncate -s 0 /var/log/auth.log
		cat /etc/script_logs/recent_log.log >> /etc/script_logs/master_log.log
		if [[ "$(cat /etc/script_logs/recent_log.log | grep "Accepted")" = *"Accepted password for"* ]] || [[ "$(cat /etc/script_logs/recent_log.log | grep "Failed password for")" = *"Failed password for"* ]] || [[ "$(cat /var/log/auth.log | grep "sshd")" = *"sshd"* ]]; then
			echo -e "${yellow}${bold}SSH INFORMATION:${reset}"
		
		
			if [[ "$(cat /etc/script_logs/recent_log.log | grep "Accepted")" == *"Accepted password for"* ]]; then
				echo -e "   ${green}${bold}SUCCESSFUL LOGIN:${reset}"
				echo -e "    ${blue}USERNAME: ${red}$(cat /etc/script_logs/recent_log.log | grep "Accepted" | awk '{print $9}')"
				echo -e "    ${blue}IP ADDRESS: ${red}$(cat /etc/script_logs/recent_log.log | grep "Accepted" | awk '{print $11}')"
				echo -e "    ${blue}PORT: ${red}$(cat /etc/script_logs/recent_log.log | grep "Accepted" | awk '{print $13}') ${reset}"
				#echo -e "      ${red}${acceptauth}${reset}"
			fi
			if [[ "$(cat /etc/script_logs/recent_log.log | grep "Failed")" == *"Failed password for"* ]]; then
				echo -e "   ${green}${bold}FAILED LOGIN:${reset}"
				echo -e "    ${blue}USERNAME: ${red}$(cat /etc/script_logs/recent_log.log | grep "Failed" | awk '{print $9}')"
				echo -e "    ${blue}IP ADDRESS: ${red}$(cat /etc/script_logs/recent_log.log | grep "Failed" | awk '{print $11}')"
				echo -e "    ${blue}PORT: ${red}$(cat /etc/script_logs/recent_log.log | grep "Failed" | awk '{print $13}') ${reset}"
			fi
		fi
	fi

	# /var/log/secure is for Red Hat/CentOS/Fedora
	if [[ "$(cat /proc/version)" = *"Red Hat"* ]]; then
		if [[ "$(cat /var/log/secure)" = *"Accepted password for"* ]] || [[ "$(cat /var/log/secure)" = *"Failed password for"* ]]; then
			echo -e "${yellow}${bold}SSH INFORMATION:${reset}"
		
		fi
		if [[ "$acceptauthredhat" == *"Accepted password for"* ]]; then
			echo -e "   ${green}${bold}SUCCESSFUL LOGIN:${reset}"
			echo -e "      ${red}${acceptauthredhat}${reset}"
		fi
		if [[ "$failedauthredhat" == *"Failed password for"* ]]; then
			echo -e "   ${green}${bold}FAILED LOGIN:${reset}"
			echo -e "      ${red}${failedauthredhat}${reset}"
		fi
	fi

done