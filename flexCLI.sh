#!/bin/bash
# set -x
# FlexCloud Command Tool
baseurl='https://mycp.superb.net/flexapi'

user='null'
password='null'

format="0"
#formats returned results to be more human readible
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
	echo 'Virtual server command line interface
	
    Available commands:

	build <virtual_machine_id> - builds specified vm
	create - creates a new vm
	delete <virtual_machine_id>
	edit <virtual_machine_id>
	help - shows this
	ls/list - returns a quick overview of your machines
	get - returns a complete list of all your virtual machines
	get <virtual_machine_id> - returns a complete list of all your machines
	search <label>- searches for VMs with full or partial matches
	shutdown <virtual_machine_id> - shutdown specified virtual machine
	status - returns list of all your VMs and statuses
	status <virtual_machine_id> - returns status of specified vm
	stop <virtual_machine_id> - stops specified virtual machine
	startup <virtual_machine_id> - starts specified virtual machine
	test - test your api connection/credentials
	reboot <virtual_machine_id> - reboots specified virtual machine
	
	use -f to format json output vertically
	
	Specify authorization with: -u <account id> -p <api key> or with an external configuration file using --config
	config file example: $ ./flexCLI.sh test --config=flexConfig.ini
	
	To specify options when using build/create/edit use "--" to indicate which parameter you would like to change, followed by "=<value>"
	example: $ ./flexCLI.sh create --memory=966 --label="super server"...

	Virtual Machine Parameters:
	memory* - amount of RAM assigned to the VS
	cpus* - number of CPUs assigned to the VS
	cpu_shares* - required parameter. For KVM hypervisor the CPU priority value is always 100. For XEN, set a custom value. The default value for XEN is 1
	hostname* - set the host name for this VS
	label* - user-friendly VS description
	primary_disk_size* - set the disk space for this VS
	swap_disk_size* - set swap space. There is no swap disk for Windows-based VSs
	type_of_format - type of filesystem - ext4. For Linux templates, you can choose ext4 file system instead of the ext3 default one
	primary_disk_type - set the storage type "HDD" or "SSD" for the primary disk
	swap_disk_type - set the storage type "HDD" or "SSD" for the swap disk
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
	initial_root_password - the root password for a VS. Optional, if none specified, the system will provide a random password. It can consist of 6-32 characters, letters [A-Za-z], digits [0-9], dash [ - ] and lower dash [ _ ]. You can use both lower- and uppercase letters'
}

create_function(){
	createVals='{"virtual_machine":{'$key_vals'}}'
	results=`curl -sL $curlOpts -w "%{http_code}" \
	-u $user:$password \
	-H "Accept: application/json" \
	-H "Content-Type:application/json" \
	-X POST --data "$createVals" $baseurl/virtual_machines;`
	process_results "$results"
}

