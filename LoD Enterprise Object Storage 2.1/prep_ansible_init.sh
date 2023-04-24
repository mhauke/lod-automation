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
yum -y update > /dev/null 2>&1 
printresult $? "Updating CentOS system failed"

printf "%-50s" "--> Install additional packages 'yum install'"
yum -y install vim wget htop jq yum-utils > /dev/null 2>&1
printresult $? "Installing additional packages"


# Based on supplied arguments start docker containers
shopt -s nocasematch
for args in "$@"
do
    case $args in

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



