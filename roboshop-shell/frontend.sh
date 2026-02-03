#!/bin/bash 
set -e

COL="\e[32m"
NC="\e[0m"

echo -e "${COL}Install Nginx${NC}"
dnf install nginx -y &>>/tmp/roboshop.log

echo -e "${COL}Remove Default Web Content${NC}"
rm -rf /usr/share/nginx/html/*

echo -e "${COL}Download Frontend Artifacts${NC}"
curl -o /tmp/frontend.zip https://roboshop-artifacts.s3.amazonaws.com/frontend.zip &>>/tmp/roboshop.log

echo -e "${COL}Extract Frontend Content${NC}"
cd /usr/share/nginx/html &>>/tmp/roboshop.log
unzip /tmp/frontend.zip &>>/tmp/roboshop.log


echo -e "${COL}Create Reverse Proxy Configuration${NC}"
cp roboshop.conf /etc/nginx/default.d/roboshop.conf &>>/tmp/roboshop.log

echo -e "${COL}Enable & Restart Nginx Service${NC}"
systemctl enable nginx &>>/tmp/roboshop.log
systemctl restart nginx &>>/tmp/roboshop.log