#!/bin/bash

# if [[ $1 == "test" ]]
# then
#   PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
# else
#   PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
# fi

# Do not change code above this line. Use the PSQL variable above to query your database.

# Add executable permissions
# chmod +x queries.sh
# chmod +x insert_data.sh

# PSQL="psql -X --username=freecodecamp --dbname=students --no-align --tuples-only -c"
PSQL="psql -X --username=postgres --dbname=worldcup --no-align --tuples-only -c"

echo $($PSQL "TRUNCATE TABLE games, teams RESTART IDENTITY CASCADE")

cat games.csv | while IFS="," read YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS; do
    if [[ $YEAR != "year" ]]; then

        # get team ids winner_id and opponent_id
        # get winner_id
        WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'")

        # if winner_id not found
        if [[ -z $WINNER_ID ]]; then
            # insert team_id
            INSERT_WINNER_ID_RESULT=$($PSQL "INSERT INTO teams(name) VALUES('$WINNER')")
            if [[ $INSERT_WINNER_ID_RESULT = "INSERT 0 1" ]]; then
                echo "Inserted into teams, $WINNER"
            fi

            # get new winner_id
            WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'")

        fi

        # get opponent_id
        OPPONENT_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT'")

        # if opponent_id not found
        if [[ -z $OPPONENT_ID ]]; then
            # insert team_id
            INSERT_OPPONENT_ID_RESULT=$($PSQL "INSERT INTO teams(name) VALUES('$OPPONENT')")
            if [[ $INSERT_OPPONENT_ID_RESULT = "INSERT 0 1" ]]; then
                echo "Inserted into teams, $OPPONENT"
            fi

            # get new opponent_id
            OPPONENT_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT'")

        fi

        # insert into games table
        INSERT_GAMES_RESULT=$($PSQL "INSERT INTO games(year, round, winner_id, opponent_id, winner_goals, opponent_goals) VALUES($YEAR, '$ROUND', $WINNER_ID, $OPPONENT_ID, $WINNER_GOALS, $OPPONENT_GOALS)")
        if [[ $INSERT_GAMES_RESULT == "INSERT 0 1" ]]; then
            echo Inserted into games, $YEAR $ROUND $WINNER_ID $OPPONENT_ID $WINNER_GOALS $OPPONENT_GOALS
        fi
    fi
done

# Display summary
TOTAL_TEAMS=$($PSQL "SELECT COUNT(*) FROM teams")
TOTAL_GAMES=$($PSQL "SELECT COUNT(*) FROM games")

# Print summary to the terminal
echo -e "\nSummary:"
echo "Total teams inserted: $TOTAL_TEAMS"
echo "Total games inserted: $TOTAL_GAMES"
