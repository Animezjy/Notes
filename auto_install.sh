#!/bin/bash
CHECKYUM=`yum repolist |awk '/repolist/{print$2}'|sed 's/,//'`
green='\033[32m'
red='\033[31m'
plain='\033[0m'
#检查YUM源
function my_yum(){
	if [ $CHECKYUM -ne 0 ];then
		echo "开始安装"
		pre_install
	else
		echo "无YUM源"
	read -p "输入你的网段:" ip
		echo "正在准备YUM源"
		cd /etc/yum.repos.d && mkdir old_repo
		mv *.repo old_repo
		echo "[development]
name=rhel7.4
baseurl=ftp://192.168.$ip.254/rhel7
enabled=1
gpgcheck=0" > /etc/yum.repos.d/1.repo 
	yum clean all &>/dev/null
	yum repolist &>/dev/null
		echo "开始安装"
		pre_install
	fi
}
#安装依赖包
function pre_install(){
	yum -y install gcc openssl-devel pcre-devel &>/dev/null
}
#安装LNMP
function install_lnmp(){
	tar -xf lnmp_soft.tar.gz
	cd lnmp_soft/
	yum -y install php-fpm-5.4.16-42.el7.x86_64.rpm &>/dev/null
	cd ~
	yum -y install php php-mysql mariadb mariadb-server mariadb-devel &>/dev/null
	systemctl start mariadb && systemctl enable mariadb
	netstat -nlptu |grep 3306 && echo -e "${green}mariadb启动成功${plain}" || echo -e "${red}mariadb启动失败${plain}"
	systemctl start php-fpm && systemctl enable php-fpm
	netstat -nlptu |grep 9000 && echo -e "${green}php-fpm启动成功${plain}" || echo -e "${red}php-fpm启动失败${plain}"
	}	
#安装Nginx
function install_nginx(){
	clear
	cd ~
	tar -xf nginx-1.12.2.tar.gz
	cd nginx-1.12.2
	./configure --prefix=/usr/local/nginx --user=nginx --group=nginx --with-http_ssl_module --with-stream --with-http_stub_status_module &>/dev/null
	make &>/dev/null  && make install &>/dev/null 
	ln -s /usr/local/nginx/sbin/nginx /sbin/
	useradd -s /sbin/nologin nginx
	nginx
	netstat -nlptu |grep 80 && echo -e "${green}Nginx启动成功${plain}" || echo -e "${red}nginx启动失败${plain}"
	}

case $1 in 
	nginx)
		my_yum
		install_nginx;;
	lnmp)
		install_lnmp;;
	*)
		echo "Usage:$0 nginx|lnmp";;
esac
