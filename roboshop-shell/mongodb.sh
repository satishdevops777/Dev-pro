source common.sh

mongodb_setup

echo -e "${COL}Load update listen address${NC}"
sudo sed -i -e 's/127.0.0.1/0.0.0.0/' /etc/mongod.conf &>>${LOG}
systemd_setup 

