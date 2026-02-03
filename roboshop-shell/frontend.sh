#!/bin/bash
set -e

COL="\e[32m"
NC="\e[0m"
LOG=/tmp/roboshop.log

echo -e "${COL}Install Nginx${NC}"
sudo dnf install nginx -y &>>${LOG}

echo -e "${COL}Remove Default Web Content${NC}"
sudo rm -rf /usr/share/nginx/html/* &>>${LOG}

echo -e "${COL}Download Frontend Artifacts${NC}"
sudo curl -o /tmp/frontend.zip https://roboshop-artifacts.s3.amazonaws.com/frontend.zip &>>${LOG}

echo -e "${COL}Extract Frontend Content${NC}"
sudo unzip /tmp/frontend.zip -d /usr/share/nginx/html &>>${LOG}

echo -e "${COL}Create Reverse Proxy Configuration${NC}"
sudo cp roboshop.conf /etc/nginx/default.d/roboshop.conf &>>${LOG}

echo -e "${COL}Enable & Restart Nginx Service${NC}"
sudo systemctl enable --now nginx &>>${LOG}
sudo systemctl restart nginx &>>${LOG}

echo -e "${COL}Frontend setup completed successfully${NC}"
