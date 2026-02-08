source common.sh

nodejs
mongodb_setup 

echo -e "${COL}Load $1 Schema to Mongodb${NC}"
mongo --host mongod-dev.devpro18.store </app/schema/$1.js &>>${LOG}

systemd_setup