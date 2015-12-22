#!/bin/bash

# FlexCloud Command Tool
baseurl='https://mycp.superb.net/flexapi'
#baseurl='http://mycp.sraaum.superb.net/flexapi'
#if [ -z "$VAR" ];
#then
user='null'
password='null'
#fi

format="0"
#formats results returned to a more human readible
format_string(){
if [ $format == "1" ]
then
	results=$1
	results="${results//':{'/':{
	'}"
	results="${results//,/',
	'}"
	results="${results//'}},'/'}},
	'}"
	echo "$results"
else 
	echo $1
fi
}

help_function(){
	echo 'Virtual server command line interface'
	echo
	echo 'Available commands:

	build <virtual_machine_id> - builds specified vm
	create - creates a new vm
	delete <virtual_machine_id>
	edit <virtual_machine_id>
	ls/list - returns a quick overview of your machines
	get - returns a complete list of all your virtual machines
	get <virtual_machine_id> - returns a complete list of all your machines
	search <label>- searches for VMs with full or partial matches
	shutdown <virtual_machine_id> - shutdown specified virtual machine
	status - returns list of all your VMs and statuses
	status <virtual_machine_id> - returns status of specified vm
	stop <virtual_machine_id> - stops specified virtual machine
	startup <virtual_machine_id> - starts specified virtual machine
	reboot <virtual_machine_id> - reboots specified virtual machine'
	echo
	echo 'use -f to format json output vertically'
	echo
	echo 'specify authorization with: -u <account id> -p <api key>'
	echo 
	echo 'To specify options when using build/create/edit use "--" to indicate which parameter you would like to change, followed by "=<value>"'
	echo 'example: $ create --memory=966 --label="super server"...'
	echo
	echo "	memory* - amount of RAM assigned to the VS
	cpus* - number of CPUs assigned to the VS
	cpu_shares* - required parameter. For KVM hypervisor the CPU priority value is always 100. For XEN, set a custom value. The default value for XEN is 1
	hostname* - set the host name for this VS
	label* - user-friendly VS description
	primary_disk_size* - set the disk space for this VS
	swap_disk_size* - set swap space. There is no swap disk for Windows-based VSs
	type_of_format - type of filesystem - ext4. For Linux templates, you can choose ext4 file system instead of the ext3 default one
	primary_disk_type - set the storage type 'HDD' or 'SSD' for the primary disk
	swap_disk_type - set the storage type 'HDD' or 'SSD' for the swap disk
	primary_network_id - the ID of the primary network. Optional parameter that can be used only if it is assigned to the network zone
	primary_network_group_id - the ID of the primary network group. Optional parameter
	required_automatic_backup - set 1 if you need automatic backups
	rate_limit - set max port speed. Optional parameter: if none set, the system sets port speed to unlimited
	required_virtual_machine_build* - set to 1 to build VS automatically
	required_virtual_machine_startup - set to 1 to start up the VS automatically, otherwise set 0 (default state is '1')
	required_ip_address_assignment* - set to '1' if you want IP address to be assigned automatically after creation. Otherwise set '0'
	admin_note - enter a brief comment for the VS. Optional parameter
	note - a brief comment a user can add to a VS
	template_id* - the ID of a template from which a VS should be built
	initial_root_password - the root password for a VS. Optional, if none specified, the system will provide a random password. It can consist of 6-32 characters, letters [A-Za-z], digits [0-9], dash [ - ] and lower dash [ _ ]. You can use both lower- and uppercase letters"
}

create_function(){
	createVals='{"virtual_machine":{'$keyVals'}}'
	results=`curl -sL $curlOpts \
	-u $user:$password \
	-H "Accept: application/json" \
	-H "Content-Type:application/json" \
	--fail --show-error \
	-X POST --data "$createVals" $baseurl/virtual_machines;`
	format_string "$results"
}

