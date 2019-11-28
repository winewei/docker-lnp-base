set -eux
if [ ${PHP_VERSION%.*} = 7.0 ]; then
   # if PHP_VERSION is 7.0, the newest swoole version is 2.2.0
   yes Y | pecl install http://pecl.php.net/get/swoole-2.2.0.tgz;
else
   yes Y | pecl install swoole;
fi;