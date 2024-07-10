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
    curl -sL https://rpm.nodesource.com/setup_lts.x | bash &>> $LOGFILE
    VALIDATE $? "Setup the Nodejs repo"

    yum install nodejs -y &>> $LOGFILE
    VALIDATE $? "Install nodejs"

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
    curl -L -o /tmp/cart.zip https://roboshop-builds.s3.amazonaws.com/cart.zip &>> $LOGFILE
    VALIDATE $? "Download the application code"

    cd /app &>> $LOGFILE
    VALIDATE $? "Entering into app directory"

    unzip -o /tmp/cart.zip &>> $LOGFILE
    VALIDATE $? "unziping the application code"

    npm install &>> $LOGFILE
    VALIDATE $? "installing dependencies"

    cp /home/centos/Roboshop-Shell/cart.service /etc/systemd/system/ &>> $LOGFILE
    VALIDATE $? "creating cart.service"

    systemctl daemon-reload &>> $LOGFILE
    VALIDATE $? "reloading service files"

    systemctl enable cart &>> $LOGFILE
    VALIDATE $? "enabling cart"

    systemctl start cart &>> $LOGFILE
    VALIDATE $? "starting cart" &>> $LOGFILE
fi