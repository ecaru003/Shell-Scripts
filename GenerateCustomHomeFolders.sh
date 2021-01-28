#!/bin/bash

#Script presupposes that the 1,000 users in ecaru003.csv has been made Unix system users.
#Script will make two folders within /home, namely /home/paralympic and /home/olympic
#Script will further subdivide olympic athletes by their SPORT, but paralympic athlethes by their COUNTRY
#Finally, a folder is created using their username. Within which are three files:
#	For olympic users: country, event, medal, with appropriate data within
#	For paralympic users: sport, even, shell with appropriate data within


curl http://users.cis.fiu.edu/~ggome002/files/ecaru003.csv > ecaru003.csv  #gets csv file from web, overwrites if exists

oldIFS=$IFS    # IFS is a var on what character a csv should be separated
               # Saved to oldIFS for future restoration 
#IFS=$'\n'     #Makes IFS break on newline, 
IFS=","        #Makes IFS break on newline, 

testFun () {
	if [[ $7 == "olympic"  ]]   #if event is olympics
	then
		if [ ! -d "/home/olympic/$8" ]       #if /home/olympic/SPORT doesn't exist, make it 
		then
			mkdir "/home/olympic/$8"
		fi

		#mkdir "/home/olympic/$8/$1"          #make user directory in /home/olympic/SPORT
		                                     #all users are unique
		userPath="/home/olympic/$8/$1/"

		useradd -d $userPath $1

		echo $6 > "/home/olympic/$8/$1/country"  #creates the three files for country $6, event $7, medal $9 
		echo $7 > "/home/olympic/$8/$1/event"
		echo $9 > "/home/olympic/$8/$1/medal"

	elif [ $7 == "paralympic" ] 
	then
	        if [ ! -d "/home/paralympic/$6" ]
		then
			mkdir "/home/paralympic/$6"         #code is functionally identical to one above
		fi

		#mkdir "/home/paralympic/$6/$1"

		userPath="/home/paralympic/$6/$1"
		useradd -d $userPath $1


		echo $8 > "/home/paralympic/$6/$1/sport"
		echo $7 > "/home/paralympic/$6/$1/event"
		echo ${10} > "/home/paralympic/$6/$1/shell"



	else
		echo "Input incorrect or wrongly formatted."  #if for some reason the csv file is read wrong, neither above will execute
	fi
}

#if /home/olympic does not exist, then make it 
if [ ! -d "/home/olympic" ]
then
	mkdir "/home/olympic"
fi  


#if /home/paralympic does not exist, then make it 
if [ ! -d "/home/paralympic" ]
then
	mkdir "/home/paralympic"
fi

lineCount=$( cat /root/ecaru003.csv | wc -l)

echo "Working. This may take a moment.."

for (( currLine=1; currLine <= $lineCount; currLine++ ))
do
	line=$currLine"p"
	testFun $(sed -n $line /root/ecaru003.csv)  #Calls testFun, providing the entire first line of the csv file as input 
done

echo "Done!"

IFS=$oldIFS    #Restores IFS to its original value 
