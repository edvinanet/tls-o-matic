TLS-O-MATIC.COM
===============

Automated self-tests of TLS. Set up for the #MoreCrypto /#MeraKrypto
Meetup in Stockholm in March 2015.

Tests 1-18 are tests of certificate validation.

Test 20 is based on recommendations from bettercrypto.org on how
to configure Apache HTTPD for a strong server. 
Test 21 is a test of weak crypto. An application that wants to claim
to be secure today should not connect to a server configured like this.
Test 22 is focusing on modern Perfect Forward Secrecy encryption.

Test 30-32 are of elliptic curve certificates

Note that this repository will always be ahead of the web site. I test stuff
here, then publish on the web site.

The main site is at https://www.tls-o-matic.com

Note: All tests (except the SNI test) are also available on high ports.
Test 2 runs on port 402 and 60402. Documentation needs to be updated.

About the scripts
-----------------
These scripts allow you to make certificates for test purposes. The
certificates will all share a common CA root so that everyone running
these scripts can have interoperable certificates. WARNING - these
certificates are totally insecure and are for test purposes only. 

Things to go through before and during tests
--------------------------------------------
	- What is CN - Common Name
	- What is SubjectAltName
	- What is SNI - server name indication
	- What about all the other stuff in the cert?
	- Selfsigned certificates, CA signed certs - DV, EV

Certificate and CA Tests
-------------------------

1.	Describe CA, download CA cert
	- Access https://test1.tls-o-matic.com
		Warnings
	- Install the CA cert from the TLS-O-MATIC Super CA
		Show CN, key usage
	- Access the site again

2.	Wrong certificate - bad CN
	- https://test2.tls-o-matic.com:402
		Note: No SAN in the cert
		CN test2.tls-o-matic.null

3.	Test of SAN. The server name is in the Common Name but not in the SAN.
	If there is a list of SAN entries, a client should not check the common name.
	This test should fail.

	- https://test3.tls-o-matic.com:403
		SAN: https://test3.tls-o-matic.null

4.	Wildcard cert
	- https://test4.tls-o-matic.com:404
	- https://test4test.tls-o-matic.com:404

5.	Cert from future
	- https://test5.tls-o-matic.com:405

6. 	Expired certificate
	- https://test6.tls-o-matic.com:406

7.	Evil unknown CA
	- https://test7.tls-o-matic.com:407

8.	Client cert required
	- https://test8.tls-o-matic.com:408

9. 	Weak certificate - small key, MD5 signature
	- https://test9.tls-o-matic.com:409

10.	Intermediate cert
	- https://test10.tls-o-matic.com:410

11.	Long certificate chain (3 intermediaries)
	- https://test11.tls-o-matic.com:411

12.	Huge certificate with a lot of subject alt names (21 kb cert)
	- https://test12.tls-o-matic.com:412

13.	Certificate based on a very large key with SHA512 checksum
	- https://test13.tls-o-matic.com:413

14.	Certificate with a weird combination of usage bits.
	- https://test14.tls-o-matic.com:414

15.	TLS SNI test. One server, multiple certificates. Check which certificate
	you get from the server. The client indicates support for TLS SNI.

	- https://test15.tls-o-matic.com:415	Default server. You will always end up here 
						if your client does not support TLS
						server name indication for test15a or test15b
	- https://test15a.tls-o-matic.com:415
	- https://test15b.tls-o-matic.com:415

16.	Test of International domain names in certificates
	SAN certificate with IDNA names. One server, one cert with many names
	If you click through, you will get more test links on the result page.

	- https://test16.tls-o-matic.com:416
	- https://😎.test16.tls-o-matic.com:416
	- https://blåbärsmjölk.test16.tls-o-matic.com:416

	Note: Github's URL parser doesn't parse URL's with international characters
	as URL's and create clickable links. Bug.

17.	Another Test of SAN (like test 3) . The server name is in the Common Name but not in the SAN.
	If there is a list of SAN entries, a client should not check the common name. In this test
	there are some confusing SAN entries.
	This test should fail.
	- https://test17.tls-o-matic.com:417

