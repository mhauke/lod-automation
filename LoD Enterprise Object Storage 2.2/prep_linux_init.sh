#!/usr/bin/env bash

################################################################################
#
# Title:        prep_linux_init.sh
# Author:       Marko Hauke
# Date:         2023-12-04
# Description:  Prepare linux host "Linux1" in LoD lab
#               --> "Enterprise Object Storage in the Data Fabric
#                   with StorageGRID v2.2"
#
# URLs:         https://labondemand.netapp.com/node/586
#               
#               https://docs.netapp.com/us-en/storagegrid-117/
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
printf "%s\n" "#       ----- Linux1 System -----                                           #"
printf "%s\n" "# (Lab: Enterprise Object Storage in the Data Fabric with StorageGRID v2.2) #"
printf "%s\n" "#############################################################################${normal}"
printf "\n"
printf "%s\n" "This script will update the system and install required package. It will also install"
printf "%s\n" "Python 3."

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
yum -y install vim wget htop python3 bzip2 sqlite epel-release jq yum-utils > /dev/null 2>&1
printresult $? "Installing additional packages"

# Install IUS repository
yum -y install https://repo.ius.io/ius-release-el7.rpm > /dev/null 2>&1
yum -y remove git > /dev/null 2>&1
yum -y install git236 > /dev/null 2>&1


printf "%-50s\n" "--> Installing needed pip packages"
pip3 install -q requests selinux boto3 > /dev/null 2>&1
printresult $? "Installing pip packages failed"

printf "%-50s\n" "--> Adding lines to ignore certificate errors"
printf "%-50s" "      > Add PYTHONWARNINGS to .bashrc"
echo 'export PYTHONWARNINGS="ignore:Unverified HTTPS request"' >> ~/.bashrc
export PYTHONWARNINGS="ignore:Unverified HTTPS request"
printresult $? "Adding to .bashrc failed"

printf "%-50s" "      > Restarting shell for changes to take effect"
. ~/.bashrc
printresult $? "Restarting shell failed"

printf "%-50s\n" "--> Installing golang"
printf "%-50s" "      > Download golang 1.21.4 using wget"
GO_DOWNLOAD="go1.21.4.linux-amd64.tar.gz"
wget -O /tmp/$GO_DOWNLOAD https://go.dev/dl/$GO_DOWNLOAD > /dev/null 2>&1
printresult $? "Download failed"
if [ -d "/usr/local/go" ]; then
    printf "%-50s" "      > Removing old golang version"
    rm -rf /usr/local/go 
    printresult $? "Removing old version of go failed"
fi
printf "%-50s" "      > Unpacking golang to /usr/local"
tar -C /usr/local -xzf /tmp/$GO_DOWNLOAD 
printresult $? "Unpacking of golang 1.20.3 failed"

printf "%-50s" "      > Adding go binary location to path in .bash_profile"
echo 'export PATH=$PATH:/usr/local/go/bin' >> ~/.bash_profile
printresult $? "Adding path to .bash_profile for golang failed"

printf "%-50s" "      > Reloading .bash_profile for changes to take effect"
. ~/.bash_profile
printresult $? "Reloading .bash_profile failed"


printf "%-50s" "--> Cloning git repository for S3 basis demo"
git -c /root/lod-s3basics pull > /dev/null 2>&1 || git clone -q https://github.com/mhauke/lod-s3basics.git /root/lod-s3basics
printresult $? "Error getting git repository"

