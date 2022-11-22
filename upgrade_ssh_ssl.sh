#!/bin/bash
set -e

yum install -y gcc zlib-devel openssl-devel pam-devel > /dev/null

echo '' && echo '##Completed install 'gcc zlib-devel openssl-devel pam-devel''



## Update Openssl (OpenSSL openssl-1.1.1q released Mar 25, 2021)
cd /usr/local/src
wget -c --no-check-certificate https://www.openssl.org/source/openssl-1.1.1q.tar.gz        #edit me
echo '' && echo '##Completed download Openssl LTS.' && echo ''


##########################
OPENSSL=openssl-1.1.1q      #edit me
##########################

tar -xvzf $OPENSSL.tar.gz > /dev/null
cd $OPENSSL
./config --prefix=/usr/local/ssl --openssldir=/usr/local/ssl shared
make
make install

ln -s /usr/local/ssl/lib/libssl.so.1.1 /usr/lib64/libssl.so.1.1
ln -s /usr/local/ssl/lib/libcrypto.so.1.1 /usr/lib64/libcrypto.so.1.1

echo '/usr/local/ssl/lib' >> /etc/ld.so.conf.d/$OPENSSL.conf
echo '' && echo '=== Link library path ==='
ldconfig -v
echo '========================='


mv /usr/bin/openssl /usr/bin/openssl_old_`date +%Y%m%d`
ln -s /usr/local/ssl/bin/openssl /usr/bin/openssl


echo '' && echo '##Completed install Openssl'

echo '=== openssl version ==='
openssl version
echo '======================='



# Update Openssh LTS. (OpenSSH 8.0 released Apr 17, 2019)

cd /usr/local/src
cp -r /etc/ssh /etc/ssh.bak
cp -r /usr/bin/ssh /usr/bin/ssh.bak
cp -r /usr/sbin/sshd /usr/sbin/sshd.bak
cp -r /etc/ssh/sshd_config /etc/ssh/sshd_config.bak

yum -y remove openssh

wget -c --no-check-certificate https://fastly.cdn.openbsd.org/pub/OpenBSD/OpenSSH/portable/openssh-9.0p1.tar.gz

echo '' && echo '##Completed download Openssh LTS.'

#########################
OPENSSH=openssh-9.0p1
#########################
tar xvfz $OPENSSH.tar.gz > /dev/null
cd $OPENSSH
./configure --prefix=/usr --sysconfdir=/etc/ssh --with-ssl-dir=/usr/local/ssl --with-pam
chmod go-r /etc/ssh/*

make
make install
install -v -m755 contrib/ssh-copy-id /usr/bin
install -v -m644 contrib/ssh-copy-id.1 /usr/share/man/man1
install -v -m755 -d /usr/share/doc/$OPENSSH
install -v -m644 INSTALL LICENCE OVERVIEW README* /usr/share/doc/$OPENSSH

echo '' && echo '##Completed install Openssh'


cp ./contrib/sshd.pam.generic /etc/pam.d/sshd
cp -p contrib/redhat/sshd.init /etc/init.d/sshd
chmod +x /etc/init.d/sshd
echo "PermitRootLogin no" >> /etc/ssh/sshd_config
echo "Port 202" >> /etc/ssh/sshd_config
#echo "Port 10022" >> /etc/ssh/sshd_config
systemctl enable sshd
systemctl restart sshd

echo '' && echo '##Completed jobs about sshd.service'

yum history new && yum history sync

echo "+++++++++++++++++++++++"
ssh -V
echo "+++++++++++++++++++++++"