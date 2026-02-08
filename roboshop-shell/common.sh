#!/bin/bash
set -e

COL="\e[32m"
NC="\e[0m"
LOG=/tmp/roboshop.log


nodejs () {
  echo -e "${COL}Enable nodejs repo${NC}"
  dnf module disable nodejs -y &>>${LOG}
  dnf module enable nodejs:18 -y &>>${LOG}

  echo -e "${COL}Install nodejs${NC}"
  dnf install nodejs -y &>>${LOG}

  app_presetup

  echo -e "${COL}Install Application Dependencies${NC}"
  npm install &>>${LOG}
}

add_user () {
  echo -e "${COL}Add Application User${NC}"
  if ! id roboshop &>>${LOG}; then
    useradd roboshop &>>${LOG} 
  else 
    echo -e "${COL}User roboshop already exists${NC}"
  fi
}

app_presetup () {
  add_user
  echo -e "${COL}Create Application Directory${NC}"
  mkdir /app &>>${LOG}

  echo -e "${COL}Download Application Content${NC}"
  curl -L -o /tmp/$1.zip https://roboshop-artifacts.s3.amazonaws.com/$1.zip 
  cd /app &>>${LOG}
  unzip /tmp/$1.zip &>>&${LOG}

  echo -e "${COL}Setup SystemD Service${NC}"
  cp $1.service /etc/systemd/system/$1.service &>>${LOG}
}

mongodb_setup () {
  echo -e "${COL}Add Mongodb Repo File${NC}"
  cp mongod.repo /etc/yum.repos.d/mongod.repo &>>${LOG}

  echo -e "${COL}Install Mongodb${NC}"
  sudo dnf install mongodb-org -y  &>>${LOG}
}

mysql_setup() {
  echo -e "${COL}Enable $1 repo${NC}"
  dnf module disable $1 -y &>>${LOG}   

  echo -e "${COL}Add $1 repo file${NC}"
  cp $1.repo /etc/yum.repos.d/$1.repo &>>${LOG}

  echo -e "${COL}Install $1 Server${NC}"
  dnf install $1-community-server -y &>>${LOG}

  echo -e "${COL}Enable & Start $1 Service${NC}"
  systemctl enable --now mysqld &>>${LOG}
  systemctl start mysqld &>>${LOG}
 
  echo -e "${COL}Reset $1 root password${NC}"
  mysql_secure_installation --set-root-pass RoboShop@1 &>>${LOG}

  echo -e "${COL}Validate $1 Installation${NC}"
  mysql -uroot -pRoboShop@1 -e "show databases;" &>>${LOG} 
}

redis_setup() {
echo -e "${COL}Enable $1 repo${NC}"
dnf module disable $1 -y &>>${LOG}
dnf module enable $1:6 -y &>>${LOG}

echo -e "${COL}Install $1${NC}"
dnf install $1 -y &>>${LOG}  

echo -e "${COL}Update $1 Configuration to listen on all interfaces${NC}"
sed -i -e 's/127.0.0.0/0.0.0.0/' /etc/$1.conf /etc/$1/$1.conf &>>${LOG}
}


maven_setup() {
  echo -e "${COL}Install Maven${NC}"
  dnf install maven -y &>>${LOG}

  app_presetup
}

python_setup() {
echo -e "${COL}Install Python 3.6 and dependencies${NC}"
dnf install python36 gcc python3-devel -y &>>${LOG}

app_presetup

echo -e "${COL}Install Application Dependencies${NC}"
pip3.6 install -r requirements.txt &>>${LOG}
}

go_setup() {
  echo -e "${COL}Install Golang${NC}"
  dnf install golang -y &>>${LOG}

  app_presetup

  echo -e "${COL}Download Go Dependencies${NC}"
  go mod init dispatch &>>${LOG}
  go get &>>${LOG}
}

systemd_setup () {
  echo -e "${COL}Start $1 Service${NC}"
  systemctl daemon-reload &>>${LOG}
  systemctl enable --now $1 &>>${LOG}
  systemctl restart $1 &>>${LOG}
}



