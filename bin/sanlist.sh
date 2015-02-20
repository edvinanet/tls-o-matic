#!/bin/sh
# Create a list of Subejct ALT Names

DOMAIN=testsna.tls-o-matic.com
DEFDOMAIN=DNS:test12.tls-o-matic.com

/bin/echo -n "$DEFDOMAIN"
MAXSAN=200
for ((  i = 0 ;  i <= $MAXSAN;  i++  ))
do
	/bin/echo -n ",DNS:server$i$DOMAIN"
done
echo ""
