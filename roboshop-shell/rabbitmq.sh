source common.sh

echo -e "${COL}Configure YUM Repos from the script${NC}"
curl -s https://packagecloud.io/install/repositories/rabbitmq/erlang/script.rpm.sh | bash &>>${LOG}

echo -e "${COL}Configure YUM Repos for RabbitMQ${NC}"
curl -s https://packagecloud.io/install/repositories/rabbitmq/rabbitmq-server/script.rpm.sh | bash &>>&{LOG}

echo -e "${COL}Install RabbitMQ Server${NC}"
dnf install rabbitmq-server -y &>>&{LOG}

echo -e "${COL}Enable & Start RabbitMQ Service${NC}"
systemctl enable --now rabbitmq-server &>>&{LOG}
systemctl start rabbitmq-server &>>&{LOG}

echo -e "${COL}Add Application User to RabbitMQ${NC}"
rabbitmqctl add_user roboshop roboshop123 &>>&{LOG}
rabbitmqctl set_permissions -p / roboshop ".*" ".*" ".*" &>>&{LOG}

echo -e "${COL}RabbitMQ setup completed successfully${NC}" 