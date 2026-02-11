source common.sh

maven_setup

echo -e "${COL}Install Mysql Client${NC}"
dnf install mysql -y &>>${LOG}
stat_check $?

echo -e "${COL}Load Shipping Schema to Mysql${NC}"
mysql --host=mysql-dev.devpro18.online -uroot -pRoboShop@1 < /app/schema/shipping.sql &>>${LOG}
stat_check $?

systemd_setup
