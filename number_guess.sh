#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"
# Program to guess a random number

# generate random number
SECRET_NUMBER=$((1 + $RANDOM % 1000))

# ask for username
echo "Enter your username:"
read USERNAME

# query database
IFS='|' read PLAYED BEST <<< $($PSQL "SELECT games_played, best_game FROM users WHERE username='$USERNAME';")

# welcome message
if [[ -n $PLAYED ]]
then
echo "Welcome back, $USERNAME! You have played $PLAYED games, and your best game took $BEST guesses."
else
echo "Welcome, $USERNAME! It looks like this is your first time here."
fi

# count guess and tries
GUESS=0
TRIES=0

echo -e "Guess the secret number between 1 and 1000:"

# while guess not equal to secret number
while [[ $NUMBER_CHOOSED != $SECRET_NUMBER ]]
do
# increase tries count
((TRIES++))
# read input
read NUMBER_CHOOSED

# if is not an integer
if [[ ! $NUMBER_CHOOSED =~ ^[0-9]+$ ]]
then
echo "That is not an integer, guess again:"
else
if [[ $NUMBER_CHOOSED -gt $SECRET_NUMBER ]]
then
echo "It's lower than that, guess again:"
elif [[ $NUMBER_CHOOSED -lt $SECRET_NUMBER ]]
then
echo "It's higher than that, guess again:"
else
echo "You guessed it in $TRIES tries. The secret number was $SECRET_NUMBER. Nice job!"
fi
fi

done

# update database
if [[ -n $PLAYED ]]
then
# update existing user
NEW_PLAYED=$(($PLAYED + 1))
NEW_BEST=$BEST
if [[ $TRIES -lt $BEST ]]
then NEW_BEST=$TRIES
fi
UPDATE_RESULT=$($PSQL "UPDATE users SET games_played=$NEW_PLAYED, best_game=$NEW_BEST WHERE username='$USERNAME';")
else
# insert new user
INSERT_RESULT=$($PSQL "INSERT INTO users(username, games_played, best_game) VALUES ('$USERNAME', 1, $TRIES);")
fi
