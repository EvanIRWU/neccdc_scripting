#!/bin/bash
#echo tty1 > /etc/securetty
#getent groups root, wheel, adm, admin
#I know this isn't prime. It's actually quite terrible, and I want it to be much better.
#https://github.com/ucrcyber/CCDC ?
#cron
###Kasey Litchford - 01/11/2021

while [[ $# -ne 0 ]]; do

	case $1 in
	"-h")
		echo "
-------------------------------------------------
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

		sudo ./kaseylinux.sh --illegal-users --userlist --purge-ssh --services-running --services-off --backup --suids --ss -p --ss -l --update -d --pcheck
		"
		shift

		;;

	\
		\
		"--illegal-users")
		echo "
-------------------------------------------------
		users with 999 or below, containing /bin/ in their shell path
		set to /sbin/nologin | /bin/false
		usermod --shell /sbin/nologin <user>
		chsh --shell /sbin/nologin <user>
		userdel -r -f <user>
		"
		cat /etc/passwd | awk -F: '{if ($3 < 1000) print $0;}'
		users=$(cat /etc/passwd | awk -F: '{if ($3 < 1000) print $0;}')
		echo "
		
		groups in sudoers
		
		"
		cat /etc/sudoers | grep ALL
		shift

		;;

	"--userlist")

		echo "
-------------------------------------------------
		users with 1000 or above
		double check that these are approved users only
		grep for :0: to look for other root users
		userdel -r -f <user>
		"
		cat /etc/passwd | awk -F: '{if ($3 > 999) print $0;}'
		users=$(cat /etc/passwd | awk -F: '{if ($3 > 999) print $0;}')
		shift
		;;
	"--purge-ssh")

		echo "
-------------------------------------------------
		/home/<user>/.ssh/id_rsa is where pre-authenticated users will store their keys
		we don't want that
		was previously authorized_keys but that's for keys you're comfortable connecting to
		overall, delete .ssh entirely for a quick reset		
		also looks for some persistence by red team
		"
		rm -rf /home/*/.ssh/id_rsa
		echo "authorized_keys ------ :
		"
		cat /etc/ssh/sshd_config | grep authorized_keys
		shift
		;;
	"--services-running")
		echo '
-------------------------------------------------
		I like detailed, but thats not necessary
		make sure none of these are crazy ones we might not need
		service --status-all | grep [+] | awk "{print $4}" | grep -E "cups|isc-dhcp-server|slapd|nfs-server|rpcbind|bind9|vsftpd|pure-ftpd|apache2|nginx|dovecot|smbd|squid|snmpd|tigervnc|tightvnc|vino-viewe|named|ircd-irc2|nis|talk"
		'
		if [[ $2 == "-d" ]]; then
			#detailed view
			echo "
			detailed services ON
			"
			service --status-all | grep [+] | awk '{print $4}' | xargs systemctl status
		else
			#simple view
			echo "
			simple services ON
			"
			service --status-all | grep [+]
		fi
		shift
		shift

		;;
	"--services-off")
		echo '
-------------------------------------------------
		I like detailed, but thats not necessary
		make sure none of these are crazy ones we might not need
		service --status-all | grep [+] | awk "{print $4}" | grep -E "cups|isc-dhcp-server|slapd|nfs-server|rpcbind|bind9|vsftpd|pure-ftpd|apache2|nginx|dovecot|smbd|squid|snmpd|tigervnc|tightvnc|vino-viewe|named|ircd-irc2|nis|talk"
		'
		if [[ $2 == "-d" ]]; then
			#detailed view
			echo "
			detailed services OFF
			"
			service --status-all | grep [-] | awk '{print $4}' | xargs systemctl status
		else
			#simple view
			echo "
			simple services OFF
			"
			service --status-all | grep [-]
		fi
		shift
		shift

		;;
	"--backup")
		echo "
-------------------------------------------------
		backing up important directories
		not perfect, better implementations out there
		"
		bud=/etc/opt/hereitis
		mkdir $bud
		echo "
			copying
			"
		cp /etc/passwd $bud/pw
		cp /etc/shadow $bud/sdw
		cp /etc/group $bud/grp
		cp /etc/gshadow $bud/gsdw
		cp /etc/ssh $bud/ssh
		cp /etc/hosts $bud/hosts
		cp -r /etc/cron* $bud/
		cp /etc/services /$bud/svs
		echo "
			copying done
			"
		shift

		;;
	"--suids")
		echo "
-------------------------------------------------
		SUIDs and GUIDs have the potential for priv esc, so compare these with GTFOBins"
		echo "
		PRINTING SUIDS
		"
		find / -perm -4000 | grep -v "find:" | xargs ls -lah
		echo "
		PRINTING GUIDS
		"
		find / -perm -2000 | grep -v "find:" | xargs ls -lah
		shift
		#GTFOBins

		;;
	"--ss")
		echo "
-------------------------------------------------
		all connections in and out
		Evan thought 'plunt' and 'peunt' was too much to type lol
		"
		if [[ $2 == "-l" ]]; then
			echo "
			plunt
			"
			ss -plunt
		fi
		if [[ $2 == "-e" ]]; then
			echo "
			peunt
			"
			ss -peunt
		fi
		shift
		shift

		;;
	"--update")
		echo "
-------------------------------------------------
		apt and yum are the updaters on each system
		because Kali is all RWU exposes us to (so far) there's a yum cheatsheet for further research
		Fedora in Linux Server Admin next sem though!
		"
		if [[ $2 == "-d" ]]; then
			echo "
			debian
			"
			apt update
			apt upgrade
			apt autoremove
		fi
		if [[ $2 == "-rh" ]]; then
			echo "
			red hat
			"
			yum update
		fi #https://access.redhat.com/sites/default/files/attachments/rh_yum_cheatsheet_1214_jcs_print-1.pdf
		shift
		shift

		;;

	"--pcheck")
		echo "
		I don't want to be caught off-guard by the red team 
		so here's as many persistence checks as I can come up with
		"
		echo "
		kill /root/.ssh
		"
		rm -rf /root/.ssh
		echo "
		any authorized_keys out there? (/root/ /etc/ /dev/) + (/.ssh/) (maybe /dev/.ssh)
		"
		sudo apt install locate -y
		locate authorized_keys
		echo "
		is it set in the config?
		"
		cat /etc/ssh/sshd_config | grep uthorized
		echo "
		sudoers ALL ALL=(ALL:ALL) NOPASSWD:ALL is BAD
		"
		cat /etc/sudoers | grep ALL
		echo "
		they wanna break update! (apt)
		"
		ls /etc/apt/preferences.d/ | xargs cat | grep Pin
		ls /etc/apt/preferences | xargs cat | grep Pin
		echo "
		they wanna break update! (yum)
		"
		cat /etc/yum.conf | grep exclude
		echo "
		ssh configs PermitRootLogin to NO and PasswordAuthentication to YES
		"
		cat /etc/ssh/sshd_config | grep -E "ermit"
		shift
	;;

	esac

done
