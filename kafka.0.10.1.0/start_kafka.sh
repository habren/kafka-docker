source /root/.bash_profile

KAFKA_HOME=/opt/kafka/kafka_2.11-$KAFKA_VERSION

pushd $KAFKA_HOME
[ ! -z $ZOOKEEPER_CONNECT ] && sed -i 's%.*zookeeper.connect=.*$%zookeeper.connect='$ZOOKEEPER_CONNECT'%g' config/server.properties
[ ! -z $BROKER_ID ] && sed -i 's%broker.id=.*$%broker.id='$BROKER_ID'%g' config/server.properties
sed -i 's%#listeners=.*$%listeners=PLAINTEXT://'$(hostname -i)':9092%g' config/server.properties
[ ! -z $LISTENERS ] && sed -i 's%listeners=.*$%listeners='$LISTENERS'%g' config/server.properties
[ ! -z $ZOOKEEPER_SESSION_TIMEOUT ] && sed -i 's%zookeeper.connection.timeout.ms.*$%zookeeper.connection.timeout.ms='$ZOOKEEPER_SESSION_TIMEOUT'%g' config/server.properties
[ ! -z $CONNECT_REST_PORT ] && echo rest.port=$CONNECT_REST_PORT >> /opt/kafka/kafka_2.11-0.10.1.0/config/connect-standalone.properties && echo -e '\nrest.port='$CONNECT_REST_PORT >> config/connect-distributed.properties
popd


if [[ $(echo $LISTENERS | tr '[:upper:]' '[:lower:]') =~ ssl ]]
then
	pushd /opt/kafka
	mkdir /opt/kafka/ssl
	country=US ; [ ! -z $SSL_C ] && country=$SSL_C 
	organization=UNKNOWN ; [ ! -z $SSL_O ] && organization=$SSL_O  
	organizationalunit=UNKNOWN ; [ ! -z $SSL_OU ] && organizationalunit=$SSL_OU 
	province=UNKNOWN ; [ ! -z $SSL_ST ] && province=$SSL_ST 
	commonname=US ; [ ! -z $SSL_CN ] && commonname=$SSL_CN 
	locality=UNKNOWN ; [ ! -z $SSL_L ] && locality=$SSL_L 
	ssl_password=jasonguo ; [ ! -z $SSL_PASSWORD ] && ssl_password=$SSL_PASSWORD

	if [ -f ca/ca.crt ] || [ -f ca/ca.key ]
	then
		sleep 5s
	else
		openssl req -new -x509 -keyout ca/ca.key -out ca/ca.crt -days 365 -passout pass:$ssl_password -subj "/C="$country"/ST="$province"/L="$locality"/O="$organization"/OU="$organizationalunit"/CN="$commonname
	fi

	keytool -keystore ssl/$HOSTNAME.keystore.jks -alias $HOSTNAME -validity 365 -storepass $ssl_password -keypass $ssl_password  -genkey -dname "CN="$commonname", OU="$organizationalunit", O="$organization", L="$locality", ST="$province", C="$country
	
	keytool -v -keystore ssl/$HOSTNAME.truststore.jks -alias CARoot -import -file ca/ca.crt -storepass $ssl_password <<EOF
	y

EOF
	
	keytool -keystore ssl/$HOSTNAME.keystore.jks -alias $HOSTNAME -certreq -file ssl/$HOSTNAME.crt -storepass $ssl_password
	
	openssl x509 -req -CA ca/ca.crt -CAkey ca/ca.key -in ssl/$HOSTNAME.crt -out ssl/$HOSTNAME-signed.crt -days 365 -CAcreateserial -passin pass:$ssl_password
	
	keytool -keystore ssl/$HOSTNAME.keystore.jks -alias CARoot -import -file ca/ca.crt  -storepass $ssl_password <<EOF
	y
EOF

	keytool -keystore ssl/$HOSTNAME.keystore.jks -alias $HOSTNAME -import -file ssl/$HOSTNAME-signed.crt  -storepass $ssl_password <<EOF
	y
EOF

	echo "ssl.keystore.location=/opt/kafka/ssl/"$HOSTNAME".keystore.jks
ssl.keystore.password="$ssl_password"
ssl.key.password="$ssl_password"
ssl.truststore.location=/opt/kafka/ssl/"$HOSTNAME".truststore.jks
ssl.truststore.password="$ssl_password >>  /opt/kafka/kafka_2.11-$KAFKA_VERSION/config/server.properties
	popd

	echo "security.protocol=SSL
ssl.truststore.location=/opt/kafka/ssl/"$HOSTNAME".truststore.jks
ssl.truststore.password="$ssl_password"
ssl.keystore.location=/opt/kafka/ssl/"$HOSTNAME".keystore.jks
ssl.keystore.password="$ssl_password"
ssl.key.password="$ssl_password >> /opt/kafka/client.propertiess
fi


pushd $KAFKA_HOME
for PROPERTY in $(env)
do
	if [[ $PROPERTY =~ ^KAFKA_PROPERTY_ ]]
	then
		property_name=$(echo $PROPERTY | awk -F'=' '{print $1}' | sed 's/^KAFKA_PROPERTY_//g' | tr '[:upper:]' '[:lower:]' | tr _ .)
		property_entry=$(echo $PROPERTY | sed 's/^KAFKA_PROPERTY_//g' | tr '[:upper:]' '[:lower:]' | tr _ .)
		if egrep -q "(^|^#)$property_name=" config/server.properties
		then
			sed -r -i "s@(^|^#)($property_name)=(.*)@$property_entry@g" config/server.properties
		else
			echo $property_entry >> config/server.properties
		fi
	fi
done
popd

cd $KAFKA_HOME
bin/kafka-server-start.sh config/server.properties
