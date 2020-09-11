# Ferramentas na Máquina Física

É necessário a instalação das ferramentas abaixo na máquina física:

* [Virtualbox e Extension Pack](https://www.virtualbox.org/wiki/Downloads)
* [Vagrant](https://www.vagrantup.com/downloads.html)


## Instalando plugin do Vagrant

Na raíz do projeto digite o comando abaixo:
```
vagrant plugin install vagrant-vbguest
```

## Finalizando

No terminal da sua máquina fisíca, execute o comando abaixo:
```
cat <<EOF | sudo tee --append /etc/hosts

192.168.15.10 tpd.local         haproxy.sre.local portainer.sre.local rmq.sre.local rmq-monitor.sre.local
192.168.15.11 creone.local      haproxy.sre.local portainer.sre.local rmq.sre.local rmq-monitor.sre.local
192.168.15.12 parrerito.local   haproxy.sre.local portainer.sre.local rmq.sre.local rmq-monitor.sre.local
192.168.15.13 xonadao.local     haproxy.sre.local portainer.sre.local rmq.sre.local rmq-monitor.sre.local

EOF
```

Próximo: [Provisionando Máquinas Virtuais](docs/03-provisionando-maquinas-virtuais.md)