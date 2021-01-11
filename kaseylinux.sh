#!/bin/bash
if [[ $1 == "-illegal-users" ]]
	#prints the users with UIDs under 1000 that have /bin/ in theit logon shell
	users=$(cat /etc/passwd | awk -F: '{if ($3 < 1000) print $0;}')
	echo -e "userdel -r LOGIN to remove unwanted users"
fi

if [[ $1 == "-userlist" ]]
        #prints the current userlist on the box with UIDs over 1000
        users=$(cat /etc/passwd | awk -F: '{if ($3 > 999) print $0;}')
	echo -e "userdel -r LOGIN to remove unwanted users"
fi

if [[ $1 == "-purge-ssh" ]] 
	#remove all ssh keys
	rm -rf /home/*/.ssh/authorized_keys
fi

if [[ $1 == "--services-running" ]]
	if [[ $2 == "-d" ]]
		#detailed view
		service --status-all | grep [+] | awk '{print $4}' | xargs systemctl status
	else 
		#simple view
		service --status-all | grep [+]
	fi
fi

if [[ $1 == "--services-off" ]]
        if [[ $2 == "-d" ]]
                #detailed view
                service --status-all | grep [-] | awk '{print $4}' | xargs systemctl status
        else
                #simple view
                service --status-all | grep [-]
        fi
fi

if [[ $1 == "--backup" ]]
	bud=/etc/opt/hereitis
	mkdir $bud
	cp /etc/passwd $bud/pw
	cp /etc/shadow $bud/sdw
	cp /etc/group $bud/grp
	


