#! /bin/bash

PSQL="psql --username=freecodecamp --dbname=salon --tuples-only -c"

SERVICES_MENU(){
  #get services 
  SERVICES=$($PSQL "SELECT service_id, name FROM services")

  #display services
  echo "$SERVICES" | while read SERVICE_ID BAR NAME 
  do
    if [[ $SERVICE_ID != 'service_id' ]]
    then
      echo "$SERVICE_ID) $NAME"
    fi
  done

  #ask for a service
  echo -e "\nChoose a service"
  read SERVICE_ID_SELECTED

  #check if the service exist 
  CORRESPONDING_SERVICE_ID=$($PSQL "SELECT service_id FROM services WHERE service_id = $SERVICE_ID_SELECTED")
  if [[ -z $CORRESPONDING_SERVICE_ID ]]
  then 
    SERVICES_MENU
  else 
    #ask for phone number 
    echo -e "\nPlease enter your phone number:"
    read CUSTOMER_PHONE
    CORRESPONDING_CUSTOMER_PHONE=$($PSQL "SELECT phone FROM customers WHERE phone ='$CUSTOMER_PHONE'")

    #check if the customer already exist 
    if [[ -z $CORRESPONDING_CUSTOMER_PHONE ]]
    then 
      echo -e "\nPlease enter your name to register you as a new client"
      read CUSTOMER_NAME

      #add the new customer in the DB
      ADD_CUSTOMER=$($PSQL "INSERT INTO customers(name, phone) VALUES('$CUSTOMER_NAME', '$CUSTOMER_PHONE')")
      
      #get the customer id
      CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")

      #Ask for the service time
      echo -e "\nAt what time do you want this service"
      read SERVICE_TIME

      #add the appointment
      ADD_APPOINTMENT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")
      SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED")
      echo -e "\nI have put you down for a $(echo $SERVICE_NAME | sed -r 's/^ *| *$//g') at $(echo $SERVICE_TIME | sed -r 's/^ *| *$//g'), $(echo $CUSTOMER_NAME | sed -r 's/^ *| *$//g')."
    
    else
      #get customer id
      CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")

      #Ask for the service time
      echo -e "\nAt what time do you want this service"
      read SERVICE_TIME

      #add the appointment
      ADD_APPOINTMENT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")
      SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED")
      CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE'")
      echo -e "\nI have put you down for a $(echo $SERVICE_NAME | sed -r 's/^ *| *$//g') at $(echo $SERVICE_TIME | sed -r 's/^ *| *$//g'), $(echo $CUSTOMER_NAME | sed -r 's/^ *| *$//g')."
    fi
  fi
}

SERVICES_MENU