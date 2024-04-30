#!/bin/bash

USERID=$(id -u)
TIMESTAMP=$(date +%F-%H-%M-%S)
SCRIPT_NAME=$(echo $0 | cut -d "." -f1)
LOGFILE=/tmp/$SCRIPT_NAME-$TIMESTAMP.log
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

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

dnf install mysql-server -y &>> $LOGFILE
VALIDATE $? "Installing MYSQL server"

systemctl enable mysqld  &>>$LOGFILE
VALIDATE $? "Enabling MYSQL server"

systemctl start mysqld &>>$LOGFILE
VALIDATE $? "Starting MYSQL server"

#mysql_secure_installation --set-root-pass ExpenseApp@1 &>>$LOGFILE
#VALIDATE $? "Setting up root password"

#Below code will be useful for idempotent nature
mysql -h db.learningdevopsaws.online -uroot -pExpenseApp@1 -e 'SHOW DATABASES;' &>>$LOGFILE

if [ $? -ne 0 ]
then
   mysql_secure_installation --set-root-pass ExpenseApp@1 &>>$LOGFILE
   VALIDATE $? "Setting up root password"

else
    echo -e "Mysql password already setup... $Y SKIPPING $N"
fi
   
   