#!/bin/bash -x
# Make sure 3 replicas available
function checkparameters() {
  if [ "$#" -eq 0 ]; then
    mongonodes=( rs1 rs2 rs3 )
    echo no nodes definde as parameter
    echo using default nodes ${mongonodes[@]}
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
nodecount=${#mongonodes[*]}

#echo ${mongonodes[@]}
#echo ${mongonodes[*]}
#exit 0
# Connect to rs1 and check is replicaset already configured with 3 nodes
status=$(mongo --host ${mongonodes[0]} --quiet --eval 'rs.status().members.length')
if [ $? -ne 0 ]; then
  echo Replicaset not yet configured
  echo rs.initiate
  mongo --host ${mongonodes[0]} --eval 'rs.initiate()';
  echo rs.conf
  mongo --host ${mongonodes[0]} --eval 'rs.conf()';
  for (( rs=1; i<=${nodecount}; i++ ));
  do
    mongocmd="--host "${mongonodes[0]}" --eval 'rs.add(\""${mongonodes[$rs]}"\")';"
    echo $mongocmd
    mongo $mongocmd
    echo add node $rs
  done




fi
mongo --host ${mongonodes[0]} --eval 'rs.status().members.length';
mongo --host ${mongonodes[0]} --eval 'rs.status()';
exit 0
