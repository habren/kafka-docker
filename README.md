Build Kafka cluster with docker-compose

------

# 构建image
```bash
cd demokafka.0.10.1.0
docker-compose build
```

# 启动集群
```bash
cd demokafka.0.10.1.0
docker-compose up -d
```

# 停止集群
```bash
cd demokafka.0.10.1.0
docker-compose stop
```

# 删除集群
```bash
cd demokafka.0.10.1.0
docker-compose rm -f
```
