# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  config.vm.box = "bento/centos-7.7"
  config.vm.provision "shell", inline: <<-SHELL
    if [[ ! -e Makefile ]] ; then
      sudo -u vagrant ln -s /vagrant/SPECS/ SPECS
      sudo -u vagrant ln -s /vagrant/SOURCES/ SOURCES
      sudo -u vagrant ln -s /vagrant/Makefile Makefile
      sudo -u vagrant ln -s /vagrant/prep-lua-deps.sh prep-lua-deps.sh
    fi
  SHELL
end
