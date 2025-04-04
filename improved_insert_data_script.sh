PSQL="psql -X --username=postgres --dbname=worldcup --no-align --tuples-only -c"
LOG_FILE="insert_log.txt"
# Clear the log file at the start of the script
>$LOG_FILE

# Clear tables
echo "TRUNCATING TABLES..." >>$LOG_FILE
$PSQL "TRUNCATE TABLE games, teams RESTART IDENTITY CASCADE;" >>$LOG_FILE

# Process games.csv
while IFS=, read -r YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS; do
  [[ $YEAR == "year" ]] && continue # Skip header
  echo -n "." >&2                   # Progress dot

  # Clean data
  ROUND=$(echo "$ROUND" | tr -d '"')
  WINNER=$(echo "$WINNER" | tr -d '"')
  OPPONENT=$(echo "$OPPONENT" | tr -d '"')

  # Get/insert winner_id
  WINNER_ID=$($PSQL "WITH inserted AS (
        INSERT INTO teams(name) VALUES('$WINNER') 
        ON CONFLICT(name) DO NOTHING 
        RETURNING team_id
      )
      SELECT team_id FROM inserted
      UNION
      SELECT team_id FROM teams WHERE name='$WINNER';")

  # Get/insert opponent_id
  OPPONENT_ID=$($PSQL "WITH inserted AS (
        INSERT INTO teams(name) VALUES('$OPPONENT') 
        ON CONFLICT(name) DO NOTHING 
        RETURNING team_id
      )
      SELECT team_id FROM inserted
      UNION
      SELECT team_id FROM teams WHERE name='$OPPONENT';")

  # Insert game
  $PSQL "INSERT INTO games(year, round, winner_id, opponent_id, winner_goals, opponent_goals)
           VALUES($YEAR, '$ROUND', $WINNER_ID, $OPPONENT_ID, $WINNER_GOALS, $OPPONENT_GOALS);" >>$LOG_FILE

  echo "Inserted: $YEAR, $ROUND, $WINNER ($WINNER_ID) vs $OPPONENT ($OPPONENT_ID)" >>$LOG_FILE
  # echo "Added: $YEAR $ROUND - $WINNER $WINNER_GOALS-$OPPONENT_GOALS $OPPONENT" >>$LOG_FILE

done <games.csv

echo # Newline after dots

# Summary
TOTAL_TEAMS=$($PSQL "SELECT COUNT(*) FROM teams;")
TOTAL_GAMES=$($PSQL "SELECT COUNT(*) FROM games;")
echo -e "\nSummary:\nTeams: $TOTAL_TEAMS\nGames: $TOTAL_GAMES" | tee -a $LOG_FILE
