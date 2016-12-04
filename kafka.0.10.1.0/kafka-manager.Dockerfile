FROM centos:6.6

RUN mkdir /etc/yum.repos.d/backup &&\
	mv /etc/yum.repos.d/*.repo /etc/yum.repos.d/backup/ &&\
	curl -o /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-6.repo

RUN yum -y install nc vim lsof wget tar bzip2 unzip vim-enhanced passwd sudo yum-utils hostname net-tools rsync man git make automake cmake patch logrotate python-devel libpng-devel libjpeg-devel pwgen python-pip

RUN mkdir /opt/java &&\
	wget --no-check-certificate --no-cookies --header "Cookie: oraclelicense=accept-securebackup-cookie" http://download.oracle.com/otn-pub/java/jdk/8u102-b14/jdk-8u102-linux-x64.tar.gz -P /opt/java

ENV JAVA_HOME "/opt/java/jdk1.8.0_102"

RUN tar zxvf /opt/java/jdk-8u102-linux-x64.tar.gz -C /opt/java &&\
	sed -i "/^PATH/i export JAVA_HOME="$JAVA_HOME /root/.bash_profile &&\
	sed -i "s%^PATH.*$%&:"$JAVA_HOME"/bin%g" /root/.bash_profile &&\
	source /root/.bash_profile

COPY kafka-manager-1.3.2.1.zip /opt

RUN unzip /opt/kafka-manager-1.3.2.1.zip -d /opt &&\
	mv /opt/kafka-manager-1.3.2.1 /opt/kafka-manager

WORKDIR /opt/kafka-manager

ENTRYPOINT ["bin/kafka-manager", "-Dhttp.port=38080"]

