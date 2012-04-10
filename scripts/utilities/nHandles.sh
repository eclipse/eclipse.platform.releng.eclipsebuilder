#!/usr/bin/env bash
PIDFILE=cc.pid
echo;
if [ -f ${PIDFILE} ] ; then
  PID=`cat ${PIDFILE}`
  # I've found lsof is in /user/sbin on some machines
  nhandles=`/usr/bin/lsof -p $PID | wc -l`
  echo "    Number of handles in wtp's CC process: $nhandles"
else
  echo "    PID file (${PIDFILE}) does not exist."
  echo "        Either CC not running, or PID file deleted"
fi
echo
