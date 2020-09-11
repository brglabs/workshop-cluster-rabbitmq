# Testando com Pub/Sub

Vamos testar o cluster para ver se tudo está ok.

### Criando a queue 'pubsub'

Declarando um exchange (`rabbitmqadmin -u {user} -p {password} -V {vhost} declare exchange name={name} type={type}`)
rabbitmqadmin -u admin -p admin declare exchange -V lab1 name=troca-troca type=fanout

Declarando uma queue com parâmetros opcionais (`rabbitmqadmin -u {user} -p {password} -V {vhost} declare queue name={name} durable={boolean}`)
rabbitmqadmin -u admin -p admin declare -V lab1 queue name=my-new-queue durable=false

Bindando uma exchange a uma fila (`rabbitmqadmin -u {user} -p {password} -V {vhost} declare binding source={Exchange} destination={queue}`)
rabbitmqadmin -u admin -p admin -V lab1 declare binding source=troca-troca destination=my-new-queue

Publicando uma mensagem
rabbitmqadmin -u admin -p admin -V lab1 publish exchange=amq.default routing_key=my-new-queue payload="hello, world"

Obtendo a mensagem da fila
rabbitmqadmin -u admin -p admin -V lab1 getqueue=my-new-queue ackmode=ack_requeue_false


* [Limpando Tudo](docs/13-limpando-tudo.md)