create schema mgmt;
create table mgmt.lock_list (lock_id integer);
insert into mgmt.lock_list select generate_series(1, <WRITEABLE_DB_COUNT>);
-- change to the catalog to indicate that we've succeeded
create schema create_complete;