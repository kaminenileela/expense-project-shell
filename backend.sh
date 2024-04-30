#!/bin/bash

USERID=$(id -u)
TIMESTAMP=$(date +%F-%H-%M-%S)
SCRIPT_NAME=$(echo $0 | cut -d "." -f1)
LOGFILE=/tmp/$SCRIPT_NAME-$TIMESTAMP.log
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

echo "Enter Password:"
read -s PASSWORD

VALIDATE(){

if [ $1 -ne 0 ]
then
    echo -e "$2...$R FAILURE $N"
    exit 1
else
    echo -e "$2...$G SUCCESS $N"
fi

}

if [ $USERID -ne 0 ]
then
    echo "Please run script with super user access"
    exit 2
else
    echo "You are super user"
fi

dnf module disable nodejs -y &>>$LOGFILE
VALIDATE $? "Disabling default nodejs"

dnf module enable nodejs:20 -y &>>$LOGFILE
VALIDATE $? "Enabling nodejs version 20"

dnf install nodejs -y &>>$LOGFILE
VALIDATE $? "Installing nodejs"

id expense &>>$LOGFILE

if [ $? -ne 0 ]
then
    useradd expense &>>$LOGFILE
    VALIDATE $? "creating expense user"
else
     echo -e "Expense user already created ... $Y SKIPPING $N"
fi

mkdir -p /app &>>$LOGFILE
VALIDATE $? "creating app directory"

curl -o /tmp/backend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-backend-v2.zip &>>$LOGFILE
VALIDATE $? "downloading backend code"

cd /app

unzip /tmp/backend.zip &>>$LOGFILE
VALIDATE $? "Extracted backend code"

npm install &>>$LOGFILE
VALIDATE $? "installing nodejs dependencies"

cp /home/ec2-user/expense-project-shell/backend.service /etc/systemd/system/backend.service
VALIDATE $? "copied backend service"

systemctl daemon-reload &>>$LOGFILE
VALIDATE $? "Daemon Reload"
systemctl start backend &>>$LOGFILE
systemctl enable backend &>>$LOGFILE
VALIDATE $? "Starting and Enabling backend"

dnf install mysql -y &>>$LOGFILE
VALIDATE $? "Installing mysql client"


mysql -h db.learningdevopsaws.online -uroot -p$PASSWORD < /app/schema/backend.sql &>>$LOGFILE
VALIDATE $? "Schema loading"


systemctl restart backend &>>$LOGFILE
VALIDATE $? "restaring backend"