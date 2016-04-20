#!/bin/bash

# Note: requires a running meteor instance


watch=""
quit=0


if [ "$WATCH" == "true" ]; then
  watch="--watch";
  SECONDS=0
fi


# Put the data back
function finish {
  echo "Restoring the stashed data..."
  mongo localhost:13001/meteor .scripts/database/drop.js
  mongorestore -h 127.0.0.1 --port 13001 -d meteor tests/dump/meteor
  rm -rf tests/dump/
}
trap finish EXIT
trap finish INT
trap finish SIGINT  # 2
trap finish SIGQUIT # 3
trap finish SIGKILL # 9
trap finish SIGTERM # 15
# Note: must be bound before starting the actual test


# Back up the current database
rm -rf tests/dump/
echo "Create a bson dump of our 'meteor' db..."
mongodump -h 127.0.0.1 --port 13001 -d meteor -o tests/dump/


# Run our tests
chimp $watch --ddp=http://localhost:13000 \
        --path=tests/ \
        --coffee=true \
        --compiler=coffee:coffee-script/register \
        --chai=true \
        --sync=false


# Output time elapsed
if [ "$WATCH" != "true" ]; then
  echo ''
  echo "$(($SECONDS / 60)) minutes and $(($SECONDS % 60)) seconds elapsed"
  echo ''
fi
