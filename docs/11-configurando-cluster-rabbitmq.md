# Configurando Cluster do RabbitMQ

Para darmos continuidade nesse laboratório, é necessario que realizemos algumas configurações no RabbiMQ

## Pré Requisitos

Para facilitar a execução dos comandos desta etapa, usaremos o Portainer.


### Configuração inicial do Cluster

Abra um navegador na sua máquina fisica e acesse o link [Portainer: http://portainer.sre.local](http://portainer.sre.local), após o login, siga as etapas abaixo:

* No menu direito, clique em `Stacks`;
* Na listagem, clique em `rabbitmq`;
* Escolha qualquer nó e clique no nome;
* No menu a direita, clique em Tasks e navegue até o final da página;
* Na task com o Status `running`, cluque no ícone `>_` na coluna Actions, depois clique em `Connect`;

Agora você está no terminal do seriviço do rabbitmq escolhido. Siga as instruções abaixo:

```
### Configurando nome do Cluster e do primeiro Host;
CLUSTER_NAME="sre";
HOST_NAME="lab1";

### Setando o nome do Cluster
rabbitmqctl set_cluster_name $CLUSTER_NAME;

### Adicionamdo o Host "$HOST_NAME"
rabbitmqctl add_vhost $HOST_NAME;

### Setando para que todas as filas do Host "$HOST_NAME" seja de Alta Disponibilidade
rabbitmqctl set_policy -p $HOST_NAME ha-all "" '{"ha-mode": "all", "ha-sync-mode": "automatic"}';

### Setando todas as permissões do usuário admin para o host "$HOST_NAME" 
rabbitmqctl set_permissions -p $HOST_NAME admin ".*" ".*" ".*";

#################################
# CRIANDO USUÁRIOS DE APLICAÇÂO #
#################################

### Adicionando o usuário Produtor:
rabbitmqctl add_user producer 123456

### Setando tag ao producer:
rabbitmqctl set_user_tags producer read-only

### Setando permissão de escrita para o produtor na fila pubsub:
rabbitmqctl set_permissions -p $HOST_NAME producer "^pubsub" ".*" ".^$";

### Adicionando o usuário Consumidor:
rabbitmqctl add_user consumer 123456

### Setando tag ao consumer
rabbitmqctl set_user_tags consumer write-only

# Setando permissão de leitura para o consumidor na fila:
rabbitmqctl set_permissions -p $HOST_NAME consumer "^pubsub" ".^$" ".*";
```

Próximo: [Testando Pub/Sub](12-testando-pub-sub.md)