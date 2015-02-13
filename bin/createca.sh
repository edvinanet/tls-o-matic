#!/bin/sh
# Create a CA
DOMAIN=tls-o-matic.com

cd ca
mkdir certs private newcerts
echo 1000 > serial
touch index.txt
export COMMONNAME=$DOMAIN
export ALTNAME=$DOMAIN
# Create keys
openssl req -new -x509 -days 365 -extensions v3_ca -nodes \
-keyout private/cakey.pem -out cacert.pem \
-config ../etc/openssl.cnf
