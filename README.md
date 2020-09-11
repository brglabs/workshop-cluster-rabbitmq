# Workshop Cluster RabbitMQ

Este tutorial orienta você na configuração de um Cluster de RabbitMQ. Este guia não é para pessoas que procuram um comando totalmente automatizado para ativar um cluster.

O Workshop Cluster RabbitMQ é otimizado para aprendizagem, o que significa seguir um longo caminho para garantir que você entenda cada tarefa necessária para inicializar um cluster RabbitMQ com Alta Disponibilidade.

> Os resultados deste tutorial não devem ser vistos como prontos para produção, mas não deixe que isso o impeça de aprender!

## Tech Stack

O  Workshop Cluster RabbitMQ orienta você na inicialização de um cluster RabbitMQ Altamente Disponível.

* [Vagrant](https://www.vagrantup.com)
* [Virtualbox](https://www.virtualbox.org)
* [Docker](https://www.docker.com) 
* [Docker Swarm](https://docs.docker.com/engine/swarm)
* [Visualizer](https://hub.docker.com/r/dockersamples/visualizer)
* [Portainer](https://www.portainer.io)
* [etcd](https://github.com/coreos/etcd)
* [HAProxy](https://www.haproxy.org)
* [RabbitMQ](https://www.rabbitmq.com)
* [Prometheus](https://prometheus.io)
* [Grafana](https://grafana.com/)

## Lab

* [Pré-requisitos](docs/01-pre-requisitos.md)
* [Instalando as Ferramentas na Máquina Física](docs/02-ferramentas-maquina-fisica.md)
* [Provisionando Máquinas Virtuais](docs/03-provisionando-maquinas-virtuais.md)
* [Inicializando o Cluster do Swarm](docs/04-iniciando-cluster-swarm.md)
* [Implantando o Visualizer](docs/05-implantando-visualiser.md)
* [Configurando extra no Swarm](docs/06-configuracao-extra-swarm.md)
* [Inicializando o Cluster etcd](docs/07-iniciando-cluster-etcd.md)
* [Implantando a Stack do Portainer](docs/08-implantando-stack-portainer.md)
* [Implantando a Stack do RabbitMQ](docs/09-implantando-stack-rabbitmq.md)
* [Implantando LoadBalance nas Stacks](docs/10-implantando-loadbalance-stacks.md)
* [Configurando o Cluster do RabbitMQ](docs/11-configurando-cluster-rabbitmq.md)
* [Testando Pub/Sub](docs/12-testando-pub-sub.md)
* [Limpando Tudo](docs/13-limpando-tudo.md)