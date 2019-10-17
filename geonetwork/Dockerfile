
# ALlow the base-image to be selected at build time.
# The default is a security-hardened version of the official tomcat image.
ARG BASE_IMAGE="unidata/tomcat-docker:8.5"
FROM $BASE_IMAGE

# Record the actual base image used from the FROM command in the build output.
ARG BASE_IMAGE=$BASE_IMAGE
RUN echo "Base Image: ${BASE_IMAGE}"

# Install the PostgreSQL Client.
RUN apt-get update && \
    apt-get install -y postgresql-client && \
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

# Tell tomcat where to find the geonetwork application.
#RUN mkdir -p ${CATALINA_HOME}/conf/Catalina/localhost
#COPY ./geonetwork.xml ${CATALINA_HOME}/conf/Catalina/localhost/geonetwork.xml
#RUN find ${CATALINA_HOME}/conf -type d -print0 | xargs -0 --no-run-if-empty chmod 0777 && \
#    find ${CATALINA_HOME}/conf -type f -print0 | xargs -0 --no-run-if-empty chmod 0666


# Overwrite the default entrypoint script with our derived one.
COPY ./entrypoint.sh /entrypoint.sh
RUN chmod 0755 /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]

# Clean installation and prepare to launch
WORKDIR ${CATALINA_HOME}
EXPOSE 8080 8443

CMD ["catalina.sh", "run"]
