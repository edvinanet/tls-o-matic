#!/bin/sh
ERROR=1
CACERT=ca/cacert.pem
DOMAIN=tls-o-matic.com
FILENAME=$2

if test -z "$COMPANYNAME"
then
	COMPANYNAME="Unknown Security Customer"
fi

function findkey()
{
	KEYFILE=`dirname $CACERT`/`basename $CACERT .pem`.key
	if ! test -f $KEYFILE
	then
		KEYFILE=`dirname $CACERT`/private/`basename $CACERT .pem`.key
		if ! test -f $KEYFILE;then
			KEYFILE=`dirname $CACERT`/`basename $CACERT .cert`.key
			if ! test -f $KEYFILE;then
				echo "ERROR: Can't find $KEYFILE."
				exit 1
			fi
		fi
	fi
}

function help()
{
	echo "Syntax: <certtype> hostname altname [filename]"
	echo "Certtype:"
	echo "    cert      Default: SHA 256, subject alt name"
	echo "    bigcert   Default: SHA 256, subject alt name, big key"
	echo "    sancert   Default: SHA 256, subject alt name list as argument"
	echo "    md5       MD5-signed certificate"
	echo "    nosan     Certificate with only CN"
	echo "    evil      Certificate signed by evil CA"
	echo "    expired   Expired default cert"
	echo "    future    Valid in the future default cert"
	echo "    weird     Weird certificate with strange usages"
	echo "    intermed  Create intermediate cert. First arg is CA cert to sign with, second is name"
	echo "              $0 intermed certname servername"
	echo "    intercert  Create cert signed by intermediate cert"
	echo "              $0 intercert certname servername"
	echo "    inter3cert  Create cert signed by intermediate cert 3"
	echo ""
	exit
}

if test -z $1;then
	help
fi
if test $1 = md5; then
	OPTION="$OPTION -md md5"
    	OPTION="$OPTION -startdate 920101012828Z -enddate 350401010101Z"
	# Use a smaller key length too
	REQOPTION="$REQOPTION -newkey rsa:512"
	ERROR=0
fi
if test $1 = nosan; then
	# Use another section of openssl.cnf
	OPTION="$OPTION -extensions usr_cert_no_san"
	ERROR=0
fi
if test $1 = weird; then
	# Use another section of openssl.cnf
	OPTION="$OPTION -extensions strangecert"
	REQOPTION="$REQOPTION -newkey rsa:4096"
	ERROR=0
fi
if test $1 = evil; then
	echo "Mohahahaha 👿 "
	CACERT=ca/bad/cacert.pem
	OPTION="$OPTION  -name CA_bad"  
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
if test $1 = bigcert; then
	OPTION="$OPTION -md sha512"
	REQOPTION="$REQOPTION -newkey rsa:16384"
	ERROR=0
fi
if test $1 = cert; then
	ERROR=0
fi
if test $1 = intercert; then
	# Sign with intermediate cert
	CACERT=$2
	COMMONNAME=$3
	FILENAME=$3
	KEYFILE=`dirname $CACERT`/`basename $CACERT`.key
	findkey
	OPTION="$OPTION  -keyfile $KEYFILE"
	ALTNAME=email:info@$DOMAIN
	echo "*** --- Signing with intermediate CA cert with CERT $CACERT and key $KEYFILE "
	# AltName is not used, but the req settings require one
	ERROR=0
fi
if test $1 = inter3cert; then
	# Sign with intermediate cert
	CACERT=$2
	COMMONNAME=$3
	FILENAME=$3
	KEYFILE=`dirname $CACERT`/`basename $CACERT .pem`.key
	findkey
	OPTION="$OPTION  -keyfile $KEYFILE"
	ALTNAME=email:info@$DOMAIN
	echo "*** --- Signing with intermediate CA cert with CERT $CACERT and key $KEYFILE "
	# AltName is not used, but the req settings require one
	ERROR=0
fi
if test $1 = sancert; then
	COMMONNAME="$2"
	ALTNAME="$3"
	ERROR=0
fi
if test $1 = intermed; then
	# Create intermediate cert
	OPTION="$OPTION -extensions intermediate_cert"
	CACERT=$2
	COMMONNAME=$3
	FILENAME=$3
	KEYFILE=`dirname $CACERT`/`basename $CACERT .pem`.key
	if ! test -f $KEYFILE
	then
		KEYFILE=`dirname $CACERT`/private/`basename $CACERT .pem`.key
		if ! test -f $KEYFILE;then
			KEYFILE=`dirname $CACERT`/`basename $CACERT .cert`.key
			if ! test -f $KEYFILE;then
				echo "ERROR: Can't find $KEYFILE."
				exit 1
			fi
		fi
	fi
	OPTION="$OPTION  -keyfile $KEYFILE"
	# To switch CA certs
	# -certfile file
	# -keyfile file
	echo "*** --- Creating intermediate CA cert with CERT $CACERT and key $KEYFILE "
	# AltName is not used, but the req settings require one
	ALTNAME=email:info@$DOMAIN
	ERROR=0
fi
if test $ERROR = 1;then
	echo "ERROR - bad command $1. "
	help
	exit 1
fi
if test -z $3;then
	# Should possible change "www.skrep.com" and add "skrep.com" as alt name.
	if test -z $COMMONNAME;then
		COMMONNAME="$2"
		ALTNAME="DNS:$2"
	fi
else
	if test -z $COMMONNAME;then
		COMMONNAME=$2
		ALTNAME=DNS:$3
	fi
fi
if ! test -z $4;then
	FILENAME=$4
fi
#Generate request
echo "Company $COMPANYNAME Common Name (CN) $COMMONNAME Alt $ALTNAME"
export COMMONNAME ALTNAME
# -digest sha256|md5|sha1
#	-extensions section
#	-reqexts section
#	- utf8		Fields are default ASCII
#	- verbose  Extra information

openssl req -new -nodes $REQOPTION \
	-out "ca/request/$FILENAME.req" \
	-keyout "ca/private/$FILENAME.key" \
	-config etc/openssl.cnf

#Sign request And create cert
#echo Command: openssl ca  $OPTION \
	#-cert $CACERT \
	#-config etc/openssl.cnf \
	#-out "ca/certs/$FILENAME.cert" \
	#-infiles "ca/request/$FILENAME.req"
openssl ca  $OPTION \
	-cert $CACERT \
	-config etc/openssl.cnf \
	-out "ca/certs/$FILENAME.cert" \
	-infiles "ca/request/$FILENAME.req"

# Move the files to the proper place
if test -f ca/certs/$FILENAME.cert
then
	mv ca/certs/$FILENAME.cert certs
	rm ca/request/$FILENAME.req
fi
if test -f ca/private/$FILENAME.key
then
	mv ca/private/$FILENAME.key certs
fi
