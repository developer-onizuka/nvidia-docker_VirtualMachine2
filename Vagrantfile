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
  config.vm.box = "generic/ubuntu2004"

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
  config.vm.define "ubuntu_192.168.33.110"
  config.vm.network "private_network", ip: "192.168.33.110"
  config.vm.hostname = "gpu"

  # Create a public network, which generally matched to bridged network.
  # Bridged networks make the machine appear as another physical device on
  # your network.
  # config.vm.network "public_network"

  # Share an additional folder to the guest VM. The first argument is
  # the path on the host to the actual folder. The second argument is
  # the path on the guest to mount the folder. And the optional third
  # argument is a set of non-required options.
  # config.vm.synced_folder "../data", "/vagrant_data"

  # Provider-specific configuration so you can fine-tune various
  # backing providers for Vagrant. These expose provider-specific options.
  # Example for VirtualBox:
  config.vm.provider "libvirt" do |kvm|
    kvm.memory = 8192 
    kvm.cpus = 2
    kvm.machine_type = "q35"
    kvm.cpu_mode = "host-passthrough"
    kvm.kvm_hidden = true
    kvm.pci :bus => '0x01', :slot => '0x00', :function => '0x0'
  #   # Display the VirtualBox GUI when booting the machine
  #   vb.gui = true
  #
  #   # Customize the amount of memory on the VM:
  #   vb.memory = "1024"
  end
  #
  # View the documentation for the provider you are using for more
  # information on available options.

  # Enable provisioning with a shell script. Additional provisioners such as
  # Ansible, Chef, Docker, Puppet and Salt are also available. Please see the
  # documentation for more information about their specific syntax and use.
  config.vm.provision "shell", inline: <<-SHELL
     apt-get update
     apt-get install -y docker.io
     apt-get install -y curl
     curl -s -L https://nvidia.github.io/nvidia-docker/gpgkey | sudo apt-key add -
     distribution=$(. /etc/os-release;echo $ID$VERSION_ID)
     curl -s -L https://nvidia.github.io/nvidia-docker/$distribution/nvidia-docker.list |sudo tee /etc/apt/sources.list.d/nvidia-docker.list
     apt-get update
     apt-get install -y nvidia-docker2
     systemctl restart docker
     sed -i 's/^#root/root/' /etc/nvidia-container-runtime/config.toml
     tee /etc/modules-load.d/ipmi.conf <<< "ipmi_msghandler"   && sudo tee /etc/modprobe.d/blacklist-nouveau.conf <<< "blacklist nouveau"   && sudo tee -a /etc/modprobe.d/blacklist-nouveau.conf <<< "options nouveau modeset=0"
     update-initramfs -u
     docker pull nvcr.io/nvidia/driver:470.57.02-ubuntu20.04
     docker pull nvidia/cuda:11.4.1-cudnn8-devel-ubuntu20.04
     git clone https://github.com/developer-onizuka/nvidia-docker_VirtualMachine2.git
     docker build -t face_recognizer:1.0.0 ./nvidia-docker_VirtualMachine2/
   SHELL
end
