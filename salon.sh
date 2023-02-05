#! /bin/bash

PSQL="psql -t --username=freecodecamp --dbname=salon -c "

MAIN_MENU() {
  # Output the message
  if [[ $1 ]]
  then
    echo "$1"
  fi
  
  LIST_OF_SERVICES=$($PSQL "SELECT service_id, name FROM services")
  if [[ -z $LIST_OF_SERVICES ]]
  then 
    echo -e "\nList of servises is empty!\n"
  else
    echo -e "\nSelect the service you need:\n"
    echo "$LIST_OF_SERVICES" | while read SERVICE_ID BAR SERVICE
    do
      echo "$SERVICE_ID) $SERVICE"
    done
    read SERVICE_ID_SELECTED
    SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED")
    echo $SERVICE_NAME
    if [[ -z $SERVICE_NAME ]]
    then
      MAIN_MENU "There aren't the service, you selected"
    else 
      echo -e "\nEnter your phone number"
      read CUSTOMER_PHONE
      CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE'")
      if [[ -z $CUSTOMER_NAME ]]
      then
        # Add a new customer
        echo -e "\nIt looks like you are not our customer, please enter your name"
        read CUSTOMER_NAME
        CUSTOMER_ADD_RESULT=$($PSQL "INSERT INTO customers (phone, name) VALUES ('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")
        if [[ $CUSTOMER_ADD_RESULT == 'INSERT 0 1' ]]
        then
          echo -e "\n You have added as a new customer"
        else
          echo -e "\nSomething went wrong with message: $CUSTOMER_ADD_RESULT"
        fi
      fi
      # Book date and time
      echo -e "\nWhat time you want to be booked, $CUSTOMER_NAME?"
      read SERVICE_TIME
      CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")
      if [[ -z $CUSTOMER_ID ]]
      then
        echo -e "\nSomething went wrong while customer_id responding"
      fi 
      APPOINTMENT_CREATED=$($PSQL "INSERT INTO appointments (customer_id, service_id, time) VALUES ($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME') ") 
      if [[ $APPOINTMENT_CREATED == 'INSERT 0 1' ]]
      then
        echo -e "\nI have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
      else
        echo -e "\nSomething went wrong with message: $CUSTOMER_ADD_RESULT"
      fi
    fi
  fi
  
}

MAIN_MENU 
