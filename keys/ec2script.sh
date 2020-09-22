#!bin/bash

# Defining the function help, user can check options to pass in argument while executing script
function print_help()
{
echo "ec2script v.1.0
Use to retrieve EC2 instance metadata from within a running EC2 instance.
e.g. Run the command ./ec2script.sh in linux, To run the script in windows you need to install Bash.
		to retrieve instance id: ec2script -i or ec2script --instanceid
                 to retrieve ami id: ec2script -a or ec2script --ami-id
ll                     Show all metadata information for this host (also default).
-a/--ami-id               The AMI ID used to launch this instance
-l/--ami-launch-index     The index of this instance in the reservation (per AMI).
-m/--ami-manifest-path    The manifest path of the AMI with which the instance was launched.
-n/--ancestor-ami-ids     The AMI IDs of any instances that were rebundled to create this AMI.
-b/--block-device-mapping Defines native device names to use when exposing virtual devices.
-i/--instance-id          The ID of this instance
-t/--instance-type        The type of instance to launch. For more information, see Instance Types.
-h/--local-hostname       The local hostname of the instance.
-o/--local-ipv4           Public IP address if launched with direct addressing; private IP address if launched with public addressing.
-k/--kernel-id            The ID of the kernel launched with this instance, if applicable.
-z/--availability-zone    The availability zone in which the instance launched. Same as placement
-c/--product-codes        Product codes associated with this instance.
-p/--public-hostname      The public hostname of the instance.
-v/--public-ipv4          NATted public IP Address
-u/--public-keys          Public keys. Only available if supplied at instance launch time
-r/--ramdisk-id           The ID of the RAM disk launched with this instance, if applicable.
-e/--reservation-id       ID of the reservation.
-s/--security-groups      Names of the security groups the instance is launched in. Only available if supplied at instance launch time
-d/--user-data            User-supplied data.Only available if supplied at instance launch time.

Usage: ec2script <option>
}
"
}
# Print Function to give user a choice to select from range of numbers depending upom their requirment
function print_option()
{
echo "Choose from the follwing number to select the output of metadata :

1. All (Show all metadata information for this host (also default))
2. Ami-Id (The ami id used to launch this instance)
3. Ami-Launch-Index (The index of this instance in the reservation (per AMI))
4. Ami-Manifest-Path (The manifest path of The ami with which The instance was launched.)
5. Ancestor-Ami-Ids (The ami ids of any instances that were rebundled to create this AMI.)
6. Block-Device-Mapping (Defines native device names to use when exposing virtual devices.)
7. Instance-Id (The id of this instance)
8. Instance-Type (The type of instance to launch. for more information, see instance Types.)
9. Local-Hostname (The local hostname of The instance.)
10. Local-Ipv4 (Public IP address if launched with direct addressing; private IP address if launched with public addressing.)
11. Kernel-Id (The id of The kernel launched with this instance, if applicable.)
12. Availability-Zone (The availability zone in which The instance launched. Same as placement)
13. Product-Codes (Product codes associated with this instance.)
14. Public-Hostname (The Public hostname of The instance.)
15. Public-Ipv4 (NATted Public IP address)
16. Public-Keys (Public keys. Only available if supplied at instance launch time)
17. Ramdisk-Id (The ID of the RAM disk launched with this instance, if applicable.)
18. Reservation-Id (id of The reservation.)
19. Security-Groups (names of The security groups The instance is launched in. Only available if supplied at instance launch time)
20. User-Data (User-supplied data.Only available if supplied at instance launch time.)
21. Help (Arguments or direct options to get metadata.)"
}


