#!/bin/bash
set -ex

POSTGRES_USER="${POSTGRES_USER:-postgres}"
POSTGRES_DB="${POSTGRES_DB:-postgres}"

function ensure_database(){
  local DATABASE="${1}"
  local USERNAME="${2}"
  local PASSWORD="${3}"
  if [ -z "${DATABASE}" ] || [ -z "${USERNAME}" ] || [ -z "${PASSWORD}" ]; then
    echo "Database, Username and Password are all required:  DATABASE='${DATABASE}', USERNAME='${USERNAME}', PASSWORD='${PASSWORD}'"
    return 1
  fi
  echo "SELECT 'CREATE ROLE ${USERNAME}' WHERE NOT EXISTS(SELECT FROM pg_roles WHERE rolname = '${USERNAME}')\gexec" | psql --username "${POSTGRES_USER}" --dbname "${POSTGRES_DB}"
  echo "SELECT 'CREATE DATABASE ${DATABASE}' WHERE NOT EXISTS (SELECT FROM pg_database WHERE datname = '${DATABASE}')\gexec" | psql --username "${POSTGRES_USER}" --dbname "${POSTGRES_DB}"
  psql --username "${POSTGRES_USER}" --dbname "${POSTGRES_DB}" -c "ALTER ROLE ${USERNAME} WITH LOGIN;"
  psql --username "${POSTGRES_USER}" --dbname "${POSTGRES_DB}" -c "ALTER USER ${USERNAME} WITH PASSWORD '${PASSWORD}';"
  psql --username "${POSTGRES_USER}" --dbname "${POSTGRES_DB}" -c "GRANT ALL PRIVILEGES ON DATABASE ${DATABASE} TO ${USERNAME};"
}

GN_PASSWORD=$(cat "${GEONETWORK_PASSWORD_FILE}" | sed 's/^[[:blank:]]*//;s/[[:blank:]]*$//')
ensure_database "${GEONETWORK_DATABASE}" "${GEONETWORK_USERNAME}" "${GN_PASSWORD}"

KC_PASSWORD=$(cat "${KEYCLOAK_PASSWORD_FILE}" | sed 's/^[[:blank:]]*//;s/[[:blank:]]*$//')
ensure_database "${KEYCLOAK_DATABASE}" "${KEYCLOAK_USERNAME}" "${KC_PASSWORD}"
