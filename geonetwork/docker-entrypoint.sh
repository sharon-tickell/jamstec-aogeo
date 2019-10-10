#!/bin/bash
set -e

if [ "$1" = 'catalina.sh' ]; then

	# Configure the Geonetwork Data Directory.
	mkdir -p "$DATA_DIR"
	export CATALINA_OPTS="$CATALINA_OPTS -Dgeonetwork.dir=$DATA_DIR"

	# Ensure that the Postgres connection is configured.
	db_host="${POSTGRES_DB_HOST:-postgres}"
	echo "db host: $db_host"

	db_port="${POSTGRES_DB_PORT:-5432}"
	echo "db port: $db_port"

    db_admin="${POSTGRES_DB_ADMIN:-admin}"
    echo "db admin: ${db_admin}"

	db_gn="${POSTGRES_DB_NAME:-geonetwork}"
    echo "db name: ${db_name}"

	if [ -z "${POSTGRES_DB_USERNAME}" ]; then
		echo >&2 "you must set POSTGRES_DB_USERNAME"
		exit 1
	fi

	if [ -z "${POSTGRES_DB_PASSWORD}" ]; then
        if [ -z "${POSTGRES_DB_PASSWORD_FILE}" ]; then
		    echo >&2 "you must set POSTGRES_DB_PASSWORD or POSTGRES_DB_PASSWORD_FILE"
		    exit 1
        elif [ ! -f "${POSTGRES_DB_PASSWORD_FILE}" ]; then
        	echo >&2 "POSTGRES_DB_PASSWORD_FILE='${POSTGRES_DB_PASSWORD_FILE}' not found."
		    exit 1
        else
            POSTGRES_DB_PASSWORD=$(cat "${POSTGRES_DB_PASSWORD_FILE}")
            if [ -z "${POSTGRES_DB_PASSWORD_FILE}" ]; then
		        echo >&2 "POSTGRES_DB_PASSWORD_FILE='${POSTGRES_DB_PASSWORD_FILE}' is empty."
		        exit 1
            fi
        fi
	fi

	#Create databases, if they do not exist yet (http://stackoverflow.com/a/36591842/433558)
	echo  "$db_host:$db_port:*:$POSTGRES_DB_USERNAME:$POSTGRES_DB_PASSWORD" > ~/.pgpass
	chmod 0600 ~/.pgpass
	for db_name in "$db_admin" "$db_gn"; do
		if psql -h "$db_host" -U "$POSTGRES_DB_USERNAME" -p "$db_port" -tqc "SELECT 1 FROM pg_database WHERE datname = '$db_name'" | grep -q 1; then
			echo "database '$db_name' exists; skipping createdb"
		else
			createdb -h "$db_host" -U "$POSTGRES_DB_USERNAME" -p "$db_port" -O "$POSTGRES_DB_USERNAME" "$db_name"
		fi
	done
	rm ~/.pgpass

	#Write connection string for GN
	sed -ri '/^jdbc[.](username|password|database|host|port)=/d' "$CATALINA_HOME"/webapps/geonetwork/WEB-INF/config-db/jdbc.properties
	echo "jdbc.username=$POSTGRES_DB_USERNAME" >> "$CATALINA_HOME"/webapps/geonetwork/WEB-INF/config-db/jdbc.properties
	echo "jdbc.password=$POSTGRES_DB_PASSWORD" >> "$CATALINA_HOME"/webapps/geonetwork/WEB-INF/config-db/jdbc.properties
	echo "jdbc.database=$db_gn" >> "$CATALINA_HOME"/webapps/geonetwork/WEB-INF/config-db/jdbc.properties
	echo "jdbc.host=$db_host" >> "$CATALINA_HOME"/webapps/geonetwork/WEB-INF/config-db/jdbc.properties
	echo "jdbc.port=$db_port" >> "$CATALINA_HOME"/webapps/geonetwork/WEB-INF/config-db/jdbc.properties

	#Fixing an hardcoded port on the connection string (bug fixed on development branch)
	sed -i -e 's#5432#${jdbc.port}#g' $CATALINA_HOME/webapps/geonetwork/WEB-INF/config-db/postgres.xml
fi

exec "$@"
