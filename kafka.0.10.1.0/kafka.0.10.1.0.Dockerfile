FROM centos:6.6

RUN mkdir /etc/yum.repos.d/backup &&\
	mv /etc/yum.repos.d/*.repo /etc/yum.repos.d/backup/ &&\
	curl -o /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-6.repo

RUN yum -y install nc vim lsof wget tar bzip2 unzip vim-enhanced passwd sudo yum-utils hostname net-tools rsync man git make automake cmake patch logrotate python-devel libpng-devel libjpeg-devel pwgen python-pip

RUN mkdir /opt/java &&\
	wget --no-check-certificate --no-cookies --header "Cookie: oraclelicense=accept-securebackup-cookie" http://download.oracle.com/otn-pub/java/jdk/8u102-b14/jdk-8u102-linux-x64.tar.gz -P /opt/java

ENV KAFKA_VERSION "0.10.1.0"

RUN mkdir /opt/kafka &&\
	wget http://apache.fayea.com/kafka/$KAFKA_VERSION/kafka_2.11-$KAFKA_VERSION.tgz -P /opt/kafka

ENV JAVA_HOME "/opt/java/jdk1.8.0_102"

RUN tar zxvf /opt/java/jdk-8u102-linux-x64.tar.gz -C /opt/java &&\
	sed -i "/^PATH/i export JAVA_HOME="$JAVA_HOME /root/.bash_profile &&\
	sed -i "s%^PATH.*$%&:"$JAVA_HOME"/bin%g" /root/.bash_profile &&\
	source /root/.bash_profile

RUN tar zxvf /opt/kafka/kafka*.tgz -C /opt/kafka &&\
	sed -i 's/num.partitions.*$/num.partitions=3/g' /opt/kafka/kafka_2.11-$KAFKA_VERSION/config/server.properties

RUN sed -i '0,/^if/s%^if%export JAVA_HOME='$JAVA_HOME'\nexport PATH=$PATH:$JAVA_HOME/bin\nif%' /opt/kafka/kafka_2.11-0.10.1.0/bin/kafka-run-class.sh

COPY start_kafka.sh /opt/kafka

EXPOSE 9092

WORKDIR /opt/kafka/kafka_2.11-$KAFKA_VERSION

ENTRYPOINT ["sh", "/opt/kafka/start_kafka.sh"]
