#!/bin/bash
#
# this script takes in a japanese word as input and uses the jisho.org api to parse it into a csv file readable by anki
# note that the parse cards are parsed into a format which matches syntax that I have personally created for myself for anki cards
# if you don't like the parsed format or cant figure it out you should change this script
#
# script is dependent on jq to parse data

inputword="$1"
wordjson=$(curl -XGET http://jisho.org/api/v1/search/words?keyword="${1}")

#echo ${wordjson}

#TODO add:
#	   "Godan verb - aru special class",
#	   "Nidan verb (lower class) with dzu ending (archaic)","Ichidan verb - zuru verb (alternative form of -jiru verbs)"
#	   something about kuru and suru as well
#I may need to account for the other godan verbs as well?
declare -A ling_func_map=(
	["Godan verb with ru ending"]="五段"
	["Godan verb with u ending"]="五段"
        ["Godan verb with su ending"]="五段"
        ["Godan verb with mu ending"]="五段"
        ["Godan verb with gu ending"]="五段"
        ["Godan verb with ku ending"]="五段"
        ["Godan verb with bu ending"]="五段"
        ["Godan verb with nu ending"]="五段"
        ["Godan verb with tsu ending"]="五段"
	["Ichidan verb"]="一段"
	["Transitive verb"]="他動詞"
	["intransitive verb"]="自動詞"
	["Noun"]="名詞"
	["Adverbial noun"]="名詞"
	["Temporal noun"]="名詞"
	["Suru verb"]="する" 
	["I-adjective"]="形容詞"
	["Na-adjective"]="形容動詞"
	["No-adjective"]="の形容動詞"
	["Adverb"]="副詞"
	["Adverb taking the 'to' particle"]="と副詞"
	["Suffix"]="接尾辞"
	["Expression"]="表現"
)


#loop through the parts of speech and put them in the linguistic_function
i=0
#pos = part of speech
current_pos=$(echo "${wordjson}" | jq -r .data[0].senses[0].parts_of_speech["${i}"])
#if current_pos = "null" then that means that we've reached the end of the parts_of_speech array
while [[ "null" != "${current_pos}" ]]; do
    #if this is the first time throught the loop then ${Linguistic_function} is empty
    if [[ -z  "${Linguistic_function}" ]]; then
	Linguistic_function=${ling_func_map["${current_pos}"]}
    else
	Linguistic_function="${Linguistic_function},${ling_func_map["${current_pos}"]}"
    fi
    i=$(($i+1))
    current_pos=$(echo ${wordjson} | jq -r .data[0].senses[0].parts_of_speech[${i}])
done


#for back we need to loop through .data[0].senses and then loop throught senses[i].english_definitions[j]
#and get the .data[0].senses[i].english_definitions[] array
#TODO move linguistic function to be calculated here maybe
i=0
current_sense=$(echo "${wordjson}" | jq -r .data[0].senses["${i}"])
Back=""
while [[ "null" != "${current_sense}" ]]; do
    #echo "${current_sense}"
    j=0

    current_definition=$(echo "${current_sense}" | jq -r .english_definitions["${j}"])
    while [[ "null" != "${current_definition}" ]]; do
    	#echo "${current_definition}"
    	if [[ "0" == "${j}" ]]; then
	    #if this is the case then this is the start of a new definition and thus back currently ends in a "; "
	    Back="${Back}${current_definition}"
	else
	    Back="${Back}, ${current_definition}"
	fi
	j=$(($j+1))
    	current_definition=$(echo "${current_sense}" | jq -r .english_definitions["${j}"])
    done

    #there may be more than 1 piece of info (I have yet to find a definition that does though) but for now we only take the first piece of info TODO
    current_info=$(echo "${wordjson}" | jq -r .data[0].senses["${i}"].info[0])
    if [[ "null" != "${current_info}" ]]; then
	Back="${Back} (${current_info})"
    fi

    Back="${Back}; "
    j=0

    current_pos=$(echo "${current_sense}" | jq -r .parts_of_speech["${j}"])
    while [[ "null" != "${current_pos}" ]]; do
        #for debugging purposes...
        #echo "pos"
        #echo "The current pos is:   ${current_pos}"
        #echo "pos"
        #we define 2 ling func vars since sometimes cards have pos which apply to every sense of the word, and sometimes we need to distinguish the senses with their unique pos
        if [[ "0" ==  "${j}" ]]; then
            ling_func="${ling_func}${ling_func_map["${current_pos}"]}"
        else
            ling_func="${ling_func},${ling_func_map["${current_pos}"]}"
        fi
	#if i != 0 then that means that this word has different senses with different pos, therefore we must use this version for the card instead of the Linguistic_function we defined earlier
	if [[ "0" != "${i}" ]]; then
	    multiple_pos=true
	fi
        j=$(($j+1))
        current_pos=$(echo ${current_sense} | jq -r .parts_of_speech[${j}])
    done
    ling_func="${ling_func}; "

    i=$(($i+1))
    current_sense=$(echo "${wordjson}" | jq -r .data[0].senses["${i}"])
done

if [[ "true" == "${multiple_pos}" ]]; then
    Linguistic_function="${ling_func}"
fi

#Front="${inputword}"
Front=$(echo ${wordjson} | jq -r '.data[0].japanese[0].word')
#Back=""
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
