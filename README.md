# proxysql + etcd + mysql percona xtradb cluster 5.7 in swarm mode



## deploy on current node (for testing purpose)

```
docker-compose up
```

## deploy in swarm mode

```
docker stack deploy -c docker-compose.yml galera
```

----

## add cluster nodes to proxysql container

```
docker exec -it percona-xtradb-cluster-57_proxy_1 add_cluster_nodes.sh
```

** Then after the adding of some nodes is possible to connect to proxysql through 3306.**

Note: without adding any mysql worker node to proxysql it's not possible to connect to mysql proxysql.




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

