#!/bin/bash

# Script is intended to work on Fedora.
# Script will install apache web server, and acquire necessary .csv file
# Male athlethes are sorted by their sport
# For each sport, all male data is compiled into a single index.html file, but reordered

#Female athlethes are similarly sorted by their country, and a single index.html file is made with all their data reordered

dnf -q -y install httpd

curl http://users.cis.fiu.edu/~ggome002/files/ecaru003.csv > /root/ecaru003.csv
doStuff () {
  if [[ $4 == "m" ]]
    then 
      mkdir -p "/var/www/html/male/$8"
      out="$2,$6,$7,$9,${10},$5,$8,$4,${11},$1,$3"
      echo $out >> "/var/www/html/male/$8/index.html"

  elif [[ $4 == "f" ]]
    then       
      mkdir -p "/var/www/html/female/$6"
      out2="${11},$1,$6,$2,$8,$4,$3,$9,${10},$7,$5"
      echo $out2 >> "/var/www/html/female/$6/index.html"

  else
    echo "Input incorrect or wrongly formatted."  #if for some reason the csv file is read wrong, neither above will execute

  fi
}

oldIFS=$IFS
IFS=","
lineCount=$( cat /root/ecaru003.csv | wc -l )
for (( currLine=1; currLine <= $lineCount; currLine++ ))
do
        #echo "Enter line #"
        #read currLine
        line=$currLine"p"
        #echo $line
        #echo $(sed -n $line /root/ecaru003.csv)
        doStuff $(sed -n $line /root/ecaru003.csv)  #Calls testFun, providing the entire first line of the csv file as input
done
IFS=$oldIFS





