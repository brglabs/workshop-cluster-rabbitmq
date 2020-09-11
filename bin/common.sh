#/bin/sh

echo #######################################################################################
echo # Update e Upgrade
echo #######################################################################################
sudo apt update && sudo apt upgrade -y

echo #######################################################################################
echo # Instalando Pacotes
echo #######################################################################################
sudo apt install -y curl htop vim jq tree

echo #######################################################################################
echo # Instalando o Docker
echo #######################################################################################
sudo mkdir -p /etc/systemd/system/docker.service.d/
cat <<EOF | sudo tee /etc/systemd/system/docker.service.d/override.conf
[Service]
ExecStart=
ExecStart=/usr/bin/dockerd
EOF

cat <<EOF | sudo tee /etc/docker/daemon.json
{
    "log-level":"debug",
    "hosts": ["unix:///var/run/docker.sock","tcp://0.0.0.0:2376"],
    "metrics-addr" : "127.0.0.1:9000",
    "experimental" : true
}
EOF

sudo curl -fsSL get.docker.com -o get-docker.sh 
sudo sh get-docker.sh
sudo rm -rf get-docker.sh

echo #######################################################################################
echo # Configurando usuário e grupo
echo #######################################################################################
sudo gpasswd -a vagrant docker
sudo usermod -aG docker vagrant
sudo systemctl restart docker

echo #######################################################################################
echo # Instalando o docker-compose
echo #######################################################################################
sudo curl -fsSL https://github.com/docker/compose/releases/download/1.21.0/docker-compose-$(uname -s)-$(uname -m) -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose


sudo curl -fsSL https://raw.githubusercontent.com/rabbitmq/rabbitmq-management/v3.8.8/bin/rabbitmqadmin -o /usr/local/bin/rabbitmqadmin
sudo chmod +x /usr/local/bin/rabbitmqadmin

echo #######################################################################################
echo # Configurando hosts
echo #######################################################################################
cat <<EOF | sudo tee --append /etc/hosts

192.168.15.10 tpd.local        tpd       
192.168.15.11 creone.local     creone    rmq.sre.local
192.168.15.12 parrerito.local  parrerito rmq.sre.local
192.168.15.13 xonadao.local    xonadao   rmq.sre.local

EOF

echo #######################################################################################
echo # Desativando swap
echo #######################################################################################
sudo swapoff -a

echo #######################################################################################
echo # Reiniciando sistema
echo #######################################################################################
sudo reboot