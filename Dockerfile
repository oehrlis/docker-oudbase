# ----------------------------------------------------------------------
# Trivadis AG, Infrastructure Managed Services
# Saegereistrasse 29, 8152 Glattbrugg, Switzerland
# ----------------------------------------------------------------------
# Name.......: Dockerfile 
# Author.....: Stefan Oehrli (oes) stefan.oehrli@trivadis.com
# Editor.....: 
# Date.......: 
# Revision...: 
# Purpose....: Dockerfile to build OUD image
# Notes......: --
# Reference..: --
# License....: CDDL 1.0 + GPL 2.0
# ----------------------------------------------------------------------
# Modified...:
# see git revision history for more information on changes/updates
# TODO.......:
# --
# ----------------------------------------------------------------------

# Pull base image
# ----------------------------------------------------------------------
FROM oraclelinux:7-slim

# Maintainer
# ----------------------------------------------------------------------
LABEL maintainer="stefan.oehrli@trivadis.com"

# Arguments for MOS Download
ARG MOS_USER
ARG MOS_PASSWORD

# Arguments for MOS Download
ARG TEST_USER
ARG TEST_PASSWORD

# Arguments for Oracle Installation
ARG ORACLE_ROOT
ARG ORACLE_DATA
ARG ORACLE_BASE

# Environment variables required for this build (do NOT change)
# -------------------------------------------------------------
ENV DOWNLOAD="/tmp/download" \
    DOCKER_SCRIPTS="/opt/docker/bin" \
    START_SCRIPT="start_OUD_Instance.sh" \
    CHECK_SCRIPT="check_OUD_Instance.sh" \
    ORACLE_HOME_NAME="fmw12.2.1.3.0" \
    ORACLE_ROOT=${ORACLE_ROOT:-/u00} \
    ORACLE_DATA=${ORACLE_DATA:-/u01} \
    LDAP_PORT=${LDAP_PORT:-1389} \
    LDAPS_PORT=${LDAPS_PORT:-1636} \
    REP_PORT=${REP_PORT:-8989} \
    ADMIN_PORT=${ADMIN_PORT:-4444}

# Use second ENV so that variable get substituted
ENV ORACLE_BASE=${ORACLE_BASE:-$ORACLE_ROOT/app/oracle} \
    OUD_INSTANCE_BASE=${OUD_INSTANCE_BASE:-$ORACLE_DATA/instances}

# same same but third ENV so that variable get substituted
ENV PATH=${PATH}:"${ORACLE_BASE}/product/${ORACLE_HOME_NAME}/oud/bin"

# copy all setup scripts to DOCKER_BIN
COPY scripts ${DOCKER_SCRIPTS}
COPY software ${DOWNLOAD}

RUN ${DOCKER_SCRIPTS}/setup_test.sh TEST_USER=${TEST_USER} TEST_PASSWORD=${TEST_PASSWORD}

# Java and OUD base environment setup via shell script to reduce layers and 
# optimize final disk usage
#RUN ${DOCKER_SCRIPTS}/setup_java.sh MOS_USER=${MOS_USER} MOS_PASSWORD=${MOS_PASSWORD} && \
#    ${DOCKER_SCRIPTS}/setup_oudbase.sh

# Switch to user oracle, oracle software as to be installed with regular user
USER oracle

# Instal OUD / OUDSM via shell script to reduce layers and optimize final disk usage
#RUN ${DOCKER_SCRIPTS}/setup_oud.sh MOS_USER=${MOS_USER} MOS_PASSWORD=${MOS_PASSWORD}

# OUD admin and ldap ports as well the OUDSM console
#EXPOSE ${LDAP_PORT} ${LDAPS_PORT} ${ADMIN_PORT} ${REP_PORT}

# run container health check
#HEALTHCHECK --interval=1m --start-period=5m \
#   CMD "${DOCKER_SCRIPTS}/${CHECK_SCRIPT}" >/dev/null || exit 1

# Oracle data volume for OUD instance and configuration files
VOLUME ["${ORACLE_DATA}"]

# set workding directory
WORKDIR "${ORACLE_BASE}"

# Define default command to start OUD instance
#CMD exec "${DOCKER_SCRIPTS}/${START_SCRIPT}"
# --- EOF --------------------------------------------------------------