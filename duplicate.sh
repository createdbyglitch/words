#!/bin/sh
sort words.txt | uniq -c | awk '$1>1 {print $2, $1}'
