#!/bin/sh
ERROR=1
CACERT=ca/cacert.pem
DOMAIN=tls-o-matic.com
FILENAME=$2
KEYTYPE=rsa

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
	echo "    intermedc  Create intermediate cert with name constraints. First arg is CA cert to sign with, second is name"
	echo "              $0 intermed certname servername"
	echo "    intercert  Create cert signed by intermediate cert"
	echo "              $0 intercert certname servername"
	echo "    inter3cert   Create cert signed by intermediate cert 3"
	echo "    ecrsacert    EC CA signing RSA cert - Default: SHA 256, subject alt name"
	echo "    eccert       EC Cert - Default: SHA 256, subject alt name"
	echo "    rsaeccert    EC Cert signed by RSA ca- Default: SHA 256, subject alt name"
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
if test $1 = eccert; then
	echo "==> EC Cert signed by EC ca"
	ERROR=0
	CACERT=ca/ec/cacert.pem
	OPTION="$OPTION  -name EC_CA_default"  
	KEYTYPE=ec
fi
if test $1 = ecrsacert; then
	echo "==> RSA Cert signed by EC ca "
	ERROR=0
	CACERT=ca/ec/cacert.pem
	OPTION="$OPTION  -name EC_CA_default"  
fi
if test $1 = rsaeccert; then
	echo "==> EC Cert signed by RSA ca "
	ERROR=0
	CACERT=ca/cacert.pem
	KEYTYPE=ec
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
if test $1 = intermed -o $1 = intermedc; then
	# Create intermediate cert
	if test $1 = intermed; then
		OPTION="$OPTION -extensions intermediate_cert"
	else
		OPTION="$OPTION -extensions intermediate_cert_constraints"
	fi
	
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




if test $KEYTYPE = ec
then
echo "====> Creating Elliptic Curve keys"
# Create EC key and request
KEYFILE=ca/ec/private/$FILENAME.key
openssl ecparam -out $KEYFILE -genkey \
	$REQOPTION \
	-name prime256v1 -noout
# Copy the same file to the request file
REQFILE=ca/ec/request/$FILENAME.req

#openssl req -new -key $KEYFILE -out $REQFILE
openssl req -new -nodes $REQOPTION \
	-out "$REQFILE" \
	-key "$KEYFILE" \
	-config etc/openssl.cnf

#
else
# Keytype = RSA
KEYFILE=ca/private/$FILENAME.key
REQFILE=ca/request/$FILENAME.req
openssl req -new -nodes $REQOPTION \
	-out "$REQFILE" \
	-keyout "$KEYFILE" \
	-config etc/openssl.cnf
fi

#Sign request And create cert
#echo Command: openssl ca  $OPTION \
	#-cert $CACERT \
	#-config etc/openssl.cnf \
	#-out "ca/certs/$FILENAME.cert" \
	#-infiles "$REQFILE"
openssl ca  $OPTION \
	-utf8 -cert $CACERT \
	-config etc/openssl.cnf \
	-out "certs/$FILENAME.cert" \
	-infiles "$REQFILE"

# Move the files to the proper place
if test -f certs/$FILENAME.cert
then
	rm -rf ca/request/$FILENAME.req
	rm -rf ca/ec/request/$FILENAME.req
fi
if test -f $KEYFILE
then
	mv $KEYFILE certs
fi
