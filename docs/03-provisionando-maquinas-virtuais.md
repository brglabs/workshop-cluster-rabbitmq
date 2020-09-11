# Provisionando Máquinas Virtuais

O vagrant irá provisionar máquínas virtuais do VirtualBox e instalar algumas dependências.

Na raíz do projeto digite o comando abaixo:
```
vagrant up
```

Após a conclusão verifique o status das máquinas criadas:
```
vagrant status
```

Para acessar o console de cada máquina virtual, siga o exemplo abaixo:
```
vagrant ssh NOME_DA_VM
```

Próximo: [Inicializando o Cluster do Swarm](docs/04-iniciando-cluster-swarm.md)