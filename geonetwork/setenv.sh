#!/bin/sh

# Assemble the JVM Environment variables.
if [ -r "$CATALINA_HOME/bin/javaopts.sh" ]; then
  . "$CATALINA_HOME/bin/javaopts.sh"
fi

export CLASSPATH="${CLASSPATH}:${CATALINA_HOME}/lib/log4j-jul-${LOG4J_VERSION}.jar:${CATALINA_HOME}/lib/log4j-api-${LOG4J_VERSION}.jar:${CATALINA_HOME}/lib/log4j-core-${LOG4J_VERSION}.jar"
echo "CLASSPATH=\"${CLASSPATH}\""

CATALINA_OPTS="${CATALINA_OPTS} -Dconnector.compression='${CONNECTOR_COMPRESSION}'"
CATALINA_OPTS="${CATALINA_OPTS} -Dconnector.compressibleMimeType='${CONNECTOR_COMPRESSIBLE_MIME_TYPE}'"
CATALINA_OPTS="${CATALINA_OPTS} -Dconnector.connectionTimeout='${CONNECTOR_CONNECTION_TIMEOUT}'"
CATALINA_OPTS="${CATALINA_OPTS} -Dconnector.maxThreads='${CONNECTOR_MAX_THREADS}'"
CATALINA_OPTS="${CATALINA_OPTS} -Dconnector.protocol='${CONNECTOR_PROTOCOL}'"
CATALINA_OPTS="${CATALINA_OPTS} -Dconnector.proxyName='${CONNECTOR_PROXYNAME}'"
CATALINA_OPTS="${CATALINA_OPTS} -Dconnector.proxyPort='${CONNECTOR_PROXYPORT}'"
CATALINA_OPTS="${CATALINA_OPTS} -Dconnector.proxyScheme='${CONNECTOR_PROXYSCHEME}'"
CATALINA_OPTS="${CATALINA_OPTS} -Dconnector.proxySecure='${CONNECTOR_PROXYSECURE}'"
CATALINA_OPTS="${CATALINA_OPTS} -Dconnector.server='${CONNECTOR_SERVER}'"
CATALINA_OPTS="${CATALINA_OPTS} -Dconnector.trustedProxies='${CONNECTOR_TRUSTED_PROXIES}'"
CATALINA_OPTS="${CATALINA_OPTS} -Dcors.allowed.origins='${CORS_ALLOWED_ORIGINS}'"
CATALINA_OPTS="${CATALINA_OPTS} -Dcors.allowed.methods='${CORS_ALLOWED_METHODS}'"
CATALINA_OPTS="${CATALINA_OPTS} -Dcors.allowed.headers='${CORS_ALLOWED_HEADERS}'"
CATALINA_OPTS="${CATALINA_OPTS} -Dcors.exposed.headers='${CORS_EXPOSED_HEADERS}'"
CATALINA_OPTS="${CATALINA_OPTS} -Dcors.support.credentials='${CORS_SUPPORT_CREDENTIALS}'"
CATALINA_OPTS="${CATALINA_OPTS} -Dcors.preflight.maxage='${CORS_PREFLIGHT_MAXAGE}'"
CATALINA_OPTS="${CATALINA_OPTS} -Dgeonetwork.dir=${DATA_DIR}"
export CATALINA_OPTS

echo "CATALINA_OPTS=\"${CATALINA_OPTS}\""

# Create a named pipe for the access logs, and redirect anything that comes to it to stdout.
# This is in lieu of making the logs write to /dev/stdout (/proc/self/fd/1), which doesn't
# work for non-root users in docker.
# See: https://github.com/moby/moby/issues/6880#issuecomment-170214851
mkfifo -m 600 /tmp/logpipe
cat < /tmp/logpipe 2>&1 &

echo
