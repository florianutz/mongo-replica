#!/bin/bash
# Make sure 3 replicas available
function checkparameters() {
  if [ "$#" -eq 0 ]; then
    mongonodes=( rs1 rs2 rs3 )
    echo no nodes definde as parameter
    echo using default nodes $mongonodes
  else
    mongonodes=( "$@" )
    echo not default nodes
  fi
}

# Make sure all replicas available
function checknodes() {
  for rs in "${mongonodes[@]}";do
    mongo --host $rs --eval 'db'
    if [ $? -ne 0 ]; then
      exit 1
    fi
  done
}

checkparameters $@
checknodes
#echo ${mongonodes[@]}
#echo ${mongonodes[*]}
exit 0
# Connect to rs1 and check is replicaset already configured with 3 nodes
status=$(mongo --host ${mongonodes[0]} --quiet --eval 'rs.status().members.length')
if [ $? -ne 0 ]; then
  # Replicaset not yet configured
  mongo --host ${mongonodes[0]} --eval 'rs.initiate()';
  mongo --host ${mongonodes[0]} --eval 'rs.conf()';
  for rs in "${mongonodes[@]}";do
    mongo --host ${mongonodes[0]} --eval 'rs.add("$rs")';
  done
fi

exit 0
