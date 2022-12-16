##########################################################################
#### Written by Edrey Carulo
#### Question was asked, how to get IP or MAC from hostname.
#### Device in question was in the network, and in an ActiveDirectory domain.
#### Used:
#### sudo nmap -sn 10.11.12.0/20 > nmap_results.txt
#### As $FILE in this example. sudo is necessary, as nmap requires it to fetch hostname
#### Written in under an hour, and never used. ):
#### Saved for future reference.
##########################################################################



FILE="$1"
searchTerm="$2"
ip="error"
hostname="error"
mac="error"

get_lineNum() {
        #Sifts through nmap results, grep filters out only lines which contain the domain.
        #Assumes all devices worth scanning are on said domain.
        #Assumes $searchterm is going to be a part of the hostname/domain 
        #cat -n prints out scan results wiht line numbers, cut gives only the line numbers, xargs removes unnecessary values
        #Outputs an arbitrary size list, e.g.:    14 18 23 84 1235
        lineNumbers=$(cat -n "$FILE" | grep "$searchTerm" | cut -f1 | xargs)
        echo $lineNumbers
}

get_IP_Hostname() {
        #Following assumptions listed in get_lineNum(), edits string resutls from nmap results file
        #Expects to get a single integer result. Leverages sed to fetch the one line in question.
        #Expects to get IP and hostname, as per nmap result output as of time of writing 
        result=$(sed "$1!d" $FILE)
        ip=$(echo $result | cut -d' ' -f6 | tr -d '()' | xargs)
        hostname=$(echo $result | cut -d' ' -f5 | xargs)
}

get_MAC() {
        #Following assumptions listed in get_lineNum(), fetches two lines below the line fetched in get_IP_Hostname()
        #At time of writing, this is done to conform to nmap output format where IP and Hostname are on line n, and MAC on line n+2
        #nmap must be run as sudo for this to work
        originalLine=$1
        correctLine=$((originalLine + 2))
        result=$(sed "$correctLine!d" $FILE)
        mac=$(echo $result | cut -d' ' -f3 )
}

#Searchterm must NOT be empty. If it is, returns error expla
if [[ -n $searchTerm ]]; then
        for line in $(get_lineNum)
        do
                #Populate variables initiailized above, overwriting as needed, print them to stdout
                get_IP_Hostname $line
                get_MAC $line
                echo "$ip, $hostname, $mac"
        done
else
        echo "Error. Search term cannot be empty. USAGE: getIP_MAC_Hostname [FILE] [SEARCH TERM] "
fi
