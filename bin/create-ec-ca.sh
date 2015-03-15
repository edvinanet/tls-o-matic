#!/bin/sh
# Inspired by http://blogs.splunk.com/2014/06/03/generate-elliptical-curve-certkeys-for-splunk/
DOMAIN=tls-o-matic.com
mkdir -p ca/ec
mkdir -p ca/ec/private
mkdir -p ca/ec/newcerts ca/ec/certs
cd ca/ec
echo 1000 > serial
touch index.txt
export COMMONNAME="EC CA for $DOMAIN"
export ALTNAME=email:info@$DOMAIN
cd ca/ec
# Create key
openssl ecparam -out private/cakey.pem -genkey -name prime256v1
# Create and sign request
openssl req -x509 -new -key private/cakey.pem -days 3650 -extensions v3_ca -out cacert.pem


