#!/bin/bash
set -e

COL="\e[32m"
NC="\e[0m"
LOG=/tmp/roboshop.log
user_id=$(id -u)
component=$1


if [ $user_id -ne 0 ]; then
  echo Script should be running with sudo
  exit 1
fi

stat_check() {
  if [ $1 -eq 0 ]; then
    echo SUCCESS
  else
    echo FAILURE
    exit 1
  fi
}

if [ -z "$component" ]; then
  echo "Usage: $0 <component-name>"
  exit 1
fi

echo -e "${COL}Starting setup for $component${NC}"

add_user () {
  if ! id roboshop &>>${LOG}; then
    useradd -r roboshop &>>${LOG}
  fi
  stat_check $?
}

app_presetup () {
  add_user

  echo -e "${COL}Preparing application directory${NC}"
  rm -rf /app/*
  mkdir -p /app 
 
  echo -e "${COL}Downloading application content${NC}"
  curl -L -o /tmp/$component.zip https://roboshop-artifacts.s3.amazonaws.com/$component.zip &>>${LOG}
  stat_check $?

  echo -e "${COL}Unzipping application content${NC}"
  cd /app
  unzip /tmp/$component.zip &>>${LOG}
  stat_check $?

  echo -e "${COL}Setting up systemd service${NC}"
  cp /home/centos/Dev-pro/roboshop-shell/$component.service /etc/systemd/system/$component.service &>>${LOG}
  stat_check $?
}

systemd_setup () {
  systemctl daemon-reload &>>${LOG}
  systemctl enable --now $component &>>${LOG}
  systemctl restart $component &>>${LOG}
  stat_check $?
}

nodejs () {
  echo -e "${COL}Installing NodeJS${NC}"
  dnf module disable nodejs -y &>>${LOG}
  stat_check $?

  dnf module enable nodejs:18 -y &>>${LOG}
  stat_check $?

  dnf install nodejs unzip curl -y &>>${LOG}
  stat_check $?

  app_presetup

  echo -e "${COL}Installing NodeJS dependencies${NC}"
  npm install &>>${LOG}
  stat_check $?

  systemd_setup
}



mongodb_client_setup () {
  echo -e "${COL}Cpoying & Installing MongoDB Client${NC}"
  cp /home/centos/Dev-pro/roboshop-shell/mongodb.repo /etc/yum.repos.d/mongodb.repo &>>${LOG}
  stat_check $?

  dnf install mongodb-org-shell -y &>>${LOG}
  stat_check $?

  echo -e "${COL}Load $component Schema to Mongodb${NC}"
  mongo --host mongodb-dev.devpro18.online </app/schema/$component.js &>>${LOG}
  stat_check $?
}


mysql_setup () {
  echo -e "${COL}Installing MySQL${NC}"
  dnf module disable mysql -y &>>${LOG}
  stat_check $?

  echo -e "${COL}copying MySQL repo${NC}"
  cp /home/centos/Dev-pro/roboshop-shell/mysql.repo /etc/yum.repos.d/mysql.repo &>>${LOG}
  stat_check $?

  dnf install mysql-community-server -y &>>${LOG}
  stat_check $?

  systemctl enable --now mysqld &>>${LOG}
  stat_check $? 

  mysql_secure_installation --set-root-pass RoboShop@1 &>>${LOG}
  stat_check $?
}

redis_setup () {
  echo -e "${COL}Installing Redis${NC}"
  dnf module disable redis -y &>>${LOG}
  stat_check $?

  dnf module enable redis:6 -y &>>${LOG}
  stat_check $?

  dnf install redis -y &>>${LOG}
  stat_check $?

  sed -i 's/127.0.0.1/0.0.0.0/' /etc/redis.conf &>>${LOG}
  systemctl enable --now redis &>>${LOG}
  stat_check $?
}

maven_setup () {
  echo -e "${COL}Installing Maven${NC}"
  dnf install maven unzip curl -y &>>${LOG}
  stat_check $? 

  app_presetup
  mvn clean package &>>${LOG}
  mv target/shipping-1.0.jar shipping.jar 
  stat_check $?

  systemd_setup
}

python_setup () {
  echo -e "${COL}Installing Python${NC}"
  dnf install python36 gcc python3-devel unzip curl -y &>>${LOG}
  stat_check $?

  app_presetup
  pip3.6 install -r requirements.txt &>>${LOG}
  stat_check $?

  systemd_setup
}

go_setup () {
  echo -e "${COL}Installing Golang${NC}"
  dnf install golang unzip curl -y &>>${LOG}
  stat_check $?

  app_presetup
  go mod init $component &>>${LOG}
  stat_check $?

  go get &>>${LOG}
  stat_check $?

  systemd_setup
}

rabbitmq_setup () {
  echo -e "${COL}Installing RabbitMQ${NC}"
  curl -s https://packagecloud.io/install/repositories/rabbitmq/erlang/script.rpm.sh | bash &>>${LOG}
  stat_check $?

  curl -s https://packagecloud.io/install/repositories/rabbitmq/rabbitmq-server/script.rpm.sh | bash &>>${LOG}
  stat_check $?

  dnf install rabbitmq-server -y &>>${LOG}
  stat_check $?

  systemctl enable --now rabbitmq-server &>>${LOG}
  stat_check $?

  rabbitmqctl add_user roboshop roboshop123 &>>${LOG} || true
  stat_check $?

  rabbitmqctl set_permissions -p / roboshop ".*" ".*" ".*" &>>${LOG}
  stat_check $?
}

echo -e "${COL}Setup completed for $component${NC}"