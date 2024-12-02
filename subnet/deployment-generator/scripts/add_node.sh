#!/bin/bash

FILE="../docker-compose.yml"

# read the current maximum subnet ID (for incrementing)
MAX_SUBNET_ID=$(grep -oP 'subnet[0-9]+' "$FILE" | sed 's/subnet//' | sort -n | tail -n 1)

if [ -z "$MAX_SUBNET_ID" ]; then
    NEW_SUBNET_ID=1
else
    NEW_SUBNET_ID=$((MAX_SUBNET_ID + 1))
fi

# calculate the port numbers and ipv4 address
PORT_20303=$((20302 + NEW_SUBNET_ID))
PORT_8545=$((8544 + NEW_SUBNET_ID))
PORT_9555=$((9554 + NEW_SUBNET_ID))
IPV4_ADDRESS=$((10+4 + NEW_SUBNET_ID))

add_docker-compose() {

# new subnet configuration content
NEW_SUBNET="
  subnet$NEW_SUBNET_ID:
    image: xinfinorg/xdcsubnets:v0.3.1
    volumes:
      - ./xdcchain$NEW_SUBNET_ID:/work/xdcchain
      - \${SUBNET_CONFIG_PATH}/genesis.json:/work/genesis.json
    restart: always
    env_file:
      - \${SUBNET_CONFIG_PATH}/subnet$NEW_SUBNET_ID.env
    profiles:
      - machine1
    ports:
      - '$PORT_20303:$PORT_20303'
      - '$PORT_8545:$PORT_8545'
      - '$PORT_9555:$PORT_9555'
    networks:
      docker_net:
        ipv4_address: 192.168.25.$IPV4_ADDRESS
"


# find the "services:" line and insert the new subnet configuration
awk -v new_subnet="$NEW_SUBNET" '
  BEGIN {found_services=0}
  /services:/ {found_services=1; print ""; print "services:"; print new_subnet; next}
  {print}
' "$FILE" > temp_file && mv temp_file "$FILE"
# prompt message
echo "Added new subnet${NEW_SUBNET_ID} configuration to docker-compose.yml!"
# echo "$NEW_SUBNET"

}


# function to create a new env file and modify its content
create_new_env_file() {
  read -p "input private_key: " private_key
    local source_file="../subnet1.env"
    local new_file="../subnet${NEW_SUBNET_ID}.env"

    # check if the source file exists
    if [ ! -f "$source_file" ]; then
        echo "Source file $source_file does not exist!"
        exit 1
    fi

    # read the source file content and modify the specified entry
    cp "$source_file" "$new_file"

    # modify the specified entry
    sed -i "s/^INSTANCE_NAME=.*$/INSTANCE_NAME=${NEW_SUBNET_ID}/" "$new_file"
    sed -i "s/^PRIVATE_KEY=.*$/PRIVATE_KEY=${private_key}/" "$new_file"
    sed -i "s/^PORT=.*$/PORT=${PORT_20303}/" "$new_file"
    sed -i "s/^RPCPORT=.*$/RPCPORT=${PORT_8545}/" "$new_file"
    sed -i "s/^WSPORT=.*$/WSPORT=${PORT_9555}/" "$new_file"
    sed -i "s/^LOG_LEVEL=.*$/LOG_LEVEL=2/" "$new_file"

    echo "New subnet${NEW_SUBNET_ID}.env file created!"
    # echo "New env file created: $new_file"
    # cat "$new_file"


}



add_docker-compose
create_new_env_file 