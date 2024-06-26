#/bin/bash

# go to repo folder, with autocomplete
function repos () {
 cd ~/Documents/repos/"$1";
}
#list all repo names for compgen customization
_active_repos() {
 ls ~/Documents/repos/
}
#
_complete_repo() {
    COMPREPLY=()
    local word="${COMP_WORDS[COMP_CWORD]}"
    COMPREPLY=( $( compgen -W "$(_active_repos)" -- "$word" ) );
    return 0
}

complete -F _complete_repo repos

# Generate rds auth token by db or host
# Fill out your user profile and generate dev, QA, or (hopefully not) prod tokens on the fly
function psa() {
  host= <db host>
  database=postgres

  local OPTIND svr
  while getopts ":h:d" option; do
     case $option in
       h) host=$OPTARG;;
       d) database=$OPTARG;;
       *) echo "Please provide a valid option"; return 1 ;;
     esac
  done

  aws_profile=<profile>
  user=<user>
  port=<port>
  region=<region>

  export RDSHOST="$host"
  echo "$(aws rds generate-db-auth-token --hostname $RDSHOST --port $port --region $region  --username $user --profile $aws_profile)"
}

# Start a multi-service  project that needs auth. This requires wait-on to be installed and imported.
# This is really just a starting point, since you don't need the key sync function I needed,
# but add your own security requirements. Really have fun with it! Auth!
function start-serial-project () {
     OUTPUT_FILE=<path to output file that indicates thing is compiled>
     #delete the output file so waiton won’t start until after first proj compilation
     rm -rf $OUTPUT_FILE;

     # if there's a "Key" flag, do auth tasks
    local OPTIND svr
     while getopts ":k" option; do
        case $option in
          k) <call your own auth_func> ;;
          *) echo "Robocop is riding a unicorn. Your $OPTARG is invalid."; return 1 ;;
        esac
     done

     <call first project start>
     wait-on file:$OUTPUT_FILE && <call second step>;
     <continue for all steps and waits>
     return 0;
   }



