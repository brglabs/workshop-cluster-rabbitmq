# Iniciando o Cluster do Swarm

O Swarm irá gerenciar os containers do RabbitMQ ajudando a manter a Alta Disponibilidade. 

## Pré Requisitos

Para iniciar essa etapa, e obrigatório ter feito corretamente a etapa [Provisionando Máquinas Virtuais](docs/03-provisionando-maquinas-virtuais.md).

### Subindo o Swarm

Inicie o Swarm digitando o comando abaixo na máquina física:
```
vagrant ssh tpd -c 'docker swarm init --advertise-addr enp0s8'
```

Copie a saída da execução do comando acima, e execute nos outros nós:
```
vagrant ssh creone -c 'COMANDO COPIADO DO PASSO ANTERIOR'
vagrant ssh parrerito -c 'COMANDO COPIADO DO PASSO ANTERIOR'
vagrant ssh xonadao -c 'COMANDO COPIADO DO PASSO ANTERIOR'
```

Execute o comando abaixo para verificar o nós do cluster (é necessário executar na VM que foi selecionada como o nó `leader`, no cado a VM `tpd`):
```
vagrant ssh tpd -c 'docker node ls'
```

Próximo: [Implantando o Visualizer](docs/05-implantando-visualiser.md)