#!/bin/bash

set -e

CA_DIR=demoCA
RootCA_DIR=${CA_DIR}/rootCA
IntermediateCA_DIR=${CA_DIR}/intermediateCA

BASESUBJ="/C=CN/ST=GuangDong/L=SZ/O=Leegoogol/OU=Testing"

create_ca() {
	mkdir -p ${RootCA_DIR}/{certs,newcerts,private,crl}
	chmod 700 ${RootCA_DIR}/private
	touch ${RootCA_DIR}/index.txt
	touch ${RootCA_DIR}/index.txt.attr
	echo 1000 > ${RootCA_DIR}/serial

	# 生成 rootCA key, 不加密密钥
	echo "+-+-+-+- Create Root CA Key -+-+-+-+"
	openssl genrsa -out ${RootCA_DIR}/private/ca.key.pem 2048
	chmod 400 ${RootCA_DIR}/private/ca.key.pem

	# 生成根证书，即自签名证书
	echo "+-+-+-+- Create Root CA Certificate -+-+-+-+"
	openssl req -config ca.cnf -key ${RootCA_DIR}/private/ca.key.pem -new -x509 -days 7300 -sha256 -extensions v3_ca -out ${RootCA_DIR}/certs/ca.cert.pem -subj "${BASESUBJ}/CN=Root CA/"
	chmod 444 ${RootCA_DIR}/certs/ca.cert.pem

	# 输出证书信息
	echo "+-+-+-+- Show Root CA Certificate Information -+-+-+-+"
	openssl x509 -noout -text -in ${RootCA_DIR}/certs/ca.cert.pem


	#=============================================================
	mkdir -p ${IntermediateCA_DIR}/{certs,crl,csr,newcerts,private}
	chmod 700 ${IntermediateCA_DIR}/private
	touch ${IntermediateCA_DIR}/index.txt
	touch ${IntermediateCA_DIR}/index.txt.attr
	echo 1000 > ${IntermediateCA_DIR}/serial
	echo 1000 > ${IntermediateCA_DIR}/crlnumber

	# 生成 intermediateCA key, 不加密密钥
	echo "+-+-+-+- Create Intermediate CA Key -+-+-+-+"
	openssl genrsa -out ${IntermediateCA_DIR}/private/intermediate.key.pem 2048
	chmod 400 ${IntermediateCA_DIR}/private/intermediate.key.pem

	# 生成证书签名请求
	echo "+-+-+-+- Create Intermediate CSR -+-+-+-+"
	openssl req -config intermediate.cnf -new -sha256 -key ${IntermediateCA_DIR}/private/intermediate.key.pem -out ${IntermediateCA_DIR}/csr/intermediate.csr.pem -subj "${BASESUBJ}/CN=Inter CA/"

	# 用根证书签名中间证书请求,生成中间证书
	echo "+-+-+-+- Create Intermediate CA Certificate -+-+-+-+"
	openssl ca -config ca.cnf -extensions v3_intermediate_ca -days 3650 -notext -md sha256 -in ${IntermediateCA_DIR}/csr/intermediate.csr.pem -out ${IntermediateCA_DIR}/certs/intermediate.cert.pem

	# 输出证书信息
	echo "+-+-+-+- Show Intermediate CA Certificate Information -+-+-+-+"
	openssl x509 -noout -text -in ${IntermediateCA_DIR}/certs/intermediate.cert.pem

	# 用根证书验证中间证书 
	echo "+-+-+-+- Verify Intermediate CA Certificate -+-+-+-+"
	openssl verify -CAfile ${RootCA_DIR}/certs/ca.cert.pem ${IntermediateCA_DIR}/certs/intermediate.cert.pem

	# 合并证书链
	cat ${IntermediateCA_DIR}/certs/intermediate.cert.pem ${RootCA_DIR}/certs/ca.cert.pem > ${IntermediateCA_DIR}/certs/ca-chain.cert.pem
	chmod 444 ${IntermediateCA_DIR}/certs/ca-chain.cert.pem


	# ======================================================================
	# 创建服务器/客户端证书
	# 创建服务器密钥,不加密密钥
	openssl genrsa -out ${CA_DIR}/www.leegoogol.com.key.pem 2048
	chmod 400 ${CA_DIR}/www.leegoogol.com.key.pem

	# 创建服务器证书签名请求
	openssl req -config intermediate.cnf -key ${CA_DIR}/www.leegoogol.com.key.pem -new -sha256 -out ${CA_DIR}/www.leegoogol.com.csr.pem -subj "${BASESUBJ}/CN=www.leegoogol.com/"

	# 使用中间证书签名服务器证书签名请求
	openssl ca -config intermediate.cnf -extensions server_cert -days 375 -notext -md sha256 -in ${CA_DIR}/www.leegoogol.com.csr.pem -out ${CA_DIR}/www.leegoogol.com.cert.pem
	chmod 444 ${CA_DIR}/www.leegoogol.com.cert.pem

	# 输出证书信息
	openssl x509 -noout -text -in ${CA_DIR}/www.leegoogol.com.cert.pem

	# 用中间证书验证服务器证书
	openssl verify -CAfile ${IntermediateCA_DIR}/certs/ca-chain.cert.pem ${CA_DIR}/www.leegoogol.com.cert.pem
}

remove_ca() {
	rm -rf ${CA_DIR}
}

case "$1" in
	create)
		create_ca
		;;

	c*)
		create_ca
		;;

	remove)
		remove_ca
		;;

	r*)
		remove_ca
		;;

	*)
		echo "Usage: $0 create|remove"
		;;
esac
