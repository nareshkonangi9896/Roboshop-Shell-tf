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
    yum install maven -y &>> $LOGFILE
    VALIDATE $? "Setup the Nodejs repo"

    getent passwd|grep roboshop &>> $LOGFILE
    if [ $? -ne 0 ]
    then
        useradd roboshop &>> $LOGFILE
        VALIDATE $? "adding roboshop user"
    fi
    ls /|grep app &>> $LOGFILE
    if [ $? -ne 0 ]
    then
        mkdir /app &>> $LOGFILE
        VALIDATE $? "creating app directory"
    fi
    curl -L -o /tmp/shipping.zip https://roboshop-builds.s3.amazonaws.com/shipping.zip &>> $LOGFILE
    VALIDATE $? "Download the application code"

    cd /app &>> $LOGFILE
    VALIDATE $? "Entering into app directory"

    unzip -o /tmp/shipping.zip &>> $LOGFILE
    VALIDATE $? "unziping the application code"

    mvn clean package&>> $LOGFILE
    VALIDATE $? "installing dependencies"

    mv target/shipping-1.0.jar shipping.jar
    VALIDATE $? "Moving jar file"

    cp /home/centos/Roboshop-Shell-tf/shipping.service /etc/systemd/system/&>> $LOGFILE
    VALIDATE $? "creating shipping service"

    systemctl daemon-reload &>> $LOGFILE
    VALIDATE $? "reloading shipping files"

    systemctl enable shipping &>> $LOGFILE
    VALIDATE $? "enabling shipping"

    systemctl start shipping &>> $LOGFILE
    VALIDATE $? "starting shipping" &>> $LOGFILE

    yum install mysql -y &>> $LOGFILE
    VALIDATE $? "installing mysql client"

    mysql -h mysql.nareshdevops.online -uroot -pRoboShop@1 < /app/schema/shipping.sql &>> $LOGFILE
    VALIDATE $? "Load Schema into mySQL"

    systemctl restart shipping &>> $LOGFILE
    VALIDATE $? "restart shipping"
fi