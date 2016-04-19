#!/bin/bash

port=13010
watch=""
SECONDS=0
quit=0

if [ "$WATCH" == "true" ]; then
  watch="--watch";
fi

MONGO_URL=mongodb://localhost:13001/${port} meteor --settings settings.json --port ${port}
CUCUMBER_TAIL=1 chimp $watch --ddp=http://localhost:13010 \
                  --watch \
                  --path=tests/ \
                  --coffee=true \
                  --compiler=coffee:coffee-script/register \
                  --chai=true \
                  --sync=false
kill `lsof -t -i:${port}`

echo "$(($SECONDS / 60)) minutes and $(($SECONDS % 60)) seconds elapsed"
