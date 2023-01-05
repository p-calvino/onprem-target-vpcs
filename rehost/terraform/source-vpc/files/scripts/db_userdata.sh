#!/bin/bash

apt update -y
apt install postgresql-12 -y

# bind 5432 to the public IP so we can access it from outside the machine
echo "listen_addresses = '*'" >> /etc/postgresql/12/main/postgresql.conf
# update hba conf
echo "host    all             all              0.0.0.0/0                       md5" >> /etc/postgresql/12/main/pg_hba.conf
echo "host    all             all              ::/0                            md5" >> /etc/postgresql/12/main/pg_hba.conf

# restart the server
systemctl restart postgresql

su - postgres -c 'psql -U postgres -c "CREATE ROLE ubuntu SUPERUSER;"'
su - postgres -c 'psql -U postgres -c "ALTER ROLE  ubuntu  WITH LOGIN;"'
su - postgres -c 'psql -U postgres -c "ALTER USER  ubuntu  CREATEDB;"'
su - postgres -c $'psql -U postgres -c "ALTER USER  ubuntu  WITH PASSWORD \'ubuntu\';"'
su - postgres -c 'psql -U postgres -c "CREATE DATABASE ubuntu;"'
