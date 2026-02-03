source common.sh

echo -e "${COL}Installing golang Service${NC}"
dnf install golang -y &>>${LOG} 

echo -e "${COL}Adding Application User${NC}"
useradd roboshop &>>${LOG} #Address if user already exists

echo -e "${COL}Creating Application Directory${NC}"
mkdir /app &>>${LOG}

echo -e "${COL}Downloading Application Content${NC}"
curl -L -o /tmp/dispatch.zip https://roboshop-artifacts.s3.amazonaws.com/dispatch.zip 
cd /app  &>>${LOG}
unzip /tmp/dispatch.zip &>>${LOG}

echo -e "${COL}Building Application${NC}"
go mod init dispatch  &>>${LOG}
go get &>>${LOG}
go build &>>${LOG}

echo -e "${COL}Setting up SystemD Service${NC}"
cp dispatch.service /etc/systemd/system/dispatch.service &>>${LOG}

echo -e "${COL}Starting Dispatch Service${NC}"
systemctl daemon-reload &>>${LOG}
systemctl enable --now dispatch &>>${LOG}
systemctl restart dispatch &>>${LOG}

echo -e "${COL}Dispatch setup completed successfully${NC}"