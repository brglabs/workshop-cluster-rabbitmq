# Implantando a Stack do Portainer

Para este lab, será usado o RabbitMQ via container docker sendo orquestrado pelo Swarm.

## Pré Requisitos

Para iniciar essa etapa, e obrigatório ter feito corretamtne a etapa [Configurando extra no Swarm](docs/06-configuracao-extra-swarm.md).

Para melhor agilidade, iremos usar o Portainer para implantar as Stacks, criar e gerenciar as senhas, arquivos de configuração, entre outros.


## Criando arquivos de configuração

Antes de subir a stack, é necessário criar dois arquivos de configuração.

Abra o Portainer em um browser, exemplo `tpd.sre.local:9000`. Lembre se para acessar diretamente é necessário expor a porta `9000` no docker-compose.

## Criando o arquivo rabbitmq.conf

* No Portainer, no menu da esquerda, clique em Configs, depois clique em `+ Add Config`;
* No campo name, digite `rabbitmq_rabbitmq.conf`;
* No campo abaixo, copia e cole o código a seguir: 
```
# ======================================
# RabbitMQ broker section
# ======================================

cluster_name = sre

vm_memory_high_watermark.absolute = 768MiB
vm_memory_high_watermark_paging_ratio = 0.2

## Related doc guide: http://rabbitmq.com/configure.html. See
## http://rabbitmq.com/documentation.html for documentation ToC.

## Networking
## ====================
##
## Related doc guide: http://rabbitmq.com/networking.html.
##
## By default, RabbitMQ will listen on all interfaces, using
## the standard (reserved) AMQP 0-9-1 and 1.0 port.
##
listeners.tcp.default = 5672

##
## Security, Access Control
## ==============
##

## Related doc guide: http://rabbitmq.com/access-control.html.

## The default "guest" user is only permitted to access the server
## via a loopback interface (e.g. localhost).
## {loopback_users, [<<"guest">>]},
##

## Uncomment the following line if you want to allow access to the
## guest user from anywhere on the network.
loopback_users.guest = false

##
## Default User / VHost
## ====================
##

## On first start RabbitMQ will create a vhost and a user. These
## config items control what gets created.
## Relevant doc guide: http://rabbitmq.com/access-control.html
##
default_vhost = /
default_user = admin
default_pass = admin

## Make clustering happen *automatically* at startup. Only applied
## to nodes that have just been reset or started for the first time.
##
## Relevant doc guide: http://rabbitmq.com//cluster-formation.html
##

cluster_formation.peer_discovery_backend = etcd

cluster_formation.etcd.endpoints.1 = tpd.local:2379
cluster_formation.etcd.endpoints.1 = creone.local:2379
cluster_formation.etcd.endpoints.1 = parrerito.local:2379
cluster_formation.etcd.endpoints.1 = xonadao.local:2379

cluster_formation.etcd.key_prefix = rabbitmq_discovery
cluster_formation.etcd.cluster_name = staging

# nó TTL em segundos 
# padrão: 30 
cluster_formation.etcd.node_ttl = 120

# Repita as operações de descoberta de pares até dez vezes 
cluster_formation.discovery_retry_limit = 10

# 500 milissegundos 
cluster_formation.discovery_retry_interval = 500

##
## Misc/Advanced Options
## =====================
##
## NB: Change these only if you understand what you are doing!
##

## Explicitly enable/disable hipe compilation.
##
hipe_compile = false

## Whether or not to enable proxy protocol support.
## Once enabled, clients cannot directly connect to the broker
## anymore. They must connect through a load balancer that sends the
## proxy protocol header to the broker at connection time.
## This setting applies only to AMQP clients, other protocols
## like MQTT or STOMP have their own setting to enable proxy protocol.
## See the plugins documentation for more information.
##
proxy_protocol = false

# =======================================
# Management section
# =======================================

## Preload schema definitions from the following JSON file.
## Related doc guide: http://rabbitmq.com/management.html#load-definitions.
##
# management.load_definitions = /etc/rabbitmq/rabbitmq-definitions.json

## Log all requests to the management HTTP API to a file.
##
# management.http_log_dir = /var/log/rabbitmq/access.log

## Change the port on which the HTTP listener listens,
## specifying an interface for the web server to bind to.
## Also set the listener to use TLS and provide TLS options.
##

management.listener.port = 15672
# management.listener.ip   = 127.0.0.1
management.listener.ssl  = false

# =======================================
# AMQP 1.0 section
# =======================================


## Connections that are not authenticated with SASL will connect as this
## account. See the README for more information.
##
## Please note that setting this will allow clients to connect without
## authenticating!
##
# amqp1_0.default_user = guest

## Enable protocol strict mode. See the README for more information.
##
# amqp1_0.protocol_strict_mode = false

## Logging settings.
##
## See http://rabbitmq.com/logging.html and https://github.com/erlang-lager/lager for details.
##

## Log direcrory, taken from the RABBITMQ_LOG_BASE env variable by default.
##
# log.dir = /var/log/rabbitmq

## Logging to file. Can be false or a filename.
## Default:
# log.file = rabbit.log

## To disable logging to a file
# log.file = false

## Log level for file logging
##
log.file.level = debug

## File rotation config. No rotation by default.
## DO NOT SET rotation date to ''. Leave the value unset if "" is the desired value
# log.file.rotation.date = 
# log.file.rotation.size = 0

## Logging to console (can be true or false)
##
log.console = true

## Log level for console logging
##
log.console.level = debug


# Increase the 5s default so that we are below Prometheus' scrape interval,
# but still refresh in time for Prometheus scrape
# This is linked to Prometheus scrape interval & range used with rate()
collect_statistics_interval = 10000
```

