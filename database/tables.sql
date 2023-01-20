create table customer (
	cid int,
	name varchar(255) not null,
	natcod char(10) not null,
	birthdate date not null,
	add varchar(1024),
	tel varchar(11),
	primary key(cid)
);

create table branch (
	branch_id int not null,
	branch_name varchar(255) not null,
	branch_add varchar(1024),
	branch_tel varchar(11),
	primary key(branch_id)
);

create table trn_src_des (
	voucherid varchar(10),
	trndate date not null,
	trntime time not null,
	amount bigint not null,
	sourcedep int,
	desdep int,
	branch_id int,
	trn_desc varchar(255),
	primary key(voucherid),
	foreign key(branch_id) references branch
);

create table deposit_type (
	dep_type int,
	dep_typ_desc varchar(255),
	primary key(dep_type)
);

create table deposit_status (
	status int,
	status_desc varchar(255),
	primary key(status)
);

create table deposit (
	dep_id int,
	dep_type int,
	cid int,
	opendate date,
	status int,
	primary key(dep_id),
	foreign key(dep_type) references deposit_type,
	foreign key(cid) references customer,
	foreign key(status) references deposit_status
);