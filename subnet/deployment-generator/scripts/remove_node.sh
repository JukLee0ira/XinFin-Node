#!/bin/bash

read -p "input SUBNET_ID: " SUBNET_ID

# validate input
if [[ ! "$SUBNET_ID" =~ ^[0-9]+$ ]]; then
	echo "invalid SUBNET_ID, please input a number."
    exit 1
fi

FILE="../docker-compose.yml"

# check if file exists
if [ ! -f "$FILE" ]; then
	echo "file $FILE does not exist!"
    exit 1
fi

# delete specified subnet configuration block
sed -i "/^  subnet$SUBNET_ID:/,/^        ipv4_address[^ ]/ {
    d
}" "$FILE"

# output modified docker-compose.yml content
# cat "$FILE"

# delete specified .env file
ENV_FILE="../subnet$SUBNET_ID.env"
if [ -f "$ENV_FILE" ]; then
    rm "$ENV_FILE"
	# echo "file $ENV_FILE has been deleted!"
# else
	# echo "file $ENV_FILE does not exist!"
fi

echo "subnet$SUBNET_ID configuration has been removed"