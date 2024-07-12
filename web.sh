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

    yum install nginx -y &>> $LOGFILE
    VALIDATE $? "Install nginx"

    systemctl enable nginx &>> $LOGFILE
    VALIDATE $? "enabling nginx"

    systemctl start nginx &>> $LOGFILE
    VALIDATE $? "starting nginx"

    rm -rf /usr/share/nginx/html/* &>> $LOGFILE
    VALIDATE $? "removing default content"

    curl -o /tmp/web.zip https://roboshop-builds.s3.amazonaws.com/web.zip &>> $LOGFILE
    VALIDATE $? "Download the application code"

    cd /usr/share/nginx/html &>> $LOGFILE
    VALIDATE $? "Entering into html directory"

    unzip -o /tmp/web.zip &>> $LOGFILE
    VALIDATE $? "unziping the application code"

    cp /home/centos/Roboshop-Shell-tf/roboshop.conf /etc/nginx/default.d/ &>> $LOGFILE
    VALIDATE $? "creating roboshop.conf "

    systemctl restart nginx &>> $LOGFILE
    VALIDATE $? "restarting nginx"
fi