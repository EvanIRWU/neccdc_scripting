#!/bin/bash
#echo tty1 > /etc/securetty
#getent groups root, wheel, adm, admin
#I know this isn't prime. It's actually quite terrible, and I want it to be much better. 
###Kasey Litchford - 01/11/2021

while [[ $# -ne 0 ]]; do

	if [[ $1 == "-h" ]]; then
		echo "
		-illegal-users				#users under 1000 with /bin/ in the logon shell field
		-userlist					#users on the box with uid's 1000 and over
		-purge-ssh					#kills all .ssh keys
		--services-running	[-d]	#prints all services running, detailed shows systemctl status
		--services-off	[-d]	#prints all services not running, detailed shows systemctl status
		--backup					#backs up directories of interest
		--suids						#prints suid and guid bit files, contrast with GTFOBins
		--ss	[-p] [-l]			#plunt or peunt for listening or established ports
		--update	[-d] [-rh]		#debian or redhat update (sources.list or repos.list check em)
		--sums						#makes sums of directories that may or may not have reason to change
		--sumdiff					#hopefully will implement some way to compare and understand diff

		-illegal-users -userlist -purge-ssh --services-running -d --services-off -d --backup --suids --ss -p ss -l --update -d --sums
		"
	fi

	if [[ $1 == "-illegal-users" ]]; then
		echo "
		users with 999 or below, containing /bin/ in their shell path
		set to /sbin/nologin | /bin/false
		usermod --shell /sbin/nologin <user>
		chsh --shell /sbin/nologin <user>
		userdel -r -f <user>
		"
		cat /etc/passwd | awk -F: '{if ($3 < 1000) print $0;}'
		users=$(cat /etc/passwd | awk -F: '{if ($3 < 1000) print $0;}')
		echo "groups in sudoers"
		cat /etc/sudoers | grep ALL
		shift
	fi

	if [[ $1 == "-userlist" ]]; then
		echo "
		users with 1000 or above
		double check that these are approved users only
		grep for :0: to look for other root users
		userdel -r -f <user>
		"
		cat /etc/passwd | awk -F: '{if ($3 > 999) print $0;}'
		users=$(cat /etc/passwd | awk -F: '{if ($3 > 999) print $0;}')
		shift
	fi

	if [[ $1 == "-purge-ssh" ]]; then
		echo "
		/home/<user>/.ssh/id_rsa is where pre-authenticated users will store their keys
		we don't want that
		was previously authorized_keys but that's for keys you're comfortable connecting to
		overall, delete .ssh entirely for a quick reset		
		also looks for some persistence by red team
		"
		rm -rf /home/*/.ssh/id_rsa
		echo "authorized_keys ------ :"
		cat /etc/ssh/sshd_config | grep authorized_keys
		shift
	fi

	if [[ $1 == "--services-running" ]]; then
		echo '
		I like detailed, but thats not necessary
		make sure none of these are crazy ones we might not need
		service --status-all | grep [+] | awk "{print $4}" | grep -E "cups|isc-dhcp-server|slapd|nfs-server|rpcbind|bind9|vsftpd|pure-ftpd|apache2|nginx|dovecot|smbd|squid|snmpd|tigervnc|tightvnc|vino-viewe|named|ircd-irc2|nis|talk"
		'
		if [[ $2 == "-d" ]]; then
			#detailed view
			service --status-all | grep [+] | awk '{print $4}' | xargs systemctl status
		else
			#simple view
			service --status-all | grep [+]
		fi
		shift
		shift
	fi

	if [[ $1 == "--services-off" ]]; then
		echo '
		I like detailed, but thats not necessary
		make sure none of these are crazy ones we might not need
		service --status-all | grep [+] | awk "{print $4}" | grep -E "cups|isc-dhcp-server|slapd|nfs-server|rpcbind|bind9|vsftpd|pure-ftpd|apache2|nginx|dovecot|smbd|squid|snmpd|tigervnc|tightvnc|vino-viewe|named|ircd-irc2|nis|talk"
		'
		if [[ $2 == "-d" ]]; then
			#detailed view
			service --status-all | grep [-] | awk '{print $4}' | xargs systemctl status
		else
			#simple view
			service --status-all | grep [-]
		fi
		shift
		shift
	fi

	if [[ $1 == "--backup" ]]; then
		echo "
		backing up important directories
		not perfect, better implementations out there
		"
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
		shift
	fi

	if [[ $1 == "--suids" ]]; then
		echo "
		SUIDs and GUIDs have the potential for priv esc, so compare these with GTFOBins		
		"
		echo "suids"
		echo
		find / -perm -4000
		echo "guids"
		echo
		find / -perm -2000
		shift
	#GTFOBins
	fi

	if [[ $1 == "--ss" ]]; then
		echo "
		all connections in and out
		Evan thought 'plunt' and 'peunt' was too much to type lol
		"
		if [[ $2 == "-l" ]]; then
			ss -plunt
		fi
		if [[ $2 == "e" ]]; then
			ss -peunt
		fi
		shift
		shift
	fi

	if [[ $1 == "--update" ]]; then
		echo "
		apt and yum are the updaters on each system
		because Kali is all RWU exposes us to (so far) there's a yum cheatsheet for further research
		Fedora in Linux Server Admin next sem though!
		"
		if [[ $2 == "-d" ]]; then
			apt update
			apt upgrade
			apt autoremove
		fi
		if [[ $2 == "-rh" ]]; then
			yum update
		fi #https://access.redhat.com/sites/default/files/attachments/rh_yum_cheatsheet_1214_jcs_print-1.pdf
		shift
		shift
	fi

	function log() {
		ls -R $1 | awk '
	/:$/&&f{s=$0;f=0}
	/:$/&&!f{sub(/:$/,"");s=$0;f=1;next}
	NF&&f{ print s"/"$0 }' | sudo xargs md5sum | grep -v "director" >/home$1"$(date +"%d-%m-%Y-%H-%M-%S")"
		shift
	}

	if [[ $1 == "--sums" ]]; then
		echo "
		thank got for people who understand awk to a great extent. Trying to hash and diff all of this
		"
		log "/etc/rc.local"
		log "/etc/rc.d"
		log "/etc/init.d"
		log "/etc/cron*"
		log "/user/cron"
		log "/etc/profile*"
		log "/home/*/.bashrc"
		log "/home/*/bash_logout"
		shift
	fi

	if [[ $1 == "--sumdiff" ]]; then

		shift
	fi

done
