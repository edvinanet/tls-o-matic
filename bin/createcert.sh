#!/bin/sh
if test -z $1;then
	COMMONNAME=sip.sipguru.no
	ALTNAME=sipguru.no
else
	if test -z $2;then
		COMMONNAME=$1
		ALTNAME=DNS:$1
	else
		COMMONNAME=$1
		ALTNAME=DNS:$2
	fi
fi
echo Name: COMMONNAME
#Generate request
export COMMONNAME ALTNAME
openssl req -new -nodes \
	-out ca/request/$COMMONNAME.req \
	-keyout ca/private/$COMMONNAME.key \
	-config etc/openssl.cnf

#Sign request And create cert
openssl ca  \
	-config etc/openssl.cnf \
	-out ca/certs/$COMMONNAME.cert \
	-infiles ca/request/$COMMONNAME.req
cp ca/certs/$COMMONNAME.cert ca/private/$COMMONNAME.key certs