## Criando o arquivo enabled_plugins

* Ainda em Configs, clique em `+ Add Config`;
* No campo name, digite `rabbitmq_enabled_plugins`;
* No campo abaixo, copia e cole o código a seguir: 
```
[rabbitmq_management,
rabbitmq_peer_discovery_etcd,
rabbitmq_federation,
rabbitmq_federation_management,
rabbitmq_prometheus].
```

## Criando o arquivo enabled_plugins

> NOTA: nesse ponto, será criado um arquivo em cada container do RabbtiMQ contendo um secredo que será utilizado na descoberta dos nós que farão parte do cluster:

* No Portainer, no menu da esquerda, clique em `Secrets`, depois clique em `+ Add Secret`;
* No campo name, digite `rabbitmq_erlang.cookie`;
* No campo `Secret`, copia e cole a frase a seguir: `"a-grama-do-vizinho-eh-sempre-mais-verde"`


## Implantando a Stack do RabbitMQ

Agora iremos subir a stack do RabbitMQ de fato.

* No menu da esquerda do Portainer, clique em Stack: 
* Em seguida clique em `+ Add Stack`;
* No campo name, digite `rabbitmq`;
* Em `Web editor` copia e cole o código abaixo: 
```
version: '3.7'

configs:
  rabbitmq_rabbitmq.conf:
    external: true
  rabbitmq_enabled_plugins:
    external: true

secrets:
  rabbitmq_erlang.cookie:
    external: true

volumes:
  node1:
  node2:
  node3:

networks:
  infra:
    external: true
  rabbitmq:
    external: true
      
services:

  node3:
    image: rabbitmq:3.8.7-management
    hostname: node3
    extra_hosts: 
      - "tpd.local:192.168.15.10"
      - "creone.local:192.168.15.11"
      - "parrerito.local:192.168.15.12"
      - "xonadao.local:192.168.15.13"
    configs:
      - source: rabbitmq_enabled_plugins
        target: /etc/rabbitmq/enabled_plugins
        uid: "999"
        gid: "999"
        mode: 0600
      - source: rabbitmq_rabbitmq.conf
        target: /etc/rabbitmq/rabbitmq.conf
        uid: "999"
        gid: "999"
        mode: 0777
    secrets:
      - source: rabbitmq_erlang.cookie
        target: /var/lib/rabbitmq/.erlang.cookie
        uid: "999"
        gid: "999"
        mode: 0600
    volumes:
      - /etc/localtime:/etc/localtime
      - node3:/var/lib/rabbitmq
    networks:
      - infra
      - rabbitmq 
    deploy:
      replicas: 1
      placement:
        constraints: [node.labels.rabbitmq3 == true]

  node2:
    image: rabbitmq:3.8.7-management
    hostname: node2
    extra_hosts: 
      - "tpd.local:192.168.15.10"
      - "creone.local:192.168.15.11"
      - "parrerito.local:192.168.15.12"
      - "xonadao.local:192.168.15.13"
    configs:
      - source: rabbitmq_enabled_plugins
        target: /etc/rabbitmq/enabled_plugins
        uid: "999"
        gid: "999"
        mode: 0600
      - source: rabbitmq_rabbitmq.conf
        target: /etc/rabbitmq/rabbitmq.conf
        uid: "999"
        gid: "999"
        mode: 0777
    secrets:
      - source: rabbitmq_erlang.cookie
        target: /var/lib/rabbitmq/.erlang.cookie
        uid: "999"
        gid: "999"
        mode: 0600
    volumes:
      - /etc/localtime:/etc/localtime
      - node2:/var/lib/rabbitmq
    networks:
      - infra
      - rabbitmq       
    depends_on:
      - node3
    deploy:
      replicas: 1
      placement:
        constraints: [node.labels.rabbitmq2 == true]
            
  node1:
    image: rabbitmq:3.8.7-management
    hostname: node1
    extra_hosts: 
      - "tpd.local:192.168.15.10"
      - "creone.local:192.168.15.11"
      - "parrerito.local:192.168.15.12"
      - "xonadao.local:192.168.15.13"
    configs:
      - source: rabbitmq_enabled_plugins
        target: /etc/rabbitmq/enabled_plugins
        uid: "999"
        gid: "999"
        mode: 0600
      - source: rabbitmq_rabbitmq.conf
        target: /etc/rabbitmq/rabbitmq.conf
        uid: "999"
        gid: "999"
        mode: 0777
    secrets:
      - source: rabbitmq_erlang.cookie
        target: /var/lib/rabbitmq/.erlang.cookie
        uid: "999"
        gid: "999"
        mode: 0600
    volumes:
      - /etc/localtime:/etc/localtime
      - node1:/var/lib/rabbitmq
    networks:
      - infra
      - rabbitmq
    depends_on:
     - node3
     - node2
    deploy:
      replicas: 1
      placement:
        constraints: [node.labels.rabbitmq1 == true]
```

