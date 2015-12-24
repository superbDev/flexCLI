# FlexVM command line control (For UNIX systems only)

FlexVM is a simple command line tool to access and manage your servers via the console. With some basic commands you can view the states of your virtual servers, and do everything from creation to deletion. 

## 1. Download
Visit https://confluence.dev.superb.net/display/AD/Flex+Cloud+VM+Control
You will see a link to download the script. Click the link to download the latest version, save it to an appropriate directory like /usr/local/. Alternatively you can use wget to download.
In your terminal, navigate to desired directory download and then unpack:

```
  $ wget https://github.com/superbDev/flexCLI/archive/v1.0.tar.gz
  $ tar -zxvf v1.0.tar.gz
```
Then modify the permissions so that it can be executed:

```  
  $ chmod 700 /usr/local/flexCLI<Version>/flexCLI.sh 
```

This will give only you access to read+write+execute. (Use chmod 777 to grant all users/groups read+write+execute permissions).

## 2. Authentication
When using the flexCLI tool it is necessary to provide your basic authentication credentials. You will need your accountID and your API key. (Please note that if you have multiple Flex Cloud accounts each one will need its own API key.)

You can provide the credentials when making each request using –u <accountID> –p <API Key> flags. Test your credentials with the “test” request:

```
  $ ./flexCLI.sh test -u 712345 -p 7519caea9926a0227debb2e36bc08f012b52dee6
```

Alternatively you can store your configuration in a separate file.

### a. Edit the example config file by substituting <account_id> with your Account ID and <API_Key> with your API key. The modified file should look something like this:

```  
  user=7654321
  password=7231caea9926b0227beda2e31bc08f012b52dee6
```
  
### b. Include the config file by declaring the --config parameter on execution:
 
When working with multiple Flex Cloud accounts, use separate configuration files to store your credentials. So if you had two Flex Cloud accounts, one at the Springfield datacenter and another in Seattle, create two separate config files such as: “springConf.ini” and “seattleConf.ini”

## 3. Executing commands
When you’re ready to start executing commands, check out the available commands at: https://confluence.dev.superb.net/display/AD/Flex+Cloud+VM+Control

Here is an example using the FlexCLI to create a new server. 

 ```
 $ ./flexCLI.sh create --config=flexConfig.ini --primary_disk_type=SSD --template_label="CentOS 6.7 x64" --hostname="zaza"             --label="zaza" --primary_disk_size="5" --memory="500"
```  

The required parameters used are:

--primary_disk_type: SSD (solid state) or HDD (hard disk)

--primary_disk_size: Size in GBs of the primary disk

--memory: Size in MB of RAM allocated to your VM

--template_label: Label of desired operating system (or a label of one of your custom templates). System templates labels can be found here: https://confluence.dev.superb.net/display/AD/Virtual+Server+Operating+Systems

--hostname: Hostname of your VM

--Label: User friendly name to search/view your VM by.

Upon success a JSON string representation of the Virtual Server is returned:

```
{"virtual_machine":{"add_to_marketplace":null,"admin_note":null,"allowed_hot_migrate":true,"allowed_swap":true,"booted":false,"built":false,"cores_per_socket":0,"cpu_shares":1,"cpu_sockets":null,"cpu_threads":null,"cpu_units":10,"cpus":1,"created_at":"2015-12-03T21:17:19+00:00","customer_network_id":null,"deleted_at":null,"edge_server_type":null,"enable_autoscale":null,"enable_monitis":null,"firewall_notrack":false,"hostname":"zaza","hypervisor_id":6,"id":685,"identifier":"awtfj2dls1prtf","initial_root_password_encrypted":false,"iso_id":null,"label":"zaza","local_remote_access_ip_address":null,"local_remote_access_port":null,"locked":false,"memory":500,"min_disk_size":5,"note":null,"operating_system":"linux","operating_system_distro":"rhel","preferred_hvs":[5,8,11,12,6,10,3,7,9,4,2],"recovery_mode":null,"remote_access_password":null,"service_password":null,"state":"new","storage_server_type":null,"strict_virtual_machine_id":null,"suspended":false,"template_id":148,"template_label":"CentOS 6.7 x64","updated_at":"2015-12-03T21:17:19+00:00","user_id":337,"vip":null,"xen_id":null,"ip_addresses":[],"monthly_bandwidth_used":"0","total_disk_size":5,"price_per_hour":0.009028340000000001,"price_per_hour_powered_off":0.0013889,"support_incremental_backups":true,"cpu_priority":1}}
 ```

For an explanation of all the returned parameters checkout the API guide: https://confluence.dev.superb.net/display/AD/Get+List+of+Virtual+Machines
Alternatively, the “help” command provides details on parameters used when adding, editing, and deleting virtual machines.

## 4.	Getting a quick overview of your machines and their states.
The “ls” command is an excellent way to check on the current state (either running, shutdown, or building) of your machines.

```
  $ ./flexVM ls --config="flexConfig.ini"
	|--id--|--------label-------|---ip-address---|--memory--|-storage-|---status---|
	|   511|          hostOmatic|   192.168.000.1|       500|       31|     running|
	|   561|         emailServer|   192.168.000.1|      1500|        7|    building|
	|   562|          superServe|   192.168.000.1|       384|        6|     running|
	|   576|          serverTron|   192.168.000.1|      1548|        8|     running|
	|   587|          powerServe|   192.168.000.1|       384|        6|     running|
	|   589|            hosteria|   192.168.000.1|       512|        6|     running|
```

You can see how much memory and storage they have, get ip addresses, and retrieve your virtual machines’ ids for use with other commands.  
Let’s say we decide we want to shutdown “hosteria” (at the bottom), we get the id 589 and then call the stop command:

``` 
	$ ./flexVM stop 589 --config="flexConfig.ini"
	Success
```

We can then use another “ls” call to ensure any pending changes:

```
	$ ./flexVM ls --config="flexConfig.ini"
	|--id--|--------label-------|---ip-address---|--memory--|-storage-|---status---|
	|   511|          hostOmatic|   192.168.000.1|       500|       31|     running|
	|   561|         emailServer|   192.168.000.1|      1500|        7|    building|
	|   562|          superServe|   192.168.000.1|       384|        6|     running|
	|   576|          serverTron|   192.168.000.1|      1548|        8|     running|
	|   587|          powerServe|   192.168.000.1|       384|        6|     running|
	|   589|            hosteria|   192.168.000.1|       512|        6|    shutdown|
```

We can see that this machine is now shutdown, for more details on working with FlexCLI, checkout: https://confluence.dev.superb.net/display/AD/Flex+Cloud+VM+Control

	
