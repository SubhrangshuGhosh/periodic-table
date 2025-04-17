#!/bin/bash

# Check if an argument is provided
if [ -z "$1" ]; then
  echo "Please provide an element as an argument."
  exit 0
fi

# Set the PSQL command for querying the database
PSQL="psql --username=freecodecamp --dbname=periodic_table -t --no-align -c"

# Check if the input is a number (atomic number)
if [[ "$1" =~ ^[0-9]+$ ]]; then
  QUERY="SELECT elements.atomic_number, elements.name, elements.symbol, properties.atomic_mass, properties.melting_point_celsius, properties.boiling_point_celsius FROM elements JOIN properties USING (atomic_number) WHERE elements.atomic_number = $1"
else
  # Query the database for symbol or name
  QUERY="SELECT elements.atomic_number, elements.name, elements.symbol, properties.atomic_mass, properties.melting_point_celsius, properties.boiling_point_celsius FROM elements JOIN properties USING (atomic_number) WHERE elements.symbol = '$1' OR elements.name = '$1'"
fi

# Run the query and store the result
RESULT=$($PSQL "$QUERY")

# Check if the result is empty
if [ -z "$RESULT" ]; then
  echo "I could not find that element in the database."
else
  # Format the output properly
  IFS='|' read -r ATOMIC_NUMBER NAME SYMBOL ATOMIC_MASS MELTING_POINT BOILING_POINT <<< "$RESULT"
  echo "The element with atomic number $ATOMIC_NUMBER is $NAME ($SYMBOL). It's a nonmetal, with a mass of $ATOMIC_MASS amu. $NAME has a melting point of $MELTING_POINT celsius and a boiling point of $BOILING_POINT celsius."
fi
