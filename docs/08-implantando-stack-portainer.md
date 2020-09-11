# Implantando a Stack do Portainer

Usaremos o Portainer para gerenciar o Swarm e facilitar a criação e manutenção do Cluster do RabbitMQ.

## Pré Requisitos

Para iniciar essa etapa, e obrigatório ter feito corretamtne a etapa [Configurando extra no Swarm](docs/06-configuracao-extra-swarm.md).

Para melhor efetividade, o docker-compose.yml da stack do Portainer deve ficar dentro do diretório `~/workshop-cluster-rabbitmq/docker/portainer`, assim estará disponível para todas a máquinas virtuais. 


### Implantando a Stack do Portainer

No terminal da `sua máqina física` navegue até o diretório tool que dentro do projeto `~/workshop-cluster-rabbitmq/docker/portainer`, execute o comando abaixo:

```
cat <<EOF | tee docker-compose-stack.yml
version: '3.2'

volumes:
  server:

networks:
  infra:
    external: true

services:
  agent:
    image: portainer/agent:linux-amd64-2.0.0-alpine
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
      - /var/lib/docker/volumes:/var/lib/docker/volumes
    networks:
      - infra
    deploy:
      mode: global
      placement:
        constraints: [node.platform.os == linux]

  server:
    image: portainer/portainer:alpine
    command: -H tcp://agent:9001 --tlsskipverify
    volumes:
      - server:/data
    networks:
      - infra
    depends_on:
      - agent
    deploy:
      mode: replicated
      replicas: 1
      placement:
        constraints: [node.role == manager]
EOF
```

Ainda na máquina fisica, no terminal e na raiz do projeto, execute o comando abaixo:

> NOTA: o comando para implantar a stack deve executado na máquina que está o nó `leader` do Swarm.
```
vagrant ssh tpd -c 'docker stack deploy -c /vagrant/docker/portainer/docker-compose-stack.yml portainer'
```


### Verificando a stack

Ainda na máqina fisica e na raiz do projeto, execute o comando abaixo para verificar o status do agente do Portainer:
```
vagrant ssh tpd -c 'docker service ps portainer_agent'
```

Verifique o status do servidor do Portainer
```
vagrant ssh tpd -c 'docker service ps portainer_server'
```

> NOTA: se quer acessar o Portainer via browser sem um loadbacance/proxy-reverso na frente, precisa expor a porta 9001:9000, podender acessar, por exemplo: `tpd.sre.local:9001`.


Próximo: [Implantando a Stack do RabbitMQ](09-implantando-stack-rabbitmq.md)