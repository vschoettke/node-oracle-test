#!/bin/bash
# set -e

# sudo add-apt-repository ppa:webupd8team/java -y
sudo apt-get -q update
# requires "ENTER + LEFT + ENTER"
#sudo apt-get install oracle-java7-installer -y
java -version
#echo "export JAVA_HOME=/usr/lib/jvm/java-7-oracle" | sudo tee -a /etc/bash.bashrc
#echo "export PATH=\$JAVA_HOME/bin:\$PATH" | sudo tee -a /etc/bash.bashrc

echo "JAVA_HOME: $JAVA_HOME"
echo "PATH: $PATH"

if [ -z "$1" ]; then
    echo "secret missing"
    exit 1;
fi

SECRET=$1

curl https://raw.githubusercontent.com/vschoettke/ci-test/master/chunk_a >test.deb.enc
curl https://raw.githubusercontent.com/vschoettke/ci-test/master/chunk_b >>test.deb.enc
curl https://raw.githubusercontent.com/vschoettke/ci-test/master/chunk_c >>test.deb.enc
curl https://raw.githubusercontent.com/vschoettke/ci-test/master/chunk_d >>test.deb.enc
curl https://raw.githubusercontent.com/vschoettke/ci-test/master/chunk_e >>test.deb.enc
curl https://raw.githubusercontent.com/vschoettke/ci-test/master/chunk_f >>test.deb.enc
openssl enc -aes-256-cbc -d -in test.deb.enc -out test.deb -k `echo $SECRET`
openssl dgst -sha1 test.deb

echo "Installing libaio and unixodbc"

apt-get install -qq libaio1 unixodbc bc
cp chkconfig /sbin/
chmod 755 /sbin/chkconfig

ls -al /etc/init.d/
# cp 60-oracle.conf /etc/sysctl.d/
# service procps start
sysctl -q fs.file-max

echo "Preparing expected files"

ln -s /usr/bin/awk /bin/awk
mkdir /var/lock/subsys
touch /var/lock/subsys/listener

echo "Installing"

dpkg --install test.deb

echo "Cleanup after install"

rm -rf /dev/shm
mkdir /dev/shm
mount -t tmpfs shmfs -o size=1024m /dev/shm

echo "Configuring"

printf 8080\\n1521\\noracle\\noracle\\ny\\n | /etc/init.d/oracle-xe configure

echo "Dumping install logs"

pushd .
cd /u01/app/oracle/product/11.2.0/xe/config/log
find . -type f -exec cat {} +
popd

echo "Preparing bash enviroment"

echo "export ORACLE_HOME=/u01/app/oracle/product/11.2.0/xe" | tee -a /etc/bash.bashrc
echo "export ORACLE_SID=XE" | tee -a /etc/bash.bashrc
echo "export NLS_LANG=\`\$ORACLE_HOME/bin/nls_lang.sh\`" | tee -a /etc/bash.bashrc
echo "export ORACLE_BASE=/u01/app/oracle" | tee -a /etc/bash.bashrc
echo "export LD_LIBRARY_PATH=\$ORACLE_HOME/lib:\$LD_LIBRARY_PATH" | tee -a /etc/bash.bashrc
echo "export PATH=\$ORACLE_HOME/bin:\$PATH" | tee -a /etc/bash.bashrc

export ORACLE_HOME=/u01/app/oracle/product/11.2.0/xe
export ORACLE_SID=XE
export NLS_LANG=\`\$ORACLE_HOME/bin/nls_lang.sh\`
export ORACLE_BASE=/u01/app/oracle
export LD_LIBRARY_PATH=\$ORACLE_HOME/lib:\$LD_LIBRARY_PATH
export PATH=\$ORACLE_HOME/bin:\$PATH

echo "===[ Enviroment ]==============================================================="

env

echo "===[ Creating User ]============================================================"

echo "CREATE USER testuser IDENTIFIED BY travis;" | sqlplus -S -L SYSTEM/oracle
echo "grant CREATE SESSION, ALTER SESSION, CREATE DATABASE LINK, CREATE MATERIALIZED VIEW, CREATE PROCEDURE, CREATE PUBLIC SYNONYM, CREATE ROLE, CREATE SEQUENCE, CREATE SYNONYM, CREATE TABLE, CREATE TRIGGER, CREATE TYPE, CREATE VIEW, UNLIMITED TABLESPACE to testuser;" | sqlplus -S -L SYSTEM/oracle

echo "Finished"