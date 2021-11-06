#!/bin/bash

letsencrypt certonly --webroot -w /var/www/letsencrypt -d "$CN" --agree-tos --email "$EMAIL" --non-interactive --text

$name = "${CN:2}"
echo $name

cp /etc/letsencrypt/archive/"$name"/cert1.pem /var/certs/"$name"-cert1.pem
cp /etc/letsencrypt/archive/"$name"/chain1.pem /var/certs/chain1.pem
cp /etc/letsencrypt/archive/"$name"/fullchain1.pem /var/certs/fullchain1.pem
cp /etc/letsencrypt/archive/"$name"/privkey1.pem /var/certs/"$name"-privkey1.pem
