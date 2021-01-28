#!/bin/bash


# This script dynamically adds users to an LDAP server.
# The script will make two LDAP groups, one for each gender present in the csv (m,f)
# Then it will add each user to the appropriate gender group 


systemctl start slapd

value=$(ldapsearch -x -b 'ou=group,dc=cts4348,dc=fiu,dc=edu' | grep gidNumber | cut -d: -f2 | sort -u | tail -1) #find last gid
#echo "$value"
gen=""
gid=`expr $value + 1` 
cat /root/ecaru003.csv | cut -d, -f4 | sort -u | while read gender
do
	if [[ $gender == "f" ]]; then
		gen="female"
	elif [[ $gender == "m" ]]; then
		gen="male"
	else
		echo "Error. Improper gender."
	fi
	#echo $gender
	#echo $gid


	if [[ $gen != "" ]]; then
		echo "dn: cn=$gen,ou=group,dc=cts4348,dc=fiu,dc=edu" >> /root/tmpgrp
		echo "objectClass: top" >> /root/tmpgrp
		echo "objectClass: posixGroup" >> /root/tmpgrp
		echo "gidNumber: $gid" >> /root/tmpgrp
		
		ldapadd -x -w 5908318 -D cn=admin,dc=cts4348,dc=fiu,dc=edu -f /root/tmpgrp
		> /root/tmpgrp
		cat /root/ecaru003.csv | grep olympic | grep ,$gender, | cut -d, -f1 | while read user;
		do
			#echo $user" "$gen" "$gid
			echo "dn: cn=$gen,ou=group,dc=cts4348,dc=fiu,dc=edu" >> /root/tmpgrp
			echo "changetype: modify" >> /root/tmpgrp
			echo "add: memberUid" >> /root/tmpgrp
			echo "memberUid: $user" >> /root/tmpgrp
			ldapmodify -w 5908318 -D cn=admin,dc=cts4348,dc=fiu,dc=edu -f /root/tmpgrp
			> tmpgrp
		done
		> tmpgrp
	else
		"Error. No gender set."	
	fi
	
	gid=`expr $gid + 1`
done




