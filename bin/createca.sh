#!/bin/sh
# Create a CA
if test -z $1
then
DOMAIN=tls.example.com
else
DOMAIN=$1
fi
export COMPANYNAME="D&O Trustworth Certificates - \"Trust Us For Your Security\""

mkdir -p ca
cd ca
mkdir -p certs private newcerts
echo 1000 > serial
touch index.txt
export COMMONNAME="CA for $DOMAIN"
export ALTNAME=email:info@$DOMAIN
cd ..
# Create keys and sign the cert in one move
openssl req -new -x509 -batch -days 2500 -newkey rsa:4096 -extensions v3_ca -nodes \
-keyout ca/private/cacert.key -out ca/cacert.pem \
-config etc/openssl.cnf
