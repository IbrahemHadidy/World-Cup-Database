#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.
# Modify the insert_team function to handle the case when team_id is empty
insert_team() {
    local team_name="$1"
    local team_id
    # Check if the team already exists
    team_id="$($PSQL "SELECT team_id FROM teams WHERE name = '$team_name';" | tail -3 | head -1)"
    if [[ -z "$team_id" ]]; then
        # Insert the team if it doesn't exist
        team_id="$($PSQL "INSERT INTO teams (name) VALUES ('$team_name') RETURNING team_id;" | tail -3 | head -1)"
    fi
    echo "$team_id"
}

# Read each line of the games.csv file, skipping the first line
tail -n +2 games.csv | while IFS=, read -r year round winner opponent winner_goals opponent_goals; do
    # Insert winner and opponent teams and get their IDs
    winner_id=$(insert_team "$winner")
    opponent_id=$(insert_team "$opponent")
    # Insert game data into games table
    $PSQL "INSERT INTO games (year, round, winner_id, opponent_id, winner_goals, opponent_goals) 
           VALUES ('$year', '$round', $winner_id, $opponent_id, $winner_goals, $opponent_goals);" > /dev/null
    echo "Inserted game: $year, $round, $winner vs $opponent"
done

