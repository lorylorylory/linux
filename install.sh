#!/bin/sh

echo "关闭防火墙"
systemctl stop firewalld
systemctl disable firewalld
echo "防火墙关闭"

echo "正在检测Docker环境...."
bak=`docker -v >/dev/null 2>&1;echo $?`
if [ $bak -eq 127 ];then
        echo "正在安装Docker...."
        chmod 777 /usr/item/docker/docker.sh;/usr/item/docker/docker.sh;
        echo "docker安装完毕并启动成功"
elif [ $bak -eq 0 ];then
        echo "已检测到Docker环境...."
fi


echo "正在检测postgresql环境...."
bak=`psql --version >/dev/null 2>&1;echo $?`
if [ $bak -eq 127 ];then
        echo "正在安装postgresql"
        chmod 777 /usr/item/pg14rmp/postgresql.sh;/usr/item/pg14rmp/postgresql.sh;
        echo "postgresql安装成功"
elif [ $bak -eq 0 ];then
        echo "postgresql已安装"
fi

echo "设置数据库密码"
chmod  755  /root
su - postgres <<EOF
psql
ALTER USER postgres WITH PASSWORD '1234';
create database automated;
EOF

echo "导入数据库"
psql -d automated -U postgres -f /usr/item/pg14rmp/sql.sql
echo "导入成功"

echo "导入nginx镜像"
docker load < /usr/item/nginx/nginx.tar.gz >/dev/null
docker run -d -p 8083:8083 --name nginx -v /usr/item/nginx/conf/nginx.conf:/etc/nginx/nginx.conf -v /usr/item/nginx/html:/etc/nginx/html -v /usr/item/nginx/log:/var/log/nginx nginx:1.10.1 
echo "nginx容器生成"

echo "导入centos镜像"
docker load < /usr/item/dotnet/centos7.tar >/dev/null
docker run -dit -p 8888:8888 -v /usr/item:/usr/item --name centos --privileged=true  centos:7 /sbin/init
echo "centos容器生成"
