使用OpenSSL构建自签名证书
=========================
仅学习SSL/TLS编程使用。所以密钥都没有加密，若用于产品，密钥都要加密以加强安全性。


脚本使用说明
------------
`create_ca.sh` 和 `create_ca_me.sh` 两个脚本都可以构建。

`create_ca.sh` 使用两个配置文件 `ca.cnf` 和 `intermediate.cnf`。  
`ca.cnf` 文件配置根证书。  
`intermediate.cnf` 文件配置中间证书。  


`create_ca_me.sh` 使用一个配置文件 `openssl_me.cnf`。  
`openssl_me.cnf`: 根证书和中间证书配置都在次文件。  

运行
----
执行脚本即可
```bash
./create_ca_me.sh c
```
或
```bash
./create_ca.sh c
```
