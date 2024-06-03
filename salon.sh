#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=salon -t -c"

echo -e "\n~~~~~ MY SALON ~~~~~\n"
echo -e "Welcome to My Salon, how can I help you?\n"

MAIN_MENU() {
  if [[ $1 ]]; then
    echo -e "\n$1"
  fi

  # Display the services
  echo -e "Here are the services we offer:"
  SERVICES=$($PSQL "SELECT service_id, name FROM services ORDER BY service_id;")
  echo "$SERVICES" | while read SERVICE_ID BAR SERVICE_NAME; do
    echo -e "$SERVICE_ID) $SERVICE_NAME"
  done

  # Prompt user to select a service
  echo -e "\nPlease enter the service_id of the service you want:"
  read SERVICE_ID_SELECTED

  # Check if the service ID exists
  SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED;")
  if [[ -z $SERVICE_NAME ]]; then
    MAIN_MENU "Invalid service_id. Please try again."
  else
    # Prompt for phone number
    echo -e "\nEnter your phone number:"
    read CUSTOMER_PHONE

    # Check if the customer exists
    CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE';")
    if [[ -z $CUSTOMER_ID ]]; then
      # If customer doesn't exist, prompt for name
      echo -e "\nEnter your name:"
      read CUSTOMER_NAME
      # Insert new customer
      INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers (name, phone) VALUES ('$CUSTOMER_NAME', '$CUSTOMER_PHONE');")
      CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE';")
    else
      CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE customer_id=$CUSTOMER_ID;")
    fi

    # Prompt for appointment time
    echo -e "\nEnter your preferred appointment time:"
    read SERVICE_TIME

    # Insert new appointment
    INSERT_APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments (customer_id, service_id, time) VALUES ($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME');")

    # Confirm the appointment
    echo -e "\nI have put you down for a $(echo $SERVICE_NAME | xargs) at $SERVICE_TIME, $(echo $CUSTOMER_NAME | xargs)."
  fi
}

# Run the main menu function
MAIN_MENU