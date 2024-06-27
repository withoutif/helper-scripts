#!/bin/bash

##################### HANGMANIMAL #######################
# The hangman game that lets you guess animal names	#
#	Animals and Computers. The 2 best things!	#
#	(Brought to you by free time and autism)	#
#########################################################

IFS=','
wd=""
mask=""
wrng_cnt=0
declare -ga gsd_ltrs
declare -gA arr_ltrs

#for quick debugging global vars when making changes
debug () {
echo "debug#################################"
echo "word: $wd"
echo "wrong count: $wrng_cnt"
echo "mask: $mask"
echo "guessed letters: ${gsd_ltrs[@]}"
echo "array letter keys: ${arr_ltrs[@]}"
echo "array letter values: ${!arr_ltrs[@]}"
echo "end debug##########################"
}

#get random word
one_player () {

wd=$(get_word)

echo "The robot has selected an animal:"

setup_game

}

#read word from user
two_player () {
echo -e "\t Okay, make your friends look away and enter the name of an animal."
echo -e "\t Spaces are allowed, but don't be a dick. And spell it right!"
echo -e "\t ...and I guess technically it doesn't have to be an animal"
echo -e "\t ...like it'll still work if it's a food or something"
read -s usr_wd

wd=$usr_wd

setup_game

}

#create display mask, show hangman, call guess func
setup_game () {

mask=$(echo $wd | sed -e 's/[a-zA-Z]/_/g') 
build_guess_list

echo -e "\t $mask"
#get character count without spaces
count=$( echo -n $wd | tr -s [:space:] | wc -c)
echo "There are $count letters in the word"
make_guess

}

#return animal name
get_word () {

#I first made this as a general purpose hangman
#if you want to restore the random category you
#can uncomment the below code:
#
#what_wd="noun"
#wd_type=$(( RANDOM % 3 ))
#
#case $wd_type in
#0) what_wd="animal" ;;
#1) what_wd="adjective" ;;
#*) what_wd="noun" ;;
#esac
#
#echo $(curl -s https://random-word-form.herokuapp.com/random/$what_wd | jq -r .[])

echo $(curl -s https://random-word-form.herokuapp.com/random/animal | jq -r .[])

}

#hash letters and letter placement for guesses
build_guess_list () {

declare -n _arr_ltrs=arr_ltrs

#parse the letters into comma delimited string
#random-word api returns two word phrases, so we can't delimit on space
_ltrs=$(echo $wd | grep -o . | tr $'\n' ',' )


#read the string into an array
read -rd '' -a _wd <<<"$_ltrs"

for i in ${!_wd[@]}; do
	k="${_wd[$i]}"
	_arr_ltrs[$k]+="${_arr_ltrs[$k]:+,}$i"
done
}

#return correct state ascii man
print_man () {

state=$1

# Do me a favor? Make a better ASCII guy. I'm not great at this.
case $state in
0) echo "!*!*!*!*!*!* Nothing hanged yet *!*!*!*!*!*!" ;;
1) echo -e "\n\t_________________
			|
			|
			|
			|
			|
			|
			|
			|
			|" ;;
2) echo -e "\n\t_________________
		 |	|
		 ^	|
		 O	|
			|
			|
			|
			|
			|
			|" ;;
3) echo -e "\n\t_________________
		 |	|
		 ^	|
	  	 O	|
		( )	|
			|
			|
			|
			|
			|" ;;
4) echo -e "\n\t_________________
		 |	|
		 ^	|
		 O	|
		( )\	|
			|
			|
			|
			|
			|" ;;
5) echo -e "\n\t_________________
		  |	|
		  ^	|
		  O	|
		/( )\	|
			|
			|
			|
			|
			|" ;;
6) echo -e "\n\t_________________
		  |	|
		  ^	|
		  O	|
		/( )\	|
		 |	|
			|
			|
			|
			|
			|" ;;
7) echo -e "\n\t_________________
		  |	|
		  ^	|
		  O	|
		/( )\	|
		 | |	|
			|
			|
			|
			|
			|" ;;
*) echo -e "\t How did you get this many guesses? The man is dead. Show some respect" ;;
esac

}

# Correct guess reveals letter in mask
# Incorrect guess increments wrong guess counter to update hangman state
# Duplicate prompts for new guess and incurs no penalty
# Multiple letters for single guess mocks user and prompts for new guess
# Win prompts for restart
# Lose induces existential crisis
make_guess () {


if [[ $wrng_cnt -eq 7 ]]; then
	echo -e "\t The word was \"$wd\""
	echo -e "\t You've killed him.You've killed an innocent man. Who will tell his family?"
	read -p $"Enter Y to play again. Enter N to tell his family: " rsp
	case $rsp in
		[yY]) start_game ;;
		[nN]) echo -e "\t ...dude"
		      exit  ;;
		*) exit ;;
	esac
fi

declare -n _gsd_ltrs=gsd_ltrs

read -p "Guess your letter: " ltr
ln=$(echo -n $ltr | wc -c)


if [ $ln -ne 1 ]; then
	echo -e "\t One letter at a time. Do you not know the rules?"
	echo -e "\t ...everyone knows them"
	make_guess
	return
fi

if [[ ${gsd_ltrs[*]} =~ $ltr ]]; then
	echo -e "\t You've already guessed $ltr. Focus. A man's life hangs in the balance."
	make_guess
elif [[ ${!arr_ltrs[*]} =~ $ltr ]]; then
	i_set="${arr_ltrs[$ltr]}"
	for i in $i_set; do
		#add letter to mask at index (sed uses 1 based index)
		mask=$( echo $mask | sed s/./$ltr/$(($i+1)))
	done
else
	echo -e  "\t $ltr? You fool. You're comdemning an innocent man."
	wrng_cnt=$(( $wrng_cnt+1 ))
fi

#if theres already data, append a comma. This'll show up as a space
#when we display the whole array because of the IFS setting
_gsd_ltrs+="${_gsd_ltrs[0]:+,}$ltr"

if [[ $mask != *"_"* ]]; then
	echo -e "\t\"$mask\" is the correct word!"
	echo -e "\t You've saved him. He's probably maimed, but you've saved him."
	read -p "Want to play again? (y/n) " rsp

	case $rsp in
		[yY]) start_game ;;
	*) exit ;;
	esac

fi

echo $mask
echo $( print_man $wrng_cnt )
echo -e "\t Guessed letters: "
echo -e "\t ${gsd_ltrs[@]}"
#Create a divider before next guess
echo "***********************************************"

make_guess

}

start_game () {
wd=""
mask=""
wrng_cnt=0
gsd_ltrs=()
declare -A arr_ltrs=()

echo -e "\t Welcome to Hangmanimal!"
echo -e "\t An animal-name version of the macabre game beloved by school children"
echo -e "\t 1) Have the computer generate a word (1 player)"
echo -e "\t 2) Enter my own word for others to guess (multi player) "

read -p "How many players are there? " players

case $players in
1) one_player ;;
*) two_player ;;
esac
}

start_game
