
# ALlow the base-image to be selected at build time.
ARG BASE_IMAGE="tomcat:8.5-jdk8"
FROM $BASE_IMAGE

# Record the actual base image used from the FROM command in the build output.
ARG BASE_IMAGE=$BASE_IMAGE
RUN echo "Base Image: ${BASE_IMAGE}"

# Environment variables
ENV DATA_DIR=${CATALINA_HOME}/webapps/geonetwork/WEB-INF/data
ENV GN_VERSION="3.8.0"
ENV GN_DOWNLOAD_MD5="8d08ef7d758392bdf3de68f3aeb5e2e7"
ENV GN_FILE="geonetwork.war"
ENV JAVA_OPTS="-Djava.security.egd=file:/dev/./urandom -Djava.awt.headless=true -server -Xms512m -Xmx2024m -XX:NewSize=512m -XX:MaxNewSize=1024m -XX:+UseConcMarkSweepGC"
ENV POSTGRES_DB_ADMIN="admin"
ENV POSTGRES_DB_NAME="geonetwork"
ENV POSTGRES_DB_PASSWORD_FILE=""

# Download and unpack the Geonetwork web application.
WORKDIR $CATALINA_HOME/webapps
RUN curl -fSL -o $GN_FILE \
     https://sourceforge.net/projects/geonetwork/files/GeoNetwork_opensource/v${GN_VERSION}/geonetwork.war/download && \
     echo "$GN_DOWNLOAD_MD5 *$GN_FILE" | md5sum -c && \
     mkdir -p geonetwork && \
     unzip -e $GN_FILE -d geonetwork && \
     rm $GN_FILE

# Install the PostgreSQL Client.
RUN apt-get update && apt-get install -y postgresql-client && \
    rm -rf /var/lib/apt/lists/*

# Tweak the Geonetwork Configuration Files.
RUN sed -i -e 's#<import resource="../config-db/h2.xml"/>#<!--<import resource="../config-db/h2.xml"/> -->#g' $CATALINA_HOME/webapps/geonetwork/WEB-INF/config-node/srv.xml && \
sed -i -e 's#<!--<import resource="../config-db/postgres.xml"/>-->#<import resource="../config-db/postgres.xml"/>#g' $CATALINA_HOME/webapps/geonetwork/WEB-INF/config-node/srv.xml
COPY ./jdbc.properties $CATALINA_HOME/webapps/geonetwork/WEB-INF/config-db/jdbc.properties


# Run the Tomcat instance in the foreground.
# The Entrypoint script will
COPY ./docker-entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
CMD ["catalina.sh", "run"]
