#!/bin/bash

LOGDIR=/tmp
SCRIPT_NAME=$0
DATE=$(date +%F:%H:%M:%S)
LOGFILE=$LOGDIR/$SCRIPT_NAME-$DATE.log
R="\e[31m"
G="\e[32m"
N="\e[0m"
Y="\e[33m"
VALIDATE(){
    if [ $1 -ne 0 ]
    then
        echo -e " $2.....$R FAILURE $N"
        exit 1
    else
        echo -e " $2.....$G SUCCESS $N"
    fi
}
USERID=$(id -u)
if [ $USERID -ne 0 ];
then
    echo -e "$R ERROR : Please run this script as a ROOT user $N"
    exit 1
else
    curl -s https://packagecloud.io/install/repositories/rabbitmq/erlang/script.rpm.sh | bash &>> $LOGFILE
    VALIDATE $? "Configure YUM Repos"

    curl -s https://packagecloud.io/install/repositories/rabbitmq/rabbitmq-server/script.rpm.sh | bash &>> $LOGFILE
    VALIDATE $? "Configure YUM Repos for RabbitMQ"

    yum install rabbitmq-server -y  &>> $LOGFILE
    VALIDATE $? "Install rabbitmq"

    systemctl enable rabbitmq-server &>> $LOGFILE
    VALIDATE $? "enable rabbitmq"

    systemctl start rabbitmq-server &>> $LOGFILE
    VALIDATE $? "start rabbitmq"

    sudo rabbitmqctl list_users|grep roboshop &>> $LOGFILE
    if [ $? -ne 0 ]
    then
        rabbitmqctl add_user roboshop roboshop123 &>> $LOGFILE
        VALIDATE $? "adding roboshop user for rabbitmq"
    fi

    rabbitmqctl set_permissions -p / roboshop ".*" ".*" ".*" &>> $LOGFILE
    VALIDATE $? "Giving permissions to roboshop user"
fi