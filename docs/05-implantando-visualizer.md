# Implantando o Visualizer

Usaremos o Visualizer para ter a noção visual dos primeiros passos usando o Swarm.

## Pré Requisitos

Para iniciar essa etapa, e obrigatório ter feito corretamente a etapa [Inicializando o Cluster do Swarm](docs/04-iniciando-cluster-swarm.md).


### Subindo o Container

Acesse a VM onde está o líder do swarm: `vagrant ssh tpd`, no terminal do `tpd` execute o comando abaixo:

```
docker service create \
  --name=visualizer \
  --publish=5000:8080/tcp \
  --mode global \
  --constraint=node.role==manager \
  --mount=type=bind,src=/var/run/docker.sock,dst=/var/run/docker.sock \
  dockersamples/visualizer
```

### Acessando o a interface do Visualizer


Abra algum browser da sua máquina fisica e digite qualquer IP ou Host + a porta 5000 (configurados no /etc/hosts da máquina física), por exemplo `tpd.local:5000`.

Próximo: [Configurando extra no Swarm](docs/06-configuracao-extra-swarm.md)