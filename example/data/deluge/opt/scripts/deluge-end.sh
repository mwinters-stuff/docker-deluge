#!/bin/bash
cd /scripts
# Change this if you wish to log the verification
LOG_FILE=/scripts/deluge-end.log
export HOME=/config
TR_TORRENT_ID=$1
TR_TORRENT_NAME=$2
TR_TORRENT_DIR=$3
touch $LOG_FILE
echo "RUN: $@" >> $LOG_FILE
echo "TR_TORRENT_DIR=${TR_TORRENT_DIR}" >> $LOG_FILE
echo "TR_TORRENT_ID=${TR_TORRENT_ID}"  >> $LOG_FILE
echo "TR_TORRENT_NAME=${TR_TORRENT_NAME}" >> $LOG_FILE


function startTorrent {
  echo "Re-Starting ${TR_TORRENT_NAME}" >> $LOG_FILE
  deluge-console -c /config/ start ${TR_TORRENT_ID} >> $LOG_FILE
}

function stopTorrent {
  echo "Stopping ${TR_TORRENT_NAME}" >> $LOG_FILE
  deluge-console -c /config/ pause ${TR_TORRENT_ID} >> $LOG_FILE
}

function deleteTorrent {
  echo "Deleting ${TR_TORRENT_NAME}" >> $LOG_FILE
  deluge-console -c /config/ rm --confirm --remove_data ${TR_TORRENT_ID} >> $LOG_FILE
  # deluge-console -c /opt/deluge/config/ rm --remove_data ${TR_TORRENT_ID} >> $LOG_FILE
}


echo "Processing ${TR_TORRENT_NAME}" >> $LOG_FILE

stopTorrent

find "${TR_TORRENT_DIR}" -name "*.nfo" -delete
find "${TR_TORRENT_DIR}" -name "*.txt" -delete
find "${TR_TORRENT_DIR}" -name "*.exe" -delete

TEMPLOG=/tmp/nmamer$$.log

echo "about to mnamer ${TR_TORRENT_DIR}/${TR_TORRENT_NAME}" >> $LOG_FILE
# /usr/local/bin/tvr -r -l DEBUG --config=/opt/deluge/scripts/tvrconfig.yml --log-file=/opt/logs/tvrenamer.log ${TR_TORRENT_DIR}/${TR_TORRENT_NAME} >> $LOG_FILE
/usr/local/bin/mnamer --no-style "${TR_TORRENT_DIR}/${TR_TORRENT_NAME}" > $TEMPLOG
tvrrv=$?
cat $TEMPLOG >>  $LOG_FILE
echo "RESULT $tvrrv" >> $LOG_FILE
if [ $tvrrv -eq 0 ]
then
  grep -i "processed successfully" $TEMPLOG >> $LOG_FILE
  if [ $? -eq 0 ]
  then
    echo "Rename Success  ${TR_TORRENT_DIR}" >> $LOG_FILE
    deleteTorrent
    /usr/bin/curl "http://192.168.1.3:32400/library/sections/4/refresh?X-Plex-Token=dqG18RQoR2FMWqUX2pTT" >> $LOG_FILE 2>&1 
  else
    echo "Rename Failed" >> $LOG_FILE
    echo "RUN: $@" >> $LOG_FILE
  fi
else
  echo "Rename Failed ${tvrrv} ${TR_TORRENT_DIR}/${TR_TORRENT_NAME}" >> $LOG_FILE
fi
