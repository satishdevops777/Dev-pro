source common.sh

maven_setup

echo -e "${COL}Install Mysql Client${NC}"
dnf install mysql -y &>>${LOG}

echo -e "${COL}Load Shipping Schema to Mysql${NC}"
mysql --host=mysql-dev.devopspro789.store -uroot -pRoboShop@1 < /app/schema/shipping.sql &>>${LOG}

systemd_setup
