#!/bin/bash

while true
do
    echo
    bundle exec dotenv ./bot.rb
    secs=$(( 3600 + (RANDOM % 64) ))
    printf 'Sleeping for %d seconds\n' $secs
    sleep $secs
done
