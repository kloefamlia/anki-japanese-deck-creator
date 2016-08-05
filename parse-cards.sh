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
declare -A ling_func_map=( 
	["Godan verb with ru ending"]="五段"
	["Ichidan verb"]="一段"
	["Transitive verb"]="他動詞"
	["intransitive verb"]="自動詞"
	["Noun"]="名詞"
	["Suru verb"]="する" 
	["I-adjective"]="形容詞"
	["Na-adjective"]="形容動詞"
	["No-adjective"]="の形容動詞"
	["Adverb"]="副詞"
	["Adverb taking the 'to' particle"]="と副詞"
)

#loop through the parts of speech and put them in the linguistic_function
i=0
#pos = part of speech
current_pos=$(echo ${wordjson} | jq -r .data[0].senses[0].parts_of_speech[${i}])
#if current_pos = "null" then that means that we've reached the end of the parts_of_speech array
while [[ "null" != "${current_pos}" ]]; do
    #for debugging purposes...
    echo "pos"
    echo "${current_pos}"
    echo "pos"
    #if this is the first time throught the loop then ${Linguistic_function} is empty
    if [[ -z  "${Linguistic_function}" ]]; then
	Linguistic_function="${ling_func_map["${current_pos}"]}"
    else
	Linguistic_function="${Linguistic_function},${ling_func_map["${current_pos}"]}"
    fi
    i=$(($i+1))
    current_pos=$(echo ${wordjson} | jq -r .data[0].senses[0].parts_of_speech[${i}])
done

#for back we need to loop through .data[0].senses
#and get the .data[0].senses[i].english_definitions[] array

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
