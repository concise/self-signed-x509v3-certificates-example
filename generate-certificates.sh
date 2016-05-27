#!/bin/bash

set -e


### Make sure you have openssl in your PATH ###

type -a openssl
openssl version


### Secret key and certificate for root certificate authority ###

openssl genrsa -out rootca.key 2048
openssl req -x509 -new -sha256 -days 1000 -subj /CN=rootca/ -key rootca.key \
        -config ./extensions-for-rootca.cnf \
        -out rootca.crt


### Secret key and certificate for intermediate certificate authority ###

openssl genrsa -out intermediateca.key 2048
openssl req -new -sha256 -subj /CN=intermediateca/ -key intermediateca.key \
        -out intermediateca.csr
openssl x509 -req -days 1000 -CA rootca.crt -CAkey rootca.key -CAcreateserial \
        -extfile ./extensions-for-intermediateca.cnf \
        -extensions extension \
        -in intermediateca.csr -out intermediateca.crt
rm intermediateca.csr


### Secret key and certificate for localhost ###

openssl genrsa -out localhost.key 2048
openssl req -new -sha256 -subj /CN=localhost/ -key localhost.key \
        -out localhost.csr
openssl x509 -req -days 1000 -CA intermediateca.crt -CAkey intermediateca.key \
        -extfile ./extensions-for-localhost.cnf -extensions extension \
        -CAcreateserial -in localhost.csr -out localhost.crt
rm localhost.csr


### Certificate chain for localhost ###

cat localhost.crt intermediateca.crt rootca.crt > localhost.crtchain

