#!/bin/sh
ERROR=1

function help()
{
	echo "Syntax: <certtype> hostname altname"
	echo "Certtype:"
	echo "    cert      Default: SHA 256, subject alt name"
	echo "    md5       MD5-signed certificate"
	echo "    nosan     Certificate with only CN"
	echo "    evil      Certificate signed by evil CA"
	echo "    expired   Expired default cert"
	echo "    future    Valid in the future default cert"
	exit
}

if test -z $1;then
	help
fi
if test $1 = md5; then
	OPTION="$OPTION -digest md5"
	ERROR=0
fi
if test $1 = nosan; then
	OPTION="$OPTION -extensions usr_cert_no_san"
	ERROR=0
fi
if test $1 = evil; then
	echo "Mohahahaha 👿 "
	ERROR=0
fi
if test $1 = expired; then
	# Date format is YYMMDDHHMMSSZ
    	OPTION="$OPTION -startdate 631224142828Z -enddate 631224142829Z"
	ERROR=0
fi
if test $1 = future; then
	# Date format is YYMMDDHHMMSSZ
    	OPTION="$OPTION -startdate 250214220000Z -enddate 250214220101Z"
	ERROR=0
fi
if test $1 = cert; then
	ERROR=0
fi
if test $ERROR = 1;then
	echo "ERROR - bad command $1. "
	help
	exit 1
fi
if test -z $3;then
	# Should possible change "www.skrep.com" and add "skrep.com" as alt name.
	COMMONNAME="$2"
	ALTNAME="DNS:$2"
else
	COMMONNAME=$2
	ALTNAME=DNS:$3
fi
#Generate request
echo "Common Name (CN) $COMMONNAME Alt $ALTNAME"
export COMMONNAME ALTNAME
# -digest sha256|md5|sha1
#	-extensions section
#	-reqexts section
#	- utf8		Fields are default ASCII
#	- verbose  Extra information

openssl req -new -nodes \
	-out "ca/request/$COMMONNAME.req" \
	-keyout "ca/private/$COMMONNAME.key" \
	-config etc/openssl.cnf

#Sign request And create cert
openssl ca  $OPTION \
	-config etc/openssl.cnf \
	-out "ca/certs/$COMMONNAME.cert" \
	-infiles "ca/request/$COMMONNAME.req"
cp ca/certs/$COMMONNAME.cert ca/private/$COMMONNAME.key certs
