#!/bin/bash

# Using gum and httpie, a script to fetch Advent of Code input data.
# An env var AOC_SESSION is checked for, else gum prompts for it.
# The year is assumed to this year, and the day is the first argument.
# The input is saved to solutions/dayXX/input.txt.

SESSION_FILE="./aoc_session"

# Function to prompt for session token and update the session file
prompt_for_session() {
    AOC_SESSION=$(gum input --placeholder "Enter your Advent of Code session token")
    http --session=$SESSION_FILE "https://adventofcode.com" Cookie:session=$AOC_SESSION > /dev/null
}

check_for_bin() {
    if ! command -v $1 &> /dev/null; then
        echo "Command $1 not found. Please install it."
        exit 1
    fi
}

check_for_bin http
check_for_bin jq
check_for_bin gum

# Check if the session file exists
if [ ! -f "$SESSION_FILE" ]; then
echo "Session file does not exist: $SESSION_FILE"
  # If the session file does not exist, prompt for session token and create the session file
  prompt_for_session
else
  # If the session file exists, check if the cookie value is blank
  COOKIE_VALUE=$(jq -r '.cookies[0].value' $SESSION_FILE)
  if [ -z "$COOKIE_VALUE" ]; then
    prompt_for_session
  fi
fi

# Get the current year
YEAR=$(date +%Y)

# Get the day from the first argument
DAY=$1

# Ensure the day is provided
if [ -z "$DAY" ]; then
  echo "Usage: $0 <day>"
  exit 1
fi

# Fetch the input data using httpie
RESPONSE=$(http --session=$SESSION_FILE --check-status --ignore-stdin "https://adventofcode.com/$YEAR/day/$DAY/input")

# Check if the request was successful
if [ $? -ne 0 ]; then
  gum format "## Failed to fetch input data. Please check your session token and day."
  exit 1
fi

# Save the input data to the appropriate file
mkdir -p solutions/day$DAY
echo "$RESPONSE" > solutions/day$DAY/input.txt

# Notify the user of success
gum format "Input data for day $DAY saved to \`solutions/day$DAY/input.txt\`"
