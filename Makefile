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
OPENSSL=/opt/local/bin/openssl

export COMPANYNAME

web:
	make -C httpd/test1
	make -C httpd/test2
	make -C httpd/test3
	make -C httpd/test4
	make -C httpd/test5
	make -C httpd/test6
	make -C httpd/test7
	make -C httpd/test8
	make -C httpd/test9
	make -C httpd/test10
	make -C httpd/test11
	make -C httpd/test12
	make -C httpd/test13
	#	make -C httpd/test14
	make -C httpd/test15
	make -C httpd/test20
	@echo "✅  done!"

certs: intermediate test1 test2 test3 test4 test5 test6 test7 test8 test9 test10 test11 test12 test13 test15 test20
	@echo "✅  done!"

ca:
	@echo "===> Creating normal CA"
	bin/createca.sh
	@echo "===> Creating evil CA"
	bin/createevilca.sh
	@echo "✅  done!"

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
	@echo " "
	@echo "==> Fourth intermediate cert "
	COMPANYNAME="Intermediate 4 $(domain)" \
	bin/createcert.sh intermed certs/TLS-o-matic-intermediate-4.cert	TLS-o-matic-intermediate-4
	@echo "✅  done!"

test1:  
	# Normal cert, with SAN for domain
	COMPANYNAME="Arrogant Security Consultants LLC" \
	bin/createcert.sh cert test1.$(domain) $(domain)
	@echo "✅  done!"

test2:  
	# Cert with no SAN, bad CN
	COMPANYNAME="Another one bites the dust Inc" \
	bin/createcert.sh nosan test2.tls-o-matic.null
	@echo "✅  done!"

test3:  
	# Cert with bad SAN
	COMPANYNAME="Lucy In the Sky with Certificates" \
	bin/createcert.sh cert test3.$(domain) test3.tls-o-matic.null
	@echo "✅  done!"

test4:
	# Wildcards
	COMPANYNAME="Can't Make Up My Mind Inc" \
	bin/createcert.sh cert \*.$(domain) \*.test.$(domain),DNS:\*.$(domain),DNS:\*.beta.$(domain)
	@echo "✅  done!"

test5:
	# Future certificate
	COMPANYNAME="Marty and Doc's Environmentally friendly cars" \
	bin/createcert.sh future test5.$(domain) test5.$(domain)
	@echo "✅  done!"

test6:
	# Expired certificate
	COMPANYNAME="Soup and Barbecue Kitchen from the 60's" \
	bin/createcert.sh expired test6.$(domain) test6.$(domain)
	@echo "✅  done!"

test7:
	# Certificate from bad CA
	COMPANYNAME="We don't trust anyone" \
	bin/createcert.sh evil test7.$(domain) test7.$(domain)
	@echo "✅  done!"

test8:  
	# Normal cert, with SAN for domain (test involves client cert)
	COMPANYNAME="We Challenge You, Inc" \
	bin/createcert.sh cert test8.$(domain) $(domain)
	@echo "✅  done!"

test9:
	# Certificate from md5 CA with 512 bits. Good old times.
	COMPANYNAME="MD5 was good enough in the 90's" \
	bin/createcert.sh md5 test9.$(domain) $(domain)
	@echo "✅  done!"

test10:
	# intermediate cert under the first one 
	# ca -> intermediate 1 -> test10
	# depends on running "make intermediate" first
	COMPANYNAME="Give it UP" \
	bin/createcert.sh intercert test10.$(domain) $(domain)
	@echo "✅  done!"

test11:
	# intermediate cert 3
	# depends on running "make intermediate" first
	# ca -> intermediate 1 -> intermediate 2 -> intermediate 3 -> cert
	COMPANYNAME="Do it yourself" \
	bin/createcert.sh intercert certs/TLS-o-matic-intermediate-3.cert test11.$(domain)
	@echo "✅  done!"

test12:   
	#Many SANs
	bin/sanlist.sh $(domain)> /tmp/sanlist.tmp
	COMPANYNAME="The Web Server King" \
	bin/createcert.sh sancert "test12.$(domain)"  `cat /tmp/sanlist.tmp`
	rm /tmp/sanlist.tmp
	@echo "✅  done!"

