#

.PHONY=certs
certs: test1 test3 test2
	@echo "✅  done!"

# Normal cert, with SAN for domain
test1:  
	bin/createcert.sh cert test1.tls-o-matic.com tls-o-matic.com

# Cert with no SAN, bad CN
test2:  
	bin/createcert.sh nosan test2.tls-o-matic.null

# Cert with bad SAN
test3:  
	bin/createcert.sh cert test3.tls-o-matic.com test3.tls-o-matic.null

test4:
	bin/createcert.sh cert \'*.tls-o-matic.com\' \'*.test.tls-o-matic.com\'
