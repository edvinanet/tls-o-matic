TLS-O-MATIC.COM
===============

Automated self-tests of TLS. Set up for the #MoreCrypto /#MeraKrypto
Meetup in Stockholm in March 2015.

About the scripts
-----------------
These scripts allow you to make certificates for test purposes. The
certificates will all share a common CA root so that everyone running
these scripts can have interoperable certificates. WARNING - these
certificates are totally insecure and are for test purposes only. All
the CA created by this script share the same private key to
facilitate interoperation testing, but this totally breaks the
security since the private key of the CA is well known.

Things to go through before and during tests
--------------------------------------------
	- What is CN - Common Name
	- What about all the other stuff in the cert?
	- What is SubjectAltName
	- Selfsigned certificates, CA signed certs - DV, EV

Tests
-----

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

3.	Wrong cert - bad SubjAltName
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

9. 	MD5 certificate
	- https://test9.tls-o-matic.com:409

10.	Intermediate cert
	- https://test10.tls-o-matic.com:410

11.	Long certificate chain (3 intermediaries)
	- https://test11.tls-o-matic.com:411

12.	Huge certificate with a lot of subject alt names (21 kb cert)
	- https://test12.tls-o-matic.com:412

Possible future cert tests
--------------------------
	- SNI, Server name indication
	- Cert with wrong usage (E-mail sign or SIP)

Other TLS test ideas
--------------------
	- Site that only allows SSLv2
	- Site that only allows TLSv1.2
	- Site that only offers null crypto
	- Site that actually follows bettercrypto.org (and UTA BCP)

API tests
---------
	- Possibly add a json payload in return for javascript/app testing
	- Possibly add a XML payload in return for app testing


Installing
----------
You can install this on your own system - check out in /usr/local/tls-o-matic
To test another domain you can change domain in the Makefile. Not sure
if this works in all scripts yet.
