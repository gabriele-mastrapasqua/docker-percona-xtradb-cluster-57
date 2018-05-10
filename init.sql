create database test;
use test
create table if not exists user (id int auto_increment, nome varchar(256), primary key (id) );
insert into user values(1, "pippo"), (2, "pluto");
