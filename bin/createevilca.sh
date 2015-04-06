#!/bin/sh
# Create a CA
DOMAIN=not-your-friend.co.uk
export COMPANYNAME="The very trustworthy CA and used car sales inc"

cd ca/bad
mkdir -p certs private newcerts
echo 1000 > serial
touch index.txt
export COMMONNAME=$DOMAIN
export ALTNAME=DNS:$DOMAIN
# Create keys and sign it with itself
openssl req -new -x509 -batch -newkey rsa:4096 -days 5026 -extensions v3_bad_ca -nodes \
 -keyout private/cacert.key -out cacert.pem  \
 -config ../../etc/openssl.cnf
