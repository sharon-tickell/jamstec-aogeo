#!/bin/bash
set -ex

# preferable to fire up Tomcat via start-tomcat.sh (From unidata/tomcat-docker) which will
# start Tomcat with security manager, but inheriting containers can also start Tomcat via
# catalina.sh (from the official tomcat image)
if [ "$1" = 'start-tomcat.sh' ] || [ "$1" = 'catalina.sh' ]; then

    # Ensure the Tomcat user and group exist.
    USER_ID=${TOMCAT_USER_ID:-1000}
    GROUP_ID=${TOMCAT_GROUP_ID:-1000}
    groupadd -r tomcat -g ${GROUP_ID} && \
    useradd -u ${USER_ID} -g tomcat -d ${CATALINA_HOME} -s /sbin/nologin -c "Tomcat user" tomcat

    # Change CATALINA_HOME ownership to tomcat user and tomcat group
    CURRENT_UID=$(stat -c '%u' "${CATALINA_HOME}")
    if [ "${CURRENT_UID}" != "${USER_ID}" ]; then
        # Ownership has not been configured in the dockerfile: Change it now.
        # This can be *very* slow if you have big webapps and docker is not
        # native (e.g. windows or mac)
        chown -R ${USER_ID}:${GROUP_ID} ${CATALINA_HOME}
    fi

    # Restrict permissions on conf
    chmod 400 ${CATALINA_HOME}/conf/*


    # Ensure the geonetwork data directory exists and is writable by the tomcat user.
    mkdir -p "$DATA_DIR"
    if [ "${CURRENT_UID}" != "${USER_ID}" ]; then
        chown -R ${USER_ID}:${GROUP_ID} "${DATA_DIR}"
    fi

    # Ensure that the Postgres connection is configured.
    db_host="${POSTGRES_DB_HOST:-postgres}"
    db_port="${POSTGRES_DB_PORT:-5432}"
    db_admin="${POSTGRES_DB_ADMIN:-admin}"
    db_gn="${POSTGRES_DB_NAME:-geonetwork}"
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
            POSTGRES_DB_PASSWORD=$(cat "${POSTGRES_DB_PASSWORD_FILE}" | sed 's/^[[:blank:]]*//;s/[[:blank:]]*$//')
            if [ -z "${POSTGRES_DB_PASSWORD_FILE}" ]; then
                echo >&2 "POSTGRES_DB_PASSWORD_FILE='${POSTGRES_DB_PASSWORD_FILE}' is empty."
                exit 1
            fi
        fi
    fi

    sed -ri '/^jdbc[.](username|password|database|host|port)=/d' "${CATALINA_HOME}"/webapps/geonetwork/WEB-INF/config-db/jdbc.properties
    echo "jdbc.username=$POSTGRES_DB_USERNAME" >> "${CATALINA_HOME}"/webapps/geonetwork/WEB-INF/config-db/jdbc.properties
    echo "jdbc.password=$POSTGRES_DB_PASSWORD" >> "${CATALINA_HOME}"/webapps/geonetwork/WEB-INF/config-db/jdbc.properties
    echo "jdbc.database=$db_gn" >> "${CATALINA_HOME}"/webapps/geonetwork/WEB-INF/config-db/jdbc.properties
    echo "jdbc.host=$db_host" >> "${CATALINA_HOME}"/webapps/geonetwork/WEB-INF/config-db/jdbc.properties
    echo "jdbc.port=$db_port" >> "${CATALINA_HOME}"/webapps/geonetwork/WEB-INF/config-db/jdbc.properties
    sed -i -e 's#5432#${jdbc.port}#g' ${CATALINA_HOME}/webapps/geonetwork/WEB-INF/config-db/postgres.xml

    # Wait until the postgres server is online and listening
    WAIT_TIMEOUT="${WAIT_TIMEOUT:-30}"
    echo "Waiting ${WAIT_TIMEOUT}s for something to be listening on ${db_host}:${db_port}..."
    set +e
    nc -z -w ${WAIT_TIMEOUT} "${db_host}" "${db_port}"
    wait_result=$?
    if [ $wait_result -ne 0 ]; then
    echo "Timed out waiting for ${db_host}:${db_port} :("
    exit $wait_result
    fi

    # Create the postgres databases if they do not exist yet (http://stackoverflow.com/a/36591842/433558)
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

    ###
    # Run tomcat as the tomcat user.
    ###
    sync
    exec gosu ${USER_ID} "$@"
fi

exec "$@"
