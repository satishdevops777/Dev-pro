source common.sh

nodejs

app_presetup

echo -e "${COL}Install Application Dependencies${NC}"
npm install &>>${LOG}

systemd_setup