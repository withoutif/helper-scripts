# Note - some of these aliases call each other, so make sure you double check if a
# command you want to use relies on another one. Some of these are outdated as git
# has since added similar functionality by default

	
co = checkout
# get branch name
brn = symbolic-ref --short HEAD
# ”status” has too many letters in it
sts = status
#commit with message
cm = "!sh -c 'git commit -m \"$1\"' -"
# if you use a JIRA ticket naming strategy (eg PROJ-12345-branch-name) to name your
# branches, this will automatically prepend the comment with the ticket
cmb = !"f () { branch=$(git brn | cut -d '-' -f-2); msg=$1; git commit -m \"${branch}: ${msg}\"; unset branch; unset msg;}; f"
# (new push) If you  need the first push to set upstream, just np and kick back
np = !"f () { branch=$(git brn); git push --set-upstream origin ${branch}; unset branch; }; f"
# create and checkout new branch
new = !sh -c 'git co -b $1 ' $1
# add/commit all. Use at your own peril
cma = !sh -c 'git add . && git cm "$1" ' $1
# overwrite the file with the version at master. Again, peril.
mfile = !sh -c 'git checkout origin/main -- "$1" ' $1
# open the gui. This isn’t always configured by default.
# to find the location of your git-gui use "whereis git-gui"
gui = !sh -c '/usr/share/git-gui'

