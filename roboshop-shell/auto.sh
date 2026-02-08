for component in catalogue cart user shipping payment frontend mongodb mysql rabbitmq redis dispatch; do
  #systemctl status ${component}
  bash ${component}.sh ${component}
done