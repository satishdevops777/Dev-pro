#!/bin/bash
set -e

LOG=/tmp/tools-install.log
COL="\e[32m"
NC="\e[0m"

echo -e "${COL}Starting installation of Git, Ansible, Terraform${NC}"

# ---------- Git ----------
echo -e "${COL}Installing Git${NC}"
dnf install git -y &>>${LOG}

# ---------- Ansible ----------
echo -e "${COL}Installing Ansible${NC}"
dnf install epel-release -y &>>${LOG}
dnf install ansible -y &>>${LOG}

# ---------- Terraform ----------
echo -e "${COL}Installing Terraform${NC}"
dnf install yum-utils -y &>>${LOG}
yum-config-manager --add-repo https://rpm.releases.hashicorp.com/RHEL/hashicorp.repo &>>${LOG}
dnf install terraform -y &>>${LOG}

# ---------- Verify ----------
echo -e "${COL}Verifying installations${NC}"
git --version
ansible --version | head -n 1
terraform version

echo -e "${COL}All tools installed successfully${NC}"
