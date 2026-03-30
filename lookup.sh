#!/bin/sh

WORDS_FILE="words.txt"

if [ ! -f "$WORDS_FILE" ]; then
    echo "Error: $WORDS_FILE not found" >&2
    exit 1
fi

ALL=""
ANY=""
EXACT=""
LENGTH=""
STARTS=""
ENDS=""
COUNT=""
RANDOM=""
EXISTS=""

while [ $# -gt 0 ]; do
    case $1 in
        --all) ALL="$2"; shift 2 ;;
        --any) ANY="$2"; shift 2 ;;
        --exact) EXACT="1"; shift ;;
        --length) LENGTH="$2"; shift 2 ;;
        --starts) STARTS="$2"; shift 2 ;;
        --ends) ENDS="$2"; shift 2 ;;
        --count) COUNT="1"; shift ;;
        --random) RANDOM="1"; shift ;;
        --exists) EXISTS="$2"; shift 2 ;;
        *) echo "Unknown option: $1"; exit 1 ;;
    esac
done

if [ -n "$EXISTS" ]; then
    if grep -Fxq "$EXISTS" "$WORDS_FILE"; then
        echo "yes"
    else
        echo "no"
    fi
    exit 0
fi

RESULT=$(cat "$WORDS_FILE")

if [ -n "$EXACT" ]; then
    RESULT=$(echo "$RESULT" | grep -Fx "$RESULT")
fi

if [ -n "$ALL" ]; then
    PATTERN=$(echo "$ALL" | sed 's/./&/g')
    for CHAR in $(echo "$ALL" | fold -w1); do
        RESULT=$(echo "$RESULT" | grep "$CHAR")
    done
fi

if [ -n "$ANY" ]; then
    PATTERN=$(echo "$ANY" | sed 's/./[&]/g' | sed 's/\[\(.\)\]/\1/g')
    RESULT=$(echo "$RESULT" | grep "[$ANY]")
fi

if [ -n "$STARTS" ]; then
    RESULT=$(echo "$RESULT" | grep "^$STARTS")
fi

if [ -n "$ENDS" ]; then
    RESULT=$(echo "$RESULT" | grep "$ENDS\$")
fi

if [ -n "$LENGTH" ]; then
    RESULT=$(echo "$RESULT" | awk "length == $LENGTH")
fi

if [ -n "$RANDOM" ]; then
    if [ -z "$RESULT" ]; then
        exit 0
    fi
    RESULT=$(echo "$RESULT" | shuf -n 1)
fi

if [ -n "$COUNT" ]; then
    echo "$RESULT" | grep -c '^'
else
    echo "$RESULT"
fi
