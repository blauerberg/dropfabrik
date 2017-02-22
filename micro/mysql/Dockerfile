FROM mariadb:10.1

COPY server.cnf /etc/mysql/conf.d/server.cnf
COPY initdb.sql.gz /docker-entrypoint-initdb.d/initdb.sql.gz
