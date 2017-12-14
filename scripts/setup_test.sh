#!/bin/bash
# ----------------------------------------------------------------------
# Trivadis AG, Infrastructure Managed Services
# Saegereistrasse 29, 8152 Glattbrugg, Switzerland
# ----------------------------------------------------------------------
# Name.......: setup_oudbase.sh 
# Author.....: Stefan Oehrli (oes) stefan.oehrli@trivadis.com
# Editor.....: Stefan Oehrli
# Date.......: 2017.09.22
# Revision...: 
# Purpose....: Setup script for docker oudbase image 
# Notes......: Will download oudbase from githup 
# Reference..: --
# License....: CDDL 1.0 + GPL 2.0
# ----------------------------------------------------------------------
# Modified...: 
# see git revision history for more information on changes/updates
# TODO.......: 
# ----------------------------------------------------------------------

# get the MOS Credentials
TEST_USER="${1#*=}"
TEST_PASSWORD="${2#*=}"

echo "--- Setup Docker Test -----------------------------------------------"
echo "My TEST_USER=>$TEST_USER"
echo "My TEST_PASSWORD=>$TEST_PASSWORD"
echo "---------------------------------------------------------------------"
# Download and Package Variables
# OUD BASE
OUDBASE_URL="https://github.com/oehrlis/oudbase/raw/master/build/oudbase_install.sh"
OUDBASE_PKG="oudbase_install.sh"

# define environment variables
export ORACLE_ROOT=/u00             # oracle root directory
export ORACLE_DATA=/u01             # oracle data directory
export ORACLE_BASE=/u00/app/oracle  # oracle base directory
export JAVA_DIR=/usr/java           # java home location
export DOWNLOAD=/tmp/download       # temporary download directory
export ORACLE_HOME_NAME="fmw12.2.1.3.0"
mkdir -p $DOWNLOAD
chmod 777 $DOWNLOAD

echo "--- Setup Oracle OFA environment -----------------------------------------------"
echo "--- Create groups for Oracle software"
# create oracle groups
groupadd --gid 1000 oinstall
groupadd --gid 1010 osdba
groupadd --gid 1020 osoper
groupadd --gid 1030 osbackupdba
groupadd --gid 1040 oskmdba
groupadd --gid 1050 osdgdba

echo "--- Create user oracle"
# create oracle user
useradd --create-home --gid oinstall --shell /bin/bash \
    --groups oinstall,osdba,osoper,osbackupdba,osdgdba,oskmdba \
    oracle

echo "--- Create OFA directory structure"
# create oracle directories
mkdir -p $ORACLE_ROOT
mkdir -p $ORACLE_DATA
mkdir -p $ORACLE_BASE
mkdir -p $ORACLE_DATA/etc
mkdir -p $ORACLE_BASE/local
mkdir -p $ORACLE_BASE/product

echo "--- Create response and inventory loc files"
# create an oraInst.loc file
echo "inventory_loc=$ORACLE_BASE/oraInventory" > $ORACLE_DATA/etc/oraInst.loc
echo "inst_group=oinstall" >> $ORACLE_DATA/etc/oraInst.loc

# create a generic response file for OUD/WLS
echo "[ENGINE]" > $ORACLE_DATA/etc/install.rsp
echo "Response File Version=1.0.0.0.0" >> $ORACLE_DATA/etc/install.rsp
echo "[GENERIC]" >> $ORACLE_DATA/etc/install.rsp
echo "DECLINE_SECURITY_UPDATES=true" >> $ORACLE_DATA/etc/install.rsp
echo "SECURITY_UPDATES_VIA_MYORACLESUPPORT=false" >> $ORACLE_DATA/etc/install.rsp

# change permissions and ownership
chmod a+xr $ORACLE_ROOT $ORACLE_DATA
chown oracle:oinstall -R $ORACLE_BASE $ORACLE_DATA

echo "--- Upgrade OS and install additional Packages ---------------------------------"
# update existing packages
#yum upgrade -y

# install basic packages util-linux, libaio 
#yum install -y libaio util-linux procps-ng hostname which unzip zip tar sudo

# add oracle to the sudoers
#echo "oracle  ALL=(ALL)   NOPASSWD: ALL" >>/etc/sudoers

# OUD Base package if it does not exist /tmp/download
#if [ ! -e $DOWNLOAD/$OUDBASE_PKG ]
#then
#    echo "--- Download OUD Base package from github --------------------------------------"
#    curl --cookie-jar $DOWNLOAD/cookie-jar.txt \
#    --location-trusted $OUDBASE_URL -o $DOWNLOAD/$OUDBASE_PKG
#else
#    echo "--- Use local copy of $DOWNLOAD/$OUDBASE_PKG -----------------------------------"
#fi
#
#echo "--- Install OUD Base scripts ---------------------------------------------------"
## Install OUD Base scripts
#chmod 755 $DOWNLOAD/$OUDBASE_PKG
#sudo -u oracle $DOWNLOAD/$OUDBASE_PKG -v -b /u00/app/oracle -d $ORACLE_DATA

# clean up
echo "--- Clean up yum cache and temporary download files ----------------------------"
yum clean all
rm -rf /var/cache/yum
rm -rf $DOWNLOAD
echo "=== Done runing $0 ==================================="