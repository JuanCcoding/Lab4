#!/bin/bash
#
EFS_ID="${EFS_ID}"
EFS_DNS="${EFS_DNS}"
DB_PASSWORD="${DB_PASSWORD}"


yum install memcached -y
systemctl start memcached
mkdir /var/www/html/efs
# Mounting Efs 
mount -t nfs4 -o nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport ${EFS_DNS}:/ /var/www/html/efs

# Making Mount Permanent
echo "${EFS_ID}:/ /var/www/html/efs efs tls,_netdev 0 0" | sudo tee -a /etc/fstab

#sed -i 's/database_name_here/wordpress/g' /var/www/html/wp-config.php
 
#sed -i 's/username_here/admin123/g' /var/www/html/wp-config.php
 
sed -i "s/passwordddbb/${DB_PASSWORD}/g" /var/www/html/wp-config.php # sobre escribimos esta linea del archivo con nuestra clave generada aleatoriamente
 
#sed -i 's/localhost/bbdd.lab4.com/g' /var/www/html/wp-config.php

