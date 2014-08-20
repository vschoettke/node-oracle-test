#!/bin/bash

if [ -z "$1" ]; then
    echo "secret missing"
    exit 1;
else

SECRET=$1

if [ -z "$2" ]; then
    ORACLE_USER=testuser
else
    ORACLE_USER=$2
fi

if [ -z "$3" ]; then
    ORACLE_PW=test
else
    ORACLE_PW=$3
fi

curl https://raw.githubusercontent.com/vschoettke/ci-xe-deb-enc/master/xe.deb.enc_a >xe.deb.enc
curl https://raw.githubusercontent.com/vschoettke/ci-xe-deb-enc/master/xe.deb.enc_b >>xe.deb.enc
curl https://raw.githubusercontent.com/vschoettke/ci-xe-deb-enc/master/xe.deb.enc_c >>xe.deb.enc
curl https://raw.githubusercontent.com/vschoettke/ci-xe-deb-enc/master/xe.deb.enc_d >>xe.deb.enc
curl https://raw.githubusercontent.com/vschoettke/ci-xe-deb-enc/master/xe.deb.enc_e >>xe.deb.enc
curl https://raw.githubusercontent.com/vschoettke/ci-xe-deb-enc/master/xe.deb.enc_f >>xe.deb.enc
openssl enc -aes-256-cbc -d -in xe.deb.enc -out xe.deb -k `echo $SECRET`
openssl dgst -sha1 xe.deb

sudo apt-get -qq update
sudo apt-get install -qq libaio1 unixodbc bc

sudo tee /sbin/chkconfig <<EOF > /dev/null
#!/bin/bash
# Oracle 11gR2 XE installer chkconfig hack for Ubuntu
file=/etc/init.d/oracle-xe
if [[ ! \`tail -n1 \$file | grep INIT\` ]]; then
echo >> \$file
echo '### BEGIN INIT INFO' >> \$file
echo '# Provides: OracleXE' >> \$file
echo '# Required-Start: \$remote_fs \$syslog' >> \$file
echo '# Required-Stop: \$remote_fs \$syslog' >> \$file
echo '# Default-Start: 2 3 4 5' >> \$file
echo '# Default-Stop: 0 1 6' >> \$file
echo '# Short-Description: Oracle 11g Express Edition' >> \$file
echo '### END INIT INFO' >> \$file
fi
update-rc.d oracle-xe defaults 80 01
EOF

sudo chmod 755 /sbin/chkconfig

sudo ln -s /usr/bin/awk /bin/awk
sudo mkdir /var/lock/subsys
sudo touch /var/lock/subsys/listener

sudo dpkg --install xe.deb

sudo rm -rf /dev/shm
sudo mkdir /dev/shm
sudo mount -t tmpfs shmfs -o size=1024m /dev/shm

printf 8080\\n1521\\noracle\\noracle\\ny\\n | sudo /etc/init.d/oracle-xe configure

export ORACLE_HOME=/u01/app/oracle/product/11.2.0/xe
export ORACLE_SID=XE
export NLS_LANG=`$ORACLE_HOME/bin/nls_lang.sh`
export ORACLE_BASE=/u01/app/oracle
export LD_LIBRARY_PATH=$ORACLE_HOME/lib:$LD_LIBRARY_PATH
export PATH=$ORACLE_HOME/bin:$PATH

echo "Creating user: $ORACLE_USER with password: $ORACLE_PW"

echo "CREATE USER $ORACLE_USER IDENTIFIED BY $ORACLE_PW;" | sqlplus -S -L SYSTEM/oracle
echo "grant CREATE SESSION, ALTER SESSION, CREATE DATABASE LINK, CREATE MATERIALIZED VIEW, CREATE PROCEDURE, CREATE PUBLIC SYNONYM, CREATE ROLE, CREATE SEQUENCE, CREATE SYNONYM, CREATE TABLE, CREATE TRIGGER, CREATE TYPE, CREATE VIEW, UNLIMITED TABLESPACE to $ORACLE_USER;" | sqlplus -S -L SYSTEM/oracle

export CI_ORACLE_USER=$ORACLE_USER
export CI_ORACLE_PW=$ORACLE_PW
export CI_ORACLE_DB=XE
export CI_ORACLE_HOSTNAME=localhost
export CI_ORACLE_PORT=1521
fi
