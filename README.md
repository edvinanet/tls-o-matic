TLS-O-MATIC.COM

Automated self-tests of TLS. Set up for the #MoreCrypto /#MeraKrypto
Meetup in Stockholm in March 2015.


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

Possible future cert tests
--------------------------
	- SNI, Server name indication
	- Cert with wrong usage (E-mail sign or SIP)
	- MD5 signed cert

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

