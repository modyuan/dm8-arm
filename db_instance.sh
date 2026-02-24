#!/bin/bash
# create dmdb or start db when runing the container

set -e
echo "[Entrypoint]  Docker Image DM8"

DM_HOME=/opt/dmdbms/bin
dbcmd=/opt/dmdbms/bin/dmserver
export ARCH_FLAG=${ARCH_FLAG:-0}

function  create_db {
    echo "start create db..."
$DM_HOME/dminit path=${DATA_DIR} \
 CHARSET=${CHARSET:-1} \
 PAGE_SIZE=${PAGE_SIZE:-16} \
 CASE_SENSITIVE=${CASE_SENSITIVE:-1} \
 BLANK_PAD_MODE=${BLANK_PAD_MODE:-0} \
 ARCH_FLAG=${ARCH_FLAG:-0} \
 SYSDBA_PWD=${SYSDBA_PWD:-sysDBA123} \
 SYSAUDITOR_PWD=${SYSAUDITOR_PWD:-sysAUDITOR123}

if [ $ARCH_FLAG = 1 ];then
cat > /opt/data/DAMENG/dmarch.ini << EOF
[ARCHIVE_LOCAL1]
ARCH_TYPE = LOCAL
ARCH_DEST = /opt/data/arch
ARCH_FILE_SIZE = 256
ARCH_SPACE_LIMIT = 10240
ARCH_FLUSH_BUF_SIZE = 0
EOF
fi

echo "create db OK"
}

function  start_db {
    echo "init dm"
    "$dbcmd"  /opt/data/DAMENG/dm.ini -noconsole > /opt/dmdbms/log/DmServiceDM.log 2>&1
}


# Check whether the database exists
if [ -d $DATA_DIR/DAMENG ]; then
    echo "starting database";
        start_db;
   else
        create_db;
        start_db;
fi

# !!! tail on /dev/null and always runing (otherwise container will exit)
tail -f /dev/null