edit_function(){
	editVals='{"virtual_machine":{'$key_vals'}}'
	URI=$baseurl/virtual_machines;

	if [ ${#function_vars[@]} -gt "0" ]
	then 
		URI=$URI/${function_vars[0]}
		curl_put_request $editVals 
	else
		echo "Please provide an id:"
		echo "edit <virtual_machine_id>"
	fi

}

delete_function(){
	URI=$baseurl/virtual_machines;
	if [ ${#function_vars[@]} -gt "0" ]
	then 
		URI=$URI/${function_vars[0]}
		curl_delete_request
	else
		echo "Please provide an id:"
		echo "delete <virtual_machine_id>"

	fi
}

build_function(){
	if [ ${#function_vars[@]} -gt "0" ]
	then 
		URI=$baseurl/virtual_machines/${function_vars[0]}/build
		createVals='{"virtual_machine":{'$key_vals'}}'
		curl_post_with_send $createVals
	else

	echo "Please provide an id:"
	echo "build <virtual_machine_id>"

	fi
}

get_function(){

	URI=$baseurl/virtual_machines;

	if [ ${#function_vars[@]} -gt "0" ]
	then 
		URI=$URI/${function_vars[0]}
	fi
	curl_get_no_std_out
}

overview_function(){

	URI=$baseurl/virtual_machines/overview
	
	if [ ${#function_vars[@]} -gt "0" ]
	then 
		URI="$URI"/${function_vars[0]}
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

if [ ${#function_vars[@]} -gt "0" ]
then 
	URI=$baseurl/virtual_machines/${function_vars[0]}/reboot
	curl_post_request
else
	echo 
	echo "Please provide an id"
	echo "reboot <virtual_machine_id>"

fi
}

search_function(){

URI=$baseurl/virtual_machines;

if [ ${#function_vars[@]} -gt "0" ]
then 
	URI=$URI?q=${function_vars[0]}
	curl_get_no_write
else
	echo no label provided to search for.
fi
}

status_function(){

	URI=$baseurl/virtual_machines;

	if [ ${#function_vars[@]} -gt "0" ]
	then 
		URI=$URI/${function_vars[0]}
	fi

	URI=$URI/status
	curl_get_no_std_out
}

stop_function(){

	if [ ${#function_vars[@]} -gt "0" ]
	then 
	URI=$baseurl/virtual_machines/${function_vars[0]}/stop
	curl_post_request
	
	else
		echo "Please provide an id"
		echo "stop <virtual_machine_id>"
	fi
}


startup_function(){

	if [ ${#function_vars[@]} -gt "0" ]
	then 
		URI=$baseurl/virtual_machines/${function_vars[0]}/startup
		curl_post_request
		
	else
		echo "Please provide an id"
		echo "startup <virtual_machine_id>"
	fi
}

shutdown_function(){

	if [ ${#function_vars[@]} -gt "0" ]
	then 
		URI=$baseurl/virtual_machines/${function_vars[0]}/shutdown
		curl_post_request
	else
		echo "Please provide an id"
		echo "startup <virtual_machine_id>"
	fi
}

test_function(){
	URI=$baseurl/test
	curl_get_request
}



curl_get_no_std_out(){
	results=`curl $curlOpts -s $curlOpts\
	-u $user:$password \
	-H "Accept: application/json" \
	-H "Content-Type:application/json" \
	--fail --show-error \
	-X GET $URI;`
	process_results "$results"
}

curl_get_request(){
	results=`curl $curlOpts -sL -w "%{http_code}" $curlOpts\
	-u $user:$password \
	-H "Accept: application/json" \
	-H "Content-Type:application/json" \
	--fail --show-error \
	-X GET $URI;`
	process_results "$results"
}

curl_post_request(){
	results=`curl $curlOpts -sL -w "%{http_code}" $curlOpts\
	-u $user:$password \
	-H "Accept: application/json" \
	-H "Content-Type:application/json" \
	--fail --show-error \
	-X POST $URI;`
	process_results "$results"
}

curl_post_with_send(){
#		params='{"virtual_machine":{'$1'}}'
# -w "%{http_code}"
		results=`curl -sL -i $curlOpts\
		-u $user:$password \
		-H "Accept: application/json" \
		-H "Content-Type:application/json" \
		--fail --show-error \
		-X POST --data "$1" $URI;`
		process_results "$results"
}

curl_delete_request(){
results=`curl -sL -w "%{http_code}" $curlOpts\
		-u $user:$password \
		-H "Accept: application/json" \
		-H "Content-Type:application/json" \
		--fail --show-error \
		-X DELETE $URI;`
		process_results "$results"
}
curl_put_request(){

	results=`curl $curlOpts -sL -w "%{http_code}" $curlOpts\
		-u $user:$password \
		-H "Accept: application/json" \
		-H "Content-Type:application/json" \
		--fail --show-error \
		-X PUT --data "$1" $URI;`
		process_results "$results"
}

process_results(){
len=$1
len=$((${#results} - 3))
		code=${results:$len:3}
		body=${results:0:len}
		if [ $code -eq 201 ] || [ $code -eq 204 ] || [ $code -eq 200 ] 
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

input_check(){
	if [ "$user" == 'null' ] || [ "$password" == 'null' ]
	then
		echoerr 'missing user/password use the -u and -p flags: -u <account id> -p <api key> or include them in a configuration file using --config="flexConfig.ini"'
		exit 1
	fi
}

echoerr() { echo "$@" 1>&2; }

args=()
for i in "$@"; do
    args+=("$i") 
done

j="0"
function_vars=()
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
		--config=*)
			val=${args[$j]}
			val=${val#--*=}
			parse_config $val
			baseurl=${baseurl//[$'\t\r\n']}
			j=$(($j + 1))
		;;
		build|create|delete|edit|help|ls|list|get|search|shutdown|status|status|stop|start|startup|test|reboot)
			command=${args[$j]}
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
				key_vals=$key_vals'"'$key'"':'"'$val'",'
				j=$(($j + 1))
			else
				function_vars+=($input)
				j=$(($j + 1))
			fi
		;;
	esac
done

key_vals=${key_vals%,}

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
	start|startup)
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


