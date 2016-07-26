#!/bin/bash
#
# this script takes in a japanese word as input and uses the jisho.org api to parse it into a csv file readable by anki
# note that the parse cards are parsed into a format which matches syntax that I have personally created for myself for anki cards
# if you don't like the parsed format or cant figure it out you should change this script
#
# script is dependent on jq to parse data
inputword="$1"
wordjson=$(curl -XGET http://jisho.org/api/v1/search/words?keyword="${1}")


echo ${wordjson}

Front="${inputword}"
Back=""
Example=""
Reading=$(echo ${wordjson} | jq '.data[0].japanese[0].reading')
Linguistic_function=""

echo "the variables are..."
echo ${Front}
echo ${Back}
echo ${Example}
echo ${Reading}
echo ${Linguistic_function}
