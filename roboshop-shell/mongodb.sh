source common.sh
component=mongodb

echo -e " ${COL} Copy MongoDB Repo file  ${NC}"
cp /home/centos/roboshop-shell/mongodb.repo /etc/yum.repos.d/mongodb.repo   &>>${LOG}
stat_check $?

echo -e " ${COL} Installing MongoDB Server ${NC} "
yum install mongodb-org -y  &>>${LOG}
stat_check $?

echo -e " ${COL} Update MongoDB Listen Address ${NC} "
sed -i 's/127.0.0.1/0.0.0.0/' /etc/mongod.conf &>>${LOG}
stat_check $?

echo -e " ${COL} Start MongoDB Service ${NC} "
systemctl enable mongod  &>>${LOG}
systemctl restart mongod  &>>${LOG}
stat_check $?

