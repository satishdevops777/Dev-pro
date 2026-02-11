#!/bin/bash
set -e

COL="\e[32m"
NC="\e[0m"
LOG=/tmp/roboshop.log
user_id=$(id -u)

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
}

app_presetup () {
  add_user

  echo -e "${COL}Preparing application directory${NC}"
  mkdir -p /app &>>${LOG}
  rm -rf /app/*
  stat_check $?

  echo -e "${COL}Downloading application content${NC}"
  curl -L -o /tmp/$component.zip https://roboshop-artifacts.s3.amazonaws.com/$component.zip &>>${LOG}
  cd /app
  unzip /tmp/$component.zip &>>${LOG}
  stat_check $?

  echo -e "${COL}Setting up systemd service${NC}"
  cp /home/centos/Dev-pro/roboshop-shell/$component.service /etc/systemd/system/$component.service &>>${LOG}
}

systemd_setup () {
  systemctl daemon-reload &>>${LOG}
  systemctl enable --now $component &>>${LOG}
  systemctl restart $component &>>${LOG}
}

nodejs () {
  echo -e "${COL}Installing NodeJS${NC}"
  dnf module disable nodejs -y &>>${LOG}
  dnf module enable nodejs:18 -y &>>${LOG}
  dnf install nodejs unzip curl -y &>>${LOG}

  app_presetup

  echo -e "${COL}Installing NodeJS dependencies${NC}"
  npm install &>>${LOG}

  systemd_setup
}



mongodb_client_setup () {
  echo -e "${COL}Cpoying & Installing MongoDB Client${NC}"
  cp mongo.repo /etc/yum.repos.d/mongo.repo &>>${LOG}
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
  cp mysql.repo /etc/yum.repos.d/mysql.repo &>>${LOG}

  dnf install mysql-community-server -y &>>${LOG}
  systemctl enable --now mysqld &>>${LOG}

  mysql_secure_installation --set-root-pass RoboShop@1 &>>${LOG}
}

redis_setup () {
  echo -e "${COL}Installing Redis${NC}"
  dnf module disable redis -y &>>${LOG}
  dnf module enable redis:6 -y &>>${LOG}
  dnf install redis -y &>>${LOG}

  sed -i 's/127.0.0.1/0.0.0.0/' /etc/redis.conf &>>${LOG}
  systemctl enable --now redis &>>${LOG}
}

maven_setup () {
  echo -e "${COL}Installing Maven${NC}"
  dnf install maven unzip curl -y &>>${LOG}

  app_presetup
  mvn clean package &>>${LOG}

  systemd_setup
}

python_setup () {
  echo -e "${COL}Installing Python${NC}"
  dnf install python36 gcc python3-devel unzip curl -y &>>${LOG}

  app_presetup
  pip3.6 install -r requirements.txt &>>${LOG}

  systemd_setup
}

go_setup () {
  echo -e "${COL}Installing Golang${NC}"
  dnf install golang unzip curl -y &>>${LOG}

  app_presetup
  go mod init $component &>>${LOG}
  go get &>>${LOG}

  systemd_setup
}

rabbitmq_setup () {
  echo -e "${COL}Installing RabbitMQ${NC}"
  curl -s https://packagecloud.io/install/repositories/rabbitmq/erlang/script.rpm.sh | bash &>>${LOG}
  curl -s https://packagecloud.io/install/repositories/rabbitmq/rabbitmq-server/script.rpm.sh | bash &>>${LOG}

  dnf install rabbitmq-server -y &>>${LOG}
  systemctl enable --now rabbitmq-server &>>${LOG}

  rabbitmqctl add_user roboshop roboshop123 &>>${LOG} || true
  rabbitmqctl set_permissions -p / roboshop ".*" ".*" ".*" &>>${LOG}
}

echo -e "${COL}Setup completed for $component${NC}"