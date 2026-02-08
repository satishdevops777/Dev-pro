source common.sh

echo -e "${COL}Install Maven${NC}"
dnf install maven -y &>>${LOG}

echo -e "${COL}Add Application User${NC}"
useradd roboshop &>>${LOG} #Address if user already exists

echo -e "${COL}Create Application Directory${NC}"
mkdir /app &>>${LOG}

echo -e "${COL}Download Application Content${NC}"
curl -L -o /tmp/shipping.zip https://roboshop-artifacts.s3.amazonaws.com/shipping.zip &>>${LOG}
cd /app &>>${LOG}
unzip /tmp/shipping.zip &>>${LOG}

echo -e "${COL}Build Application${NC}"
mvn clean package &>>${LOG}
mv target/shipping-1.0.jar shipping.jar &>>${LOG}

echo -e "${COL}Setup SystemD Service${NC}"
cp shipping.service /etc/systemd/system/shipping.service &>>${LOG}


echo -e "${COL}Install Mysql Client${NC}"
dnf install mysql -y &>>${LOG}

echo -e "${COL}Load Shipping Schema to Mysql${NC}"
mysql --host=mysql-dev.devopspro789.store -uroot -pRoboShop@1 < /app/schema/shipping.sql &>>${LOG}

echo -e "${COL}Start Shipping Service${NC}"
systemctl daemon-reload &>>${LOG}
systemctl enable --now shipping &>>${LOG}
systemctl restart shipping &>>${LOG}


echo -e "${COL}shipping setup completed successfully${NC}"