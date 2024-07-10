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
    cp mongo.repo /etc/yum.repos.d/ &>> $LOGFILE
    VALIDATE $? "Setup the MongoDB repo file"

    yum install mongodb-org -y &>> $LOGFILE
    VALIDATE $? "Install MongoDB"

    systemctl enable mongod &>> $LOGFILE
    VALIDATE $? "enable mongod"

    systemctl start mongod &>> $LOGFILE
    VALIDATE $? "start mongod"

    cat /etc/mongod.conf|grep 127.0.0.1 &>> $LOGFILE
    if [ $? -eq 0 ];
    then
        sed -i "s/127.0.0.1/0.0.0.0/g" /etc/mongod.conf&>> $LOGFILE
        VALIDATE $? "Update listen address from 127.0.0.1 to 0.0.0.0"
    fi
    systemctl restart mongod &>> $LOGFILE
    VALIDATE $? "Restart the service"
fi