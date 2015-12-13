# Cert

#### This folder contains self generated SSL certs.<br>

##### Create root.key/root.pem (证书密钥文件)
openssl genrsa -des3 -out root.key

##### Create root.csr (证书的申请文件)
openssl req -new -key root.key -out root.csr

##### Create root.crt available for 10 years (证书)
openssl x509 -req -days 3650 -sha1 -extensions v3_ca -signkey root.key -in root.csr -out root.crt

reference: http://blog.csdn.net/fyang2007/article/details/6180361
