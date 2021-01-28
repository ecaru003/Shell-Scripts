cat /root/swap.sh

sportU=$(cat /root/ecaru003.csv | grep "olympic" | cut -d"," -f8 | sort -u)
#!/bin/bash

# This script is by far the most unusual. To understand how it works, we must consider what the environment was. 
# This script was meant to be run on a centOS machine with an apache server and a mysql server running
# The users from ecaru003.csv were sorted by their sport

#The goal of this script was to remove that old configuration, and reapply it with users sorted by country instead

#First it deletes hosts from the /etc/hosts which referenced the already-
#It will then remove old apache webpages, and clear old custom apache configs without deleting critical (default) apache configs

# Although apache server was already installed, it attempts to reinstall it.
# If the server really is there, then it will return an error and nothing will happen
# If the server is missing, it will install it 

# New configs are applied, new sql tables are made, and apache is restarted 

db="ecaru003"

for sport in $sportU
do
	echo "Removing old hosts from /etc/hosts and dropping table $sport from mysql"
        servName="ecaru003.$sport.cts4348.fiu.edu" #determines specific string that must be removed
        lineNum=$(cat /etc/hosts | grep -n $servName | cut -d":" -f1) #determines line where above str was found

        if grep -q $servName /etc/hosts;
        then
                sed -i "$lineNum"d /etc/hosts  #removes said line
        fi

        rm -r /var/www/$sport/ #removes localhost entry for current specific country

	script="DROP TABLE $sport;"
	mysql -D $db -e "$script"
done

echo "Removing old apache2 configs"
rm -r /etc/httpd/conf.d/ecaru003/ #removes specified folder and all subfolders

if grep -q "IncludeOptional conf.d/ecaru003/\*.conf" /etc/httpd/conf/httpd.conf;
then
        lineNum=$(cat /etc/httpd/conf/httpd.conf | grep -n "IncludeOptional conf.d/ecaru003/\*.conf" | cut -d":" -f1)
        #determines specific line number where above str was found
        sed -i "$lineNum"d /etc/httpd/conf/httpd.conf #removes only that specific line
fi
###REMOVES PREVIOUS JUNK


##################################################### FEDORA
echo "Installing httpd..."
yum -y -q install httpd
#####################################################


#####################################################
echo "Starting httpd..."
systemctl start httpd
#####################################################


#####################################################
echo "Editing /etc/httpd/conf/httpd.conf..."
if grep -q "IncludeOptional conf.d/ecaru003/\*.conf" /etc/httpd/conf/httpd.conf;
then
        echo "Done!"
else
        echo "IncludeOptional conf.d/ecaru003/*.conf" >> /etc/httpd/conf/httpd.conf
fi
#####################################################


#####################################################
echo "Adding Virtual Host Configuration..."

if [[ -d /etc/httpd/conf.d/ecaru003 ]]; then
        echo "Config folder exists,"
else
        mkdir /etc/httpd/conf.d/ecaru003/
        echo "Config folder made,"
fi


countryU=$(cat /root/ecaru003.csv | grep "paralympic" | cut -d"," -f6 | sort -u)


        echo "Making config file for $country and SQL table for $country"

        echo "Adding players to /var/www/$country/index.html and mysql"

for country in $countryU
do
	script="CREATE TABLE $country( username VARCHAR(50), md5sum VARCHAR(50)  );"
	mysql -D $db -e "$script"

        servName="ecaru003."$country".cts4348.fiu.edu"
        echo "<VirtualHost *:80>" >> /etc/httpd/conf.d/ecaru003/$country".conf"
        echo "   ServerName "$servName >> /etc/httpd/conf.d/ecaru003/$country".conf"
        echo "   ServerAlias "$servName >> /etc/httpd/conf.d/ecaru003/$country".conf"
        echo "   DocumentRoot /var/www/$country/" >> /etc/httpd/conf.d/ecaru003/$country".conf"
        echo "</VirtualHost>" >> /etc/httpd/conf.d/ecaru003/$country".conf"


        playersU=$(cat /root/ecaru003.csv | grep "paralympic" | grep "$country" )
        oldIFS=$IFS
        IFS=$'\n'
        for player in $playersU
        do
		userscript="INSERT INTO $country VALUES( \"$(echo $player | cut -d"," -f1)\", \"$(echo $player | md5sum )\"  );"
		mysql -D $db -e "$userscript"

                mkdir -p /var/www/$country/
                echo $(echo "$player" | cut -d',' -f1)", ecaru003, $(echo $player | md5sum)" >> /var/www/$country/index.html
        done
        IFS=$oldIFS

        echo "Adding $country to /etc/hosts file"
        echo "127.0.0.1 $servName" >> /etc/hosts
done
#####################################################


#####################################################

echo "Restarting httpd"
systemctl restart httpd
##################################################### APPLIES FEDORA CHANGES TO CENTOS


