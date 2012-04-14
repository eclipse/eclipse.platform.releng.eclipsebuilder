#!/usr/bin/env bash

# since I always forget, some of my favorite "date formats"

# timestamps, year, month, day, hour, minute 
# (sorts well, since "least changed" is towards the left). 
timestamp=$( date +%Y%m%d%H%M )

echo $timestamp

#some like hyphens before time
timestamp=$( date +%Y%m%d-%H%M )

echo $timestamp
