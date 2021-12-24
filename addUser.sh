#!/bin/bash

username="dev-fai"

mkdir $username
cd $username

#Generate key 
openssl genrsa -out ${username}.key 2048

#Generate Certificate Signing Request
openssl req -new -key ${username}.key -subj "/CN=${username}" -out ${username}.csr

#Encoding the CSR using base64
baseEncodedCsr=$(cat ${username}.csr | base64 | tr -d "\n")

echo "apiVersion: certificates.k8s.io/v1
kind: CertificateSigningRequest
metadata:
  name: ${username}
spec:
  request: ${baseEncodedCsr}
  signerName: kubernetes.io/kube-apiserver-client
  #expirationSeconds: 86400  # one day
  usages:
  - client auth" >> ${username}-csr.yaml

kubectl apply -f ${username}-csr.yaml

kubectl certificate approve $username

kubectl get csr $username -o yaml | grep certificate: | sed 's/certificate://' | xargs | base64 --decode > ${username}.crt

#decodedUserCert=$(echo $userCert | base64 --decode)

#echo $decodedUserCert > ${username}.crt

cp ~/.kube/config ./config

authorityCA=$(cat config | grep certificate-authority-data: | sed 's/certificate-authority-data://' | xargs)
server=$(cat config | grep server: | sed 's/server://' | xargs)

echo "apiVersion: v1
clusters:
- cluster:
    certificate-authority-data: $authorityCA 
    server: $server
  name: kubernetes
contexts:
- context:
    cluster: kubernetes
    user: ${username}
  name: ${username}@kubernetes
current-context: ${username}@kubernetes
kind: Config
preferences: {}
users:
- name: ${username}
  user:
    client-certificate: ${username}.crt
    client-key: ${username}.key" >> ${username}.config

