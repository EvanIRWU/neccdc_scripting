#!/bin/bash
#echo tty1 > /etc/securetty
#getent groups root, wheel, adm, admin

if [[ $1 == "-illegal-users" ]]; then
	#prints the users with UIDs under 1000 that have /bin/ in theit logon shell
	users=$(cat /etc/passwd | awk -F: '{if ($3 < 1000) print $0;}')
	echo -e "userdel -r LOGIN to remove unwanted users"
fi

if [[ $1 == "-userlist" ]]; then
        #prints the current userlist on the box with UIDs over 1000
        users=$(cat /etc/passwd | awk -F: '{if ($3 > 999) print $0;}')
	echo -e "userdel -r LOGIN to remove unwanted users"
fi

if [[ $1 == "-purge-ssh" ]]; then
	#remove all ssh keys
	rm -rf /home/*/.ssh/authorized_keys
fi

if [[ $1 == "--services-running" ]]; then
	if [[ $2 == "-d" ]]; then
		#detailed view
		service --status-all | grep [+] | awk '{print $4}' | xargs systemctl status
	else 
		#simple view
		service --status-all | grep [+]
	fi
fi

if [[ $1 == "--services-off" ]]; then
        if [[ $2 == "-d" ]]; then
                #detailed view
                service --status-all | grep [-] | awk '{print $4}' | xargs systemctl status
        else
                #simple view
                service --status-all | grep [-]
        fi
fi

if [[ $1 == "--backup" ]]; then
	bud=/etc/opt/hereitis
	mkdir $bud
	cp /etc/passwd $bud/pw
	cp /etc/shadow $bud/sdw
	cp /etc/group $bud/grp
	cp /etc/gshadow
	cp /etc/ssh $bud/ssh
	cp /etc/hosts $bud/hosts
	cp -r /etc/cron* $bud/
	cp /etc/services /$bud/svs
fi	

if [[ $1 == "-suids" ]]; then
	echo "suids"
	echo
	find / -perm -4000
	echo "guids"
	echo
	find / -perm -2000
#GTFOBins
fi

if [[ $1 == "-ss" ]]; then
	if [[ $2 == "-l" ]]; then
		ss -plunt
	fi
	if [[ $2 == "e" ]]; then
		ss -peunt
	fi
fi

if [[ $1 == "-update" ]]; then
	if [[ $2 == "-d" ]]; then
		apt update
		apt upgrade
		apt autoremove
	fi
	if [[ $2 == "-rh" ]]; then
		yum update
	fi #https://access.redhat.com/sites/default/files/attachments/rh_yum_cheatsheet_1214_jcs_print-1.pdf
fi



