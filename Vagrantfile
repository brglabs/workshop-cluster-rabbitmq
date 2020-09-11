# -*-a mode: ruby -*-
# vi: set ft=ruby :

VAGRANTFILE_API_VERSION = "2"
VAGRANT_ROOT = File.dirname(File.expand_path(__FILE__))

$COMMON_SETUP = File.join(VAGRANT_ROOT, "bin/common.sh")

# Nome dos servidores
$NODE_0 = "tpd"
$NODE_1 = "creone"
$NODE_2 = "parrerito"
$NODE_3 = "xonadao"

cluster = {
  $NODE_0 => { 
    :hostname => $NODE_0,
    :eth0 => "192.168.15.10", 
    :domain_name => "tpd.local",
    :cpu => 1, 
    :mem => 1024
  },
  $NODE_1 => { 
    :hostname => $NODE_1,
    :eth0 => "192.168.15.11", 
    :domain_name => "creone.local",
    :cpu => 1, 
    :mem => 1024
  },
  $NODE_2 => { 
    :hostname => $NODE_2,
    :eth0 => "192.168.15.12", 
    :domain_name => "parrerito.local",
    :cpu => 1, 
    :mem => 1024
  },
  $NODE_3 => { 
    :hostname => $NODE_3,
    :domain_name => "xonadao.local",
    :eth0 => "192.168.15.13", 
    :cpu => 1, 
    :mem => 1024  
  }
}

$after_msg = <<MSG
-----------------------------------------------------
# Acessar a máquinha: vagrant ssh NOME-DA-MAQUINA
-----------------------------------------------------
MSG

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.box = "ubuntu/bionic64"

  cluster.each_with_index do |(hostname, opt), index|

    config.vm.define hostname do |cnf|
      cnf.vm.hostname = hostname
      
      cnf.vm.provider :virtualbox do |vb, override|
        vb.name = hostname 
        vb.gui = false;       

        # Memory
        vb.customize ["modifyvm", :id, "--memory", opt[:mem]]

        # CPUs
        vb.customize ["modifyvm", :id, "--cpus", opt[:cpu]]

        # --hwvirtex on | off: habilita ou desabilita o uso de virtualização de hardware     
        # extensões (Intel VT-x ou AMD-V) no processador do seu sistema host;
        vb.customize ["modifyvm", :id, "--hwvirtex", "on"]

        # Criando uma rede privada, que permite acesso apenas ao host para a máquina usando um IP específico
        override.vm.network :private_network, :ip => opt[:eth0]

      end # end cnf.vm.provider

      cnf.vm.provision :shell, privileged: true, path: $COMMON_SETUP

      cnf.vm.synced_folder ".", "/vagrant", type: "rsync", rsync__auto: true, sync__exclude: ".git/"

    end # config.vm.define hostname

  end # end cluster.each_with_index

  config.vm.post_up_message = $after_msg  

end  # end Vagrant.configure