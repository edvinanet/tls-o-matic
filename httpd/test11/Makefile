all:
	# Create a combined intermediate cert file
	cat  TLS-o-matic-intermediate-1.cert  TLS-o-matic-intermediate-2.cert  TLS-o-matic-intermediate-3.cert > intermediate.cert
	/usr/sbin/httpd -f /usr/local/tls-o-matic/httpd/test11/server.conf
