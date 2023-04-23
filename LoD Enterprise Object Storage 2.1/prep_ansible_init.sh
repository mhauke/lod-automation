#!/usr/bin/env bash

################################################################################
#
# Title:        prep_ansible_init.sh
# Author:       Marko Hauke
# Date:         2023-04-22
# Description:  Prepare linux host "Ansible" in LoD lab
#               --> "Enterprise Object Storage in the Data Fabric
#                   with StorageGRID v2.1"
#
# URLs:         https://labondemand.netapp.com/lab/sl10712 (NetApp + Partner)
#               
#               https://docs.netapp.com/us-en/storagegrid-116/
#               https://galaxy.ansible.com/netapp/storagegrid
#
################################################################################

# setting colors
blue=$(tput setaf 4)
red=$(tput setaf 1)
green=$(tput setaf 2)
normal=$(tput sgr0)

printf "\n\n"
printf "%s\n" "${blue}#############################################################################"
printf "%s\n" "# Preparing NetApp Lab on Demand system                                     #"
printf "%s\n" "#       ----- Ansible System -----                                          #"
printf "%s\n" "# (Lab: Enterprise Object Storage in the Data Fabric with StorageGRID v2.1) #"
printf "%s\n" "#############################################################################${normal}"
printf "\n"
printf "%s\n" "This script will update the system and install required package. It will prepare"
printf "%s\n" "the system to run various docker containers, i.e. elasticsearch, minio etc."

# defining a function to print results base on exit code
# Params:
#       exit code   - exit code to be evaluated
#       error       - message to display
function printresult {
    if (( $1 != 0 )); then
        printf "%s\n\n" "${red}Error: $2 (Code: $1).${normal}"
        exit $retval
    else 
        printf "%s\n" "${green}OK${normal}"
    fi
}

printf "%-50s" "--> Updating CentOS system 'yum update'"
yum -q -y update 
printresult $? "Updating CentOS system failed"

printf "%-50s" "--> Install additional packages 'yum install'"
yum -q -y install vim wget htop jq 
printresult $? "Installing additional packages"


printf "%-50s" "--> Turning swap memory off"
swapoff -a
printresult $? "Turning swap memory off failed"


# Edit the sysctl config file
# Add a line to define the desired value
# or change the value if the key exists,
# and then save your changes.
printf "%-50s" "--> Setting max_map_count to '262144' in sysctl.conf"
echo 'vm.max_map_count=262144' >> /etc/sysctl.d/99-sysctl.conf
printresult $? "Adding line for max_map_count in sysctl.conf failed"

printf "%-50s" "--> Reloading kernel parameters using sysctl"
sysctl -p
printresult $? "Reloading kernel parameters failed"

# Verify that the change was applied by checking the value
printf "%-50s" "--> Check if changes in sysctl were applied"
printf "%s\n" $(cat /proc/sys/vm/max_map_count)


# Based on supplied arguments start docker containers
shopt -s nocasematch
for args in "$@"
do
    case $args in

      elastic)
        printf "%-50s" "--> Starting Docker container for Elasticsearch"
        # Creating volume to hold Opensearch data
        printf "%-50s" "      > Creating directory for Elastic Search data"
        mkdir /usr/share/elastic-data
        printresult $? "Failed to create directory '/usr/share/elastic-data' kernel parameters failed"
        mkdir /usr/share/kibana-data
        printresult $? "Failed to create directory '/usr/share/kibana-data' kernel parameters failed"

        cd ./elastic
        docker-compose up -d
        ;;

      minio)
        printf "%-50s" "--> Starting Docker container for Minio"
        cd ./minio
        docker-compose up -d        
        ;;

      *)
        ;;
    esac

done
shopt -u nocasematch



