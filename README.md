# proxysql + etcd + mysql percona xtradb cluster 5.7 in swarm mode
Deploy in swarm mode a proxysql load balancer container, etcd for service discovery and some pecona xtradb cluster for mysql 5.7.


## deploy on current node (for testing purpose)

```
docker-compose up
```

## deploy in swarm mode (from manager node)

deploy stack:
```
docker stack deploy -c docker-compose.yml galera
```

ps stack:
```
docker stack ps galera
```

stop stack:
```
docker stack rm galera
```

----

## firewall setup for swarm mode and overlay networks
Open ports for service discovery on overlay networks on swarm mode:
See: https://docs.docker.com/network/overlay/#publish-ports

- on manager node:
```
ufw allow 22/tcp
ufw allow 2376/tcp
ufw allow 2377/tcp
ufw allow 7946/tcp
ufw allow 7946/udp
ufw allow 4789/udp
```

- on worker nodes:
```
ufw allow 22/tcp
ufw allow 2376/tcp
ufw allow 7946/tcp 
ufw allow 7946/udp 
ufw allow 4789/udp 
```

----

## add cluster nodes to proxysql container
is mandatory to run this command to join nodes to proxysql:

```
docker exec -it percona-xtradb-cluster-57_proxy_1 add_cluster_nodes.sh
```

** Then after the adding of some nodes is possible to connect to proxysql through 3306.**


----

# Manage


## 1) optional - get ip address of proxysql container to connect to the container with a mysql client
```
docker inspect -f '{{range .NetworkSettings.Networks}}[{{.IPAddress}}] {{end}}' percona-xtradb-cluster-57_proxy_1
```

- then connect to proxysql "admin interface" (6032):
```
mysql -u admin -padmin -h <IP_PROXYSQL> -P6032 --prompt='Admin> '
```


## 2) otherwise connect to proxysql container locally:
```
docker exec -it percona-xtradb-cluster-57_proxy_1 bash
```

- then connect to proxysql "admin interface" (6032) from the local container:
```
mysql -u admin -padmin -h 127.0.0.1 -P6032 --prompt='Admin> '
```

- to show cluster connected to the proxysql manager:  

```
select * from stats.stats_mysql_connection_pool;
```


Also with this command:

```
docker exec -it percona-xtradb-cluster-57_proxy_1 mysql -u admin -padmin -h 127.0.0.1 -P6032 --prompt='Admin> ' -e "select * from stats.stats_mysql_connection_pool;"
```



- connect to proxysql mysql interface (3306):

```
mysql -P3306 -h127.0.0.1 -uproxyuser -ps3cr3TL33tPr0xyP@ssw0rd
```

- test if balancing works (round robin of nodes):
connect through proxysql balancer:

```
docker exec -it percona-xtradb-cluster-57_proxy_1 mysql -uproxyuser -ps3cr3TL33tPr0xyP@ssw0rd  -h 127.0.0.1  -P3306 -e "SELECT @@hostname"
```



---- 

## scale mysql replication:
```
docker-compose scale percona-xtradb-cluster=3
```



----

# sample init sql:
```
-- create database test;
-- use test
-- create table if not exists user (id int auto_increment, nome varchar(256), primary key (id) );
-- insert into user values(1, "pippo"), (2, "pluto");
select * from user;
```

