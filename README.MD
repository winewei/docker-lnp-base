# php base image
`base debian:stretch-slim`
```
- Include php-fpm 7.*
- Include phpunit
- Include composer
- Include pecl
- Include openresty
```
## php modules:
```
[PHP Modules]
bcmath
Core
ctype
curl
date
dom
exif
fileinfo
filter
ftp
gd
gettext
hash
iconv
igbinary
json
libxml
mbstring
mongodb
mysqli
mysqlnd
openssl
pcntl
pcre
PDO
pdo_mysql
pdo_sqlite
Phar
posix
readline
redis
Reflection
session
shmop
SimpleXML
soap
sockets
SPL
sqlite3
standard
swoole
sysvsem
tokenizer
xml
xmlreader
xmlrpc
xmlwriter
Zend OPcache
zip
zlib

[Zend Modules]
Zend OPcache
```
## thanks
- source code copy from: <https://github.com/shansongxian/docker>
- token-init.sh copy from:  <https://github.com/Kaggggggga/docker-php>
