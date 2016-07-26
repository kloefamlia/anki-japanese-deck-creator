#!/bin/bash
#
# this script takes in a japanese word as input and uses the jisho.org api to parse it into a csv file readable by anki
# note that the parse cards are parsed into a format which matches syntax that I have personally created for myself for anki cards
# if you don't like the parsed format or cant figure it out you should change this script
#
# script is dependent on jq to parse data

#i have realized that trying to deal with json using bash was a terrible idea so i guess I'll have to learn python :\

inputword="$1"
wordjson=$(curl -XGET http://jisho.org/api/v1/search/words?keyword="${1}")

#we define an associative array which maps the jisho.org parts_of_speech (i.e. intransative vs transative verb, adjective etc.) to the corresponding japanese words
declare -A ling_func_map=([])

Front="${inputword}"
Back=""
Example=""
Reading=$(echo ${wordjson} | jq '.data[0].japanese[0].reading')
parts_of_speech=$(echo ${wordjson} | jq '.data[0].senses[0].parts_of_speech')
#Linguistic_function="$(echo ${wordjson} | jq '.data[0].senses[0].parts_of_speech'),$(echo ${wordjson} | jq '.data[0].japanese[0].reading')"

for i in ${parts_of_speech}; do
   echo ${i}
done

echo ""
echo "the variables are..."
echo ${Front}
echo ${Back}
echo ${Example}
echo ${Reading}
echo ${Linguistic_function}
echo ${parts_of_speech}
