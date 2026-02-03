#!/bin/bash
set -e

COL="\e[32m"
NC="\e[0m"

echo -e "${COL}Auto Shell Roboshop${NC}"

# $1 → component name (frontend, cart, user, etc.)
# $2 → SSH password

run_script() {
  COMPONENT=$1
  PASSWORD=$2
  HOST="${COMPONENT}-dev.devopspro789.online"

  echo "Running script on $HOST"

  sshpass -p "$PASSWORD" scp ${COMPONENT}.sh centos@${HOST}:/tmp/

  sshpass -p "$PASSWORD" ssh centos@${HOST} "
    chmod +x /tmp/${COMPONENT}.sh && bash /tmp/${COMPONENT}.sh
  "
}

run_script "$1" "$2"
