#!/bin/bash

apt install -y sudo
groupadd -g 30000 admin
useradd -u 30000 -m -g admin admin
usermod -a -G admin admin

mkdir /testdb
chown admin: /testdb
sudo -u admin /pg/bin/initdb -D /testdb
sudo -u admin /pg/bin/pg_ctl -D /testdb start
sudo -u admin /pg/bin/psql -d postgres -c "select * from pg_available_extensions order by name;"
#sudo -u admin /pg/bin/pg_ctl -D /testdb restart
