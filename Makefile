# $(domain)
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

all:
	@echo "Targets:"
	@echo " clean    Remove all certs and keys"
	@echo " web      Start all web servers"
	@echo " killall  Stop all http servers"
	@echo " certs    Create all the certificates"
	@echo " test<x>  Certificates for test #1 - like \"make test1\" "

clean:
	rm -rf ca/cacert.pem ca/bad/cacert.pem ca/private/cacert.key ca/bad/private/cacert.key
	rm -rf certs/*
	rm -rf ca/index.*

killall:
	make -C httpd/test1 kill
	make -C httpd/test2 kill
	make -C httpd/test3 kill
	make -C httpd/test4 kill
	make -C httpd/test5 kill
	make -C httpd/test6 kill
	make -C httpd/test7 kill
	make -C httpd/test8 kill
	make -C httpd/test9 kill
	make -C httpd/test10 kill
	make -C httpd/test11 kill
	make -C httpd/test12 kill
	make -C httpd/test13 kill
	make -C httpd/test14 kill
	make -C httpd/test15 kill
	make -C httpd/test20 kill
	make -C httpd/test21 kill
	make -C httpd/test22 kill
	@echo "✅  done!"

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
	make -C httpd/test14
	make -C httpd/test15
	make -C httpd/test20
	make -C httpd/test21
	make -C httpd/test22
	@echo "✅  done!"

certs: ca/cacert.pem ca/bad/cacert.pem intermediate test1 test2 test3 test4 \
	test5 test6 test7 test8 test9 test10 test11 test12 test13 test15 test20 test21 \
	test22
	@echo "✅  done!"

ca:	ca/cacert.pem

ca/cacert.pem:
	@echo "===> Creating normal CA"
	bin/createca.sh $(domain)

ca/bad/cacert.pem:
	@echo "===> Creating evil CA"
	bin/createevilca.sh
	@echo "✅  done!"

intermediate: certs/TLS-o-matic-intermediate-1.cert certs/TLS-o-matic-intermediate-2.cert certs/TLS-o-matic-intermediate-3.cert \
	certs/TLS-o-matic-intermediate-4.cert	certs/TLS-o-matic-intermediate-5.cert
	# Create three intermediate certificates under the primary cert
	@echo "✅  done!"

certs/TLS-o-matic-intermediate-1.cert: ca/cacert.pem
	@echo " "
	@echo "==> First intermediate cert "
	COMPANYNAME="Intermediate 1 $(domain)" \
	bin/createcert.sh intermed ca/cacert.pem TLS-o-matic-intermediate-1

certs/TLS-o-matic-intermediate-2.cert: certs/TLS-o-matic-intermediate-1.cert
	@echo " "
	@echo "==> Second intermediate cert "
	COMPANYNAME="Intermediate 2 $(domain)" \
	bin/createcert.sh intermed certs/TLS-o-matic-intermediate-1.cert	TLS-o-matic-intermediate-2

certs/TLS-o-matic-intermediate-3.cert: certs/TLS-o-matic-intermediate-2.cert
	@echo " "
	@echo "==> Third intermediate cert "
	COMPANYNAME="Intermediate 3 $(domain)" \
	bin/createcert.sh intermed certs/TLS-o-matic-intermediate-2.cert	TLS-o-matic-intermediate-3

certs/TLS-o-matic-intermediate-4.cert: certs/TLS-o-matic-intermediate-3.cert
	@echo " "
	@echo "==> Fourth intermediate cert "
	COMPANYNAME="Intermediate 4 $(domain)" \
	bin/createcert.sh intermed certs/TLS-o-matic-intermediate-3.cert	TLS-o-matic-intermediate-4

certs/TLS-o-matic-intermediate-5.cert: certs/TLS-o-matic-intermediate-4.cert
	@echo " "
	@echo "==> Fifth intermediate cert "
	COMPANYNAME="Intermediate 5 $(domain)" \
	bin/createcert.sh intermed certs/TLS-o-matic-intermediate-4.cert	TLS-o-matic-intermediate-5


test1:  ca/cacert.pem
	@echo " "
	@echo "==> Test 1 "
	# Normal cert, with SAN for domain
	COMPANYNAME="Arrogant Security Consultants LLC" \
	bin/createcert.sh cert test1.$(domain) test1.$(domain)
	@echo "✅  done!"

curltest1: ca/cacert.pem
	# Successful test
	curl --cacert ca/cacert.pem https://test1.tls-o-matic.com/

test2:  ca/cacert.pem
	@echo " "
	@echo "==> Test 2 "
	# Cert with no SAN, bad CN
	COMPANYNAME="Another one bites the dust Inc" \
	bin/createcert.sh nosan test2.tls-o-matic.null
	@echo "✅  done!"

curltest2: ca/cacert.pem
	# Successful test
	@echo "Wrong certificate - bad SAN"
	curl --cacert ca/cacert.pem https://test2.tls-o-matic.com:402/


test3:  ca/cacert.pem
	@echo " "
	@echo "==> Test 3 "
	# Cert with bad SAN
	COMPANYNAME="Lucy In the Sky with Certificates" \
	bin/createcert.sh cert test3.$(domain) test3.tls-o-matic.null
	@echo "✅  done!"

test4:  ca/cacert.pem
	# Wildcards
	COMPANYNAME="Can't Make Up My Mind Inc" \
	bin/createcert.sh cert \*.$(domain) \*.test.$(domain),DNS:\*.$(domain),DNS:\*.beta.$(domain)	test4.$(domain)
	@echo "✅  done!"

test5:	ca/cacert.pem
	# Future certificate
	COMPANYNAME="Marty and Doc's Environmentally friendly cars" \
	bin/createcert.sh future test5.$(domain) test5.$(domain)
	@echo "✅  done!"

test6:	ca/cacert.pem
	# Expired certificate
	COMPANYNAME="Soup and Barbecue Kitchen from the 60's" \
	bin/createcert.sh expired test6.$(domain) test6.$(domain)
	@echo "✅  done!"

test7:	ca/bad/cacert.pem
	# Certificate from bad CA
	COMPANYNAME="We don't trust anyone" \
	bin/createcert.sh evil test7.$(domain) test7.$(domain)
	@echo "✅  done!"

test8:  ca/cacert.pem
	# Normal cert, with SAN for domain (test involves client cert)
	COMPANYNAME="We Challenge You, Inc" \
	bin/createcert.sh cert test8.$(domain) $(domain),DNS:test8.$(domain),URI:sip:info@$(domain)
	@echo "✅  done!"

test9:	ca/cacert.pem
	# Certificate from md5 CA with 512 bits. Good old times.
	COMPANYNAME="MD5 was good enough in the 90's" \
	bin/createcert.sh md5 test9.$(domain) $(domain)
	@echo "✅  done!"

test10:	certs/TLS-o-matic-intermediate-1.cert
	# intermediate cert under the first one 
	# ca -> intermediate 1 -> test10
	# depends on running "make intermediate" first
	COMPANYNAME="Give it UP" \
	bin/createcert.sh intercert certs/TLS-o-matic-intermediate-1.cert test10.$(domain) 
	@echo "✅  done!"

test11:	certs/TLS-o-matic-intermediate-3.cert
	# intermediate cert 3
	# ca -> intermediate 1 -> intermediate 2 -> intermediate 3 -> cert
	COMPANYNAME="Do it yourself" \
	bin/createcert.sh intercert certs/TLS-o-matic-intermediate-3.cert test11.$(domain)
	@echo "✅  done!"

test12: ca/cacert.pem
	#Many SANs
	bin/sanlist.sh $(domain)> /tmp/sanlist.tmp
	COMPANYNAME="The Web Server King" \
	bin/createcert.sh sancert "test12.$(domain)"  `cat /tmp/sanlist.tmp`
	rm /tmp/sanlist.tmp
	@echo "✅  done!"

test13:	ca/cacert.pem
	# A key of 8192 bits
	COMPANYNAME="The Large Super Key Company" \
	bin/createcert.sh bigcert test13.$(domain)  test13.$(domain)
	@echo "✅  done!"


test14:	ca/cacert.pem
	# weird usage bits
	COMPANYNAME="Ting Tagel Upside Down and Inside Out Non-Restful Services Inc" \
	bin/createcert.sh weird test14.$(domain)  test14.$(domain)
	@echo "✅  done!"

test15:	ca/cacert.pem
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

test20:	ca/cacert.pem
	# Normal cert, with SAN for domain - the test is for crypto and TLS versions (Bettercrypto.org)
	COMPANYNAME="Cybercrime Security Experts INC" \
	bin/createcert.sh cert test20.$(domain) test20.$(domain)
	@echo "✅  done!"

test21:	ca/cacert.pem
	# weak cert. Server with SSL only (no TLS)
	COMPANYNAME="King Arthur Medival Security Experts INC" \
	bin/createcert.sh md5 test21.$(domain) test21.$(domain)
	@echo "✅  done!"

test22:	ca/cacert.pem
	# Normal cert
	COMPANYNAME="NCC 1701 Security Department LLC" \
	bin/createcert.sh cert test22.$(domain) test22.$(domain)
	@echo "✅  done!"



alltests:	ca/cacert.pem	ca/bad/cacert.pem
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
	@echo "get / HTTP/1.0" |$(OPENSSL) s_client -connect test14.$(domain):414 -showcerts -state -CAfile ca/cacert.pem >> /tmp/testresult 2>&1
	@echo "get / HTTP/1.0" |$(OPENSSL) s_client -connect test15.$(domain):415 -showcerts -state -CAfile ca/cacert.pem >> /tmp/testresult 2>&1
	@echo "get / HTTP/1.0" |$(OPENSSL) s_client -connect test20.$(domain):420 -showcerts -state -CAfile ca/cacert.pem >> /tmp/testresult 2>&1
	@echo "✅  done! Check /tmp/testresult"
