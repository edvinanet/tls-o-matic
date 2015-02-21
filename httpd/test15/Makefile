all:
	# Create a combined intermediate cert file
	cp ../../certs/TLS-o-matic-intermediate-1.cert .
	cp ../../certs/test15* .
	/usr/local/apache2/bin/httpd -f /usr/local/tls-o-matic/httpd/test15/server.conf
	#/usr/sbin/httpd -f /usr/local/tls-o-matic/httpd/test15/server.conf

