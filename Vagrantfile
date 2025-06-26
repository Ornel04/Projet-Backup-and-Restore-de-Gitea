# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  # Serveur virtuel de démonstration
  config.vm.define "srv-gitea" do |machine|
    machine.vm.hostname = "srv-gitea"
    machine.vm.box = "chavinje/fr-book-64"
     config.vm.network "private_network", ip: "192.168.56.27"
     #config.vm.network :public_network, bridge: 'eno1', ip: "10.128.21.40"
    # Un repertoire partagé est un plus mais demande beaucoup plus
    # de travail - a voir à la fin
    #machine.vm.synced_folder "./data", "/vagrant_data", SharedFoldersEnableSymlinksCreate: false

    machine.vm.provider :virtualbox do |v|
      v.customize ["modifyvm", :id, "--name", "srv-gitea"]
      v.customize ["modifyvm", :id, "--groups", "/gitea"]
      v.customize ["modifyvm", :id, "--cpus", "2"]
      v.customize ["modifyvm", :id, "--memory", 2*1024]
      v.customize ["modifyvm", :id, "--natdnshostresolver1", "off"]
      v.customize ["modifyvm", :id, "--natdnsproxy1", "off"]
    end
    config.vm.provision "shell", inline: <<-SHELL
      sed -i 's/ChallengeResponseAuthentication no/ChallengeResponseAuthentication yes/g' /etc/ssh/sshd_config    
      sleep 3
      service ssh restart
    SHELL
    machine.vm.provision "shell", path: "scripts/install_sys.sh"
    machine.vm.provision "shell", path: "scripts/install_web.sh"

        # Copier et configurer le script de restauration automatique
        machine.vm.provision "shell", inline: <<-SHELL
        sudo cp /vagrant/scripts/restore_gitea.sh /usr/local/bin/restore_gitea.sh
        chmod +x /usr/local/bin/restore_gitea.sh
        /usr/local/bin/restore_gitea.sh
      SHELL
  end
end
