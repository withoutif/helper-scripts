# List all files with line number
alias lsn='ls -al | nl'
# Call kill_all_pid to list all pids for key and delete
alias killem='kill_all_pid'
# Sort ss output by descending IP
alias ordip='ss | sort -k5 -k6'
# Search history for keyword
alias ityped='history | grep'
# Call append function because I always accidentally overwrite files
alias apnd='append'
# Claim POWER (by sudoing into root)
alias pwr='sudo su -'
# View list of users in group
alias whosin='cat /etc/group | grep'
# Call get_flag_info to return info on specific flag
alias flag='get_flag_info'

#get first 2 lines of flag info
get_flag_info() {

man $1 | grep -A 2 -iE "^[[:blank:]]+\\-$2"

}

#to avoid accidental overwrites
append() {

echo "$1" >> $2
cat $2
}

#list all processes for a key and kill if yes
kill_all_pid() {

pids=$(ps -e | grep "$1") 
echo "$pids"

read -p  "Kill all? (y/n) " doDel

case $doDel in
'y') kill $(ps -e | grep $1 | awk '{print $1}');; 
*) return 0;;
esac
}

