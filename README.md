# proxysql + etcd + mysql percona xtradb cluster 5.7 in swarm mode
Deploy in swarm mode a proxysql load balancer container, etcd for service discovery and some pecona xtradb cluster for mysql 5.7.
docker swarm will create a overlay network for this stack.


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
docker exec -it galera_proxysql.1.$(docker service ps -f 'name=galera_proxysql.1' galera_proxy -q --no-trunc | head -n1) add_cluster_nodes.sh
```

** Then after the adding of some nodes is possible to connect to proxysql through 3306.**


----

# Manage

## connect to proxysql container locally:
```
docker exec -it galera_proxysql.1.$(docker service ps -f 'name=galera_proxysql.1' galera_proxy -q --no-trunc | head -n1) bash
```


- check if service discovery is working (from the local container):
```
curl http://$DISCOVERY_SERVICE/v2/keys/pxc-cluster/$CLUSTER_NAME/ | jq .
```

it will respond with a list of galera services discovered:
```
{
  "action": "get",
  "node": {
    "key": "/pxc-cluster/galera-15",
    "dir": true,
    "nodes": [
      {
        "key": "/pxc-cluster/galera-15/10.20.1.10",
        "dir": true,
        "expiration": "2018-05-09T14:36:42.36014648Z",
        "ttl": 26,
        "modifiedIndex": 9,
        "createdIndex": 9
      }
    ],
    "modifiedIndex": 5,
    "createdIndex": 5
  }
}
```


- check if galera nodes are connected to proxysql "admin interface" (6032) (from the local container):
```
mysql -u admin -padmin -h 127.0.0.1 -P6032 --prompt='Admin> ' -e "select * from stats.stats_mysql_connection_pool";
```


Also with this command:

```
docker exec -it galera_proxysql.1.$(docker service ps -f 'name=galera_proxysql.1' galera_proxy -q --no-trunc | head -n1) mysql -u admin -padmin -h 127.0.0.1 -P6032 --prompt='Admin> ' -e "select * from stats.stats_mysql_connection_pool;"
```



- connect to proxysql mysql interface (3306) (from the local container):

```
mysql -P3306 -h127.0.0.1 -uproxyuser -ps3cr3TL33tPr0xyP@ssw0rd
```

- check if balancing works (round robin of nodes):
connect through proxysql balancer:

```
docker exec -it galera_proxysql.1.$(docker service ps -f 'name=galera_proxysql.1' galera_proxy -q --no-trunc | head -n1) mysql -uproxyuser -ps3cr3TL33tPr0xyP@ssw0rd  -h 127.0.0.1  -P3306 -e "SELECT @@hostname"
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

