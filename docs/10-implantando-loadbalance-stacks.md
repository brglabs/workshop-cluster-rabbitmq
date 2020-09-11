# Implantando a Stack do HAProxy

A idéia desse laboratóro é ter um serviço altamente disponível onde iremos despachar solicitações distribuindo entre os nós em execução do cluster RabbitMQ, evitando o envio de solicitações em um único nó e/ou em nós com falha.

## Pré Requisitos

Para iniciar essa etapa, e obrigatório ter feito corretamente a etapa [Implantando a Stack do RabbitMQ](docs/09-implantando-stack-rabbitmq.md).

## Criando arquivos de configuração

Antes de subir a stack, é necessário criar um arquivo de configuração.

Abra o Portainer em um browser, exemplo `tpd.sre.local:9000`. Lembre se para acessar diretamente é necessário expor a porta `9000` no docker-compose.

## Criando o arquivo haproxy.cfg

* No Portainer, no menu da esquerda, clique em Configs, depois clique em `+ Add Config`;
* No campo name, digite `haproxy_haproxy.cfg`;
* No campo abaixo, copia e cole o código a seguir: 
```
global
    log 127.0.0.1   local0
    log 127.0.0.1   local1 notice
    maxconn 4096
 
defaults
    log     global
    option  tcplog
    option  dontlognull
    timeout connect 60s
    timeout client  60s
    timeout server  60s

listen stats
    bind            *:1936
    mode            http
    stats           enable
    maxconn         10
    timeout         queue   10s
    stats           hide-version
    stats           refresh 30s
    stats           show-node
    stats           realm Haproxy\ Statistics
    stats           uri /
    stats           admin if TRUE    
    stats auth admin:1q2w3e4r

listen rabbitmq-tcp-amqp
    bind    *:5672
    mode    tcp
    log     global
    retries 5
    option  tcplog
    option  clitcpka # permite o envio de pacotes keepalive TCP no lado do cliente
    option  persist
    balance roundrobin
    server  rabbitmq_node1-tcp-amqp rabbitmq_node1:5672 check inter 5s rise 2 fall 5
    server  rabbitmq_node2-tcp-amqp rabbitmq_node2:5672 check inter 5s rise 2 fall 5
    server  rabbitmq_node3-tcp-amqp rabbitmq_node3:5672 check inter 5s rise 2 fall 5 

listen rabbitmq-tcp-cluster
    bind    *:25672
    mode    tcp
    log     global
    retries 5
    option  tcplog
    option  clitcpka # permite o envio de pacotes keepalive TCP no lado do cliente
    option  persist
    balance roundrobin
    server  rabbitmq_node1-tcp-cluster rabbitmq_node1:25672 check inter 5s rise 2 fall 5
    server  rabbitmq_node2-tcp-cluster rabbitmq_node2:25672 check inter 5s rise 2 fall 5
    server  rabbitmq_node3-tcp-cluster rabbitmq_node3:25672 check inter 5s rise 2 fall 5   

listen rabbitmq-tcp-epmd
    bind    *:4369
    mode    tcp
    log     global
    retries 5
    option  tcplog
    option  clitcpka # permite o envio de pacotes keepalive TCP no lado do cliente
    option  persist
    balance roundrobin
    server  rabbitmq_node1-tcp-epmd rabbitmq_node1:4369 check inter 5s rise 2 fall 5
    server  rabbitmq_node2-tcp-epmd rabbitmq_node2:4369 check inter 5s rise 2 fall 5
    server  rabbitmq_node3-tcp-epmd rabbitmq_node3:4369 check inter 5s rise 2 fall 5          

#########################
# >>> FRONTEND HTTP <<< #
#########################
frontend http-in-80
    bind    *:80
    mode    http
    stats   enable
    option  http-keep-alive

    timeout http-request    60s
    timeout http-keep-alive 60s

    # Define backend
    ################
    use_backend rmq-manager if { hdr_reg(host) -i ^rmq(|\d)\. }
    use_backend rmq-monitor if { hdr_reg(host) -i ^rmq-monitor(|\d)\. }
    use_backend portainer   if { hdr_reg(host) -i ^portainer(|\d)\. } 

########################
# >>> BACKEND HTTP <<< #
########################    
backend rmq-manager
    mode    http
    log     global
    retries 5
    stats   enable

    option  persist
    
    balance roundrobin
    server  rabbitmq1-15672 rabbitmq_node1:15672 check inter 5s rise 2 fall 5
    server  rabbitmq2-15672 rabbitmq_node2:15672 check inter 5s rise 2 fall 5
    server  rabbitmq3-15672 rabbitmq_node3:15672 check inter 5s rise 2 fall 5    

backend rmq-monitor
    mode    http
    log     global
    retries 5
    stats   enable

    option  persist
    
    balance roundrobin
    server  rabbitmq1-15692 rabbitmq_node1:15692 check inter 5s rise 2 fall 5
    server  rabbitmq2-15692 rabbitmq_node2:15692 check inter 5s rise 2 fall 5
    server  rabbitmq3-15692 rabbitmq_node3:15692 check inter 5s rise 2 fall 5

backend portainer
    mode     http
    log      global
    retries  5

    stats    enable
    option   forwardfor
    option   http-keep-alive
    option   persist
    
    balance  roundrobin
    server   portainer_server portainer_server:9000 check inter 5s rise 2 fall 5 
```

### Implantando a Stack do HAProxy

Agora iremos subir a stack do HAProxy de fato.

* No menu da esquerda do Portainer, clique em Stack: 
* Em seguida clique em `+ Add Stack`;
* No campo name, digite `lb`;
* Em `Web editor` copia e cole o código abaixo: 
```
version: "3.6"

configs:
  haproxy_haproxy.cfg:
    external: true

networks:
  infra:
    external: true

services:

  haproxy:
    image: haproxy:2.2.2-alpine
    hostname: sre.local
    configs:
      - source: haproxy_haproxy.cfg
        target: /usr/local/etc/haproxy/haproxy.cfg
        uid: "999"
        gid: "999"
        mode: 0600
    ports:
      - 443:443
      - 80:80
      - 1936:1936
    networks:
      - infra
    deploy:
      mode: global      
```

### Verificando a stack

Você pode verificar a evolução da stack pelo portainer, como também pode verificar nas máquinas virtuais que estão os containers do HAProxy.

No console da máqina física, execute o comando abaixo para verificar o status dos serviço:
```
vagrant ssh creone -c 'docker service ps lb_haproxy'
```

### Acessando serviços via browser

Abra o navegador em sua máquina física e acesso os endereços abaixo:

* HAProxy: tpd.local:1936 (qualquer DNS das VMs + porta 1936)
* [Portainer: http://portainer.sre.local](http://portainer.sre.local)
* [RabbitMQ Manager: http://rmq.sre.local](http://rmq.sre.local)
* [RabbitMQ Monitor: http://rmq-monitor.sre.local](http://rmq-monitor.sre.local)

Próximo: [Configurando o Cluster do RabbitMQ](docs/11-configurando-cluster-rabbitmq.md)