HOWTO INSTALL Debian 8.11 jessie
/etc/apt/source.list.d/pg.list
deb http://apt.postgresql.org/pub/repos/apt/ YOUR_DEBIAN_VERSION_HERE-pgdg main
wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -
sudo apt-get update
sudo apt install postgresql-9.5

psql -U postgres
sudo -u postgres psql

DROP DATABASE production;

CREATE DATABASE production
 WITH OWNER = postgres
      ENCODING = 'UTF8'
       TABLESPACE = pg_default
       LC_COLLATE = 'ru_RU.UTF-8'
       LC_CTYPE = 'ru_RU.UTF-8'
      CONNECTION LIMIT = -1;

pg_restore --dbname=production --verbose --disable-triggers --jobs=4 1.dmp
psql -U postgres -d production -c "SELECT query from public.fn_get_ddl_roles_sync('192.168.25.140', 6432, 'production', 'postgres', '1');" > /tmp/roles.sql
psql -U postgres -d production -f /tmp/roles.sql

CREATE SCHEMA partitions AUTHORIZATION postgres;
GRANT ALL ON SCHEMA partitions TO postgres;
GRANT ALL ON SCHEMA partitions TO public;
GRANT USAGE ON SCHEMA partitions TO robot;
COMMENT ON SCHEMA partitions IS 'Схема для партиций';

ANALYZE;

CREATE USER postgres WITH password '1';
CREATE USER pr WITH password '1';
ALTER USER pr WITH SUPERUSER;
GRANT ALL ON DATABASE postgres TO pr;
grant all privileges on database production to pr;
CREATE ROLE replication WITH REPLICATION PASSWORD '1' LOGIN;

drop user pr;
drop role pr;
REVOKE ALL ON DATABASE postgres from pr;

host replication replication  192.168.56.10/32  trust
wal_level = hot_standby
max_wal_senders = 5
wal_keep_segments = 32
hot_standby = on

------RESTORE to SLAVE
slave stop
chown postgres:postgres /var/lib/postgresql/9.5/main/recovery.conf
SELECT pg_start_backup('label', true);
rsync -avuKL /var/lib/postgresql/9.5/main/ root@192.168.25.141:/var/lib/postgresql/9.5/main/ --exclude postmaster.pid
rsync -avuKL /data/base/ root@192.168.25.141:/data/base
SELECT pg_stop_backup();
slave start

------RESET WAL ARCHIVE LOG
cat /var/log/postgresql/postgresql_9.5.log
service postgresql stop
/usr/lib/postgresql/9.5/bin/pg_controldata /var/lib/postgresql/9.5/main/
su postgres
/usr/lib/postgresql/9.5/bin/pg_resetxlog -o 1218395 -x 263558 -f /var/lib/postgresql/9.5/main/
service postgresql start

SELECT * FROM pg_stat_replication;
SELECT now() - pg_last_xact_replay_timestamp();
SELECT pg_reload_conf();
