FROM centos:6.6

RUN mkdir /etc/yum.repos.d/backup &&\
	mv /etc/yum.repos.d/*.repo /etc/yum.repos.d/backup/ &&\
	curl -o /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-6.repo

RUN yum -y install vim lsof wget tar bzip2 unzip vim-enhanced passwd sudo yum-utils hostname net-tools rsync man git make automake cmake patch logrotate python-devel libpng-devel libjpeg-devel pwgen python-pip

RUN mkdir /opt/java &&\
	wget --no-check-certificate --no-cookies --header "Cookie: oraclelicense=accept-securebackup-cookie" http://download.oracle.com/otn-pub/java/jdk/8u102-b14/jdk-8u102-linux-x64.tar.gz -P /opt/java

ENV KAFKA_VERSION "0.8.2.2"

RUN mkdir /opt/kafka &&\
	wget http://apache.fayea.com/kafka/$KAFKA_VERSION/kafka_2.11-$KAFKA_VERSION.tgz -P /opt/kafka

RUN tar zxvf /opt/java/jdk-8u102-linux-x64.tar.gz -C /opt/java &&\
	JAVA_HOME=/opt/java/jdk1.8.0_102 &&\
	sed -i "/^PATH/i export JAVA_HOME=$JAVA_HOME" /root/.bash_profile &&\
	sed -i "s%^PATH.*$%&:$JAVA_HOME/bin%g" /root/.bash_profile &&\
	source /root/.bash_profile

RUN tar zxvf /opt/kafka/kafka*.tgz -C /opt/kafka &&\
	sed -i 's/num.partitions.*$/num.partitions=3/g' /opt/kafka/kafka_2.11-$KAFKA_VERSION/config/server.properties

RUN echo "source /root/.bash_profile" > /opt/kafka/start.sh &&\
	echo "cd /opt/kafka/kafka_2.11-"$KAFKA_VERSION >> /opt/kafka/start.sh &&\
	#echo "sed -i 's%zookeeper.connect=.*$%zookeeper.connect=zookeeper:2181%g'  /opt/kafka/kafka_2.11-"$KAFKA_VERSION"/config/server.properties" >> /opt/kafka/start.sh &&\
	echo "[ ! -z $""ZOOKEEPER_CONNECT"" ] && sed -i 's%.*zookeeper.connect=.*$%zookeeper.connect='$""ZOOKEEPER_CONNECT'""%g'  /opt/kafka/kafka_2.11-"$KAFKA_VERSION"/config/server.properties" >> /opt/kafka/start.sh &&\
	echo "[ ! -z $""BROKER_ID"" ] && sed -i 's%broker.id=.*$%broker.id='$""BROKER_ID'""%g'  /opt/kafka/kafka_2.11-"$KAFKA_VERSION"/config/server.properties" >> /opt/kafka/start.sh &&\
	echo "[ ! -z $""BROKER_PORT"" ] && sed -i 's%port=.*$%port='$""BROKER_PORT'""%g'  /opt/kafka/kafka_2.11-"$KAFKA_VERSION"/config/server.properties" >> /opt/kafka/start.sh &&\
	echo "sed -i 's%#advertised.host.name=.*$%advertised.host.name='$""(hostname -i)'""%g'  /opt/kafka/kafka_2.11-"$KAFKA_VERSION"/config/server.properties" >> /opt/kafka/start.sh &&\
	echo "[ ! -z $""ADVERTISED_HOST_NAME"" ] && sed -i 's%advertised.host.name=.*$%advertised.host.name='$""ADVERTISED_HOST_NAME'""%g'  /opt/kafka/kafka_2.11-"$KAFKA_VERSION"/config/server.properties" >> /opt/kafka/start.sh &&\
	echo "sed -i 's%#host.name=.*$%host.name='$""(hostname -i)'""%g'  /opt/kafka/kafka_2.11-"$KAFKA_VERSION"/config/server.properties" >> /opt/kafka/start.sh &&\
	echo "[ ! -z $""HOST_NAME"" ] && sed -i 's%host.name=.*$%host.name='$""HOST_NAME'""%g'  /opt/kafka/kafka_2.11-"$KAFKA_VERSION"/config/server.properties" >> /opt/kafka/start.sh &&\
	echo "[ ! -z $""ZOOKEEPER_SESSION_TIMEOUT"" ] && sed -i 's%zookeeper.connection.timeout.ms.*$%zookeeper.connection.timeout.ms='$""ZOOKEEPER_SESSION_TIMEOUT'""%g' /opt/kafka/kafka_2.11-"$KAFKA_VERSION"/config/server.properties" >> /opt/kafka/start.sh &&\
	echo "delete.topic.enable=true" >> /opt/kafka/kafka_2.11-$KAFKA_VERSION/config/server.properties &&\
	echo "bin/kafka-server-start.sh config/server.properties" >> /opt/kafka/start.sh &&\
	chmod a+x /opt/kafka/start.sh

RUN yum install -y nc

EXPOSE 9092

WORKDIR /opt/kafka/kafka_2.11-$KAFKA_VERSION

ENTRYPOINT ["sh", "/opt/kafka/start.sh"]
