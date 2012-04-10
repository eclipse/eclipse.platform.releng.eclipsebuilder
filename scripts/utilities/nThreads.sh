#!/usr/bin/env bash
PIDFILE=cc.pid
echo;
if [ -f ${PIDFILE} ] ; then
  PID=`cat ${PIDFILE}`
  nthreads=`ps -mp $PID | wc -l`
  echo "    Number of threads in wtp's CC process: $nthreads"
else
        echo "    PID file (${PIDFILE}) does not exist."
        echo "        Either CC not running, or PID file deleted"
fi
echo
