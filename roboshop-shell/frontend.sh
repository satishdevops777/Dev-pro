source common.sh
component=frontend

echo -e "${COL}Install Nginx${NC}"
sudo dnf install nginx -y &>>${LOG}

echo -e "${COL}Remove Default Web Content${NC}"
sudo rm -rf /usr/share/nginx/html/* &>>${LOG}

echo -e "${COL}Download Frontend Artifacts${NC}"
sudo curl -o /tmp/$component.zip https://roboshop-artifacts.s3.amazonaws.com/$component.zip &>>${LOG}

echo -e "${COL}Extract Frontend Content${NC}"
sudo unzip /tmp/$component.zip -d /usr/share/nginx/html &>>${LOG}

echo -e "${COL}Create Reverse Proxy Configuration${NC}"
sudo cp roboshop.conf /etc/nginx/default.d/roboshop.conf &>>${LOG}

echo -e "${COL}Enable & Restart Nginx Service${NC}"
sudo systemctl enable --now nginx &>>${LOG}
sudo systemctl restart nginx &>>${LOG}

echo -e "${COL}Frontend setup completed successfully${NC}"