test13:   
	# A key of 8192 bits
	COMPANYNAME="The Large Super Key Company" \
	bin/createcert.sh bigcert test13.$(domain)  test13.$(domain)
	@echo "✅  done!"


test15:
	# TLS SNI tests - test15a, test15b, test15 (default server)
	# ca -> intermediate 1 -> test15
	COMPANYNAME="TLS Hosting Company" \
	bin/createcert.sh intercert certs/TLS-o-matic-intermediate-1.cert test15.$(domain) 
	@echo "   ☑️   done with cert 1/3!"
	COMPANYNAME="Funny Frog API services for hot dog distribution and car wash" \
	bin/createcert.sh intercert certs/TLS-o-matic-intermediate-1.cert test15a.$(domain) 
	@echo "   ☑️   done with cert 2/3!"
	COMPANYNAME="Happy Hopper Hip Hop Music (and API services) Inc " \
	bin/createcert.sh intercert certs/TLS-o-matic-intermediate-1.cert test15b.$(domain)
	@echo "   ☑️   done with cert 3/3!"
	@echo "✅  done!"

test20:  
	# Normal cert, with SAN for domain - the test is for crypto and TLS versions (Bettercrypto.org)
	COMPANYNAME="Cybercrime Security Experts INC" \
	bin/createcert.sh cert test20.$(domain) test20.$(domain)
	@echo "✅  done!"



alltests:
	@echo `date` > /tmp/testresult
	@echo "get / HTTP/1.0" |$(OPENSSL) s_client -connect test1.$(domain):443 -showcerts -state -CAfile ca/cacert.pem >> /tmp/testresult 2>&1
	@echo "get / HTTP/1.0" |$(OPENSSL) s_client -connect test2.$(domain):402 -showcerts -state -CAfile ca/cacert.pem >> /tmp/testresult 2>&1
	@echo "get / HTTP/1.0" |$(OPENSSL) s_client -connect test3.$(domain):403 -showcerts -state -CAfile ca/cacert.pem >> /tmp/testresult 2>&1
	@echo "get / HTTP/1.0" |$(OPENSSL) s_client -connect test4.$(domain):404 -showcerts -state -CAfile ca/cacert.pem >> /tmp/testresult 2>&1
	@echo "get / HTTP/1.0" |$(OPENSSL) s_client -connect test5.$(domain):405 -showcerts -state -CAfile ca/cacert.pem >> /tmp/testresult 2>&1
	@echo "get / HTTP/1.0" |$(OPENSSL) s_client -connect test6.$(domain):406 -showcerts -state -CAfile ca/cacert.pem >> /tmp/testresult 2>&1
	@echo "get / HTTP/1.0" |$(OPENSSL) s_client -connect test7.$(domain):407 -showcerts -state -CAfile ca/cacert.pem >> /tmp/testresult 2>&1
	# test8 - Requires a client cert
	#@echo "get / HTTP/1.0" |$(OPENSSL) s_client -connect test8.$(domain):408 -showcerts -state -CAfile ca/cacert.pem >> /tmp/testresult 2>&1
	@echo "get / HTTP/1.0" |$(OPENSSL) s_client -connect test9.$(domain):409 -showcerts -state -CAfile ca/cacert.pem >> /tmp/testresult 2>&1
	@echo "get / HTTP/1.0" |$(OPENSSL) s_client -connect test10.$(domain):410 -showcerts -state -CAfile ca/cacert.pem >> /tmp/testresult 2>&1
	@echo "get / HTTP/1.0" |$(OPENSSL) s_client -connect test11.$(domain):411 -showcerts -state -CAfile ca/cacert.pem >> /tmp/testresult 2>&1
	@echo "get / HTTP/1.0" |$(OPENSSL) s_client -connect test12.$(domain):412 -showcerts -state -CAfile ca/cacert.pem >> /tmp/testresult 2>&1
	@echo "get / HTTP/1.0" |$(OPENSSL) s_client -connect test13.$(domain):413 -showcerts -state -CAfile ca/cacert.pem >> /tmp/testresult 2>&1
	@echo "✅  done! heck /tmp/testresult"
