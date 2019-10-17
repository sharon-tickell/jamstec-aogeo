
# ALlow the base-image to be selected at build time.
# The default is a security-hardened version of the official tomcat image.
ARG BASE_IMAGE="unidata/tomcat-docker:8.5"
FROM $BASE_IMAGE

# Record the actual base image used from the FROM command in the build output.
ARG BASE_IMAGE=$BASE_IMAGE
RUN echo "Base Image: ${BASE_IMAGE}"

# Install the PostgreSQL Client.
RUN apt-get update && \
    apt-get install -y netcat postgresql-client && \
    rm -rf /var/lib/apt/lists/*

# Install the GeoNetwork Web Application.
ENV GN_DIR=${CATALINA_HOME}/webapps/geonetwork

ARG GN_VERSION
ENV GN_VERSION=${GN_VERSION:-3.8.0}

ARG GN_WARFILE
ENV GN_WARFILE=${GN_WARFILE:-geonetwork.war}

ARG GN_DOWNLOAD_MD5
ENV GN_DOWNLOAD_MD5=${GN_DOWNLOAD_MD5:-8d08ef7d758392bdf3de68f3aeb5e2e7}

WORKDIR ${GN_DIR}
COPY ./downloads/* ./
RUN mkdir -p ${GN_DIR} && \
    if [ ! -f "${GN_WARFILE}" ]; then \
        curl -fSL -o $GN_WARFILE \
            https://sourceforge.net/projects/geonetwork/files/GeoNetwork_opensource/v${GN_VERSION}/geonetwork.war/download && \
            echo "$GN_DOWNLOAD_MD5 *$GN_WARFILE" | md5sum -c; \
    fi && \
    unzip -e ${GN_WARFILE} -d ${GN_DIR}/ && \
    rm ${GN_WARFILE} && \
    find . -type d -print0 | xargs -0 --no-run-if-empty chmod 0777 && \
    find . -type f -print0 | xargs -0 --no-run-if-empty chmod 0644

# Tweak the installed Geonetwork Configuration Files.
RUN sed -i -e 's#<import resource="../config-db/h2.xml"/>#<!--<import resource="../config-db/h2.xml"/> -->#g' ${GN_DIR}/WEB-INF/config-node/srv.xml && \
sed -i -e 's#<!--<import resource="../config-db/postgres.xml"/>-->#<import resource="../config-db/postgres.xml"/>#g' ${GN_DIR}/WEB-INF/config-node/srv.xml
COPY ./jdbc.properties ${GN_DIR}/WEB-INF/config-db/jdbc.properties

# Switch tomcat over to use Log4J2
# See: https://stackoverflow.com/questions/28446085/tomcat-7-internal-logging-with-log4j2-xml/35618384#35618384
ARG LOG4J_VERSION
ENV LOG4J_VERSION=${LOG4J_VERSION:-2.12.1}
ADD http://apache.mirror.serversaustralia.com.au/logging/log4j/${LOG4J_VERSION}/apache-log4j-${LOG4J_VERSION}-bin.tar.gz /tmp/
RUN tar -xzf /tmp/apache-log4j-${LOG4J_VERSION}-bin.tar.gz -C /tmp/; \
    cp /tmp/apache-log4j-${LOG4J_VERSION}-bin/log4j-core-${LOG4J_VERSION}.jar ${CATALINA_HOME}/lib/; \
    cp /tmp/apache-log4j-${LOG4J_VERSION}-bin/log4j-jul-${LOG4J_VERSION}.jar ${CATALINA_HOME}/lib/; \
    cp /tmp/apache-log4j-${LOG4J_VERSION}-bin/log4j-api-${LOG4J_VERSION}.jar ${CATALINA_HOME}/lib/; \
    cp /tmp/apache-log4j-${LOG4J_VERSION}-bin/log4j-1.2-api-${LOG4J_VERSION}.jar ${CATALINA_HOME}/lib/; \
    rm -r /tmp/apache-log4j-${LOG4J_VERSION}-bin; \
    rm /tmp/apache-log4j-${LOG4J_VERSION}-bin.tar.gz; \
    rm ${CATALINA_HOME}/conf/logging.properties

# Deploy a custom log4j configuration file.
# (The setenv.sh file tells Tomcat where this is)
COPY ./log4j2.xml ${CATALINA_HOME}/conf/

# Declare defaults for the JVM configuration settings.
ENV JAVA_OPTS="-Djava.security.egd=file:/dev/./urandom -Djava.awt.headless=true -server -Xms512m -Xmx2024m -XX:NewSize=512m -XX:MaxNewSize=1024m -XX:+UseConcMarkSweepGC"
ENV CATALINA_OPTS="-Dlog4j.configurationFile='${CATALINA_HOME}/conf/log4j2.xml' -Djava.util.logging.manager=org.apache.logging.log4j.jul.LogManager"

# Declare defaults for the configurable connector settings.
# Tomcat defaults are listed at https://tomcat.apache.org/tomcat-8.0-doc/config/http.html
ENV CONNECTOR_COMPRESSION 1000
ENV CONNECTOR_COMPRESSIBLE_MIME_TYPE "text/html,text/xml,text/plain,application/octet-stream"
ENV CONNECTOR_CONNECTION_TIMEOUT 20000
ENV CONNECTOR_MAX_THREADS 50
ENV CONNECTOR_PROTOCOL "HTTP/1.1"
ENV CONNECTOR_PROXYNAME localhost
ENV CONNECTOR_PROXYPORT 8080
ENV CONNECTOR_PROXYSCHEME http
ENV CONNECTOR_PROXYSECURE false
ENV CONNECTOR_SERVER Apache
ENV CONNECTOR_TRUSTED_PROXIES ""
ENV CORS_ALLOWED_ORIGINS *
ENV CORS_ALLOWED_METHODS "GET,POST,HEAD,OPTIONS,PUT"
ENV CORS_ALLOWED_HEADERS "Authorization,Origin,Accept,X-Requested-With,Content-Type,Access-Control-Request-Method,Access-Control-Request-Headers"
ENV CORS_EXPOSED_HEADERS ""
ENV CORS_SUPPORT_CREDENTIALS false
ENV CORS_PREFLIGHT_MAXAGE 10

# Declare environment variables for Geonetwork configuration details
ENV DATA_DIR=${CATALINA_HOME}/webapps/geonetwork/WEB-INF/data
ENV POSTGRES_DB_HOST=""
ENV POSTGRES_DB_PORT="5432"
ENV POSTGRES_DB_ADMIN="admin"
ENV POSTGRES_DB_NAME="geonetwork"
ENV POSTGRES_DB_PASSWORD=""
ENV POSTGRES_DB_PASSWORD_FILE=""
ENV POSTGRES_DB_USERNAME=""

# Override the default setenv script with one that will include
# the connector and log4j2 settings in CATALINA_OPTS.
COPY ./setenv.sh ${CATALINA_HOME}/bin/
RUN chmod 755 ${CATALINA_HOME}/bin/setenv.sh

# Override the default server.xml and web.xml with variants that allows settings
# to be configured via environment variables known to setenv.sh
COPY ./server.xml ${CATALINA_HOME}/conf/
COPY ./web.xml ${CATALINA_HOME}/conf/

# Overwrite the default entrypoint script with our derived one.
COPY ./entrypoint.sh /entrypoint.sh
RUN chmod 0755 /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]

# Clean installation and prepare to launch
WORKDIR ${CATALINA_HOME}
EXPOSE 8080 8443

CMD ["catalina.sh", "run"]
