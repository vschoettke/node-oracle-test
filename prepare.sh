#!/bin/bash
# set -e

sudo apt-get update -qq
sudo apt-get install -qq libaio1

curl https://raw.githubusercontent.com/davidgaya/docker-apache-php-oci/master/instantclient-basic-linux.x64-12.1.0.2.0.zip | python -c "import zipfile,sys,StringIO;zipfile.ZipFile(StringIO.StringIO(sys.stdin.read())).extractall(sys.argv[1] if len(sys.argv) == 2 else '.')" ./
curl https://raw.githubusercontent.com/davidgaya/docker-apache-php-oci/master/instantclient-sdk-linux.x64-12.1.0.2.0.zip | python -c "import zipfile,sys,StringIO;zipfile.ZipFile(StringIO.StringIO(sys.stdin.read())).extractall(sys.argv[1] if len(sys.argv) == 2 else '.')" ./
#curl https://raw.githubusercontent.com/davidgaya/docker-apache-php-oci/master/instantclient-sqlplus-linux.x64-12.1.0.2.0.zip -O - | unzip-stream ./

pushd .
cd instantclient_12_1
for file in *.so.*; do
    ln -s $file ${file/.so.*/.so};
done

export OCI_HOME=`pwd`
export OCI_LIB_DIR=$OCI_HOME
export OCI_INCLUDE_DIR=$OCI_HOME/sdk/include
export OCI_VERSION=12 # Integer. Optional, defaults to '11'
export NLS_LANG=.UTF8 # Optional, but required to support international characters
export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:$OCI_LIB_DIR"

echo "PATHS:"
echo $OCI_HOME
echo $OCI_LIB_DIR
echo $OCI_INCLUDE_DIR
echo $NLS_LANG
echo $LD_LIBRARY_PATH

popd
