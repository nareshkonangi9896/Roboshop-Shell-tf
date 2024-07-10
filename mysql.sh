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
    yum module disable mysql -y  &>> $LOGFILE
    VALIDATE $? "Disabling existing mysql in system"

    cp mysql.repo /etc/yum.repos.d/  &>> $LOGFILE
    VALIDATE $? "Copying mysql repo"

    yum install mysql-community-server -y &>> $LOGFILE
    VALIDATE $? "Installing mysql server"

    systemctl enable mysqld &>> $LOGFILE
    VALIDATE $? "enable mysqld"

    systemctl start mysqld &>> $LOGFILE
    VALIDATE $? "start mysqld"

    mysql_secure_installation --set-root-pass RoboShop@1 &>> $LOGFILE
    VALIDATE $? "Setting Root password for Root user"
fi