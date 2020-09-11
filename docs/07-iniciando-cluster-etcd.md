# Iniciando o Cluster ETCD

Neste laboratório, você inicializará um cluster etcd de quatro nós.

## Pré Requisitos

Alguns comandos neste laboratório devem ser executados em cada maquina virtual: `tpd`, `creone`, `parrerito` e `xonadao`. Para acessar as máquinas use o comando `vagrant ssh NOME-DA-MAQUINA`.


### Baixando o binário do ETCD

No terminal da `sua máqina física` navegue até o diretório tool que está dentro do projeto `workshop-cluster-rabbitmq` e baixe o etcd e descompacte:

```
cd ~/workshop-cluster-rabbitmq/tools

wget -q --show-progress --https-only --timestamping \
  "https://github.com/etcd-io/etcd/releases/download/v3.4.10/etcd-v3.4.10-linux-amd64.tar.gz"

tar -xvf etcd-v3.4.10-linux-amd64.tar.gz  
```

Agora que os binários estão disponíveis em todas as máquinas virtuais no diretório `/vagrant/tools`.

> NOTA: se não tiver funcionando o rsync automático, no terminal da máquina fisica e no diretório do projeto, execute o comando `vagrant rsync`.


### Configurando o cluster do ETCD

Esse procedimento deve ser feito nas 4 máquinas virtuais, porém, primeiramente faça na maquina de nome tpd.
Para acessar a máquina virtual digite no console da máquina física:

```
vagrant ssh tpd
```


Execute os comandos abaixo:

```
cat <<EOF | sudo tee --append /etc/environment
ETCDCTL_API=3 
EOF

{
    sudo cp -r /vagrant/tools/etcd-v3.4.10-linux-amd64/etcd* /usr/local/bin/
    sudo mkdir -p /etc/etcd /var/lib/etcd
    sudo chmod 700 /var/lib/etcd
}

INTERNAL_IP=$(hostname -i | awk '{print $2}')
ETCD_NAME=$(hostname -s)

TOKEN=iEeTbrisFPk6PpWWEE4rNAjuc5YUteqx
CLUSTER_STATE=new
NAME_1=tpd
NAME_2=creone
NAME_3=parrerito
NAME_4=xonadao
HOST_1=192.168.15.10
HOST_2=192.168.15.11
HOST_3=192.168.15.12
HOST_4=192.168.15.13
CLUSTER=${NAME_1}=http://${HOST_1}:2380,${NAME_2}=http://${HOST_2}:2380,${NAME_3}=http://${HOST_3}:2380,${NAME_4}=http://${HOST_4}:2380

cat <<EOF | sudo tee /etc/systemd/system/etcd.service
[Unit]
Description=etcd
Documentation=https://github.com/coreos

[Service]
Type=notify
ExecStart=/usr/local/bin/etcd \\
  --name ${ETCD_NAME} \\
  --initial-advertise-peer-urls http://${INTERNAL_IP}:2380 \\
  --listen-peer-urls http://${INTERNAL_IP}:2380 \\
  --listen-client-urls http://${INTERNAL_IP}:2379,http://127.0.0.1:2379 \\
  --advertise-client-urls http://${INTERNAL_IP}:2379 \\
  --initial-cluster-token ${TOKEN} \\
  --initial-cluster ${CLUSTER} \\
  --initial-cluster-state ${CLUSTER_STATE} \\
  --data-dir=/var/lib/etcd
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

{
  sudo systemctl daemon-reload
  sudo systemctl enable etcd
  sudo systemctl start etcd
}
```

Verifique o status do serviço:
```
sudo systemctl status etcd
```

Verifique o status do cluster:

```
etcdctl member list
```

> NOTA: agora faça o mesmo procedimento nas máquinas virtuais: creone, parrerito, xonadao e teste novamente o status do cluster da máquina xonadao.

### Verificando o funcionamento do cluster

Em qualquer VM, grave uma chava e valor

```
etcdctl put foo bar
```

Objenta chave e o valor gravado anteriormente

```
etcdctl get foo
```

> NOTA: Acessando qualquer outra máquina do cluster e executando o comando acima, deve aparecer o mesmo resultado

Delete a chave criada anteriormente

```
etcdctl del foo
```

Próximo: [Implantando a Stack do Portainer](docs/08-implantando-stack-portainer.md)