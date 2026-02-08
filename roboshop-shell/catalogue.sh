source common.sh

nodejs
app_presetup
mongodb_setup 

echo -e "${COL}Load $1 Schema to Mongodb${NC}"
mongo --host mongod-dev.devopspro789.store </app/schema/$1.js &>>${LOG}

systemd_setup