#!/bin/bash

CN="*.rapidboda.com"
EMAIL="ossentoogo@techstream.systems" 
letsencrypt certonly --manual -w certs -d "$CN" --agree-tos --preferred-challenges=dns

CN="${CN:2}"

echo "$CN"

# cp /etc/letsencrypt/archive/"$name"/cert1.pem /var/certs/"$name"-cert1.pem
# cp /etc/letsencrypt/archive/"$name"/chain1.pem /var/certs/chain1.pem
# cp /etc/letsencrypt/archive/"$name"/fullchain1.pem /var/certs/fullchain1.pem
# cp /etc/letsencrypt/archive/"$name"/privkey1.pem /var/certs/"$name"-privkey1.pem
