use test2;

create table users (
	username varchar(45) not null,
	password varchar(45) not null,
	enabled tinyint not null default 1,
	primary key (username)
);

create table usertest2_roles (
user_role_id int(11) not null AUTO_INCREMENT,
username varchar(45) not null,
role varchar(45) not null,
PRIMARY key (user_role_id),
UNIQUE key uni_username_role (role,username),
key fk_username_idx (username),
constraint fk_username foreign key (username) REFERENCES users (username)
);



insert into users(username, password, enabled) values ('kyung','123456',true);
insert into users(username, password, enabled) values ('admin','123456',true);
insert into users(username, password, enabled) values ('alex','123456',true);
insert into user_roles (username, role) values ('kyung','ROLE_MANAGER');
insert into user_roles (username, role) values ('admin','ROLE_ADMIN');
insert into user_roles (username, role) values ('alex','ROLE_USER');


#SET foreign_key_checks = 0;
#SET foreign_key_checks = 1;
#truncate users; 
#truncate user_roles; 



test2create table test(
id varchar(20) not null primary key,
pw varchar(20) not null
);

insert into test(id, pw) values ('123','123');
insert into test(id, pw) values ('234',"'OR'1'='1'");

select * from test;

select * from 

SELECT * FROM test WHERE id='000' AND pw='' OR '1' = '1';

select 
