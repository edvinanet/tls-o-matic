#!/bin/sh
if test -z $1;then
	COMMONNAME=youforgothtename.example.com
	ALTNAME=secondary.name.example.com
else
	if test -z $2;then
		COMMONNAME=$1
		ALTNAME=DNS:$1
	else
		if test $2 = none ;then
			COMMONNAME=$1
		else
			COMMONNAME=$1
			ALTNAME=DNS:$2
		fi
	fi
fi
echo Name: COMMONNAME
#Generate request
export COMMONNAME ALTNAME
openssl req -new -nodes \
	-out ca/bad/request/$COMMONNAME.req \
	-keyout ca/bad/private/$COMMONNAME.key \
	-config etc/openssl-badca.cnf

#Sign request And create cert
openssl ca  \
	-config etc/openssl-badca.cnf \
	-out ca/bad/certs/$COMMONNAME.cert \
	-infiles ca/bad/request/$COMMONNAME.req

#cp ca//bad/certs/$COMMONNAME.cert ca/bad/private/$COMMONNAME.key certs
