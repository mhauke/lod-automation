#!/usr/bin/env bash

################################################################################
#
# Title:        prep_ansible_init.sh
# Author:       Marko Hauke
# Date:         2023-12-04
# Description:  Prepare linux host "Ansible" in LoD lab
#               --> "Enterprise Object Storage in the Data Fabric
#                   with StorageGRID v2."
#
# URLs:         https://labondemand.netapp.com/node/586
#
#               https://docs.netapp.com/us-en/storagegrid-117/
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
printf "%s\n" "# (Lab: Enterprise Object Storage in the Data Fabric with StorageGRID v2.2) #"
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

# Make sure only root can run our script
if [ "$(id -u)" != "0" ]; then
   printresult 1 "This script must be run as root" 1>&2
   exit 1
fi

printf "%-50s" "--> Updating CentOS system 'yum update'"
yum -y update > /dev/null 2>&1 
printresult $? "Updating CentOS system failed"

printf "%-50s" "--> Install additional packages 'yum install'"
yum -y install vim wget htop jq yum-utils > /dev/null 2>&1
printresult $? "Installing additional packages"

printf "%-50s" "--> Update Ansible Collection for NetApp StorageGRID"
su ansible -l -c "ansible-galaxy collection install -f netapp.storagegrid" > /dev/null 2>&1
printresult $? "Updating Ansible Collection"  

printf "%-50s" "--> Cloning git repository for S3 basis demo"
su ansible -l -c "git -c /home/ansible/lod-ansible pull || git clone -q https://github.com/mhauke/lod-s3basics.git /home/ansible/lod-ansible"
printresult $? "Error getting git repository"

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



