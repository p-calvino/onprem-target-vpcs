#!/bin/bash
# Reference: https://linuxhint.com/install-pgadmin4-ubuntu/

curl  -fsSL https://www.pgadmin.org/static/packages_pgadmin_org.pub | sudo gpg --dearmor -o /etc/apt/trusted.gpg.d/pgadmin.gpg
echo "deb https://ftp.postgresql.org/pub/pgadmin/pgadmin4/apt/$(lsb_release -cs) pgadmin4 main" > /etc/apt/sources.list.d/pgadmin4.list

apt update -y
apt install -y pgadmin4

if [[ ${PGADMIN_SETUP_EMAIL:-"unset"} == "unset" ]]; then
export PGADMIN_SETUP_EMAIL="admin@example.com"
fi

if [[ ${PGADMIN_SETUP_PASSWORD:-"unset"} == "unset" ]]; then
export PGADMIN_SETUP_PASSWORD="password"
fi

echo 'export PGADMIN_SETUP_EMAIL="${PGADMIN_SETUP_EMAIL}"' >> /home/ubuntu/.bashrc
echo 'export PGADMIN_SETUP_PASSWORD="${PGADMIN_SETUP_PASSWORD}"' >> /home/ubuntu/.bashrc

/usr/pgadmin4/bin/setup-web.sh --yes
