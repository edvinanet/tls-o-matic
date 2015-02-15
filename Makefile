#
# Makefile for tls-o-matic self-tests
# ===================================
# Note: This is for test only. No certificate created should be used in
#       in production. 
# 
#
domain:=tls-o-matic.com
.PHONY=certs
COMPANYNAME:=Default TLS company

export COMPANYNAME

certs: intermediate test1 test2 test3 test4 test5 test6 test7 test10 test11
	@echo "✅  done!"

ca:
	bin/createca.sh
	bin/createevilca.sh

.PHONY=intermediate
intermediate:
	# Create three intermediate certificates under the primary cert
	# Needs to be run after 
	@echo " "
	@echo " "
	@echo "==> First intermediate cert "
	COMPANYNAME="Intermediate 1 $(domain)" \
	bin/createcert.sh intermed ca/cacert.pem TLS-o-matic-intermediate-1
	@echo " "
	@echo " "
	@echo "==> Second intermediate cert "
	COMPANYNAME="Intermediate 2 $(domain)" \
	bin/createcert.sh intermed certs/TLS-o-matic-intermediate-1.cert	TLS-o-matic-intermediate-2
	@echo " "
	@echo " "
	@echo "==> Third intermediate cert "
	COMPANYNAME="Intermediate 3 $(domain)" \
	bin/createcert.sh intermed certs/TLS-o-matic-intermediate-2.cert	TLS-o-matic-intermediate-3
	@echo "✅  done!"

test1:  
	# Normal cert, with SAN for domain
	COMPANYNAME="Arrogant Security Consultants LLC" \
	bin/createcert.sh cert test1.$(domain) $(domain)

test2:  
	# Cert with no SAN, bad CN
	COMPANYNAME="Another one bites the dust Inc" \
	bin/createcert.sh nosan test2.tls-o-matic.null

test3:  
	# Cert with bad SAN
	COMPANYNAME="Lucy In the Sky with Certificates" \
	bin/createcert.sh cert test3.$(domain) test3.tls-o-matic.null

test4:
	# Wildcards
	COMPANYNAME="Can't Make Up My Mind Inc" \
	bin/createcert.sh cert \*.$(domain) \*.test.$(domain),DNS:\*.$(domain),DNS:\*.beta.$(domain)

test5:
	# Future certificate
	COMPANYNAME="Marty and Doc's Environmentally friendly cars" \
	bin/createcert.sh future test5.$(domain) test5.$(domain)

test6:
	# Expired certificate
	COMPANYNAME="Soup and Barbecue Kitchen from the 60's" \
	bin/createcert.sh expired test6.$(domain) test6.$(domain)

test7:
	# Certificate from bad CA
	COMPANYNAME="We don't trust anyone" \
	bin/createcert.sh evil test7.$(domain) test7.$(domain)

test9:
	# Certificate from md5 CA
	COMPANYNAME="MD5 was good enough in the 90's" \
	bin/createcert.sh md5 test9.$(domain) $(domain)

test10:
	# intermediate cert under the first one 
	# ca -> intermediate 1 -> test10
	# depends on running "make intermediate" first
	COMPANYNAME="Give it UP" \
	bin/createcert.sh intercert test10.$(domain) $(domain)

test11:
	# intermediate cert 3
	# depends on running "make intermediate" first
	# ca -> intermediate 1 -> intermediate 2 -> intermediate 3 -> cert
	COMPANYNAME="Do it yourself" \
	bin/createcert.sh intercert certs/TLS-o-matic-intermediate-3.cert test11.$(domain)
