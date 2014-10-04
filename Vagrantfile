# -*- mode: ruby -*-
# vi: set ft=ruby :

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  # Every Vagrant virtual environment requires a box to build off of.
  config.vm.box = "hashicorp/precise64"
  
  # Provision!
  config.vm.provision :shell, path: "vagrant/provision.sh"

  # Provider-specific options.
  config.vm.provider "virtualbox" do |vbox|
    vbox.memory = 1024
  end
end
