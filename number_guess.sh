#!/bin/bash

# Generate a random number between 1 and 1000
secret_number=$(( RANDOM % 1000 + 1 ))

# PSQL variable to make queries easier
PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

# Prompt user for username
echo "Enter your username:"
read username

# Check if the username already exists in the database
user_check=$($PSQL "SELECT username FROM users WHERE username = '$username';")

if [[ -z $user_check ]]; then
  # If username does not exist, welcome and notify it's their first time
  echo "Welcome, $username! It looks like this is your first time here."
  games_played=0
  best_game="N/A"
  
  # Insert new user into the database
  $($PSQL "INSERT INTO users (username) VALUES ('$username');")
else
  # If username exists, retrieve games played and best game
  user_info=$($PSQL "SELECT games_played, best_game FROM users WHERE username = '$username';")
  games_played=$(echo $user_info | cut -d '|' -f 1)
  best_game=$(echo $user_info | cut -d '|' -f 2)
  echo "Welcome back, $username! You have played $games_played games, and your best game took $best_game guesses."
fi

# Start the guessing game
echo "Guess the secret number between 1 and 1000:"
guess_count=0
while true; do
  read guess
  guess_count=$((guess_count + 1))

  # Check if the guess is an integer
  if ! [[ "$guess" =~ ^[0-9]+$ ]]; then
    echo "That is not an integer, guess again:"
    continue
  fi

  # Check if the guess is too low, too high, or correct
  if (( guess < secret_number )); then
    echo "It's higher than that, guess again:"
  elif (( guess > secret_number )); then
    echo "It's lower than that, guess again:"
  else
    echo "You guessed it in $guess_count tries. The secret number was $secret_number. Nice job!"
    
    # Update the user's stats in the database
    new_games_played=$((games_played + 1))
    
    # If the current game is the user's best, update the best_game
    if [[ "$best_game" == "N/A" || $guess_count -lt $best_game ]]; then
      $($PSQL "UPDATE users SET games_played = $new_games_played, best_game = $guess_count WHERE username = '$username';")
    else
      $($PSQL "UPDATE users SET games_played = $new_games_played WHERE username = '$username';")
    fi
    
    break
  fi
done
# This is a comment to trigger a new commit
# This is a comment to trigger a new commit2
