#!/bin/bash
PSQL="psql -X --username=freecodecamp --dbname=number_guess --tuples-only -c"

RANDOM_NUMBER=$((1 + $RANDOM % 1000))
echo "Enter your username:"
read USERNAME
USER_ID=$($PSQL "SELECT user_id FROM users WHERE username = '$USERNAME'")
if [[ -z $USER_ID ]]
then
  echo "Welcome, $USERNAME! It looks like this is your first time here."
  INSERT_NEW_USER_RESULT=$($PSQL "INSERT INTO users(username) VALUES('$USERNAME')")
  USER_ID=$($PSQL "SELECT user_id FROM users WHERE username = '$USERNAME'")
else
  USER_HISTORY=$($PSQL "SELECT username,COUNT(game_id),MIN(total_guesses_to_win) FROM users FULL JOIN games USING (user_id) WHERE user_id = $USER_ID GROUP BY username")
  echo "$USER_HISTORY" | while IFS="|" read USERNAME GAMES_PLAYED BEST_GAME
  do
    echo "Welcome back, $(echo "$USERNAME" | sed 's/ //g')! You have played $(echo "$GAMES_PLAYED" | sed 's/ //g') games, and your best game took $(echo "$BEST_GAME" | sed 's/ //g') guesses."
  done
fi

TRIES=1
echo -e "\nGuess the secret number between 1 and 1000:"
read USER_GUESS
while [[ $USER_GUESS -ne $RANDOM_NUMBER ]]
do
  if ! [[ $USER_GUESS =~ ^[0-9]+$ ]]
  then
    echo "That is not an integer, guess again:"
    TRIES=$((TRIES-1))
  elif [[ $USER_GUESS -lt $RANDOM_NUMBER ]]
  then
    echo "It's higher than that, guess again:"
  else
    echo "It's lower than that, guess again:"
  fi
  TRIES=$((TRIES+1))
  read USER_GUESS
done
echo "You guessed it in $TRIES tries. The secret number was $RANDOM_NUMBER. Nice job!"
INSERT_NEW_GAME_RESULT=$($PSQL "INSERT INTO games(user_id,total_guesses_to_win) VALUES($USER_ID,$TRIES)")