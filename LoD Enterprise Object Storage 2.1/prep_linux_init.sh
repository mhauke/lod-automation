#!/usr/bin/env bash

################################################################################
#
# Title:        prep_linux_init.sh
# Author:       Marko Hauke
# Date:         2023-04-22
# Description:  Prepare linux host "Linux1" in LoD lab
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
printf "%s\n" "#       ----- Linux1 System -----                                           #"
printf "%s\n" "# (Lab: Enterprise Object Storage in the Data Fabric with StorageGRID v2.1) #"
printf "%s\n" "#############################################################################${normal}"
printf "\n"
printf "%s\n" "This script will update the system and install required package. It will also install"
printf "%s\n" "Python 3.13.3 via pyenv."

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
yum -q -y install vim wget htop gcc libffi-devel epel-release zlib-devel openssl-devel jq 
printresult $? "Installing additional packages"

printf "%-50s\n" "--> Install pyenv (Python virtual environment)"
printf "%-50s" "      > Clone pyenv repository"
git clone -q https://github.com/yyuu/pyenv.git ~/.pyenv
printresult $? "Cloning Repository not successfull"

printf "%-50s" "      > Add pyenv to .bash_profile"
echo 'export PYENV_ROOT="$HOME/.pyenv"' >> ~/.bash_profile
echo 'export PATH="$PYENV_ROOT/bin:$PATH"' >> ~/.bash_profile
echo 'eval "$(pyenv init -)"' >> ~/.bash_profile
printresult $? "Adding pyenv to .bash_profile not successfull"

printf "%-50s" "      > Restarting shell for changes to take effect"
exec $SHELL
printresult $? "Restarting shell failed"

printf "%-50s" "--> Test pyenv installation"
pyenv --version > /dev/null
printresult $? "Pyenv not installed properly"

printf "%-50s\n" "--> Installing Python 3.11.3 with pyenv"
printf "%-50s" "      > Installing Python 3.11.3"
pyenv install 3.11.3 > /dev/null
printresult $? "Python install failed"

printf "%-50s" "      > Setting Python 3.11.3 as global default"
pyenv global 3.11.3 > /dev/null
printresult $? "Setting Python version globally failed"

printf "%-50s\n" "--> Upgrading pip package manager"
pip3 install -q --upgrade pip
printresult $? "Updating pip failed"

printf "%-50s\n" "--> Installing needed pip packages"
pip3 install -q requests selinux boto3
printresult $? "Installing pip packages failed"

printf "%-50s\n" "--> Adding lines to ignore certificate errors"
printf "%-50s" "      > Add PYTHONWARNINGS to .bashrc"
echo 'export PYTHONWARNINGS="ignore:Unverified HTTPS request"' >> ~/.bashrc
export PYTHONWARNINGS="ignore:Unverified HTTPS request"
printresult $? "Adding to .bashrc failed"

printf "%-50s" "      > Restarting shell for changes to take effect"
exec $SHELL
printresult $? "Restarting shell failed"

## To Do:
- configure Storage Pools