edit_function(){
	editVals='{"virtual_machine":{'$keyVals'}}'
	URI=$baseurl/virtual_machines;

	if [ ${#functionVars[@]} -gt "0" ]
	then 
		URI=$URI/${functionVars[0]}
		results=`curl $curlOpts -sL -w "%{http_code}" $curlOpts\
		-u $user:$password \
		-H "Accept: application/json" \
		-H "Content-Type:application/json" \
		--fail --show-error \
		-X PUT --data "$editVals" $URI;`
		
		len=$results
		len=$((${#results} - 3))
		code=${results:$len:3}
		body=${results:0:len}
		if [ $code -eq 204 ] 
		then
			echo Success
		else
			echo Failure
		fi
	else
		echo "Please provide an id"
		echo "edit <virtual_machine_id>"
	fi

}

delete_function(){
	URI=$baseurl/virtual_machines;
	if [ ${#functionVars[@]} -gt "0" ]
	then 
		URI=$URI/${functionVars[0]}
		results=`curl -sL -w "%{http_code}" $curlOpts\
		-u $user:$password \
		-H "Accept: application/json" \
		-H "Content-Type:application/json" \
		--fail --show-error \
		-X DELETE $URI;`
		deleteResults "$results"
	else
		echo "Please provide an id"
		echo "delete <virtual_machine_id>"

	fi
}

build_function(){
	if [ ${#functionVars[@]} -gt "0" ]
	then 
		URI=$baseurl/virtual_machines/${functionVars[0]}/build
		createVals='{"virtual_machine":{'$keyVals'}}'
		results=`curl -sL -w "%{http_code}"\
		-u $user:$password \
		-H "Accept: application/json" \
		-H "Content-Type:application/json" \
		--fail --show-error \
		-X POST --data "$createVals" $URI;`
		postResults "$results"
	else

	echo "Please provide an id"
	echo "build <virtual_machine_id>"

	fi
}

get_function(){

	URI=$baseurl/virtual_machines;

	if [ ${#functionVars[@]} -gt "0" ]
	then 
		URI=$URI/${functionVars[0]}
	fi
	results=`curl -s $curlOpts \
	-u $user:$password \
	-H "Accept: application/json" \
	-H "Content-Type:application/json" \
	--fail --show-error \
	-X GET $URI;`
	format_string "$results"
}

overview_function(){

	URI=$baseurl/virtual_machines/overview
	
	if [ ${#functionVars[@]} -gt "0" ]
	then 
		URI="$URI"/${functionVars[0]}
	fi
	results=`curl -s $curlOpts \
	-u $user:$password \
	-H "Accept: application/json" \
	-H "Content-Type:application/json" \
	--fail --show-error \
	-X GET $URI;`
	echo -e "$results";
}

reboot_function(){

if [ ${#functionVars[@]} -gt "0" ]
then 
	URI=$baseurl/virtual_machines/${functionVars[0]}/reboot
	results=`curl -sL -w "%{http_code}" $curlOpts \
	-u $user:$password \
	-H "Accept: application/json" \
	-H "Content-Type:application/json" \
	--fail --show-error \
	-X POST --data "$createVals" $URI;`
	postResults "$results"
else

	echo "Please provide an id"
	echo "reboot <virtual_machine_id>"

fi
}

search_function(){

URI=$baseurl/virtual_machines;

if [ ${#functionVars[@]} -gt "0" ]
then 
	URI=$URI?q=${functionVars[0]}
	results=`curl $curlOpts \
	-u $user:$password \
	-H "Accept: application/json" \
	-H "Content-Type:application/json" \
	--fail --show-error \
	-X GET $URI;`
	format_string "$results"
else
	echo no label provided to search for.
fi
}

status_function(){

	URI=$baseurl/virtual_machines;

	if [ ${#functionVars[@]} -gt "0" ]
	then 
		URI=$URI/${functionVars[0]}
	fi

	URI=$URI/status
	results=`curl -s $curlOpts\
	-u $user:$password \
	-H "Accept: application/json" \
	-H "Content-Type:application/json" \
	--fail --show-error \
	-X GET $URI;`
	format_string "$results"
}

stop_function(){

	if [ ${#functionVars[@]} -gt "0" ]
	then 
	URI=$baseurl/virtual_machines/${functionVars[0]}/stop
	results=`curl $curlOpts -sL -w "%{http_code}"\
	-u $user:$password \
	-H "Accept: application/json" \
	-H "Content-Type:application/json" \
	--fail --show-error \
	-X POST $URI;`
	postResults "$results";
	
	else
	echo "Please provide an id"
	echo "stop <virtual_machine_id>"

	fi
}


startup_function(){

	if [ ${#functionVars[@]} -gt "0" ]
	then 
		URI=$baseurl/virtual_machines/${functionVars[0]}/startup
		results=`curl $curlOpts -sL -w "%{http_code}"\
		-u $user:$password \
		-H "Accept: application/json" \
		-H "Content-Type:application/json" \
		--fail --show-error \
		-X POST $URI;`
		postResults "$results";
		
	else
		echo "Please provide an id"
		echo "startup <virtual_machine_id>"
	fi
}

shutdown_function(){

	if [ ${#functionVars[@]} -gt "0" ]
	then 
		URI=$baseurl/virtual_machines/${functionVars[0]}/shutdown
		results=`curl $curlOpts -sL -w "%{http_code}"\
		-u $user:$password \
		-H "Accept: application/json" \
		-H "Content-Type:application/json" \
		--fail --show-error \
		-X POST $URI;`
		postResults "$results"
	else
		echo "Please provide an id"
		echo "startup <virtual_machine_id>"
	fi
}

test_function(){
	URI=$baseurl/test
	results=`curl $curlOpts -sL -w "%{http_code}"\
	-u $user:$password \
	-H "Accept: application/json" \
	-H "Content-Type:application/json" \
	--fail --show-error \
	-X GET $URI;`
getResults "$results"
	
}

postResults(){
len=$1
len=$((${#results} - 3))
		code=${results:$len:3}
		body=${results:0:len}
		if [ $code -eq 201 ] 
		then
			echo Success
		else
			if [ ${#body} -gt "0" ]
			then
				echoerr "Error With Request:"$body
			else 
				echoerr "Request Error"
			fi
		fi
}

getResults(){
len=$1
len=$((${#results} - 3))
		code=${results:$len:3}
		body=${results:0:len}
		if [ $code -eq 200 ] 
		then
			echo Success
		else
			if [ ${#body} -gt "0" ]
			then
				echoerr "Error With Request:"$body
			else 
				echoerr "Request Error"
			fi
		fi
}

deleteResults(){
len=$1
len=$((${#results} - 3))
		code=${results:$len:3}
		body=${results:0:len}
		if [ $code -eq 204 ] 
		then
			echo Success
		else
			if [ ${#body} -gt "0" ]
			then
				echoerr "Error With Request:"$body
			else 
				echoerr "Request Error"
			fi
		fi
}


parse_config(){
	while read line || [[ -n "$line" ]];
		do
		case $line in
		\#*)
#			Ignore Comments
		;;
		url*=*)
			baseurl=${line#*=}
		;;
		user*=*)
			user=${line#*=}
		;;
		password*=*)
			password=${line#*=}
		;;			
		esac
	done <$1	
}

echoerr() { echo "$@" 1>&2; }

command=$1; #Get command and shift
shift

args=()
for i in "$@"; do
    args+=("$i") 
done

j="0"
functionVars=()
arrayLength=${#args[@]}
while [ $j -lt $arrayLength ]
	do
	case ${args[$j]} in
		-u)
			user=${args[(($j+1))]}
			j=$(($j + 2))
		;;
		-p)
			password=${args[(($j+1))]}
			j=$(($j + 2))
		;;
		-b)
			baseurl=${args[(($j+1))]}
			j=$(($j + 2))
		;;
		-f)
			format="1"
			j=$(($j + 1))
		;;
		-d)
			curlOpts=$curlOpts" -i"
			j=$(($j + 1))
		;;
		-c)
			. ${args[(($j+1))]}
			j=$(($j + 1))
		;;
		--config=*)
			val=${args[$j]}
			val=${val#--*=}
			parse_config $val
			baseurl=${baseurl//[$'\t\r\n']}
			j=$(($j + 1))
		;;
		*)
			temp=$(($arrayLength - 1))
			input=${args[$j]}
			if [[ $input  == *"--"* ]] 
			then
				key=$input
				val=$input
				key=${key#--}
				key=${key%=*}
				val=${val#--*=}
				keyVals=$keyVals'"'$key'"':'"'$val'",'
				j=$(($j + 1))
			else
				functionVars+=($input)
				j=$(($j + 1))
			fi
		;;
	esac
done

keyVals=${keyVals%,}

input_check(){
	if [ "$user" == 'null' ]
	then
		echo "missing user/password use the -u and -p flags: -u <account id> -p <api key>"
		exit 1
	fi
	if [ "$password" == 'null' ]
	then
		echo "missing user/password use the -u and -p flags: -u <account id> -p <api key>"
		exit 1
	fi
}

case $command in
   
	create)
		input_check
		create_function
		exit
		;;
	get)
		input_check
		get_function
		exit
		;;
	ls|list)
		input_check
		overview_function
		exit
		;;
	search)
		input_check
		search_function
		exit
		;;		
	edit)
		input_check
		edit_function
		exit
		;;
	delete)
		input_check
		delete_function
		exit
		;;
	reboot)
		input_check
		reboot_function
		exit
		;;
	startup|start)
		input_check
		startup_function
		exit
		;;
	status)
		input_check
		status_function
		exit
		;;
	stop)
		input_check
		stop_function
		exit
		;;
	shutdown)
		input_check
		shutdown_function
		exit
		;;
	test)
		input_check
		test_function
		exit
		;;
	build)
		input_check
		build_function
		exit
		;;
	help | -h)
		help_function
		exit
		;;
	*)
	echo 'Command not recognized!'
	help_function
		exit
		;;
esac


