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
    yum install https://rpms.remirepo.net/enterprise/remi-release-8.rpm -y &>> $LOGFILE
    VALIDATE $? "Redis repo Install"

    yum module enable redis:remi-6.2 -y &>> $LOGFILE
    VALIDATE $? "Enable Redis Version"

    yum install redis -y  &>> $LOGFILE
    VALIDATE $? "Install redis"

    cat /etc/redis.conf|grep 127.0.0.1 &>> $LOGFILE
    if [ $? -eq 0 ];
    then
        sed -i "s/127.0.0.1/0.0.0.0/g" /etc/redis.conf&>> $LOGFILE
        VALIDATE $? "Update listen address from 127.0.0.1 to 0.0.0.0"
    fi

    cat /etc/redis/redis.conf|grep 127.0.0.1 &>> $LOGFILE
    if [ $? -eq 0 ];
    then
        sed -i "s/127.0.0.1/0.0.0.0/g" /etc/redis/redis.conf&>> $LOGFILE
        VALIDATE $? "Update listen address from 127.0.0.1 to 0.0.0.0"
    fi

    systemctl enable redis &>> $LOGFILE
    VALIDATE $? "enable redis"

    systemctl start redis &>> $LOGFILE
    VALIDATE $? "start redis"

fi