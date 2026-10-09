CREATE DATABASE matching_builds
    WITH 
    ENCODING = 'UTF8';

drop schema if exists matching_builds cascade;

create schema matching_builds;

set search_path to matching_builds;

create table users(
	user_id serial primary key,
	firstname varchar(50) not null,
	lastname varchar(50) not null,
	email varchar(150) unique not null,
	rut varchar(10) unique,
	cel varchar(15),
	budget decimal(10,2),
	confort_platform varchar(50),
	check (budget >= 0)
);

create table games(
	game_id serial primary key,
	name varchar(150) not null,
	category_1 varchar(50) not null,
	category_2 varchar(50) not null,
	population int,
	check (population >= 0)
);


create table hardware(
	hw_id serial primary key,
	hw_type varchar(50) not null check (hw_type in ('CPU', 'GPU', 'RAM', 'Storage', 'Motherboard', 'PSU', 'Case')),
	model varchar(100) not null,
	power_consumption int check (power_consumption > 0),
	cores int check (cores > 0),
	threads int check (threads > 0),
	socket varchar(50),
	vram int check (vram > 0),
	capacity int check (capacity > 0),
	mts int check (mts > 0),
	ram_slots int check (ram_slots > 0),
	interface varchar(50),
	ssd boolean,
	storage_interface varchar(64),
	wattage_output int check (wattage_output > 0)
);

create table requirements(
	req_id serial primary key,
	game_id int,
	requirement_type varchar(64) not null,
	min_scored_required decimal(20,2) not null,
	target_resolution varchar(20),
	target_fps int check (target_fps > 0),
	foreign key (game_id) references games(game_id) on delete cascade
);

create table build(
	build_id serial primary key,
	user_id int,	
	performance_tier varchar(50),
	foreign key (user_id) references users(user_id) on delete cascade
);

create table user_likes_games(
	user_id int,
	game_id int,
	primary key (user_id, game_id),
	performance_profile varchar(50),
	foreign key (user_id) references users(user_id) on delete cascade,
	foreign key (game_id) references games(game_id) on delete cascade
);

create table benchmark(
	bench_id serial primary key,
	hw_id int,
	score int not null,
	resolution varchar(20) not null,
	graphic_presets varchar(50),
	avg_fps int,
	stuttering decimal(5,2),
	api varchar(50),
	foreign key (hw_id) references hardware(hw_id) on delete cascade,
	check (score >= 0),
	check (avg_fps >= 0)	
);

create table requirements_hardware(
	req_id int,
	hw_id int,
	primary key (req_id, hw_id),
	foreign key (req_id) references requirements(req_id) on delete cascade,
	foreign key (hw_id) references hardware(hw_id) on delete cascade
);

create table hardware_build(
	hw_id int,
	build_id int,
	primary key (hw_id, build_id),
	foreign key (hw_id) references hardware(hw_id) on delete cascade,
	foreign key (build_id) references build(build_id) on delete cascade
);

create table offer(
	hw_id int,
	store_name varchar(100),
	current_price decimal(10,2) not null,
	direct_link varchar(255),
	stock int default 0,
	last_update timestamp default current_timestamp not null,
	primary key (hw_id, store_name),
	foreign key (hw_id) references hardware(hw_id) on delete cascade
);

-- Indices

-- Componentes
CREATE INDEX idx_hardware_type ON hardware(hw_type);
-- Modelo
CREATE INDEX idx_hardware_model ON hardware(model);
-- Nombre de juego
CREATE INDEX idx_game_name ON games(name);
-- Precio por orden ascendente 
CREATE INDEX idx_offer_price ON offer(current_price);
-- Joins entre games y requirements
CREATE INDEX idx_req_game_id ON requirements(game_id);