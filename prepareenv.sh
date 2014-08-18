#!/bin/bash
set -e
curl https://raw.githubusercontent.com/vschoettke/ci-test/master/chunk_a >test.deb.enc
curl https://raw.githubusercontent.com/vschoettke/ci-test/master/chunk_b >>test.deb.enc
curl https://raw.githubusercontent.com/vschoettke/ci-test/master/chunk_c >>test.deb.enc
curl https://raw.githubusercontent.com/vschoettke/ci-test/master/chunk_d >>test.deb.enc
curl https://raw.githubusercontent.com/vschoettke/ci-test/master/chunk_e >>test.deb.enc
curl https://raw.githubusercontent.com/vschoettke/ci-test/master/chunk_f >>test.deb.enc
openssl enc -aes-256-cbc -d -in test.deb.enc -out test.deb -k `echo $PASSWD`
openssl dgst -sha1 test.deb
