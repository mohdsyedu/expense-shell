#!/bin/bash


USERID=$(id -u) # Here we fetches the user id of the current user if sudo then it is '0' else any other number

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
LOGS_FOLDER="/var/log/shell-mysql-logs"
LOG_FILE=$(echo $0 | cut -d "." -f1 )
TIMIESTAMP=$(date +%Y-%m-%d-%H-%M-%S) # yyyy/mm/dd/HRS/MIN/SEC
LOG_FILE_NAME="$LOGS_FOLDER/$LOG_FILE-$TIMIESTAMP.log" # this is the folder name follwed by logfile with timestamp

# Valicdation function for success or faliure message
VALIDATE()
{
    if [ $1 -ne 0 ]
    then 
       echo -e "$2 INSTALLATION....$R IS FAILURE $N"
       exit 1 # After executing the above statement return with exit status as 1 other than 0  which is "failure"
    else 
       echo -e "$2 INSTALLATION IS $G SUCCESS $N"
    fi # End of If
}


CHECKROOT(){


   if [ $USERID -ne 0 ]
    then
            echo "ERROR:: you must have sudo access to execute this script"
            exit 1 # if ther than 0
    fi

}

echo "Script stat=rted executing at $TIMIESTAMP" &>>$LOG_FILE_NAME

CHECKROOT

dnf install mysql-server -y &&>>$LOG_FILE_NAME
VALIDATE $? "my-sql server installing..." 

systemctl enable mysqld &&>>$LOG_FILE_NAME
VALIDATE $? "Enabling mysql server..."

systemctl start mysqld &&>>$LOG_FILE_NAME
VALIDATE $? "Starting mysql server..."

mysql_secure_installation --set-root-pass ExpenseApp@1 &&>>$LOG_FILE_NAME
VALIDATE $? "Setting Root Password..."