### Verificando a stack

Você pode verificar a evolução da stack pelo portainer, como também pode verificar nas máquinas virtuais que estão os containers do RabbitMQ.

No console da máqina física, execute o comando abaixo para verificar o status dos nós:
```
vagrant ssh creone -c 'docker service ps rabbitmq_node1'
```

```
vagrant ssh parrerito -c 'docker service ps rabbitmq_node2'
```

```
vagrant ssh xonadao -c 'docker service ps rabbitmq_node3'
```


> NOTA: se quer acessar o Manager do RabbitMQ via browser sem um loadbacance ou proxy reverso na frente, precisa expor a porta 15672, acesse, por exemplo: tpd.local:15672 ou creone.local:15672 ou parrerito.local:15672 ou xonadao.local:15672. Para utilizar o protocolo AMQP deve expor a porta 5672.


## Conferindo os dados do RabbitMQ no ETCD

Anda na máquina física, digite o comando abaixo (pode ser quem qualquer VM):
```
vagrant ssh xonadao -c 'etcdctl get /rabbitmq/discovery/rabbitmq/clusters/staging/nodes/rabbit@node1'
vagrant ssh xonadao -c 'etcdctl get /rabbitmq/discovery/rabbitmq/clusters/staging/nodes/rabbit@node2'
vagrant ssh xonadao -c 'etcdctl get /rabbitmq/discovery/rabbitmq/clusters/staging/nodes/rabbit@node3'
```

Para pegar todos os dados:
```
vagrant ssh xonadao -c 'etcdctl get "" --prefix=true'
```

ou 
```
vagrant ssh xonadao -c 'etcdctl get "" --from-key'
```


Próximo: [Implantando LoadBalance nas Stacks](10-implantando-loadbalance-stacks.md)