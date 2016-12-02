Build Kafka cluster with docker-compose

------

# 集群管理方法

## 构建image
```bash
cd demokafka.0.10.1.0
docker-compose build
```

## 启动集群
```bash
cd demokafka.0.10.1.0
docker-compose up -d
```

## 停止集群
```bash
cd demokafka.0.10.1.0
docker-compose stop
```

## 删除集群
```bash
cd demokafka.0.10.1.0
docker-compose rm -f
```

# 集群配置说明

## 主要配置
 - ***ZOOKEEPER_CONNECT:*** zookeeper0:12181,zookeeper1:12182,zookeeper2:12183/kafka  
 - ***BROKER_ID:*** 0    
 - ***LISTENERS:*** PLAINTEXT://kafka0:19092,SSL://kafka0:29092
 - ***ZOOKEEPER_SESSION_TIMEOUT:*** 3600000
 - ***CONNECT_REST_PORT:*** 18083

## 其它配置
对于其它配置，配置名应以`KAFKA_PROPERTY_`开头，并且配置名须将点号换成下划线，如`auto.create.topics.enable`应以以下方式配置    
`KAFKA_PROPERTY_AUTO_CREATE_TOPICS_ENABLE: "false"`