#check some basic configurations before running the code; whether the manchine is ec2 or not
function chk_config()
{
        #check if run inside an ec2-instance
        x=$(curl -s http://169.254.169.254/)
        if [ $? -gt 0 ]; then
                echo '[ERROR] Command not valid outside EC2 instance. Please run this command within a running EC2 instance.'
                exit 1
        fi
}

#print standard metric
function print_single_metric() {
        metric_path=$2
        echo -n '  ''"'$1'"'': ''"'
        RESPONSE=$(curl -fs http://169.254.169.254/latest/${metric_path}/)
        if [ $? == 0 ]; then
                echo $RESPONSE'"'
        else
                echo 'not available"'
        fi
}

#print block-device-mapping as ec2 manchine can have multiple EBS volumes.
function print_block-device-mapping()
{
echo '  "block-device-mapping":[ 
   {'
x=$(curl -fs http://169.254.169.254/latest/meta-data/block-device-mapping/)
if [ $? -eq 0 ]; then
        for i in $x; do
		if [ $i != "root" ]; then
                	echo -e '\t''"'$i'"':' "'$(curl -s http://169.254.169.254/latest/meta-data/block-device-mapping/$i)'",'
		else
			echo -e '\t''"'$i'"':' "'$(curl -s http://169.254.169.254/latest/meta-data/block-device-mapping/$i)'"'
		fi
        done
else
        echo -e '\t''"block-device-mapping": "not available"'
fi
echo '   }
]'
}

#print public-keys
function print_public-keys()
{
        echo '  "public-keys":[ '
        x=$(curl -fs http://169.254.169.254/latest/meta-data/public-keys/)
        if [ $? -eq 0 ]; then
	echo "   {"
                for i in $x; do
                        index=$(echo $i|cut -d = -f 1)
                        keyname=$(echo $i|cut -d = -f 2)
                        echo -e '\t''"keyname": ''"'$keyname'",'
                        echo -e '\t''"index": ''"'$index'",'
                        format=$(curl -s http://169.254.169.254/latest/meta-data/public-keys/$index/)
                        echo -e '\t''"format": ''"'$format'",'
                        echo -e '\t''"key": ''"'$(curl -s http://169.254.169.254/latest/meta-data/public-keys/$index/$format)'"
   }
]'
#                        echo -e '\t''"'$(curl -s http://169.254.169.254/latest/meta-data/public-keys/$index/$format)'"'
                done
        else
                echo not available
        fi
}

#Function to print entire metadata of the server
function print_all()
{
        print_single_metric ami-id meta-data/ami-id
        print_single_metric ami-launch-index meta-data/ami-launch-index
        print_single_metric ami-manifest-path meta-data/ami-manifest-path
        print_single_metric ancestor-ami-ids meta-data/ancestor-ami-ids
        print_block-device-mapping
        print_single_metric instance-id meta-data/instance-id
        print_single_metric instance-type meta-data/instance-type
        print_single_metric local-hostname meta-data/local-hostname
        print_single_metric local-ipv4 meta-data/local-ipv4
        print_single_metric kernel-id meta-data/kernel-id
        print_single_metric placement meta-data/placement/availability-zone
        print_single_metric product-codes meta-data/product-codes
        print_single_metric public-hostname meta-data/public-hostname
        print_single_metric public-ipv4 meta-data/public-ipv4
        print_public-keys
        print_single_metric ramdisk-id /meta-data/ramdisk-id
        print_single_metric reservation-id /meta-data/reservation-id
        print_single_metric security-groups meta-data/security-groups
        print_single_metric user-data user-data
	echo "}"
}

#check if run inside an EC2 instance
chk_config


#Script to check whether any arguments are passed during script execution, if not than print all option or return results as per argument
if [ "$#" -eq 0 ]; then
        print_option
	echo -n "Please enter the number: "; read var
#Script to check whether input values are integers between 1 to 21 and if no values are passed it should be treated as default.
	if ! [ -z $var ]; then
		if echo "$var" | grep -qE '^[0-9]+$'; then
			if [ $var -gt 0 ] && [ $var -le 22 ]; then
				dummy="value"
			else 
				echo "Please make sure you are providing an integer between 1 and 21"
                        	exit 1
			fi
		else
			echo "Please make sure you are providing an integer between 1 and 21"
			exit 1
		fi
	fi


else 
	var="$1"
fi

#start processing command line arguments or choice user made
echo "The output of the requested metadata is :
{" 
case $var in
        
	-a |2| --ami-id )                print_single_metric ami-id meta-data/ami-id
                                                                                                                                 ;;
        -l | 3| --ami-launch-index )      print_single_metric ami-launch-index meta-data/ami-launch-index
                                                                                                                                 ;;
        -m | 4| --ami-manifest-path )     print_single_metric ami-manifest-path meta-data/ami-manifest-path
                                                                                                                                 ;;
        -n | 5| --ancestor-ami-ids )      print_single_metric ancestor-ami-ids meta-data/ancestor-ami-ids
                                                                                                                                 ;;
        -b | 6| --block-device-mapping )  print_block-device-mapping
                                                                                                                                 ;;
        -i | 7| --instance-id )           print_single_metric instance-id meta-data/instance-id
                                                                                                                                 ;;
        -t | 8| --instance-type )         print_single_metric instance-type meta-data/instance-type
                                                                                                                                 ;;
        -h | 9 | --local-hostname)        print_single_metric local-hostname meta-data/local-hostname
                                                                                                                                 ;;
        -o | 10 | --local-ipv4 )            print_single_metric local-ipv4 meta-data/local-ipv4
                                                                                                                                 ;;
        -k | 11 | --kernel-id )             print_single_metric kernel-id meta-data/kernel-id
                                                                                                                                 ;;
        -z | 12 | --availability-zone )     print_single_metric placement meta-data/placement/availability-zone
                                                                                                                                 ;;
        -c | 13 | --product-codes )         print_single_metric product-codes meta-data/product-codes
                                                                                                                                 ;;
        -p | 14 | --public-hostname )       print_single_metric public-hostname meta-data/public-hostname
                                                                                                                                 ;;
        -v | 15 | --public-ipv4 )           print_single_metric public-ipv4 meta-data/public-ipv4
                                                                                                                                 ;;
        -u | 16 | --public-keys )           print_public-keys
                                                                                                                                 ;;
        -r | 17 | --ramdisk-id )            print_single_metric ramdisk-id /meta-data/ramdisk-id
                                                                                                                                 ;;
        -e | 18 | --reservation-id)        print_single_metric reservation-id /meta-data/reservation-id
                                                                                                                                 ;;
        -s | 19 )       print_single_metric security-groups meta-data/security-groups
                                                                                                                                 ;;
        -d | 20 )             print_single_metric user-data user-data
                                                                                                                                 ;;
        --help| 21 )                  print_help
                                                                 exit
                                                                                                                                 ;;
        --all | 1 |"")                        print_all
                                                                 exit
                                                                                                                                 ;;
        * )      echo "Please make sure you are providing an integer between 1 and 21 or use --help see help
}"
                                                                 exit 1
																;;
        esac
echo "}"
