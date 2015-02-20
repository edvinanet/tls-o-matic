#!/bin/sh
# Create a list of Subejct ALT Names

DOMAIN=testsna.$1
DEFDOMAIN=DNS:test12.$1

/bin/echo -n "$DEFDOMAIN"
MAXSAN=200
for ((  i = 0 ;  i <= $MAXSAN;  i++  ))
do
	/bin/echo -n ",DNS:server$i$DOMAIN"
done
echo ""
