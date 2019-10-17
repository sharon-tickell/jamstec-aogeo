#!/bin/bash
set -ex

# preferable to fire up Tomcat via start-tomcat.sh (From unidata/tomcat-docker) which will
# start Tomcat with security manager, but inheriting containers can also start Tomcat via
# catalina.sh (from the official tomcat image)
if [ "$1" = 'start-tomcat.sh' ] || [ "$1" = 'catalina.sh' ]; then

    ###
    # Ensure the Tomcat user and group exist.
    ###
    USER_ID=${TOMCAT_USER_ID:-1000}
    GROUP_ID=${TOMCAT_GROUP_ID:-1000}
    groupadd -r tomcat -g ${GROUP_ID} && \
    useradd -u ${USER_ID} -g tomcat -d ${CATALINA_HOME} -s /sbin/nologin \
        -c "Tomcat user" tomcat

    ###
    # Change CATALINA_HOME ownership to tomcat user and tomcat group
    ###
    CURRENT_UID=$(stat -c '%u' "${CATALINA_HOME}")
    if [ "${CURRENT_UID}" != "${USER_ID}" ]; then
        # Ownership has not been configured in the dockerfile: Change it now.
        # This can be *very* slow if you have big webapps and docker is not
        # native (e.g. windows or mac)
        chown -R ${USER_ID}:${GROUP_ID} ${CATALINA_HOME}
    fi

    ###
    # Restrict permissions on conf
    ###
    chmod 400 ${CATALINA_HOME}/conf/*

    ###
    # Run tomcat as the tomcat user.
    ###
    sync
    exec gosu ${USER_ID} "$@"
fi

exec "$@"
