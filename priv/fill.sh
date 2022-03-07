#!env bash
file="$1"
lines="$2"

head -n "$file" "$lines" | awk '{print "+ " $0;}'

