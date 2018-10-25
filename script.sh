#!/bin/bash

echo "
------------------------------------> 1 <----------------------------------
"
echo -e "\e[1;34m Bienvenue dans l'installation de votre machine virtuelle"
menu (){
    echo -e "\e[1;34m Tu te trouves à ce niveau. Que désire tu faire ?"
    pwd
    ls
    choix="";
    select opt in "Back to menu" "Bye" "Install virtual machine";
    do
        case $opt in
        "Back to menu" ) bash script.sh;break;;
        "Bye" ) echo "Au revoir";exit 0;;
        "Install virtual machine" ) choix="iVM";break;;
        esac
    done

    if [ "$choix" == "iVM" ]
    then
        echo -e "\e[1;34m Nous devons vérifier si vagrant est déjà installé"
        vagrant status
        echo -e "\e[1;34m Aucune vagrant n'est installée ";
    fi
}

menu

echo -e "\e[1;34m Nous pouvons passer à l'étape suivante";
echo -e "\e[1;34m Voici les actions que tu peux faire: Installer, exit";
echo -e "\e[1;34m Que décides tu de faire ?";

choice=""
select act in "installer" "exit"
do
    case $act in
    "installer" ) echo -e "\e[1;34m Tu as choisis l'installation"; choice="iVM";break;;
    "exit" ) echo -e "\e[1;34m Abondon de l'installation"; exit 0;;
    esac
done
echo "
------------------------------------- 2 ----------------------------------------------
"
#Initialisation vagrant
if [ "$choice" == "iVM" ]
then 
    echo -e "\e[1;34m Installation en cours"
    vagrant init
    echo -e "\e[1;34m Un fichier Vagrantfile a été crée"
    ls
fi

echo "
------------------------------------ 3 -------------------------------
"
#Pré-Configuration

echo "> Choisi le nom du dossier :"
echo "Ou appuie 'entrer' pour selectionner par défaut : 'data'
     "
read PROJECTFOLDER
PROJECTFOLDER=${PROJECTFOLDER:-data}
echo "----------------------------------------------------------"
echo -e "OK \e[1;34m ${PROJECTFOLDER} \e[21m le dossier sera crée"
ls
echo "----------------------------------------------------------"
read -p "Appuie 'entrer' pour continuer ou compose 'ctl+c' pour quitter"


echo "
-----------------------------------> 4 <--------------------------------
"
echo "> Quel vm box :"
echo "Appuie 'entrer' pour selectioner par défaut box : 'ubuntu/xenial64'
     "
read VMBOX
VMBOX=${VMBOX:-'ubuntu/xenial64'}
echo "----------------------------------------------------------"
echo -e "OK box \e[1m ${VMBOX} \e[21m selected"
echo "----------------------------------------------------------"
read -p "Press 'entrer' pour continue Appuie 'ctl+c' pour quit"

echo "
--------------------------> 5 <-------------------------
     "
echo "> Choose private ip : 192.168.33.?? (only 2 last numbers)"
echo "Appuie 'entrer' pour selectioner par défaut value : '10'
     "
read PRIVATEIP
PRIVATEIP=${PRIVATEIP:-10}
echo "----------------------------------------------------------"
echo -e "OK ip \e[1m 192.168.33.${PRIVATEIP} \e[21m selected"
echo "----------------------------------------------------------"
read -p "Press 'enter' pour continuer ou appuie 'ctl+c' pour quitter"

#Config
VAGRANTFILE=$(cat <<EOF
# -*- mode: ruby -*-
# vi: set ft=ruby :
# All Vagrant configuration is done below. The "2" in Vagrant.configure
# configures the configuration version (we support older styles for
# backwards compatibility). Please don't change it unless you know what
# you're doing.
Vagrant.configure("2") do |config|
  # The most common configuration options are documented and commented below.
  # For a complete reference, please see the online documentation at
  # https://docs.vagrantup.com.
  # Every Vagrant development environment requires a box. You can search for
  # boxes at https://vagrantcloud.com/search.
  config.vm.box = "${VMBOX}"
  # Disable automatic box update checking. If you disable this, then
  # boxes will only be checked for updates when the user runs
  # `vagrant box outdated`. This is not recommended.
  # config.vm.box_check_update = false
  # Create a forwarded port mapping which allows access to a specific port
  # within the machine from a port on the host machine. In the example below,
  # accessing "localhost:8080" will access port 80 on the guest machine.
  # NOTE: This will enable public access to the opened port
  # config.vm.network "forwarded_port", guest: 80, host: 8080
  # Create a forwarded port mapping which allows access to a specific port
  # within the machine from a port on the host machine and only allow access
  # via 127.0.0.1 to disable public access
  # config.vm.network "forwarded_port", guest: 80, host: 8080, host_ip: "127.0.0.1"
  # Create a private network, which allows host-only access to the machine
  # using a specific IP.
  config.vm.network "private_network", ip: "192.168.33.${PRIVATEIP}"
  # Create a public network, which generally matched to bridged network.
  # Bridged networks make the machine appear as another physical device on
  # your network.
  # config.vm.network "public_network"
  # Share an additional folder to the guest VM. The first argument is
  # the path on the host to the actual folder. The second argument is
  # the path on the guest to mount the folder. And the optional third
  # argument is a set of non-required options.
  config.vm.synced_folder "./${PROJECTFOLDER}", "/var/www/html", owner: "vagrant", group: "www-data", mount_options: ["dmode=775,fmode=664"]
  # A (shell) script that runs after first setup of your box
  # Provisioning the bootstrap file:   
  if File.exists?("./${PROJECTFOLDER}/bootstrap.sh")
    config.vm.provision :shell, path: "./${PROJECTFOLDER}/bootstrap.sh"
  else
  end
  # Provider-specific configuration so you can fine-tune various
  # backing providers for Vagrant. These expose provider-specific options.
  # Example for VirtualBox:
  #
  # config.vm.provider "virtualbox" do |vb|
  #   # Display the VirtualBox GUI when booting the machine
  #   vb.gui = true
  #
  #   # Customize the amount of memory on the VM:
  #   vb.memory = "1024"
  # end
  #
  # View the documentation for the provider you are using for more
  # information on available options.
  # Enable provisioning with a shell script. Additional provisioners such as
  # Puppet, Chef, Ansible, Salt, and Docker are also available. Please see the
  # documentation for more information about their specific syntax and use.
  # config.vm.provision "shell", inline: <<-SHELL
  #   apt-get update
  #   apt-get install -y apache2
  # SHELL
end
EOF
)
echo "${VAGRANTFILE}" > ./Vagrantfile

mkdir data
vagrant up
