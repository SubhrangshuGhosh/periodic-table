#!/bin/bash

# Database file path (change this if needed)
DB_FILE="number_guessing_game.db"

# Create the database if it doesn't exist
if [ ! -f "$DB_FILE" ]; then
  sqlite3 $DB_FILE "CREATE TABLE users (id INTEGER PRIMARY KEY, username TEXT UNIQUE);"
  sqlite3 $DB_FILE "CREATE TABLE games (id INTEGER PRIMARY KEY, user_id INTEGER, guesses INTEGER, FOREIGN KEY(user_id) REFERENCES users(id));"
fi

# Function to get user data
get_user_data() {
  local username=$1
  user_data=$(sqlite3 $DB_FILE "SELECT id FROM users WHERE username='$username';")
  echo "$user_data"
}

# Function to get games played and best game for returning user
get_user_game_stats() {
  local user_id=$1
  games_played=$(sqlite3 $DB_FILE "SELECT COUNT(*) FROM games WHERE user_id=$user_id;")
  best_game=$(sqlite3 $DB_FILE "SELECT MIN(guesses) FROM games WHERE user_id=$user_id;")
  echo "$games_played $best_game"
}

# Prompt for username
echo "Enter your username:"
read username

# Check if the username exists
user_id=$(get_user_data "$username")

if [ -z "$user_id" ]; then
  # New user
  echo "Welcome, $username! It looks like this is your first time here."
  # Insert the new user into the database
  sqlite3 $DB_FILE "INSERT INTO users (username) VALUES ('$username');"
  user_id=$(sqlite3 $DB_FILE "SELECT id FROM users WHERE username='$username';")
else
  # Returning user
  echo "Welcome back, $username!"
  # Get user stats (games played, best game)
  stats=$(get_user_game_stats "$user_id")
  games_played=$(echo "$stats" | awk '{print $1}')
  best_game=$(echo "$stats" | awk '{print $2}')
  echo "You have played $games_played games, and your best game took $best_game guesses."
fi

# Start the number guessing game
secret_number=$((RANDOM % 1000 + 1))
guess_count=0
valid_guess=false

echo "Guess the secret number between 1 and 1000:"

while ! $valid_guess; do
  read guess
  ((guess_count++))

  # Check if the guess is a valid integer
  if ! [[ "$guess" =~ ^[0-9]+$ ]]; then
    echo "That is not an integer, guess again:"
  elif [ "$guess" -lt "$secret_number" ]; then
    echo "It's higher than that, guess again:"
  elif [ "$guess" -gt "$secret_number" ]; then
    echo "It's lower than that, guess again:"
  else
    # Print the success message
    echo "You guessed it in $guess_count tries. The secret number was $secret_number. Nice job!"
    valid_guess=true
    # Record the game result in the database
    sqlite3 $DB_FILE "INSERT INTO games (user_id, guesses) VALUES ($user_id, $guess_count);"
  fi
done
