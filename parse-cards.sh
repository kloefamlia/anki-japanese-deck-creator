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

#TODO we define an associative array which maps the jisho.org parts_of_speech (i.e. intransative vs transative verb, adjective etc.) to the corresponding japanese words
#declare -A ling_func_map=([])

#loop through the parts of speech and put them in the linguistic_function
i=0
while [[ "null" != "$(echo ${wordjson} | jq -r .data[0].senses[0].parts_of_speech[${i}])" ]]; do
    #current part of speech
    current_pos=$(echo ${wordjson} | jq -r .data[0].senses[0].parts_of_speech[${i}])
    i=$(($i+1))
    #if this is the first time throught the loop then ${Linguistic_function} is empty
    if [[ -z  "${Linguistic_function}" ]]; then
	Linguistic_function="${current_pos}"
    else
	Linguistic_function="${Linguistic_function},${current_pos}"
    fi
done

Front="${inputword}"
Back=""
Example=""
Reading=$(echo ${wordjson} | jq -r '.data[0].japanese[0].reading')
#Linguistic_function="$(echo ${wordjson} | jq '.data[0].senses[0].parts_of_speech'),$(echo ${wordjson} | jq '.data[0].japanese[0].reading')"


echo ""
echo "the variables are..."
echo ${Front}
echo ${Back}
echo ${Example}
echo ${Reading}
echo ${Linguistic_function}
