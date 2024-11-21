#! /bin/bash

# PSQL variable to interact with the database
PSQL="psql --username=freecodecamp --dbname=salon --no-align --tuples-only -c"

# Display the list of services
function display_services() {
  echo -e "\nWelcome to the Salon! Here are the services we offer:"
  
  # Fetch and display services
  SERVICES=$($PSQL "SELECT service_id, name FROM services ORDER BY service_id")
  echo "$SERVICES" | while IFS="|" read SERVICE_ID SERVICE_NAME
  do
    echo "$SERVICE_ID) $SERVICE_NAME"
  done
}

# Prompt the user to select a valid service
function prompt_service_selection() {
  while true
  do
    # Display services
    display_services

    # Prompt for service selection
    echo -e "\nPlease select a service by entering the corresponding number:"
    read SERVICE_ID_SELECTED

    # Validate the selected service
    SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED")
    if [[ -z $SERVICE_NAME ]]
    then
      echo -e "\nInvalid selection. Please try again."
    else
      break
    fi
  done
}

# Add a new customer if they don't exist
function handle_customer() {
  # Prompt for customer phone number
  echo -e "\nPlease enter your phone number:"
  read CUSTOMER_PHONE

  # Check if the customer exists
  CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE'")
  
  if [[ -z $CUSTOMER_NAME ]]
  then
    # If the customer doesn't exist, prompt for their name
    echo -e "\nYou are not in our system. Please enter your name:"
    read CUSTOMER_NAME

    # Add the new customer to the database
    INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")
  fi
}

# Schedule an appointment
function schedule_appointment() {
  # Prompt for appointment time
  echo -e "\nWhat time would you like your $SERVICE_NAME appointment?"
  read SERVICE_TIME

  # Get the customer_id
  CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")

  # Add the appointment to the database
  INSERT_APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")

  # Confirm the appointment
  echo -e "\nI have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
}

# Main script execution
prompt_service_selection
handle_customer
schedule_appointment
