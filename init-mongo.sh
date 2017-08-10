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
  masternode=${mongonodes[0]}
  slavenodes=${mongonodes[@]}
  unset slavenodes[0]
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

setupreplica() {
  echo Replicaset not yet configured
  echo rs.initiate
  mongo --host $masternode --eval 'rs.initiate()';
  echo rs.conf
  mongo --host $masternode --eval 'rs.conf()';
  #for (( rs=1; rs<${nodecount}; rs++ ));
  for rs in "${slavenodes[@]}"
  do
    # mongocmd="--host "${mongonodes[0]}" --eval 'rs.add(\""$rs"\")';"
    mongocmd="--host $masternode --eval 'rs.add($rs)';"
    echo $mongocmd
    mongo $mongocmd
    echo add node $rs
  done
}

checkparameters $@
checknodes
nodecount=${#mongonodes[*]}

#echo ${mongonodes[@]}
#echo ${mongonodes[*]}
#exit 0
# Connect to rs1 and check is replicaset already configured with 3 nodes
status=$(mongo --host $masternode --quiet --eval 'rs.status().members.length')
if [ $? -ne 0 ]; then
  setupreplica
fi

if [ $status -ne $nodecount ]; then
  setupreplica
fi
echo status ist $status
mongo --host $masternode --eval 'rs.status().members.length';
mongo --host $masternode --eval 'rs.status()';
exit 0
