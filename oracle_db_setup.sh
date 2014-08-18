#!/bin/bash
set -e

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

apt-get -qq update
apt-get install -qq libaio1 unixodbc bc

tee /sbin/chkconfig <<EOF > /dev/null
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

chmod 755 /sbin/chkconfig

ln -s /usr/bin/awk /bin/awk
mkdir /var/lock/subsys
touch /var/lock/subsys/listener

dpkg --install test.deb

rm -rf /dev/shm
mkdir /dev/shm
mount -t tmpfs shmfs -o size=1024m /dev/shm

printf 8080\\n1521\\noracle\\noracle\\ny\\n | /etc/init.d/oracle-xe configure
