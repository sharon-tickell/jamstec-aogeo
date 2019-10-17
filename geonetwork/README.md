### Tomcat Connector Environment Variables
See also: Tomcat connector documentation: https://tomcat.apache.org/tomcat-8.5-doc/config/http.html

- *CONNECTOR_COMPRESSIBLE_MIME_TYPE*

     A comma separated list of MIME types for which HTTP compression may be used.
     Sets the connector *compressibleMimeType* property.

- *CONNECTOR_COMPRESSION*

     'on' to allow HTTP/1.1 gzip compression for compressible MIME types.
     'force' to compress all responses regardless of MIME type.
     'off' to disable compression. (default)
     Sets the connector *compression* property

- *CONNECTOR_CONNECTION_TIMEOUT*

     The number of milliseconds this Connector will wait, after accepting a connection, for the request URI line to be presented.
     Sets the connector *connectionTimeout* property.

- *CONNECTOR_MAX_THREADS*

     The maximum number of simultaneous requests that this connector can handle.
     Sets the connector *maxThreads* property.

- *CONNECTOR_PROTOCOL*
   The protocol that tomcat should use to handle incoming traffic. The default value is *HTTP/1.1* which uses an auto-switching mechanism to select either a Java NIO based connector or an APR/native based connector.
   Sets the connector *protocol* property.

- *CONNECTOR_PROXYNAME*

   The hostname that the GeoNetwork application will be exposed at. If GeoNetwork is behind a reverse-proxy,
   then this should be the hostname of the reverse proxy webserver. Used when GeoNetwork is making absolute URLs.
   Sets the connector *proxyName* property.

- *CONNECTOR_PROXYPORT*

   The port that the GeoNetwork application will be exposed at. If GeoNetwork is behind a reverse-proxy,
   then this should be the listen port (80 or 443) of the reverse proxy webserver. Used when GeoNetwork is making absolute URLs.
   Sets the connector *proxyPort* property

- *CONNECTOR_PROXYSCHEME*

   The scheme ('http' or 'https') that the GeoNetwork application will be exposed at. If GeoNetwork is behind a reverse-proxy, then this should be the scheme for the reverse proxy webserver. Used when GeoNetwork is making absolute URLs.
   Sets the connector *scheme* property

- *CONNECTOR_PROXYSECURE*

   Set this to 'true' if GeoNetwork is behind a reverse proxy server that is handling SSL Termination (you should also set CONNECTOR_PROXYSCHEME to 'https' if this is 'true')
   Sets the connector *secure* property

- *CONNECTOR_TRUSTED_PROXIES*

   Regular expression (using java.util.regex) that a proxy's IP address must match to be considered an trusted proxy.
   Requests that have a client IP matching a trusted proxy will use the IP from the X-FORWARDED-FOR header in logs, so
   that you can see where they really come from. If not specified, no proxies will be trusted.
   See also: the trustedProxies setting on the tomcat Remote IP Filter at https://tomcat.apache.org/tomcat-8.5-doc/config/filter.html#Remote_IP_Filter

   For the docker-compose file in this repository, you can run `docker network inspect jamstec-aogeo_default` to
   find out the subnet IP.  You can trust all IPs in this subnet.

   In production, you should set this to a pipe-separated list of the IP addresses of your reverse proxy servers or
   load balancers.



### Tomcat CORS Environment Variables
See also: Tomcat CORS Filter documentation: https://tomcat.apache.org/tomcat-8.5-doc/config/filter.html#CORS_Filter

- *CORS_ALLOWED_ORIGINS*

     A list of origins that are allowed to access the resource. A * can be specified to enable access to resource from any origin. Otherwise, a whitelist of comma separated origins can be provided.
     Sets the *cors.allowed.origins* filter property.

- *CORS_ALLOWED_METHODS*

     A comma separated list of HTTP methods that can be used to access the resource, using cross-origin requests.
     Sets the *cors.allowed.methods* filter property.

- *CORS_ALLOWED_HEADERS*

     A comma separated list of request headers that can be used when making an actual request.
     Sets the *cors.allowed.headers* filter property.

- *CORS_EXPOSED_HEADERS*

     A comma separated list of headers other than simple response headers that browsers are allowed to access.
     Sets the *cors.exposed.headers* filter property.

- *CORS_PREFLIGHT_MAXAGE*

     The amount of seconds a browser is allowed to cache the result of a CORS pre-flight request.
     Sets the *cors.preflight.maxage* filter property.

- *CORS_SUPPORT_CREDENTIALS*

     A flag that indicates whether the resource supports user credentials.  Set this to 'true' to allow
     cross-origin authentication, but ONLY if CORS_ALLOWED_ORIGINS is restricted.
     Sets the *cors.support.credentials* filter property.


### GeoNetwork Environment Variables
- *DATA_DIR*

     Absolute path to the directory that GeoNetwork should keep its custom configuration and cache files in.
     You should mount a persistent volume to this path.

- *POSTGRES_DB_HOST*

     The hostname for the PostgreSQL or PostGIS database server where GeoNetwork expects to find
     its configuration database.

- *POSTGRES_DB_PORT*

     The port that *POSTGRES_DB_HOST* is listening for connections on.

- *POSTGRES_DB_ADMIN*

     The name of the administration database.

- *POSTGRES_DB_NAME*

     The name of the postgres database that GeoNetwork should keep its configuration and metadata records in.

- *POSTGRES_DB_PASSWORD*

     The password that geonetwork should use to connect to *POSTGRES_DB_NAME*.  You must set either this or *POSTGRES_DB_PASSWORD_FILE*

- *POSTGRES_DB_PASSWORD_FILE*

     Absolute path to a file inside the container that contains *POSTGRES_DB_PASSWORD*.  This is a more secure way of configuring the
     password when running a docker container, because the password setting is not in the process arguments.
     You should mount your secrets file to this location.

- *POSTGRES_DB_USERNAME*

     The username that GeoNetwork should use to connect to *POSTGRES_DB_NAME*.

