#!/bin/bash
set -e

# ---------- Colors ----------
COL="\e[32m"
RED="\e[31m"
NC="\e[0m"

echo -e "${COL}Auto Shell Roboshop${NC}"

# ---------- Argument validation ----------
if [ $# -ne 2 ]; then
  echo -e "${RED}Usage:${NC} $0 <component> <ssh-password>"
  echo "Example: $0 frontend DevOps321"
  exit 1
fi

# ---------- Variables ----------
COMPONENT="$1"
PASSWORD="$2"
HOST="${COMPONENT}-dev.devopspro789.online"
REMOTE_PATH="/tmp/${COMPONENT}.sh"

# ---------- Function ----------
run_script() {
  echo "--------------------------------------"
  echo "Component : $COMPONENT"
  echo "Host      : $HOST"
  echo "--------------------------------------"

  if [ ! -f "${COMPONENT}.sh" ]; then
    echo -e "${RED}ERROR:${NC} ${COMPONENT}.sh not found in current directory"
    exit 1
  fi

  echo "Copying script to remote host..."
  sshpass -p "$PASSWORD" scp "${COMPONENT}.sh" roboshop.conf centos@"${HOST}":/tmp/

  echo "Executing script on remote host..."
  sshpass -p "$PASSWORD" ssh centos@"${HOST}" "
    chmod +x ${REMOTE_PATH} &&
    cd /tmp && bash "${COMPONENT}.sh"
  "

  echo -e "${COL}SUCCESS:${NC} ${COMPONENT} script executed on ${HOST}"
}

# ---------- Run ----------
run_script
