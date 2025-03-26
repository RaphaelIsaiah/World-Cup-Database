-- First connect to the psql terminal

-- For FCC
psql --username=freecodecamp --dbname=postgres 

-- For Local machine
psql -U postgres

CREATE DATABASE worldcup;
\c worldcup

CREATE TABLE teams();
CREATE TABLE games();

ALTER TABLE teams ADD COLUMN team_id SERIAL PRIMARY KEY NOT NULL;
ALTER TABLE teams ADD COLUMN name VARCHAR(255) UNIQUE NOT NULL;

ALTER TABLE games ADD COLUMN game_id SERIAL PRIMARY KEY NOT NULL;
ALTER TABLE games ADD COLUMN year INT NOT NULL;
ALTER TABLE games ADD COLUMN round VARCHAR(255) NOT NULL;

ALTER TABLE games ADD COLUMN winner_id INT NOT NULL;
ALTER TABLE games ADD COLUMN opponent_id INT NOT NULL;

ALTER TABLE games ADD FOREIGN KEY(winner_id) REFERENCES teams(team_id);
ALTER TABLE games ADD FOREIGN KEY(opponent_id) REFERENCES teams(team_id);

ALTER TABLE games ADD COLUMN winner_goals INT NOT NULL;
ALTER TABLE games ADD COLUMN opponent_goals INT NOT NULL;


