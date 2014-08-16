#!/bin/bash
alias unzip-stream="python -c \"import zipfile,sys,StringIO;zipfile.ZipFile(StringIO.StringIO(sys.stdin.read())).extractall(sys.argv[1] if len(sys.argv) == 2 else '.')\""

# curl https://raw.githubusercontent.com/davidgaya/docker-apache-php-oci/master/instantclient-basic-linux.x64-12.1.0.2.0.zip  | unzip-stream ./
# curl https://raw.githubusercontent.com/davidgaya/docker-apache-php-oci/master/instantclient-sdk-linux.x64-12.1.0.2.0.zip | unzip-stream ./
#wget https://raw.githubusercontent.com/davidgaya/docker-apache-php-oci/master/instantclient-sqlplus-linux.x64-12.1.0.2.0.zip -O - | unzip-stream ./

pushd .
cd instantclient_12_1
for file in *.so.*; do
    ln -s $file ${file/.so.*/.so};
done

export OCI_HOME=`pwd`
export OCI_LIB_DIR=$OCI_HOME
export OCI_INCLUDE_DIR=$OCI_HOME/sdk/include
popd
