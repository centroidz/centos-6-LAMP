#!/bin/bash

### LAMP AUTO INSTALLER FOR CENTOS 6 ###

##############################
# disable un-needed services #
##############################
service httpd stop 
chkconfig httpd off
service xinetd stop
chkconfig xinetd off
service saslauthd stop
chkconfig saslauthd off
service sendmail stop
chkconfig sendmail off
service postfix stop
chkconfig postfix off
service rsyslog stop






#Work around OpenVZ's memory allocation limits (if on OpenVZ)

if [ -e "/proc/user_beancounters" ]
then
 echo "* soft stack 256" >/etc/security/limits.conf
  sed -i 's/plugins=1/plugins=0/' /etc/yum.conf
fi

#remove all current PHP, MySQL, mailservers, rsyslog.

yum -y remove httpd php mysql rsyslog sendmail postfix

###################
# Add a few repos #
###################

#Atomic repo for php
wget -q -O - http://www.atomicorp.com/installers/atomic | sh

#webtatic repo
yum install epel-release -y

rpm -Uvh https://mirror.webtatic.com/yum/el6/latest.rpm

####################################
# Install PHP 5.6 ,NGINX and MySQL #
####################################

yum -y install httpd mysql-server php56w php56w-mysql php56w-gd php56w-opcache nano exim syslog-ng cronie


########################
# install MySQL config #
########################



cat > /etc/my.cnf <<END
[mysqld]
default-storage-engine = myisam
key_buffer = 1M
query_cache_size = 1M
query_cache_limit = 128k
max_connections=25
thread_cache=1
skip-innodb
query_cache_min_res_unit=0
tmp_table_size = 1M
max_heap_table_size = 1M
table_cache=256
concurrent_insert=2 
max_allowed_packet = 1M
sort_buffer_size = 64K
read_buffer_size = 256K
read_rnd_buffer_size = 256K
net_buffer_length = 2K
thread_stack = 64K
END
echo  Do not worry if you see a error stopping MySQL
/etc/init.d/mysqld stop

#Create directories
mkdir /var/www
mkdir /var/www/html/

#add users, start services and configure iptables
service httpd start
chkconfig httpd on
iptables -I INPUT -p tcp --dport 80 -j ACCEPT
service iptables save
chkconfig syslog-ng on
service syslog-ng start
chkconfig crond on
service crond start
chkconfig mysqld on
service mysqld start


#Fix Sessions:
mkdir /var/lib/php/session
chmod 777 /var/lib/php/session


clear
echo Installation done.
echo run /usr/bin/mysql_secure_installation to set mysql password
exit
