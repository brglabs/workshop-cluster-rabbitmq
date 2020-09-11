# Implantando a Stack do Portainer

Precisamos fazer algumas configurações extras no Cluster do Swarm para as próximas etapas.

## Pré Requisitos

Para iniciar essa etapa, e obrigatório ter feito corretamente a etapa [Inicializando o Cluster do Swarm](docs/04-iniciando-cluster-swarm.md).

> NOTA: os comandos desta etapa devem ser executados na máquina que está o nó `leader` do Swarm.


### Executando comandos no Swarm

Acesse o nó leader do Swarm, conforme configuramos, é a VM `tpd`, execute o comando no terminal da sua máquina fisica: `vagrant ssh tpd`

Após estar no console do nó leader, execute os comandos abaixo:


Para a criação das redes overlay:

```
docker network create --driver overlay --attachable rabbitmq
docker network create --driver overlay --attachable portainer
docker network create --driver overlay --attachable infra
docker network create --driver overlay --attachable monitoring
```

> Nota: para ver a redes criadas, basta executar o comando:
```
docker network ls
```


Precisamos configurar alguns labels:

```
docker node update --label-add rabbitmq1=true creone
docker node update --label-add rabbitmq2=true parrerito
docker node update --label-add rabbitmq3=true xonadao
```

> Nota: abrindo o Visualizer você consegue ver as labels criadas (exemplo: http://tpd.local:5000).


Próximo: [Inicializando o Cluster etcd](07-iniciando-cluster-etcd.md)