#!/bin/bash
#===================================================================================
#	FILE:  letsencrypt_pound.sh
#	USAGE:  ./letsencrypt_pound.sh
#	DESCRIPTION:  A Let's Encrypt script : create or renewal your certificate with pound proxy
#
#
#	OPTION:			---
#	REQUIREMENTS:	---
#	BUGS:  ---
#	NOTES:  ---
#	AUTHOR:  Jérémie KASSIANOFF (ffonaissak), projet@kassianoff.fr
#	WEBSITE:  https://www.kassianoff.fr
#	VERSION:  1
#	CREATED:  20.04.2016 - 00:00:0
#   REVISION:  20.04.2016
#===================================================================================

#----------------------------------------------------------------------
#  Variables
#----------------------------------------------------------------------

rep=/etc/letsencrypt/live/$domain1
rep2=/etc/letsencrypt/renewal/$domain1.conf

#----------------------------------------------------------------------
#  Check root login, if "yes" continue
#----------------------------------------------------------------------

if [ "$UID" -ne "0" ]
	then
   		echo "Super User is require! please log in to root"
   		exit 1
fi

#----------------------------------------------------------------------
#  Request 3 domains for letsencrypt
#----------------------------------------------------------------------

echo "Your first domain (ex:kassianoff.fr)"
read domain1

echo "Your second domain (ex:www.kassianoff.fr)"
read domain2

echo "Your third domain (ex:www2.kassianoff.fr)"
read domain3

echo "You domains are : [$domain1] [$domain2] [$domain3], Do you want to continue ? [Y/N]"
read answer

#----------------------------------------------------------------------
#  Accept or deny, while not answer "Y" the script does not continue
#----------------------------------------------------------------------

while
	[ "$answer" != "Y" ]
do
	echo "Do you want to continue (Please choose : Y or N)"
	read answer
if [ "$answer" = "N" ]
	then
		echo "OK bye" && exit
fi
	done

#----------------------------------------------------------------------
#   Change directory
#----------------------------------------------------------------------

cd ~

#----------------------------------------------------------------------
#   Download source "letsencrypt" and follow directory : 
#----------------------------------------------------------------------

git clone https://github.com/letsencrypt/letsencrypt && cd letsencrypt

#----------------------------------------------------------------------
#   Stop reverse proxy (pound) service
#----------------------------------------------------------------------

service pound stop

#----------------------------------------------------------------------
#   If domain1 exist, delete it!
#----------------------------------------------------------------------

if [ -d "$rep" ]
  then
        rm -rf $rep && rm -rf $rep2 && rm -rf /root/letsencrypt
fi

#----------------------------------------------------------------------
#   Your own contact mail
#----------------------------------------------------------------------

echo "Your email contact for the certificat (ex:postmaster@kassianoff.fr)"
read mail

#----------------------------------------------------------------------
#   Letsencrypt-auto command certificat with different variables
#----------------------------------------------------------------------

./letsencrypt-auto --text --email $mail --domains $domain1 -d $domain2 -d $domain3 --agree-tos --standalone certonly  --rsa-key-size 4096

#----------------------------------------------------------------------
#   Processing full chain (.pem) for Pound reverse
#----------------------------------------------------------------------

cat /etc/letsencrypt/live/$domain1/privkey.pem /etc/letsencrypt/live/$domain1/fullchain.pem > /etc/pound/$domain1.pem

#----------------------------------------------------------------------
#   Start pound service
#----------------------------------------------------------------------

service pound start