18.	Test of wildcard rules.
	Wildcards can only be used for a whole part of a DNS name - not like a string wildcard.
	This cert has two wildcard SANs. Both are invalid.
	
	DNS:test18.\*.tls-o-matic.com, DNS:test\*.tls-o-matic.com
	
	It needs to be the first label, not a middle label like test.*.example.com
	Reference: RFC 6125 Section 6.4.3
	*.example.com is valid, and test*.example.com but not test.*.example.com

	This cert has two SANs - test18.*.tls-o-matic.com, test*.tls-o-matic.com
	- https://test18.test18.tls-o-matic.com:418 should work
	- https://test18.valid.tls-o-matic.com:418 should NOT work
	- https://testxx.tls-o-matic.com should work

19.	Test of wildcard rules.
	- coming -


Crypto and SSL/TLS protocol tests
---------------------------------
20.	Not a certificate test. This server has no SSLv2 or SSLv3 and only supports
	strong crypto algorithms. Based on recommendations from http://bettercrypto.org
	- https://test20.tls-o-matic.com:420

21.	Not a certificate test. This server has only SSLv2 or SSLv3 and only supports
	weak crypto algorithms. Based on recommendations from Netscape Communication in 
	the 90's. Good old times are here again.
	Browsers does not accept cert or crypto.
	- https://test21.tls-o-matic.com:421

22.	This server follows Ivan Ristic's configuration in this blog:
	http://blog.ivanristic.com/2013/08/configuring-apache-nginx-and-openssl-for-forward-secrecy.html
	It is configured without RC4 support.
	Old clients will not be able to connect.
	- https://test22.tls-o-matic.com:422

Elliptic Curve certificate and key tests
----------------------------------------

30.	The CA certificate in this test is using Elliptic Curve Key exchange instead of
	RSA, as is the classical key pair technology used for certificates. 
	The server use RSA key pair, so this is a hybrid certificate - a CA with
	Elliptic curve and a server with RSA.
	- https://test30.tls-o-matic.com:430

31.	This is another hybrid certificate - a CA using RSA keys and a server using
	elliptic curve technology.
	- https://test31.tls-o-matic.com:431

32.	This server and CA both use elliptic curve technology. Non-hybrid, pure elliptic curve
	Marketing says that this is good for cell phones and small computers.
	- https://test32.tls-o-matic.com:432


Possible future cert tests
--------------------------
	- Cert used for HTTP with no subject CN and only http URI's as sAN names
	- Site with incomplete or bad intermediate cert chain
	- Unknown extension in cert, marked critical (browser should reject)
	- weak-wildcard certs ( CN="*" )  (DSL)
	- Wrong version certificates - Cert version 0x01 (v2) or 0x03 (v4) certificates. Not sure if v4 should be invalid as that makes your test broken in the future, sometime. (DSL)
	- MD5 intermediate in chain (invalid) (DSL)
	- 1024 bit intermediate in chain (invalid) (DSL)
	- Two certificates in a chain with the same serial number (invalid) (DSL)
	- Issuer mismatch in the chain ( RFC 5280, Section 6.1.3) (DSL)
	- cert for IP address, not host name. What is the expected outcome? CA/Browser forum doesn't like it.
	- cert with null in host name

Other TLS test ideas
--------------------
	- Site that only offers null crypto
	- Build the three reference profiles from Mozilla
	  https://wiki.mozilla.org/Security/Server_Side_TLS#Recommended_configurations
	- Certificate with multiple CNs
	  https://certificates.heanet.ie/node/17

API tests (ideas)
-----------------
	- Possibly add a json payload in return for javascript/app testing
	- Possibly add a XML payload in return for app testing

Feedback and bugs
-----------------
Please use the Github bug tracker. By reporting issues you help us. It's
not for support though. If you think a mailing list or some kind of forum
is a good idea - please let us know!

https://github.com/edvinanet/tls-o-matic/issues

- Don't use reserved ports - use high ports (@sindarina on Twitter)

Installing
----------
You can install this on your own system - check out in /usr/local/tls-o-matic
To test another domain you can change domain in the Makefile. Not sure
if this works in all scripts yet.

Credits
-------
- Olle E. Johansson created the tests and the scripts
- Many participants at SIPit helped with the original SIP tests
- Jakob Schlyter provided good feedback
- D Spindel Ljungmark contributed new test ideas
- Tomas Gustavsson, Primekey for some new ideas and feedback


Contacting us
-------------
info@edvina.net
http://edvina.net

