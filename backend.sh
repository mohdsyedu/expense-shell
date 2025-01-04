#!/bin/bash

USERID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

LOGS_FOLDER="/var/log/shell-backend-logs"
LOG_FILE=$(echo $0 | cut -d "." -f1 )
TIMESTAMP=$(date +%Y-%m-%d-%H-%M-%S)
LOG_FILE_NAME="$LOGS_FOLDER/$LOG_FILE-$TIMESTAMP.log"

VALIDATE(){
    if [ $1 -ne 0 ]
    then
        echo -e "$2 ... $R FAILURE $N"
        exit 1
    else
        echo -e "$2 ... $G SUCCESS $N"
    fi
}

CHECK_ROOT(){
    if [ $USERID -ne 0 ]
    then
        echo "ERROR:: You must have sudo access to execute this script"
        exit 1 #other than 0
    fi
}

CHECK_DETAILS(){
    if [ $USERID -eq 0 ]
    then
        echo "ERROR:: You must have sudo access to execute this script"
        exit 1 #other than 0
    fi
}

# mkdir -p $LOGS_FOLDER
# echo "Script started executing at: $TIMESTAMP" &>>$LOG_FILE_NAME

CHECK_ROOT


dnf module disable nodejs -y &>>$LOG_FILE_NAME
VALIDATE $? "Disabling existing default nodejs"

dnf module enable nodejs:20 -y &>>$LOG_FILE_NAME
VALIDATE $? "Enabling version 20 of node js"

dnf install nodejs -y &>>$LOG_FILE_NAME
VALIDATE $? "Installing the Node JS"

useradd expense &>>$LOG_FILE_NAME
VALIDATE $? "Adding Expense user"

mkdir /app &>>$LOG_FILE_NAME
VALIDATE $? "Creating App directory"

curl -o /tmp/backend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-backend-v2.zip &>>$LOG_FILE_NAME
VALIDATE $? "Downloading backend App"

cd /app 
VALIDATE $? "Moving to created App Directory"

unzip /tmp/backend.zip &>>$LOG_FILE_NAME
VALIDATE $? "Unzip the downloaded zip App"

npm install &>>$LOG_FILE_NAME
VALIDATE $? "Installing dependencies"

cp /home/ec2-user/expense-shell/backend.service /etc/systemd/system/backend.service 

# Preparing mysql schemas

dnf install mysql -y &>>$LOG_FILE_NAME
VALIDATE $? "Installing mysql client"

mysql -h mysql.gasikav82s.site  -uroot -pExpenseApp@1 < /app/schema/backend.sql  &>>$LOG_FILE_NAME
VALIDATE $? "setting up the transactoins Shema and tables"

systemctl daemon-reload &>>$LOG_FILE_NAME
VALIDATE $? "Daemon Reload"

systemctl enable backend &>>$LOG_FILE_NAME
VALIDATE $? "Enabling backend"

systemctl start backend &>>$LOG_FILE_NAME
VALIDATE $? "Starting backend"





